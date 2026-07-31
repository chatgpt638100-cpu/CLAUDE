/// Facts about the build, for the About page (Screen 7).
///
/// Held as constants rather than read at runtime with `package_info_plus`.
/// That package is not in the architecture's dependency list and adding one
/// to display a version string is not worth the weight — but it does mean
/// [version] has to be kept in step with `pubspec.yaml` by hand.
class AppInfo {
  AppInfo._();

  /// Must match the `version:` field in pubspec.yaml.
  static const String version = '0.1.0';

  static const String appName = 'Invitation Editor';

  /// Shown on the About page. The claim is enforced by the app's manifest,
  /// which grants no INTERNET permission in release builds.
  static const String privacySummary =
      'This app works entirely on your phone. It has no internet access, '
      'collects nothing about you, and sends nothing anywhere. Your '
      'invitations stay on this device unless you choose to share them.';
}
