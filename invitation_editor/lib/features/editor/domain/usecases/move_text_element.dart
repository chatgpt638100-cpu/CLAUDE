import '../entities/editor_canvas.dart';

/// Drags a text box across the page (Screen 4 — "Drag/resize/rotate text
/// box as needed").
///
/// Deltas are page fractions, matching how [TextElement] stores its
/// geometry, so a drag behaves the same at any zoom level.
class MoveTextElement {
  const MoveTextElement();

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    required double deltaX,
    required double deltaY,
  }) {
    return canvas.copyWith(
      elements: [
        for (final element in canvas.elements)
          if (element.id == id)
            element.movedToCentre(
              element.centreX + deltaX,
              element.centreY + deltaY,
            )
          else
            element,
      ],
    );
  }
}
