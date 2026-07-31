import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Simple centered dialog shell — used for things like the
/// "Save as Template" dialog (Screen 5) and delete confirmations.
/// No business logic here yet; just the reusable shell.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    this.content,
    this.confirmLabel = 'Save',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: content,
      actionsPadding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceL,
        0,
        AppDimensions.spaceL,
        AppDimensions.spaceL,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: cancelLabel,
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: isDestructive
                  ? SizedBox(
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: onConfirm,
                        child: Text(confirmLabel),
                      ),
                    )
                  : PrimaryButton(
                      label: confirmLabel,
                      onPressed: onConfirm,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
