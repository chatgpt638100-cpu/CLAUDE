import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

/// The Settings screen's operations (Screen 7).
///
/// Grouped in one file rather than split across five near-identical ones:
/// each is a single delegation with no rule of its own, and the screen reads
/// better for having them together.

class LoadSettings {
  final SettingsRepository repository;

  const LoadSettings(this.repository);

  Future<AppSettings> call() => repository.load();
}

class SaveSettings {
  final SettingsRepository repository;

  const SaveSettings(this.repository);

  Future<void> call(AppSettings settings) => repository.save(settings);
}

/// Puts every preference back to its shipped value (Screen 7 — "Restore
/// defaults"). Deliberately does not touch invitations, templates or
/// artwork: restoring preferences must never look like a way to lose work.
class RestoreDefaultSettings {
  final SettingsRepository repository;

  const RestoreDefaultSettings(this.repository);

  Future<AppSettings> call() async {
    await repository.save(AppSettings.defaults);
    return AppSettings.defaults;
  }
}

class GetStorageUsage {
  final SettingsRepository repository;

  const GetStorageUsage(this.repository);

  Future<int> call() => repository.storageUsedInBytes();
}

/// Clears thumbnails and past exports (Screen 7 — storage management).
///
/// Both are rebuilt on demand: a thumbnail is regenerated the next time an
/// invitation is saved, and an export can simply be made again. Uploaded
/// artwork is never in scope.
class ClearCachedFiles {
  final SettingsRepository repository;

  const ClearCachedFiles(this.repository);

  Future<void> call() => repository.clearRegeneratableFiles();
}
