import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Actions for the currently selected text box (Screen 4 — "Delete",
/// "Duplicate", "Bring to Front", plus "Send to Back" and "Edit Text").
///
/// Placement note: the spec sketches this toolbar floating just above the
/// selected box. It sits below the canvas instead, because a floating bar
/// would be scaled by the canvas zoom, rotate with a rotated box, and get
/// clipped for a box near the top edge — all of which make it unreliable
/// exactly when it is needed. A fixed position also builds muscle memory,
/// which the spec asks for. Every action still carries a text label and a
/// touch target above the 48dp minimum.
class TextElementToolbar extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onFormat;
  final VoidCallback onDuplicate;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;
  final VoidCallback onDelete;

  const TextElementToolbar({
    super.key,
    required this.onEdit,
    required this.onFormat,
    required this.onDuplicate,
    required this.onBringToFront,
    required this.onSendToBack,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppDimensions.spaceS,
      runSpacing: AppDimensions.spaceS,
      children: [
        _ToolbarAction(
          icon: Icons.edit_outlined,
          label: 'Edit Text',
          onPressed: onEdit,
        ),
        _ToolbarAction(
          icon: Icons.text_format,
          label: 'Style',
          onPressed: onFormat,
        ),
        _ToolbarAction(
          icon: Icons.copy_outlined,
          label: 'Duplicate',
          onPressed: onDuplicate,
        ),
        _ToolbarAction(
          icon: Icons.flip_to_front_outlined,
          label: 'Front',
          onPressed: onBringToFront,
        ),
        _ToolbarAction(
          icon: Icons.flip_to_back_outlined,
          label: 'Back',
          onPressed: onSendToBack,
        ),
        _ToolbarAction(
          icon: Icons.delete_outline,
          label: 'Delete',
          onPressed: onDelete,
          isDestructive: true,
        ),
      ],
    );
  }
}

/// One labeled action. Never icon-only, per the spec's single most
/// important accessibility decision.
class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.danger : AppColors.secondaryAccent;

    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      elevation: AppDimensions.cardElevation,
      shadowColor: AppColors.secondaryAccent.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppDimensions.toolbarActionMinWidth,
            minHeight: AppDimensions.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceS,
            vertical: AppDimensions.spaceS,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: AppDimensions.spaceXS),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
