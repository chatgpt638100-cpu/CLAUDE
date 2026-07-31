import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Rows for the Settings list (Screen 7).
///
/// Each carries an icon, a label and a short description, generously spaced,
/// with every control labeled in words.

class SettingsSectionLabel extends StatelessWidget {
  final String label;

  const SettingsSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceM,
        AppDimensions.spaceM,
        AppDimensions.spaceM,
        AppDimensions.spaceS,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryAccent,
            ),
      ),
    );
  }
}

/// A row of mutually exclusive labeled choices, e.g. Small / Medium / Large.
class SettingsChoiceRow<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  const SettingsChoiceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(icon: icon, label: label, description: description),
          const SizedBox(height: AppDimensions.spaceM),
          Wrap(
            spacing: AppDimensions.spaceS,
            runSpacing: AppDimensions.spaceS,
            children: [
              for (final entry in options.entries)
                _Choice(
                  label: entry.value,
                  isSelected: entry.key == value,
                  onTap: () => onChanged(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A tappable row that performs an action.
class SettingsActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onTap;
  final bool isBusy;

  const SettingsActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceM,
          vertical: AppDimensions.spaceM,
        ),
        child: Row(
          children: [
            Expanded(
              child: _Heading(
                icon: icon,
                label: label,
                description: description,
              ),
            ),
            if (isBusy)
              const SizedBox(
                width: AppDimensions.loaderDotSize,
                height: AppDimensions.loaderDotSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

/// A read-only row, e.g. how much space the app is using.
class SettingsInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const SettingsInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceM,
      ),
      child: _Heading(icon: icon, label: label, description: description),
    );
  }
}

class _Heading extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const _Heading({
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Choice({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primaryAccent.withValues(alpha: 0.22)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTouchTarget,
            minWidth: AppDimensions.chipMinWidth,
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.textSecondary.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
