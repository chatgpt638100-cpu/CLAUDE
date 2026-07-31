import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The fonts a user can choose from in the formatting panel, and the
/// offline-safe way to turn a family name into a [TextStyle].
///
/// ## Offline behaviour — important
///
/// The app ships with no INTERNET permission, so `google_fonts` must
/// never try to download anything. [configureOffline] switches runtime
/// fetching off, which means a family renders correctly only if its font
/// file is bundled as an asset.
///
/// Bundling is a drop-in step, no code change required: put the `.ttf`
/// files in the project's `google_fonts/` folder (already declared in
/// pubspec.yaml) using the package's naming convention —
/// `Lora-Regular.ttf`, `Lora-Bold.ttf`, `Lora-Italic.ttf` and so on.
/// [resolve] picks them up automatically from then on.
///
/// Until a file is present, [resolve] falls back to the app's own serif
/// rather than throwing. A missing font must never take the Editor down
/// or block someone mid-invitation.
class AppFonts {
  AppFonts._();

  /// Fallback family, matching the app's own heading face. Also the
  /// spec's stated default for text on an invitation: serif, charcoal.
  static const String fallbackFamily = 'PlayfairDisplay';

  /// Default for a newly added text box.
  static const String defaultFamily = 'Playfair Display';

  /// Curated list, deliberately short. A hundred fonts would be a
  /// hindrance rather than a feature for this audience — these are
  /// grouped so the elegant serifs and scripts come first.
  static const List<String> catalogue = <String>[
    'Playfair Display',
    'Cormorant Garamond',
    'EB Garamond',
    'Libre Baskerville',
    'Lora',
    'Marcellus',
    'Great Vibes',
    'Dancing Script',
    'Parisienne',
    'Inter',
    'Nunito Sans',
    'Montserrat',
  ];

  /// Families whose font files were requested but could not be loaded.
  /// Cached so a failing lookup is attempted once rather than on every
  /// rebuild of every text box.
  static final Set<String> _unavailable = <String>{};

  /// Turns runtime fetching off. Called once from `main()`, before any
  /// font is resolved.
  static void configureOffline() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  /// Applies [family] to [base], falling back to the app serif if that
  /// family is not bundled.
  static TextStyle resolve(String family, TextStyle base) {
    if (_unavailable.contains(family)) return _fallback(base);

    try {
      return GoogleFonts.getFont(family, textStyle: base);
    } catch (_) {
      // Thrown when the asset is absent and fetching is disabled. Record
      // it so the next rebuild skips straight to the fallback.
      _unavailable.add(family);
      return _fallback(base);
    }
  }

  static TextStyle _fallback(TextStyle base) =>
      base.copyWith(fontFamily: fallbackFamily);
}
