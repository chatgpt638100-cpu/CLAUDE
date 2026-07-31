import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/invitation_project.dart';

/// What the user picked from a thumbnail's Options menu.
///
/// Export and Print are listed in the spec's menu but are not offered yet
/// — they arrive with the export feature. Nothing is shown for them
/// rather than showing a disabled row that invites a pointless tap.
enum InvitationOption { rename, duplicate, delete }

/// The "•••" menu on a Library thumbnail (Screen 1).
///
/// A bottom sheet of large labeled rows rather than a compact popup: this
/// audience needs targets it can hit and labels it can read, and a popup
/// anchored to a small icon gives neither.
Future<InvitationOption?> showInvitationOptionsSheet(
  BuildContext context, {
  required InvitationProject project,
}) {
  return showModalBottomSheet<InvitationOption>(
    context: context,
    backgroundColor: AppColors.cardSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.cardRadius),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            child: Text(
              project.title,
              style: Theme.of(sheetContext).textTheme.headlineMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1),
          _OptionRow(
            icon: Icons.drive_file_rename_outline,
            label: 'Rename',
            description: 'Give this invitation a different name',
            onTap: () =>
                Navigator.of(sheetContext).pop(InvitationOption.rename),
          ),
          _OptionRow(
            icon: Icons.copy_outlined,
            label: 'Duplicate',
            description: 'Make a copy you can change freely',
            onTap: () =>
                Navigator.of(sheetContext).pop(InvitationOption.duplicate),
          ),
          _OptionRow(
            icon: Icons.delete_outline,
            label: 'Delete',
            description: 'Remove this invitation for good',
            isDestructive: true,
            onTap: () =>
                Navigator.of(sheetContext).pop(InvitationOption.delete),
          ),
          const SizedBox(height: AppDimensions.spaceS),
        ],
      ),
    ),
  );
}

/// Deleting an invitation cannot be undone, so unlike deleting a text box
/// it gets a confirmation dialog — exactly the split the spec asks for.
Future<bool> confirmDeleteInvitation(
  BuildContext context, {
  required String title,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AppDialog(
      title: 'Delete "$title"?',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep it',
      isDestructive: true,
      onConfirm: () => Navigator.of(dialogContext).pop(true),
      onCancel: () => Navigator.of(dialogContext).pop(false),
      content: Text(
        'This cannot be undone.',
        textAlign: TextAlign.center,
        style: Theme.of(dialogContext).textTheme.bodyMedium,
      ),
    ),
  );
  return confirmed ?? false;
}

/// Asks for a new name, pre-filled with the current one.
Future<String?> showRenameInvitationDialog(
  BuildContext context, {
  required String currentTitle,
}) {
  final controller = TextEditingController(text: currentTitle);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      void submit() {
        final text = controller.text.trim();
        Navigator.of(dialogContext).pop(text.isEmpty ? null : text);
      }

      return AppDialog(
        title: 'Rename invitation',
        confirmLabel: 'Save',
        onConfirm: submit,
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => submit(),
          style: Theme.of(dialogContext).textTheme.bodyLarge,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(AppDimensions.spaceM),
          ),
        ),
      );
    },
  ).whenComplete(controller.dispose);
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colour =
        isDestructive ? AppColors.danger : AppColors.secondaryAccent;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceM,
          vertical: AppDimensions.spaceM,
        ),
        child: Row(
          children: [
            Icon(icon, color: colour),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: colour),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
