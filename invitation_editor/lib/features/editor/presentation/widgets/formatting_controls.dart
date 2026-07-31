import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Building blocks for the formatting panel (Screen 4).
///
/// Every control here is labeled and generously sized: no icon-only
/// buttons, no thin sliders, nothing below the 48dp touch minimum.

/// A titled group of controls, so the panel reads as a short list of
/// named choices rather than a wall of buttons.
class FormattingSection extends StatelessWidget {
  final String label;
  final Widget child;

  const FormattingSection({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          child,
        ],
      ),
    );
  }
}

/// A large +/− stepper with the current value shown between the buttons.
///
/// The spec is explicit that size uses "a simple large +/− stepper with a
/// live preview, not a tiny slider" — the same reasoning applies to
/// spacing and opacity, so they all share this control.
class FormattingStepper extends StatelessWidget {
  final String valueLabel;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  /// Spoken description, e.g. "Font size". Screen readers announce this
  /// with the value rather than just "minus" and "plus".
  final String semanticLabel;

  const FormattingStepper({
    super.key,
    required this.valueLabel,
    required this.semanticLabel,
    this.onDecrease,
    this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: valueLabel,
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove,
            tooltip: 'Less',
            onPressed: onDecrease,
          ),
          Expanded(
            child: Center(
              child: Text(
                valueLabel,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            tooltip: 'More',
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _StepperButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isEnabled
            ? AppColors.primaryAccent.withValues(alpha: 0.14)
            : AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          child: SizedBox(
            width: AppDimensions.stepperButtonSize,
            height: AppDimensions.stepperButtonSize,
            child: Icon(
              icon,
              size: 24,
              color: isEnabled
                  ? AppColors.secondaryAccent
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A labeled on/off or pick-one chip. Used for Bold, Italic, Underline,
/// alignment and shadow strength.
class FormattingChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onPressed;

  /// Renders the label in the style it applies, so "Bold" looks bold and
  /// "Italic" looks italic — the choice is visible, not just named.
  final TextStyle? labelStyle;

  const FormattingChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.icon,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    final effectiveStyle = (labelStyle ?? baseStyle)?.copyWith(
      color: isSelected ? AppColors.secondaryAccent : AppColors.textSecondary,
    );

    return Material(
      color: isSelected
          ? AppColors.primaryAccent.withValues(alpha: 0.22)
          : AppColors.cardSurface,
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTouchTarget,
            minWidth: AppDimensions.chipMinWidth,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.textSecondary.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.secondaryAccent
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppDimensions.spaceS),
              ],
              Text(label, style: effectiveStyle),
            ],
          ),
        ),
      ),
    );
  }
}
