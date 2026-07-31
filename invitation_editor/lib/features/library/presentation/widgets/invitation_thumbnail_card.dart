import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// A single invitation thumbnail shown in the Library grid.
/// UI-only for Phase 1 — no real thumbnail image, storage, or
/// options menu behavior wired up yet.
class InvitationThumbnailCard extends StatelessWidget {
  final String title;
  final String lastEditedLabel;
  final VoidCallback? onTap;
  final VoidCallback? onOptionsTap;

  const InvitationThumbnailCard({
    super.key,
    required this.title,
    required this.lastEditedLabel,
    this.onTap,
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: onOptionsTap,
                borderRadius: BorderRadius.circular(AppDimensions.spaceS),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.more_horiz, color: AppColors.textSecondary),
                      Text('Options', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            lastEditedLabel,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
