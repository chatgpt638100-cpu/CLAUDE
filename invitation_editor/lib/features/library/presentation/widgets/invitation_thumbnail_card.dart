import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../domain/entities/invitation_project.dart';

/// A single invitation in the Library grid (Screen 1) — "shown as a real
/// preview thumbnail with a soft shadow (like photos on a table)", with
/// its title and last-edited date beneath.
class InvitationThumbnailCard extends StatelessWidget {
  final InvitationProject project;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const InvitationThumbnailCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${project.title}. ${formatLastEdited(project.updatedAt)}',
      button: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              // Long-press opens the same menu as the Options button, per
              // spec — but it is never the only way to reach it.
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
                  child: _Preview(project: project),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
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
            formatLastEdited(project.updatedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// The cached thumbnail, or a quiet placeholder when one has not been
/// generated yet.
class _Preview extends StatelessWidget {
  final InvitationProject project;

  const _Preview({required this.project});

  @override
  Widget build(BuildContext context) {
    final path = project.thumbnailPath;
    if (path == null) return const _PlaceholderPreview();

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      // Decoded at roughly the size it is displayed at rather than full
      // resolution: a grid of full-size page bitmaps is the fastest way
      // to exhaust memory on an older phone.
      cacheWidth: AppDimensions.thumbnailCacheWidth,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) => const _PlaceholderPreview(),
    );
  }
}

class _PlaceholderPreview extends StatelessWidget {
  const _PlaceholderPreview();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.cardSurface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
