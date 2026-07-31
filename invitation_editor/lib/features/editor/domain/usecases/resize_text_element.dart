import '../entities/editor_canvas.dart';

/// Resizes a text box from one of its corner handles (Screen 4).
///
/// [factor] is relative — 1.0 leaves the box untouched, 1.05 grows it by
/// five percent — which lets a drag feed in a stream of small changes.
/// Scaling happens about the box's centre, so a rotated box resizes
/// predictably instead of drifting across the page.
class ResizeTextElement {
  const ResizeTextElement();

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    required double factor,
  }) {
    return canvas.copyWith(
      elements: [
        for (final element in canvas.elements)
          if (element.id == id) element.scaledBy(factor) else element,
      ],
    );
  }
}
