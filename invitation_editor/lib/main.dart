import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/storage/local_storage.dart';
import 'core/theme/app_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'injection/service_locator.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must happen before any font is resolved. The app has no INTERNET
  // permission, so google_fonts is switched to bundled assets only —
  // without this it would attempt an HTTP fetch and fail.
  AppFonts.configureOffline();

  // Opened before the first frame so the Library never renders against a
  // database that is not ready yet.
  await LocalStorage.initialise();

  await setupServiceLocator();

  runApp(const ProviderScope(child: InvitationEditorApp()));
}

class InvitationEditorApp extends ConsumerWidget {
  const InvitationEditorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Preferences are read here, at the root, so changing the theme or text
    // size repaints the whole app rather than only the Settings screen.
    // Until they have loaded, the shipped defaults apply — a first frame in
    // the default theme is better than a blank one.
    final settings = ref.watch(settingsProvider).valueOrNull ??
        AppSettings.defaults;

    return MaterialApp.router(
      title: 'Invitation Editor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Driven by the user's choice rather than the system setting: the spec
      // treats Light as the default and Warm Dark as an explicit preference.
      themeMode: settings.theme == AppThemeChoice.warmDark
          ? ThemeMode.dark
          : ThemeMode.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // The app's own Text Size setting multiplies the phone's
        // accessibility scaling rather than replacing it, so someone who has
        // already enlarged text system-wide keeps that and this adds to it.
        //
        // TextScaler has no multiply, so the platform factor is recovered by
        // measuring what it does to a known size.
        final platformFactor = MediaQuery.textScalerOf(context).scale(100) / 100;
        final effective = (platformFactor * settings.textScaleFactor)
            .clamp(0.8, 2.4)
            .toDouble();

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(effective),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
