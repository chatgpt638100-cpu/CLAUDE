import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_info.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/widgets/app_bar_widget.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/pulsing_dot_loader.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_widgets.dart';

/// Screen 7 — Settings.
///
/// "Simple list, generously spaced, each row with an icon + label + short
/// description", per the spec.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isClearing = false;

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Clear cached files?',
        confirmLabel: 'Clear',
        cancelLabel: 'Keep them',
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
        content: Text(
          'This removes preview thumbnails and PDFs you have exported. '
          'Your invitations and their artwork are not touched — thumbnails '
          'come back the next time each one is saved.',
          textAlign: TextAlign.center,
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isClearing = true);
    try {
      await sl<ClearCachedFiles>()();
      if (!mounted) return;
      // Recompute the figure now that files have gone.
      ref.invalidate(storageUsageProvider);
      _showMessage('Cached files cleared.');
    } on Failure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  Future<void> _restoreDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Restore default settings?',
        confirmLabel: 'Restore',
        cancelLabel: 'Cancel',
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
        content: Text(
          'Theme and text size go back to how they started. '
          'Your invitations and templates are not affected.',
          textAlign: TextAlign.center,
          style: Theme.of(dialogContext).textTheme.bodyMedium,
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(settingsProvider.notifier).restoreDefaults();
    if (mounted) _showMessage('Settings restored.');
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'About ${AppInfo.appName}',
        confirmLabel: 'Close',
        cancelLabel: 'Done',
        onConfirm: () => Navigator.of(dialogContext).pop(),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${AppInfo.version}',
              style: Theme.of(dialogContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppDimensions.spaceS),
                Text(
                  'Offline only',
                  style: Theme.of(dialogContext)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              AppInfo.privacySummary,
              style: Theme.of(dialogContext).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final usage = ref.watch(storageUsageProvider);

    return Scaffold(
      appBar: const AppTopBar(title: 'Settings', showBackLabel: true),
      body: SafeArea(
        child: settings.when(
          loading: () => const Center(
            child: PulsingDotLoader(label: 'Opening your settings…'),
          ),
          // Preferences fall back to defaults rather than failing, so there is
          // no error branch to render — but AsyncValue requires one.
          error: (_, __) => const Center(
            child: PulsingDotLoader(label: 'Opening your settings…'),
          ),
          data: (current) => ListView(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceM,
            ),
            children: [
              SettingsSectionLabel('Appearance'),
              SettingsChoiceRow<AppTextScale>(
                icon: Icons.format_size,
                label: 'Text Size',
                description: 'Make everything in the app easier to read',
                value: current.textScale,
                options: const {
                  AppTextScale.small: 'Small',
                  AppTextScale.medium: 'Medium',
                  AppTextScale.large: 'Large',
                },
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).setTextScale(value),
              ),
              SettingsChoiceRow<AppThemeChoice>(
                icon: Icons.palette_outlined,
                label: 'App Theme',
                description: 'Warm ivory, or a warm dark alternative',
                value: current.theme,
                options: const {
                  AppThemeChoice.light: 'Light',
                  AppThemeChoice.warmDark: 'Warm Dark',
                },
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).setTheme(value),
              ),
              const Divider(height: AppDimensions.spaceXL),
              SettingsSectionLabel('Storage'),
              SettingsInfoRow(
                icon: Icons.folder_outlined,
                label: 'Space used',
                description: usage.when(
                  loading: () => 'Working it out…',
                  error: (_, __) => 'Not available',
                  data: formatBytes,
                ),
              ),
              SettingsActionRow(
                icon: Icons.cleaning_services_outlined,
                label: 'Clear Cached Files',
                description:
                    'Removes thumbnails and past exports. Invitations are '
                    'kept.',
                isBusy: _isClearing,
                onTap: _isClearing ? null : _clearCache,
              ),
              const Divider(height: AppDimensions.spaceXL),
              SettingsSectionLabel('About'),
              SettingsActionRow(
                icon: Icons.info_outline,
                label: 'About',
                description:
                    'Version ${AppInfo.version} · works entirely offline',
                onTap: _showAbout,
              ),
              SettingsActionRow(
                icon: Icons.restart_alt,
                label: 'Restore Defaults',
                description: 'Put theme and text size back as they were',
                onTap: _restoreDefaults,
              ),
              const SizedBox(height: AppDimensions.spaceXL),
            ],
          ),
        ),
      ),
    );
  }
}
