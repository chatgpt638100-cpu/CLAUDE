import '../entities/editor_canvas.dart';

/// Rotates a text box via its rotation handle (Screen 4).
///
/// [rotation] is absolute, in radians, clockwise about the box's centre.
class RotateTextElement {
  const RotateTextElement();

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    required double rotation,
  }) {
    return canvas.copyWith(
      elements: [
        for (final element in canvas.elements)
          if (element.id == id)
            element.copyWith(rotation: rotation)
          else
            element,
      ],
    );
  }
}
