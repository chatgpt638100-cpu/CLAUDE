import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../domain/entities/text_element.dart';
import '../domain/entities/text_format.dart';

/// Translates a [TextElement]'s domain-level styling into Flutter types.
///
/// Kept in one place so the canvas and the formatting panel's live
/// preview can never drift apart — what you see in the preview is
/// produced by exactly the same code that paints the canvas.
///
/// Sits in the presentation layer because its output is all Flutter:
/// `TextStyle`, `TextAlign`, `Shadow`.
extension TextElementStyle on TextElement {
  /// [fontSizePx] is passed in rather than derived, because the same
  /// element renders at page scale on the canvas and at a fixed,
  /// readable scale in the panel preview.
  TextStyle toTextStyle({required double fontSizePx}) {
    final colour = Color(colorValue);

    final base = TextStyle(
      fontSize: fontSizePx,
      color: colour,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration:
          isUnderlined ? TextDecoration.underline : TextDecoration.none,
      decorationColor: colour,
      // Stored as a fraction of the font size, so spacing keeps its
      // proportions as the text grows.
      letterSpacing: letterSpacing * fontSizePx,
      height: lineHeight,
      shadows: shadow.toShadows(fontSizePx),
    );

    return AppFonts.resolve(fontFamily, base);
  }

  TextAlign get textAlign => switch (alignment) {
        TextAlignmentOption.left => TextAlign.left,
        TextAlignmentOption.centre => TextAlign.center,
        TextAlignmentOption.right => TextAlign.right,
      };
}

/// Private: only [TextElementStyle.toTextStyle] needs this. Kept out of
/// the public surface so there is no unused API to maintain.
extension _TextShadowStyleMapper on TextShadowStyle {
  /// Shadow geometry scales with the font so it looks the same at any
  /// text size. Charcoal rather than pure black, per the palette rule
  /// that nothing in the app is fully black.
  List<Shadow>? toShadows(double fontSizePx) => switch (this) {
        TextShadowStyle.none => null,
        TextShadowStyle.soft => [
            Shadow(
              blurRadius: fontSizePx * 0.14,
              offset: Offset(0, fontSizePx * 0.05),
              color: AppColors.secondaryAccent.withValues(alpha: 0.28),
            ),
          ],
        TextShadowStyle.strong => [
            Shadow(
              blurRadius: fontSizePx * 0.22,
              offset: Offset(0, fontSizePx * 0.10),
              color: AppColors.secondaryAccent.withValues(alpha: 0.48),
            ),
          ],
      };
}
