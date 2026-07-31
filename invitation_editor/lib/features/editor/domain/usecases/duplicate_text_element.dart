import '../entities/editor_canvas.dart';

/// Copies a text box (Screen 4 — "Duplicate").
///
/// The copy is nudged down and right so it is visibly a second box
/// rather than appearing to have done nothing, lands in front of the
/// original, and becomes the new selection.
class DuplicateTextElement {
  const DuplicateTextElement();

  /// Offset applied to the copy, as a fraction of the page.
  static const double copyOffset = 0.04;

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    required String newId,
  }) {
    final index = canvas.indexOf(id);
    if (index == -1) return canvas;

    final original = canvas.elements[index];
    final copy = original.copyWith(id: newId).movedToCentre(
          original.centreX + copyOffset,
          original.centreY + copyOffset,
        );

    return canvas.copyWith(
      elements: [...canvas.elements, copy],
      selectedElementId: copy.id,
    );
  }
}
