import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_dialog.dart';

/// Asks the user for the words that go in a text box (Screen 4).
///
/// A dialog rather than editing straight on the canvas: it gives this
/// audience a large, unmistakable field with plainly labeled Add and
/// Cancel buttons, instead of a small caret on top of an image with no
/// obvious way to finish. The same dialog handles both adding and later
/// editing, so there is only one thing to learn.
///
/// Returns the entered text, or null if the user cancelled or left it
/// empty.
Future<String?> showTextInputDialog(
  BuildContext context, {
  String? initialValue,
  String? title,
  String? hintText,
  String? confirmLabel,
}) {
  final isEditing = initialValue != null && initialValue.isNotEmpty;
  final controller = TextEditingController(text: initialValue ?? '');

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      void submit() {
        final text = controller.text.trim();
        Navigator.of(dialogContext).pop(text.isEmpty ? null : text);
      }

      return AppDialog(
        title: title ?? (isEditing ? 'Edit your text' : 'Add your text'),
        confirmLabel: confirmLabel ?? (isEditing ? 'Save' : 'Add'),
        onConfirm: submit,
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => submit(),
          style: Theme.of(dialogContext).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText ?? 'For example: Dear Margaret',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(AppDimensions.spaceM),
          ),
        ),
      );
    },
  ).whenComplete(controller.dispose);
}
