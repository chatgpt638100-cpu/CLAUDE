import 'package:equatable/equatable.dart';

/// A single text box placed on an invitation (Screen 4).
///
/// All geometry is stored **normalised to the page**, not in screen
/// pixels: `x`/`y`/`width`/`height` are fractions of the page's width
/// and height, and `fontSize` is a fraction of the page height. That
/// keeps a layout identical across phone sizes, survives zooming, and
/// lets a later export phase multiply straight through to PDF point
/// sizes without re-deriving anything.
///
/// Pure domain object — no Flutter types (hence plain doubles rather
/// than `Offset`/`Size`, which live in `dart:ui`).
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

  const TextElement({
    required this.id,
    required this.content,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    required this.fontSize,
  });

  // Defaults for a freshly added box: a little over half the page wide,
  // comfortably readable, unrotated.
  static const double defaultWidth = 0.55;
  static const double defaultHeight = 0.14;
  static const double defaultFontSize = 0.05;

  // Limits applied when resizing, so a box can never be scaled into
  // something invisible or absurdly larger than the page.
  static const double minWidth = 0.08;
  static const double maxWidth = 1.6;
  static const double minFontSize = 0.015;
  static const double maxFontSize = 0.4;

  /// A new box centred on the given point, using the default size.
  factory TextElement.centredAt({
    required String id,
    required String content,
    required double centreX,
    required double centreY,
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
    );
  }

  double get centreX => x + width / 2;

  double get centreY => y + height / 2;

  TextElement copyWith({
    String? id,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? fontSize,
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

    return copyWith(
      width: targetWidth,
      height: height * appliedFactor,
      fontSize:
          (fontSize * appliedFactor).clamp(minFontSize, maxFontSize).toDouble(),
      x: centreX - targetWidth / 2,
      y: centreY - (height * appliedFactor) / 2,
    );
  }

  @override
  List<Object?> get props =>
      [id, content, x, y, width, height, rotation, fontSize];
}
