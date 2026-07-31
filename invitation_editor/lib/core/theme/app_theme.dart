import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_dimensions.dart';

/// Assembles the Warm Ivory & Gold palette and typography into a single
/// Flutter ThemeData. This is the only place screens should pull styling
/// from — do not hardcode colors/text styles elsewhere.
class AppTheme {
  AppTheme._();

  /// The "Warm Dark" alternative (Screen 7 — App Theme).
  ///
  /// Built by overriding only what has to change, so the two themes cannot
  /// drift apart as the light one evolves. Surfaces are warm charcoal rather
  /// than black and text is warm ivory rather than white — the palette rule
  /// that nothing in the app is pure black or pure white holds in the dark
  /// theme too.
  static ThemeData get darkTheme {
    final base = lightTheme;

    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAccent,
        brightness: Brightness.dark,
        primary: AppColors.primaryAccent,
        secondary: AppColors.background,
        surface: AppColors.darkSurface,
        error: AppColors.danger,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.darkBackground,
        titleTextStyle: AppTextStyles.heading2.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      cardTheme: base.cardTheme.copyWith(color: AppColors.darkSurface),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: AppColors.darkSurface,
        titleTextStyle: AppTextStyles.heading2.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTextStyles.body.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAccent,
        brightness: Brightness.light,
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.cardSurface,
        error: AppColors.danger,
      ),

      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.body,
        labelLarge: AppTextStyles.buttonLabel,
        bodySmall: AppTextStyles.caption,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.heading2,
        iconTheme: IconThemeData(color: AppColors.secondaryAccent),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.secondaryAccent,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonLabel,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryAccent,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonLabel,
          side: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        titleTextStyle: AppTextStyles.heading2,
        contentTextStyle: AppTextStyles.body,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.secondaryAccent,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
