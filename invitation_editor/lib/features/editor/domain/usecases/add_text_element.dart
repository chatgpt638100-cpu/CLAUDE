import '../entities/editor_canvas.dart';
import '../entities/text_element.dart';

/// Adds a new text box centred on the point the user tapped, and selects
/// it so it is immediately ready to move or resize (Screen 4 — "Tap
/// anywhere to add text").
///
/// The new box goes on the end of the list, so it paints in front of
/// everything already on the canvas.
class AddTextElement {
  const AddTextElement();

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    required String content,
    required double centreX,
    required double centreY,
  }) {
    final element = TextElement.centredAt(
      id: id,
      content: content,
      centreX: centreX.clamp(0.0, 1.0).toDouble(),
      centreY: centreY.clamp(0.0, 1.0).toDouble(),
    );

    return canvas.copyWith(
      elements: [...canvas.elements, element],
      selectedElementId: element.id,
    );
  }
}
