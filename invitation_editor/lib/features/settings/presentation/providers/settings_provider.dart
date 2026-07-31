import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/service_locator.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecases.dart';

/// User preferences (Screen 7).
///
/// Watched at the root of the app, so a theme or text-size change repaints
/// everything at once rather than only the screen that made it.
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => sl<LoadSettings>()();

  Future<void> setTheme(AppThemeChoice theme) async {
    await _update((current) => current.copyWith(theme: theme));
  }

  Future<void> setTextScale(AppTextScale scale) async {
    await _update((current) => current.copyWith(textScale: scale));
  }

  Future<void> restoreDefaults() async {
    state = AsyncData(await sl<RestoreDefaultSettings>()());
  }

  /// Applies the change to the UI first, then persists.
  ///
  /// Tapping a theme should feel instant; waiting on a disk write before the
  /// screen responds would make the app feel sluggish for no benefit, and a
  /// failed write only costs the preference at next launch.
  Future<void> _update(AppSettings Function(AppSettings current) change) async {
    final current = state.valueOrNull ?? AppSettings.defaults;
    final updated = change(current);
    if (updated == current) return;

    state = AsyncData(updated);
    try {
      await sl<SaveSettings>()(updated);
    } catch (_) {
      // Nothing actionable to tell the user about a preference that did not
      // stick; it is already applied for this session.
    }
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Bytes held by the app's folders, for the storage row.
///
/// Separate from [settingsProvider] so clearing the cache can refresh the
/// figure without reloading preferences.
final storageUsageProvider = FutureProvider.autoDispose<int>((ref) {
  return sl<GetStorageUsage>()();
});
