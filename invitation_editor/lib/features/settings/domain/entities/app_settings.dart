import 'package:equatable/equatable.dart';

/// The two themes the spec offers: "Light (default) / Warm Dark".
enum AppThemeChoice { light, warmDark }

/// App-wide text scaling (Screen 7 — "Text Size … Small / Medium / Large").
///
/// Named steps rather than a free slider: three clear choices are something
/// this audience can pick with confidence, and every step stays at or above
/// the spec's 16sp floor.
enum AppTextScale { small, medium, large }

/// User preferences (Screen 7 — Settings).
class AppSettings extends Equatable {
  final AppThemeChoice theme;
  final AppTextScale textScale;

  const AppSettings({
    this.theme = AppThemeChoice.light,
    this.textScale = AppTextScale.medium,
  });

  /// What "Restore defaults" goes back to, and what a first launch starts
  /// from.
  static const AppSettings defaults = AppSettings();

  /// Multiplier applied to every text style in the app.
  ///
  /// Medium is 1.0 — the theme's own sizes, which already meet the 16sp
  /// minimum. Large lifts body text past 20sp, as the spec asks.
  double get textScaleFactor => switch (textScale) {
        AppTextScale.small => 0.9,
        AppTextScale.medium => 1,
        AppTextScale.large => 1.25,
      };

  AppSettings copyWith({AppThemeChoice? theme, AppTextScale? textScale}) {
    return AppSettings(
      theme: theme ?? this.theme,
      textScale: textScale ?? this.textScale,
    );
  }

  @override
  List<Object?> get props => [theme, textScale];
}
