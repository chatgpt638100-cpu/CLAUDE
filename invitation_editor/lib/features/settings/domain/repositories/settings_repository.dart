import '../entities/app_settings.dart';

/// Domain contract for reading and writing user preferences, and for the
/// storage housekeeping the Settings screen offers.
abstract class SettingsRepository {
  /// Never throws: a first launch, or an unreadable record, yields
  /// [AppSettings.defaults] rather than blocking the app from starting.
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);

  /// Bytes currently held by the app's own folders.
  Future<int> storageUsedInBytes();

  /// Deletes files that can be rebuilt on demand — cached thumbnails and
  /// past exports. Never touches uploaded artwork.
  Future<void> clearRegeneratableFiles();
}
