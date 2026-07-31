import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../voice_input/presentation/widgets/voice_input_button.dart';

/// Asks the user for the words that go in a text box (Screen 4).
///
/// A dialog rather than editing straight on the canvas: it gives this
/// audience a large, unmistakable field with plainly labeled buttons,
/// instead of a small caret on top of an image with no obvious way to
/// finish. The same dialog handles adding and editing, so there is only one
/// thing to learn.
///
/// The microphone sits inside it, which is where the spec puts it — "exactly
/// where text is created, not buried in a menu".
///
/// Returns the entered text, or null if cancelled or left empty.
Future<String?> showTextInputDialog(
  BuildContext context, {
  String? initialValue,
  String? title,
  String? hintText,
  String? confirmLabel,
  /// Voice typing is offered when composing invitation text, but not for
  /// naming things — dictating a file name is fiddlier than typing one.
  bool allowVoiceInput = true,
}) {
  final isEditing = initialValue != null && initialValue.isNotEmpty;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _TextInputDialog(
      initialValue: initialValue ?? '',
      title: title ?? (isEditing ? 'Edit your text' : 'Add your text'),
      hintText: hintText ?? 'For example: Dear Margaret',
      confirmLabel: confirmLabel ?? (isEditing ? 'Save' : 'Add'),
      allowVoiceInput: allowVoiceInput,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  final String initialValue;
  final String title;
  final String hintText;
  final String confirmLabel;
  final bool allowVoiceInput;

  const _TextInputDialog({
    required this.initialValue,
    required this.title,
    required this.hintText,
    required this.confirmLabel,
    required this.allowVoiceInput,
  });

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    Navigator.of(context).pop(text.isEmpty ? null : text);
  }

  void _applyTranscript(String merged) {
    setState(() {
      _controller.text = merged;
      // Caret to the end, so carrying on by keyboard continues the sentence
      // instead of typing into the middle of it.
      _controller.selection = TextSelection.collapsed(offset: merged.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: widget.title,
      confirmLabel: widget.confirmLabel,
      onConfirm: _submit,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(AppDimensions.spaceM),
              ),
            ),
            if (widget.allowVoiceInput) ...[
              const SizedBox(height: AppDimensions.spaceM),
              VoiceInputControl(
                currentText: _controller.text,
                onTranscript: _applyTranscript,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
