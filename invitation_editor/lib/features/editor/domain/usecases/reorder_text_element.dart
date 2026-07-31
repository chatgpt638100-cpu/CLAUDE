import '../entities/editor_canvas.dart';

/// Which way to move a box through the stacking order.
enum TextElementLayer {
  /// Paint in front of everything else.
  front,

  /// Paint behind everything else.
  back,
}

/// Moves a text box through the stacking order (Screen 4 — "Bring to
/// Front", plus its counterpart "Send to Back").
///
/// Stacking order is just the element list order, so this is a move
/// within that list.
class ReorderTextElement {
  const ReorderTextElement();

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    required TextElementLayer layer,
  }) {
    final index = canvas.indexOf(id);
    if (index == -1) return canvas;

    // Already where it needs to be — avoid emitting a new state for a
    // tap that changes nothing.
    final lastIndex = canvas.elements.length - 1;
    if (layer == TextElementLayer.front && index == lastIndex) return canvas;
    if (layer == TextElementLayer.back && index == 0) return canvas;

    final remaining = [...canvas.elements];
    final element = remaining.removeAt(index);

    final reordered = switch (layer) {
      TextElementLayer.front => [...remaining, element],
      TextElementLayer.back => [element, ...remaining],
    };

    return canvas.copyWith(elements: reordered);
  }
}
