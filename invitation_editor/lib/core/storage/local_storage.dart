import 'package:hive_flutter/hive_flutter.dart';

/// Hive setup for the app's offline database.
///
/// Records are stored as JSON strings rather than through generated
/// `TypeAdapter`s. That is a deliberate choice: adapters need
/// `build_runner` codegen, which adds a build step and regenerated files
/// to review, and a schema change means regenerating adapters before the
/// app will even compile. JSON strings keep the storage layer readable,
/// inspectable, and versioned by a plain integer we control — see
/// `InvitationProjectModel.schemaVersion`.
///
/// The cost is that Hive cannot query inside a record, so filtering and
/// sorting happen in Dart. For a personal library of invitations, which
/// will be tens of items rather than thousands, that is free.
class LocalStorage {
  LocalStorage._();

  /// Saved invitations, keyed by project id.
  static const String invitationsBox = 'invitations';

  /// User-saved templates, keyed by template id.
  static const String templatesBox = 'templates';

  /// App preferences (theme, text scale, export location).
  static const String settingsBox = 'settings';

  /// Opens Hive and every box the app uses, once, before `runApp`.
  ///
  /// Boxes are opened eagerly here rather than lazily on first use so a
  /// disk problem surfaces at startup instead of halfway through
  /// someone's edit.
  static Future<void> initialise() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(invitationsBox),
      Hive.openBox<String>(templatesBox),
      Hive.openBox<String>(settingsBox),
    ]);
  }

  static Box<String> box(String name) => Hive.box<String>(name);
}
