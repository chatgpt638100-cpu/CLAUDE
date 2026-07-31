import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/id_generator.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/editor_canvas.dart';
import '../../domain/entities/text_element.dart';
import '../../domain/usecases/add_text_element.dart';
import '../../domain/usecases/delete_text_element.dart';
import '../../domain/usecases/duplicate_text_element.dart';
import '../../domain/usecases/move_text_element.dart';
import '../../domain/usecases/reorder_text_element.dart';
import '../../domain/usecases/resize_text_element.dart';
import '../../domain/usecases/restore_text_element.dart';
import '../../domain/usecases/rotate_text_element.dart';
import '../../domain/usecases/select_text_element.dart';
import '../../domain/usecases/update_text_content.dart';

/// Holds the text boxes on the Editor canvas (Screen 4).
///
/// Every mutation goes through a domain use case — this notifier only
/// resolves them from GetIt, threads the current state in, and stores
/// what comes back. No editing rules live here, which keeps the
/// behaviour testable without a widget tree.
class EditorCanvasNotifier extends AutoDisposeNotifier<EditorCanvas> {
  /// Kept aside so the "Text deleted. Undo" snackbar can put a box back
  /// at the exact index it came from.
  TextElement? _lastDeletedElement;
  int _lastDeletedIndex = -1;

  @override
  EditorCanvas build() => const EditorCanvas.empty();

  void addTextAt({
    required String content,
    required double centreX,
    required double centreY,
  }) {
    state = sl<AddTextElement>()(
      state,
      id: sl<IdGenerator>().next('text'),
      content: content,
      centreX: centreX,
      centreY: centreY,
    );
  }

  void select(String? id) {
    state = sl<SelectTextElement>()(state, id: id);
  }

  void updateContent({required String id, required String content}) {
    state = sl<UpdateTextContent>()(state, id: id, content: content);
  }

  void move({
    required String id,
    required double deltaX,
    required double deltaY,
  }) {
    state = sl<MoveTextElement>()(
      state,
      id: id,
      deltaX: deltaX,
      deltaY: deltaY,
    );
  }

  void resize({required String id, required double factor}) {
    state = sl<ResizeTextElement>()(state, id: id, factor: factor);
  }

  void rotate({required String id, required double rotation}) {
    state = sl<RotateTextElement>()(state, id: id, rotation: rotation);
  }

  void bringToFront(String id) {
    state = sl<ReorderTextElement>()(
      state,
      id: id,
      layer: TextElementLayer.front,
    );
  }

  void sendToBack(String id) {
    state = sl<ReorderTextElement>()(
      state,
      id: id,
      layer: TextElementLayer.back,
    );
  }

  void duplicate(String id) {
    state = sl<DuplicateTextElement>()(
      state,
      id: id,
      newId: sl<IdGenerator>().next('text'),
    );
  }

  /// Deletes a box, remembering it so [undoDelete] can bring it back.
  void delete(String id) {
    final index = state.indexOf(id);
    if (index == -1) return;

    _lastDeletedElement = state.elements[index];
    _lastDeletedIndex = index;

    state = sl<DeleteTextElement>()(state, id: id);
  }

  /// Returns false when there is nothing to undo, so the caller can skip
  /// showing a snackbar action that would do nothing.
  bool undoDelete() {
    final element = _lastDeletedElement;
    if (element == null) return false;

    state = sl<RestoreTextElement>()(
      state,
      element: element,
      index: _lastDeletedIndex,
    );

    _lastDeletedElement = null;
    _lastDeletedIndex = -1;
    return true;
  }
}

/// Auto-disposed so each visit to the Editor starts from a clean canvas
/// rather than inheriting the previous invitation's text boxes.
final editorCanvasProvider =
    AutoDisposeNotifierProvider<EditorCanvasNotifier, EditorCanvas>(
  EditorCanvasNotifier.new,
);
