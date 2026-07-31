import '../entities/editor_canvas.dart';

/// Removes a text box and clears the selection (Screen 4 — "Delete").
///
/// Nothing is confirmed here on purpose: per the spec, deleting text
/// shows a one-tap-undo snackbar rather than a confirmation dialog, so
/// the reversal lives in [RestoreTextElement].
class DeleteTextElement {
  const DeleteTextElement();

  EditorCanvas call(EditorCanvas canvas, {required String id}) {
    return canvas.copyWith(
      elements: [
        for (final element in canvas.elements)
          if (element.id != id) element,
      ],
      clearSelection: true,
    );
  }
}
