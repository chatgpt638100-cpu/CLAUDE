import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// What the user picked from the Editor's "Menu".
enum EditorMenuAction { saveAsTemplate, printOrExport }

/// The Editor's overflow menu (Screen 4 — "Menu").
///
/// A bottom sheet of labeled rows rather than a `PopupMenuButton`, which
/// would be an icon-only trigger with cramped items — both ruled out for
/// this audience.
///
/// Undo/redo and page settings are listed in the spec's menu but are not
/// offered yet; nothing is shown for them rather than a disabled row that
/// invites a pointless tap.
Future<EditorMenuAction?> showEditorMenuSheet(BuildContext context) {
  return showModalBottomSheet<EditorMenuAction>(
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
              'More options',
              style: Theme.of(sheetContext).textTheme.headlineMedium,
            ),
          ),
          const Divider(height: 1),
          _MenuRow(
            icon: Icons.bookmark_add_outlined,
            label: 'Save as Template',
            description: 'Reuse this design for someone else',
            onTap: () => Navigator.of(sheetContext)
                .pop(EditorMenuAction.saveAsTemplate),
          ),
          _MenuRow(
            icon: Icons.print_outlined,
            label: 'Print / Export',
            description: 'Save as PDF, print, or share',
            onTap: () => Navigator.of(sheetContext)
                .pop(EditorMenuAction.printOrExport),
          ),
          const SizedBox(height: AppDimensions.spaceS),
        ],
      ),
    ),
  );
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceM),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryAccent),
            const SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyLarge),
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
