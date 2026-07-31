/// Shared spacing, sizing, and radius constants.
/// Source: UI/UX Design Spec, Section 1 — Buttons, Iconography, Accessibility.
class AppDimensions {
  AppDimensions._();

  // Spacing scale
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // Buttons — minimum 56dp height per spec, non-negotiable for 50+ audience
  static const double buttonHeight = 56;
  static const double buttonRadius = 12;

  // Touch targets — accessibility minimum
  static const double minTouchTarget = 48;

  // Card / surface
  static const double cardRadius = 16;
  static const double cardElevation = 2;

  // Source-selection option cards (Screen 2)
  static const double optionCardHeight = 100;

  // Animation durations — "subtle and slow", never bouncy
  static const Duration animationFast = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);

  // Loading — a calm pulsing gold dot rather than a spinner. Slower
  // than a transition on purpose: it should breathe, not flicker.
  static const Duration animationPulse = Duration(milliseconds: 1200);
  static const double loaderDotSize = 16;

  // Editor canvas — A4 portrait proportions for an empty blank card
  static const double blankPageAspectRatio = 1 / 1.414;

  // Editor canvas zoom limits. 1.0 is the page's comfortable starting
  // fit; 4x is enough to inspect fine print without letting the user
  // get lost in a wall of pixels.
  static const double canvasMinScale = 1;
  static const double canvasMaxScale = 4;
}
