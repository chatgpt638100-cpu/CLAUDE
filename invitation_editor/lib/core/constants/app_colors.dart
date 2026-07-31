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
}
