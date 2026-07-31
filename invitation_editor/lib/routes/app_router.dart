import 'package:go_router/go_router.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/source_selection/presentation/screens/source_selection_screen.dart';
import '../features/templates/presentation/screens/template_library_screen.dart';
import '../features/editor/presentation/screens/editor_screen.dart';
import '../features/editor/domain/entities/invitation_source_file.dart';
import '../features/export/presentation/screens/export_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

/// Central place listing every screen and how to navigate between them.
/// Only the Library (Home) and Source Selection screens have real UI so
/// far — the rest are placeholders.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/new-invitation',
        name: 'sourceSelection',
        builder: (context, state) => const SourceSelectionScreen(),
      ),
      GoRoute(
        path: '/templates',
        name: 'templates',
        builder: (context, state) => const TemplateLibraryScreen(),
      ),
      GoRoute(
        path: '/editor',
        name: 'editor',
        // The selected source file (if any) is passed via `extra` from
        // the Source Selection screen. The Editor screen only stores
        // it for now — it does not display or process it yet.
        builder: (context, state) => EditorScreen(
          sourceFile: state.extra as InvitationSourceFile?,
        ),
      ),
      GoRoute(
        path: '/export',
        name: 'export',
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
