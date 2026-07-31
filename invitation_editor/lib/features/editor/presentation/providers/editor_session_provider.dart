import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../injection/service_locator.dart';
import '../../../library/domain/entities/invitation_project.dart';
import '../../../library/domain/usecases/get_invitation.dart';
import '../../../library/domain/usecases/rename_invitation.dart';
import '../../../library/domain/usecases/save_invitation.dart';
import '../../domain/entities/invitation_source_file.dart';
import 'editor_canvas_provider.dart';

/// Which invitation the Editor currently has open, and everything to do
/// with persisting it.
///
/// Split from [editorCanvasProvider] on purpose: that one owns *what is on
/// the page*, this one owns *which document it belongs to and when it gets
/// written*. Keeping them apart means every text edit does not have to
/// know about storage, and auto-save does not have to know about text.
class EditorSessionNotifier extends AutoDisposeNotifier<EditorSessionState> {
  Timer? _debounce;

  /// Guards against two saves overlapping — auto-save firing while an
  /// explicit Save is still writing would race on the same record.
  bool _isWriting = false;

  @override
  EditorSessionState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const EditorSessionState.loading();
  }

  /// Opens an existing invitation by id, or starts a new one from a picked
  /// file (or nothing at all, for a blank card).
  Future<void> open({
    String? projectId,
    InvitationSourceFile? sourceFile,
  }) async {
    if (projectId != null) {
      final existing = await sl<GetInvitation>()(projectId);
      if (existing != null) {
        // Push the saved text onto the canvas before publishing the
        // project, so the first frame with a project already has its text.
        ref.read(editorCanvasProvider.notifier)
            .loadElements(existing.textElements);
        state = EditorSessionState.ready(existing);
        return;
      }
      // Falls through: the invitation has been deleted from under us, so
      // behave as if starting fresh rather than showing an error.
    }

    state = EditorSessionState.ready(
      InvitationProject.blank(
        id: sl<IdGenerator>().next('invitation'),
        now: DateTime.now(),
        sourceFile: sourceFile,
      ),
    );
  }

  /// Records the true page size once the preview has rendered, so exports
  /// and thumbnails can reproduce the page's proportions later.
  void setPageSize({required int widthPx, required int heightPx}) {
    final project = state.project;
    if (project == null) return;
    if (project.pageWidthPx == widthPx && project.pageHeightPx == heightPx) {
      return;
    }
    state = state.copyWith(
      project: project.copyWith(
        pageWidthPx: widthPx,
        pageHeightPx: heightPx,
      ),
    );
  }

  /// Queues a save a short while after the last edit.
  ///
  /// Debounced because a single drag emits a change on every frame; saving
  /// each one would hammer the disk and generate a thumbnail per pixel of
  /// movement. [captureThumbnail] is supplied by the widget layer, which is
  /// the only place that can see the rendered canvas.
  void scheduleAutoSave(Future<Uint8List?> Function() captureThumbnail) {
    _debounce?.cancel();
    _debounce = Timer(AppDimensions.autoSaveDebounce, () {
      save(captureThumbnail: captureThumbnail);
    });
  }

  /// Writes the invitation now, cancelling any queued auto-save.
  Future<void> save({
    Future<Uint8List?> Function()? captureThumbnail,
  }) async {
    _debounce?.cancel();

    final project = state.project;
    if (project == null || _isWriting) return;

    _isWriting = true;
    state = state.copyWith(isSaving: true);
    try {
      final thumbnail = await captureThumbnail?.call();

      final saved = await sl<SaveInvitation>()(
        project.copyWith(
          // Taken at write time rather than tracked incrementally, so the
          // stored text can never lag behind the canvas.
          textElements: ref.read(editorCanvasProvider).elements,
        ),
        thumbnailBytes: thumbnail,
      );

      state = EditorSessionState.ready(saved);
    } catch (_) {
      // Auto-save must stay silent on failure: interrupting someone
      // mid-edit with a storage error they cannot act on is worse than
      // retrying on the next pause. The explicit Save button reports
      // through its own result instead.
      state = state.copyWith(isSaving: false);
    } finally {
      _isWriting = false;
    }
  }

  Future<void> rename(String title) async {
    final project = state.project;
    if (project == null) return;

    // Renamed in place for an unsaved invitation; a record has to exist
    // before the rename use case has anything to update.
    state = state.copyWith(project: project.copyWith(title: title));
    try {
      await sl<RenameInvitation>()(project.id, title: title);
    } catch (_) {
      // The new name is already on screen and will be persisted by the
      // next save; nothing useful to tell the user here.
    }
  }
}

/// Immutable view of the Editor's document state.
class EditorSessionState {
  final InvitationProject? project;
  final bool isSaving;

  const EditorSessionState({required this.project, required this.isSaving});

  const EditorSessionState.loading() : project = null, isSaving = false;

  /// Takes a plain parameter rather than a typed initialising formal
  /// (`InvitationProject this.project`), which narrows a nullable field and
  /// is not portable across Dart versions.
  const EditorSessionState.ready(InvitationProject openProject)
      : project = openProject,
        isSaving = false;

  bool get isReady => project != null;

  EditorSessionState copyWith({InvitationProject? project, bool? isSaving}) {
    return EditorSessionState(
      project: project ?? this.project,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final editorSessionProvider =
    AutoDisposeNotifierProvider<EditorSessionNotifier, EditorSessionState>(
  EditorSessionNotifier.new,
);
