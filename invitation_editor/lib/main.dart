import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_fonts.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'injection/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must happen before any font is resolved. The app has no INTERNET
  // permission, so google_fonts is switched to bundled assets only —
  // without this it would attempt an HTTP fetch and fail.
  AppFonts.configureOffline();

  // Wiring point for later phases (hive init, repositories, etc.).
  await setupServiceLocator();

  runApp(const ProviderScope(child: InvitationEditorApp()));
}

class InvitationEditorApp extends StatelessWidget {
  const InvitationEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Invitation Editor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
