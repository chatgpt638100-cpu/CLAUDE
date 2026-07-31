import 'package:equatable/equatable.dart';

import 'text_format.dart';

/// A single text box placed on an invitation (Screen 4).
///
/// All geometry is stored **normalised to the page**, not in screen
/// pixels: `x`/`y`/`width`/`height` are fractions of the page's width
/// and height, `fontSize` is a fraction of the page height, and
/// `letterSpacing` is a fraction of the font size. That keeps a layout
/// identical across phone sizes, survives zooming, and lets a later
/// export phase multiply straight through to PDF point sizes without
/// re-deriving anything.
///
/// Pure domain object — no Flutter types. Colour is an ARGB int rather
/// than a `Color`, and alignment/shadow are domain enums, so nothing
/// here depends on `dart:ui`.
class TextElement extends Equatable {
  /// Stable identity, assigned on creation.
  final String id;

  final String content;

  /// Left edge, as a fraction of page width.
  final double x;

  /// Top edge, as a fraction of page height.
  final double y;

  /// Fraction of page width.
  final double width;

  /// Fraction of page height.
  final double height;

  /// Clockwise rotation about the box's centre, in radians.
  final double rotation;

  /// Fraction of page height.
  final double fontSize;

  /// Google Fonts family name, e.g. "Playfair Display".
  final String fontFamily;

  /// ARGB colour value.
  final int colorValue;

  final bool isBold;
  final bool isItalic;
  final bool isUnderlined;

  final TextAlignmentOption alignment;

  /// Extra space between letters, as a fraction of the font size, so it
  /// scales with the text rather than drifting apart as text grows.
  final double letterSpacing;

  /// Line height as a multiple of the font size.
  final double lineHeight;

  /// 0 = invisible, 1 = fully opaque.
  final double opacity;

  final TextShadowStyle shadow;

  const TextElement({
    required this.id,
    required this.content,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    required this.fontSize,
    required this.fontFamily,
    required this.colorValue,
    required this.isBold,
    required this.isItalic,
    required this.isUnderlined,
    required this.alignment,
    required this.letterSpacing,
    required this.lineHeight,
    required this.opacity,
    required this.shadow,
  });

  // Defaults for a freshly added box: a little over half the page wide,
  // comfortably readable, unrotated, in the spec's fallback style for
  // invitation text — serif, charcoal.
  static const double defaultWidth = 0.55;
  static const double defaultHeight = 0.14;
  static const double defaultFontSize = 0.05;
  static const int defaultColorValue = 0xFF3A3532;
  static const double defaultLetterSpacing = 0;
  static const double defaultLineHeight = 1.2;
  static const double defaultOpacity = 1;

  // Limits applied when resizing or stepping a value, so nothing can be
  // pushed into something invisible, illegible, or absurdly large.
  static const double minWidth = 0.08;
  static const double maxWidth = 1.6;
  static const double minFontSize = 0.015;
  static const double maxFontSize = 0.4;
  static const double minLetterSpacing = -0.05;
  static const double maxLetterSpacing = 0.5;
  static const double minLineHeight = 0.8;
  static const double maxLineHeight = 2.5;
  static const double minOpacity = 0.1;
  static const double maxOpacity = 1;

  // Increments used by the formatting panel's +/- steppers.
  static const double fontSizeStep = 0.0025;
  static const double letterSpacingStep = 0.01;
  static const double lineHeightStep = 0.1;
  static const double opacityStep = 0.1;

  /// A new box centred on the given point, using the default style.
  factory TextElement.centredAt({
    required String id,
    required String content,
    required double centreX,
    required double centreY,
    required String fontFamily,
  }) {
    return TextElement(
      id: id,
      content: content,
      x: centreX - defaultWidth / 2,
      y: centreY - defaultHeight / 2,
      width: defaultWidth,
      height: defaultHeight,
      rotation: 0,
      fontSize: defaultFontSize,
      fontFamily: fontFamily,
      colorValue: defaultColorValue,
      isBold: false,
      isItalic: false,
      isUnderlined: false,
      alignment: TextAlignmentOption.centre,
      letterSpacing: defaultLetterSpacing,
      lineHeight: defaultLineHeight,
      opacity: defaultOpacity,
      shadow: TextShadowStyle.none,
    );
  }

  double get centreX => x + width / 2;

  double get centreY => y + height / 2;

  /// Font size as a plain number to show in the panel. The stored value
  /// is a page fraction, which would mean nothing to a user, so it is
  /// presented on a familiar point-like scale.
  int get displayFontSize => (fontSize * 1000).round();

  TextElement copyWith({
    String? id,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? fontSize,
    String? fontFamily,
    int? colorValue,
    bool? isBold,
    bool? isItalic,
    bool? isUnderlined,
    TextAlignmentOption? alignment,
    double? letterSpacing,
    double? lineHeight,
    double? opacity,
    TextShadowStyle? shadow,
  }) {
    return TextElement(
      id: id ?? this.id,
      content: content ?? this.content,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      colorValue: colorValue ?? this.colorValue,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderlined: isUnderlined ?? this.isUnderlined,
      alignment: alignment ?? this.alignment,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      opacity: opacity ?? this.opacity,
      shadow: shadow ?? this.shadow,
    );
  }

  /// Repositions the box by its centre, keeping its size.
  ///
  /// The centre is held inside the page so a box can never be dragged
  /// somewhere the user cannot reach it again — an easy trap to fall
  /// into, and a hard one to recover from.
  TextElement movedToCentre(double centreX, double centreY) {
    final clampedX = centreX.clamp(0.0, 1.0).toDouble();
    final clampedY = centreY.clamp(0.0, 1.0).toDouble();
    return copyWith(
      x: clampedX - width / 2,
      y: clampedY - height / 2,
    );
  }

  /// Scales the box about its own centre, taking the font with it so the
  /// text keeps its proportions instead of re-wrapping mid-drag.
  TextElement scaledBy(double factor) {
    if (factor <= 0) return this;

    final targetWidth = (width * factor).clamp(minWidth, maxWidth).toDouble();
    // Derive the applied factor from the clamped width so height and
    // font stay in step even when the clamp bites.
    final appliedFactor = targetWidth / width;
    final targetHeight = height * appliedFactor;

    return copyWith(
      width: targetWidth,
      height: targetHeight,
      fontSize:
          (fontSize * appliedFactor).clamp(minFontSize, maxFontSize).toDouble(),
      x: centreX - targetWidth / 2,
      y: centreY - targetHeight / 2,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        x,
        y,
        width,
        height,
        rotation,
        fontSize,
        fontFamily,
        colorValue,
        isBold,
        isItalic,
        isUnderlined,
        alignment,
        letterSpacing,
        lineHeight,
        opacity,
        shadow,
      ];
}
