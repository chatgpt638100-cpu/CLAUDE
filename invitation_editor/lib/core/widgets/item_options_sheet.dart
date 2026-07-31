import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_dialog.dart';

/// Shared "•••" menu, rename dialog and delete confirmation, used by both
/// the Library and the Template Library.
///
/// Generic on purpose: a saved invitation and a saved template need the
/// identical three actions with identical wording and identical touch
/// targets. Two copies would be two places to fix a label.

/// What the user picked from an item's Options menu.
enum ItemOption { rename, duplicate, delete }

/// A bottom sheet of large labeled rows rather than a compact popup: this
/// audience needs targets it can hit and labels it can read, and a popup
/// anchored to a small icon gives neither.
Future<ItemOption?> showItemOptionsSheet(
  BuildContext context, {
  required String title,
  String duplicateDescription = 'Make a copy you can change freely',
  String deleteDescription = 'Remove this for good',
  bool includeDuplicate = true,
}) {
  return showModalBottomSheet<ItemOption>(
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
              title,
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
            description: 'Give this a different name',
            onTap: () => Navigator.of(sheetContext).pop(ItemOption.rename),
          ),
          if (includeDuplicate)
            _OptionRow(
              icon: Icons.copy_outlined,
              label: 'Duplicate',
              description: duplicateDescription,
              onTap: () =>
                  Navigator.of(sheetContext).pop(ItemOption.duplicate),
            ),
          _OptionRow(
            icon: Icons.delete_outline,
            label: 'Delete',
            description: deleteDescription,
            isDestructive: true,
            onTap: () => Navigator.of(sheetContext).pop(ItemOption.delete),
          ),
          const SizedBox(height: AppDimensions.spaceS),
        ],
      ),
    ),
  );
}

/// Deleting a whole invitation or template cannot be undone, so unlike
/// deleting a text box it gets a confirmation dialog — exactly the split
/// the spec asks for.
Future<bool> confirmDeletionDialog(
  BuildContext context, {
  required String title,
  String description = 'This cannot be undone.',
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
        description,
        textAlign: TextAlign.center,
        style: Theme.of(dialogContext).textTheme.bodyMedium,
      ),
    ),
  );
  return confirmed ?? false;
}

/// Asks for a new name, pre-filled with the current one. Returns null if
/// cancelled or left blank.
Future<String?> showRenameDialog(
  BuildContext context, {
  required String dialogTitle,
  required String currentValue,
}) {
  final controller = TextEditingController(text: currentValue);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      void submit() {
        final text = controller.text.trim();
        Navigator.of(dialogContext).pop(text.isEmpty ? null : text);
      }

      return AppDialog(
        title: dialogTitle,
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
        padding: const EdgeInsets.all(AppDimensions.spaceM),
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
