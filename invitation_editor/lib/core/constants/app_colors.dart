import 'package:flutter/material.dart';

/// The "Warm Ivory & Gold" color palette.
/// Source of truth: UI/UX Design Spec, Section 1 — Visual Design System.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFBF7F0); // Warm ivory/cream
  static const Color primaryAccent = Color(0xFFC6A15B); // Deep champagne gold
  static const Color secondaryAccent = Color(0xFF2E2A26); // Soft charcoal

  static const Color textPrimary = Color(0xFF3A3532); // Near-black warm gray
  static const Color textSecondary = Color(0xFF8C8275); // Muted taupe

  static const Color success = Color(0xFF7A9471); // Muted sage green
  static const Color danger = Color(0xFFB5654F); // Soft terracotta red

  static const Color cardSurface = Color(0xFFFFFFFF); // Pure white

  // "Warm Dark" theme (Screen 7 — App Theme). Warm charcoal and warm ivory
  // rather than black and white, so the palette rule holds in the dark
  // theme too.
  static const Color darkBackground = Color(0xFF221F1C);
  static const Color darkSurface = Color(0xFF2E2A26);
  static const Color darkTextPrimary = Color(0xFFF2EDE4);

  /// Curated palette offered for invitation text (Screen 4 — "a row of
  /// large circular colour swatches (curated palette, ~12 elegant
  /// colours) plus one 'More Colours' option").
  ///
  /// Deliberately muted and warm, in keeping with "no pure black, no
  /// neon" — every one of these sits comfortably on ivory or white
  /// stationery. Anything outside this set is still reachable through
  /// "More Colours".
  static const List<Color> textPalette = <Color>[
    Color(0xFF3A3532), // Near-black warm gray (default)
    Color(0xFF2E2A26), // Soft charcoal
    Color(0xFF8C8275), // Muted taupe
    Color(0xFFC6A15B), // Deep champagne gold
    Color(0xFF8C6B3F), // Antique bronze
    Color(0xFFB5654F), // Soft terracotta
    Color(0xFF7B2D3B), // Burgundy
    Color(0xFF6B4463), // Dusty plum
    Color(0xFF2F4156), // Deep navy
    Color(0xFF3E6B68), // Deep teal
    Color(0xFF7A9471), // Muted sage
    Color(0xFFFFFFFF), // White, for dark invitations
  ];
}
