import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Generic elevated surface used for thumbnails, option cards, etc.
/// Pure white surface with a soft shadow — "like photos on a table."
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.spaceM),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      elevation: AppDimensions.cardElevation,
      shadowColor: AppColors.secondaryAccent.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
