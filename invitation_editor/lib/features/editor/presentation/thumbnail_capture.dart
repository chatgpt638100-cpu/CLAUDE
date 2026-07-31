import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

/// Grabs a picture of the composed canvas for the Library grid.
///
/// The canvas is wrapped in a `RepaintBoundary`; this renders that
/// boundary to a PNG. Capturing the real widget tree, rather than
/// re-drawing the page and text separately, means the thumbnail cannot
/// disagree with what the user was just looking at — rotation, opacity,
/// shadows and stacking order all come along for free.
class ThumbnailCapture {
  const ThumbnailCapture();

  /// Roughly twice the grid's display width, so thumbnails stay crisp on
  /// a high-density screen without storing a full-size page bitmap.
  static const double targetWidth = 400;

  /// Returns null rather than throwing when the boundary is not currently
  /// painted — a thumbnail is a nicety, and failing to make one must never
  /// stop an invitation being saved.
  Future<Uint8List?> capture(GlobalKey boundaryKey) async {
    try {
      final renderObject = boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return null;

      final logicalWidth = renderObject.size.width;
      if (logicalWidth <= 0) return null;

      // Scale so the output lands near targetWidth whatever the screen
      // size, and never upscale a small canvas.
      final pixelRatio = (targetWidth / logicalWidth).clamp(0.5, 3.0);

      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data?.buffer.asUint8List();
      } finally {
        // Released immediately — these are large, and one leaked per save
        // adds up fast during a long editing session.
        image.dispose();
      }
    } catch (_) {
      return null;
    }
  }
}
