import 'dart:convert';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_paths.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/app_settings_model.dart';

/// [SettingsRepository] backed by the Hive settings box and the app's own
/// folders.
class SettingsRepositoryImpl implements SettingsRepository {
  final AppPaths appPaths;

  const SettingsRepositoryImpl(this.appPaths);

  static const String _key = 'appSettings';

  @override
  Future<AppSettings> load() async {
    try {
      final raw = LocalStorage.box(LocalStorage.settingsBox).get(_key);
      if (raw == null) return AppSettings.defaults;

      final decoded = jsonDecode(raw);
      if (decoded is! Map) return AppSettings.defaults;

      return AppSettingsModel.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      // Preferences are not worth failing a launch over.
      return AppSettings.defaults;
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    try {
      await LocalStorage.box(LocalStorage.settingsBox).put(
        _key,
        jsonEncode(AppSettingsModel.toJson(settings)),
      );
    } catch (_) {
      throw const StorageFailure('Could not save your settings.');
    }
  }

  @override
  Future<int> storageUsedInBytes() async {
    try {
      return await appPaths.storageUsedInBytes();
    } catch (_) {
      // A figure that cannot be read is shown as zero rather than as an
      // error banner over the whole screen.
      return 0;
    }
  }

  @override
  Future<void> clearRegeneratableFiles() async {
    try {
      await appPaths.clearRegeneratableFiles();
    } catch (_) {
      throw const StorageFailure('Could not clear the cached files.');
    }
  }
}
