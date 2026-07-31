import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/pulsing_dot_loader.dart';
import '../../domain/entities/invitation_source_file.dart';
import '../providers/editor_canvas_provider.dart';
import '../providers/editor_session_provider.dart';
import '../thumbnail_capture.dart';
import '../widgets/canvas_view.dart';
import '../widgets/text_input_dialog.dart';

/// Screen 4 — The Editor.
///
/// Opens either a saved invitation (by id) or a new one built on a picked
/// file. Edits are auto-saved shortly after the user pauses, and again when
/// leaving the screen, so nothing is lost by simply pressing Back — the
/// "Save" button exists for reassurance rather than as the only way to keep
/// work.
///
/// Still to come: the bottom toolbar's Templates and Print/Export entries,
/// and voice typing.
class EditorScreen extends ConsumerStatefulWidget {
  /// Id of a saved invitation to reopen, if any.
  final String? projectId;

  /// A freshly picked file to start from, if any. Both null means a blank
  /// card.
  final InvitationSourceFile? sourceFile;

  const EditorScreen({super.key, this.projectId, this.sourceFile});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  /// Wraps the canvas so it can be rendered to a thumbnail.
  final GlobalKey _canvasBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Deferred by a frame: opening the invitation writes to a provider,
    // which cannot happen while the first build is still in progress.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(editorSessionProvider.notifier).open(
            projectId: widget.projectId,
            sourceFile: widget.sourceFile,
          );
    });
  }

  Future<void> _handleRename() async {
    final session = ref.read(editorSessionProvider);
    final project = session.project;
    if (project == null) return;

    final title = await showTextInputDialog(
      context,
      initialValue: project.title,
      title: 'Name this invitation',
      hintText: 'For example: Amara\'s Birthday',
      confirmLabel: 'Save',
    );
    if (title == null || !mounted) return;

    await ref.read(editorSessionProvider.notifier).rename(title);
  }

  Future<void> _handleSave() async {
    await ref.read(editorSessionProvider.notifier).save(
          captureThumbnail: _captureThumbnail,
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Invitation saved.')));
  }

  Future<Uint8List?> _captureThumbnail() =>
      const ThumbnailCapture().capture(_canvasBoundaryKey);

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(editorSessionProvider);
    final project = session.project;

    // Any change on the canvas queues an auto-save. Registered here rather
    // than inside the canvas so the debounce has a single owner.
    ref.listen(editorCanvasProvider, (previous, next) {
      if (previous == null || previous == next) return;
      ref
          .read(editorSessionProvider.notifier)
          .scheduleAutoSave(_captureThumbnail);
    });

    return PopScope(
      canPop: true,
      // Flush pending edits on the way out, so Back is as safe as Save.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref
              .read(editorSessionProvider.notifier)
              .save(captureThumbnail: _captureThumbnail);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.secondaryAccent,
            ),
            label: const Text(
              'Back',
              style: TextStyle(color: AppColors.secondaryAccent),
            ),
          ),
          leadingWidth: 100,
          title: InkWell(
            onTap: project == null ? null : _handleRename,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceS,
                vertical: 4,
              ),
              child: Text(
                project?.title ?? 'Editor',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.spaceS),
              child: TextButton.icon(
                onPressed: project == null || session.isSaving
                    ? null
                    : _handleSave,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: project == null
              ? const Center(
                  child: PulsingDotLoader(label: 'Opening your invitation…'),
                )
              : RepaintBoundary(
                  key: _canvasBoundaryKey,
                  child: project.sourceFile == null
                      ? const BlankCanvasView()
                      : CanvasView(sourceFile: project.sourceFile!),
                ),
        ),
      ),
    );
  }
}
