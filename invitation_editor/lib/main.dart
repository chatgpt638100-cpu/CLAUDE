import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'injection/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
