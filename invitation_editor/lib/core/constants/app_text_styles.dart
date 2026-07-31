import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography from the UI/UX Design Spec, Section 1 — Typography.
///
/// Headings/branding use an elegant serif (e.g. Playfair Display).
/// UI labels/buttons use a clean, highly legible sans-serif (e.g. Inter),
/// with a minimum of 16sp, scalable up to 20sp+ (see Settings > Text Size).
///
/// NOTE: Actual font families are wired up once font assets are added
/// (see pubspec.yaml `fonts:` section, currently commented out).
class AppTextStyles {
  AppTextStyles._();

  // Headings — serif, "signals invitation, not app"
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'PlayfairDisplay',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // UI labels/buttons — sans-serif, minimum 16sp, scalable to 20sp
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
    height: 1.5,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.4,
  );
}
