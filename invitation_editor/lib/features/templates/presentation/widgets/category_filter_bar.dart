import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/template_category.dart';
import 'template_category_labels.dart';

/// The category pills above the template grid (Screen 3 — "Category filter
/// as large horizontal pill tabs at top (labeled, not icon-only)").
///
/// Wraps onto a second line rather than scrolling sideways: a pill the user
/// has to discover by swiping is a hidden gesture, which the spec rules
/// out.
class CategoryFilterBar extends StatelessWidget {
  final TemplateCategory? selected;
  final ValueChanged<TemplateCategory?> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spaceS,
      runSpacing: AppDimensions.spaceS,
      children: [
        _Pill(
          label: 'All',
          isSelected: selected == null,
          onTap: () => onSelected(null),
        ),
        for (final category in TemplateCategory.values)
          _Pill(
            label: templateCategoryLabel(category),
            isSelected: selected == category,
            onTap: () => onSelected(category),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primaryAccent.withValues(alpha: 0.22)
          : AppColors.cardSurface,
      borderRadius: BorderRadius.circular(AppDimensions.buttonHeight / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.buttonHeight / 2),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceL,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.buttonHeight / 2),
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
                    color: isSelected
                        ? AppColors.secondaryAccent
                        : AppColors.textSecondary,
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
