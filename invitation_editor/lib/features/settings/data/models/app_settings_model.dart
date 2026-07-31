import '../../domain/entities/app_settings.dart';

/// How preferences look in storage.
///
/// Enums are persisted by name rather than index, so reordering a variant
/// later cannot silently switch someone's theme.
class AppSettingsModel {
  AppSettingsModel._();

  static const int schemaVersion = 1;

  static Map<String, dynamic> toJson(AppSettings settings) {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'theme': settings.theme.name,
      'textScale': settings.textScale.name,
    };
  }

  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: _enum(json['theme'], AppThemeChoice.values, AppThemeChoice.light),
      textScale: _enum(
        json['textScale'],
        AppTextScale.values,
        AppTextScale.medium,
      ),
    );
  }

  static T _enum<T extends Enum>(Object? value, List<T> values, T fallback) {
    if (value is String) {
      for (final candidate in values) {
        if (candidate.name == value) return candidate;
      }
    }
    return fallback;
  }
}
