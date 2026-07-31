import '../entities/editor_canvas.dart';

/// Selects a text box, showing its gold outline and handles. Passing
/// null clears the selection (Screen 4 — "Tap any text box once to
/// select it").
class SelectTextElement {
  const SelectTextElement();

  EditorCanvas call(EditorCanvas canvas, {required String? id}) {
    if (id == null) {
      return canvas.copyWith(clearSelection: true);
    }
    if (canvas.indexOf(id) == -1) {
      // Selecting something that no longer exists would leave the
      // toolbar pointing at nothing.
      return canvas;
    }
    return canvas.copyWith(selectedElementId: id);
  }
}
