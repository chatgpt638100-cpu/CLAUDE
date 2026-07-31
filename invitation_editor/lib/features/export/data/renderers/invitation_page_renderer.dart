import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../editor/domain/entities/text_element.dart';
import '../../../editor/presentation/text_element_style.dart';
import '../../../library/domain/entities/invitation_project.dart';

/// Composes an invitation into a single high-resolution bitmap, ready to be
/// wrapped in a PDF.
///
/// ## Why re-render rather than screenshot the canvas
///
/// Capturing the on-screen widget would cap output at whatever the phone
/// was displaying — a few hundred logical pixels wide, which prints badly.
/// Drawing to an offscreen [ui.Canvas] instead means the output resolution
/// is chosen for paper, not for the screen, and export works from anywhere
/// without the Editor being open.
///
/// Text is painted with [TextPainter] using the *same* style mapper the
/// canvas uses, so fonts, colours, spacing, shadows, opacity, alignment and
/// rotation come out identical to what the user approved on screen.
class InvitationPageRenderer {
  const InvitationPageRenderer();

  /// Longest edge of the rendered bitmap, in pixels.
  ///
  /// 2400px across A4's long edge is roughly 200dpi — comfortably past the
  /// point where home-printed text looks soft, while staying well inside
  /// the memory a mid-range phone can spare for one image.
  static const double targetLongEdgePx = 2400;

  /// Resolution the PDF page size is derived from, so the page measures
  /// correctly in millimetres instead of being scaled arbitrarily.
  static const double outputDpi = 200;

  /// [pageImageBytes] is the already-rasterised source page, or null for a
  /// blank card.
  Future<RenderedPage> render(
    InvitationProject project, {
    Uint8List? pageImageBytes,
  }) async {
    final size = _outputSize(project);

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
    );

    // Paper is white even where the artwork does not reach, so a source
    // image with a different aspect ratio does not export with black bars.
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.width, size.height),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );

    ui.Image? pageImage;
    try {
      if (pageImageBytes != null) {
        pageImage = await _decode(pageImageBytes);
        _drawPageImage(canvas, pageImage, size);
      }

      for (final element in project.textElements) {
        _drawTextElement(canvas, element, size);
      }
    } finally {
      // Released as soon as it has been painted; a full-page bitmap held a
      // moment too long is exactly what pushes an export over the limit.
      pageImage?.dispose();
    }

    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(
        size.width.round(),
        size.height.round(),
      );
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) {
          throw StateError('Rendered page produced no bytes');
        }
        return RenderedPage(
          pngBytes: data.buffer.asUint8List(),
          widthPx: image.width,
          heightPx: image.height,
        );
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  /// Scales the project's page proportions up to [targetLongEdgePx],
  /// never beyond, so a portrait and a landscape invitation both come out
  /// at a sensible size.
  ui.Size _outputSize(InvitationProject project) {
    final aspect = project.pageAspectRatio;
    if (aspect >= 1) {
      return ui.Size(targetLongEdgePx, targetLongEdgePx / aspect);
    }
    return ui.Size(targetLongEdgePx * aspect, targetLongEdgePx);
  }

  Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  /// Fits the artwork inside the page the same way `BoxFit.contain` does on
  /// the canvas, so what was on screen is what gets printed.
  void _drawPageImage(ui.Canvas canvas, ui.Image image, ui.Size size) {
    final scale = math.min(
      size.width / image.width,
      size.height / image.height,
    );
    final drawWidth = image.width * scale;
    final drawHeight = image.height * scale;

    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(
        (size.width - drawWidth) / 2,
        (size.height - drawHeight) / 2,
        drawWidth,
        drawHeight,
      ),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
  }

  void _drawTextElement(
    ui.Canvas canvas,
    TextElement element,
    ui.Size size,
  ) {
    // Geometry is stored normalised, so it multiplies straight up to the
    // output resolution with no separate export layout to keep in step.
    final boxWidth = element.width * size.width;
    final centreX = element.centreX * size.width;
    final centreY = element.centreY * size.height;
    final fontSizePx = element.fontSize * size.height;

    if (boxWidth <= 0 || fontSizePx <= 0) return;

    final painter = TextPainter(
      text: TextSpan(
        text: element.content,
        style: element.toTextStyle(fontSizePx: fontSizePx),
      ),
      textAlign: element.textAlign,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: boxWidth, maxWidth: boxWidth);

    canvas.save();
    canvas.translate(centreX, centreY);
    canvas.rotate(element.rotation);

    // Opacity is applied to a layer rather than baked into the colour, so
    // the drop shadow fades with the text instead of staying solid.
    final needsLayer = element.opacity < 1;
    if (needsLayer) {
      canvas.saveLayer(
        ui.Rect.fromCenter(
          center: ui.Offset.zero,
          // Generous bounds so a shadow is never clipped at the edge.
          width: boxWidth * 2,
          height: (painter.height + fontSizePx) * 2,
        ),
        ui.Paint()
          ..color = ui.Color.fromRGBO(
            0,
            0,
            0,
            // toDouble() matters: num.clamp returns num.
            element.opacity.clamp(0.0, 1.0).toDouble(),
          ),
      );
    }

    // Painted from the top-left of the text block, offset so the block sits
    // centred on the element's centre — matching the canvas, which centres
    // text vertically inside the box.
    painter.paint(canvas, ui.Offset(-boxWidth / 2, -painter.height / 2));

    if (needsLayer) canvas.restore();
    canvas.restore();

    painter.dispose();
  }
}

/// The composed bitmap plus its true pixel size, which the PDF needs to
/// work out the page dimensions.
class RenderedPage {
  final Uint8List pngBytes;
  final int widthPx;
  final int heightPx;

  const RenderedPage({
    required this.pngBytes,
    required this.widthPx,
    required this.heightPx,
  });

  /// Page width in PDF points at the renderer's output dpi.
  double get widthPt =>
      widthPx / InvitationPageRenderer.outputDpi * _pdfPointsPerInch;

  double get heightPt =>
      heightPx / InvitationPageRenderer.outputDpi * _pdfPointsPerInch;
}

/// PDF's fixed unit: 72 points to the inch.
const double _pdfPointsPerInch = 72;
