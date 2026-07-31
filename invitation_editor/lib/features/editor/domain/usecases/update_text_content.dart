import '../entities/editor_canvas.dart';

/// Replaces the words in a text box, leaving its position, size and
/// rotation exactly as they were (Screen 4 — "Edit Text").
class UpdateTextContent {
  const UpdateTextContent();

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    required String content,
  }) {
    return canvas.copyWith(
      elements: [
        for (final element in canvas.elements)
          if (element.id == id)
            element.copyWith(content: content)
          else
            element,
      ],
    );
  }
}
