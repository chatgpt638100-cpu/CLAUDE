import '../entities/editor_canvas.dart';
import '../entities/text_element.dart';

/// Puts a deleted text box back exactly where it was, both on the page
/// and in the stacking order — the "Undo" half of the spec's
/// "Text deleted. Undo" snackbar.
class RestoreTextElement {
  const RestoreTextElement();

  EditorCanvas call(
    EditorCanvas canvas, {
    required TextElement element,
    required int index,
  }) {
    final elements = [...canvas.elements];
    // The list may have changed since the delete, so clamp rather than
    // trusting the old index blindly.
    // toInt() matters: num.clamp returns num, which will not assign to the
    // int that List.insert expects.
    final insertAt = index.clamp(0, elements.length).toInt();
    elements.insert(insertAt, element);

    return canvas.copyWith(
      elements: elements,
      selectedElementId: element.id,
    );
  }
}
