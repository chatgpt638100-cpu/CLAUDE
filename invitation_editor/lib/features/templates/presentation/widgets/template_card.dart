import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/invitation_template.dart';
import 'template_category_labels.dart';

/// One saved template in the Template Library grid (Screen 3).
class TemplateCard extends StatelessWidget {
  final InvitationTemplate template;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${template.name}. '
          '${templateCategoryLabel(template.category)} template',
      button: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              onLongPress: onOptionsTap,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryAccent.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardRadius),
                  child: _Preview(template: template),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Row(
            children: [
              Expanded(
                child: Text(
                  template.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: onOptionsTap,
                borderRadius: BorderRadius.circular(AppDimensions.spaceS),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.more_horiz, color: AppColors.textSecondary),
                      Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            templateCategoryLabel(template.category),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final InvitationTemplate template;

  const _Preview({required this.template});

  @override
  Widget build(BuildContext context) {
    final path = template.thumbnailPath;
    if (path == null) {
      return const ColoredBox(
        color: AppColors.cardSurface,
        child: Center(
          child: Icon(
            Icons.bookmark_border,
            size: 40,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      // Decoded near display size rather than full page resolution.
      cacheWidth: AppDimensions.thumbnailCacheWidth,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.cardSurface,
        child: Center(
          child: Icon(
            Icons.bookmark_border,
            size: 40,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// The "Blank card" tile that opens the Editor with an empty canvas
/// (Screen 3 — the grid includes a blank option alongside the designs).
class BlankTemplateCard extends StatelessWidget {
  final VoidCallback onTap;

  const BlankTemplateCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(
                  color: AppColors.primaryAccent,
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: AppColors.primaryAccent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceS),
        Text('Blank card', style: Theme.of(context).textTheme.bodyMedium),
        Text(
          'Start from scratch',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
