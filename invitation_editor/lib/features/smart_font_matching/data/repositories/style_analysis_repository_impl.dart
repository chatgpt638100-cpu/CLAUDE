import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../../../core/theme/app_fonts.dart';
import '../../domain/entities/font_suggestion.dart';
import '../../domain/repositories/style_analysis_repository.dart';

/// Offline lettering analysis, using the `image` package.
///
/// ## What this does and does not do
///
/// It does **not** identify a typeface. Recognising "this is Cormorant
/// Garamond" needs OCR plus a font database, neither of which can run
/// offline in a phone app of this size. Presenting a guess as identification
/// would be dishonest and would erode trust the first time it was wrong.
///
/// What it measures instead is real and stable:
///
/// * **Colour** — the dominant colour of the darkest ink, which is a
///   genuinely accurate match and the most visually important one.
/// * **Stroke consistency** — the spread of horizontal ink run-lengths.
///   Sans-serif letterforms have near-uniform stroke widths; serifs add thin
///   brackets and hairlines, widening the spread; script hands vary more
///   still.
/// * **Ink density** — how much of the page is covered, which separates
///   ordinary lettering from heavy display faces.
///
/// Those three signals map onto four coarse style classes with a stated
/// confidence, and anything unconvincing is reported as [low] so the caller
/// falls back to the app default. That is exactly the behaviour the spec
/// asks for: "If the app can't confidently detect a nearby style… it simply
/// falls back to the app's normal elegant default… this should never feel
/// like a failure state."
class StyleAnalysisRepositoryImpl implements StyleAnalysisRepository {
  const StyleAnalysisRepositoryImpl();

  @override
  Future<FontSuggestion?> analyse(Uint8List pageImageBytes) async {
    // Catches a typo in the style-to-font mapping during development: a
    // family missing from the catalogue would silently render as the
    // fallback serif, making the suggestion a lie. Debug-only, so it costs
    // nothing in release.
    assert(
      isCatalogueConsistent,
      'Every suggested font must exist in AppFonts.catalogue',
    );

    // Decoding and scanning a page is heavy enough to drop frames. Run it on
    // a background isolate so the canvas stays responsive while the
    // "Reading your invitation…" indicator shows.
    final reading = await compute(_analysePage, pageImageBytes);
    if (reading == null || reading.length != 3) return null;

    final styleClass = TextStyleClass.values[reading[0]];

    return FontSuggestion(
      styleClass: styleClass,
      fontFamily: _familyFor(styleClass),
      colorValue: reading[1],
      confidence: SuggestionConfidence.values[reading[2]],
    );
  }

  /// Closest match from the bundled catalogue for each style class.
  static String _familyFor(TextStyleClass styleClass) => switch (styleClass) {
        TextStyleClass.serif => 'Cormorant Garamond',
        TextStyleClass.sansSerif => 'Inter',
        TextStyleClass.script => 'Great Vibes',
        TextStyleClass.decorative => 'Marcellus',
      };

  /// Guards the mapping above: a family that is not in the catalogue would
  /// silently fall back to the app serif, making the suggestion a lie.
  static bool get isCatalogueConsistent => TextStyleClass.values
      .every((style) => AppFonts.catalogue.contains(_familyFor(style)));
}

/// Top-level so it can run under [compute].
///
/// Returns `[styleIndex, colorValue, confidenceIndex]` rather than a custom
/// class: a plain `List<int>` is trivially sendable across the isolate
/// boundary, with no dependence on how a particular Dart version handles
/// sending arbitrary objects.
List<int>? _analysePage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  // Scanned at a fixed modest width: stroke *ratios* are what matter, not
  // absolute pixels, and this bounds the work regardless of upload size.
  final image = decoded.width > _analysisWidth
      ? img.copyResize(decoded, width: _analysisWidth)
      : decoded;

  final width = image.width;
  final height = image.height;
  if (width < 16 || height < 16) return null;

  // First pass: mean brightness, to separate ink from paper without assuming
  // the paper is white — plenty of invitations are cream, kraft or navy.
  var brightnessSum = 0.0;
  var pixelCount = 0;
  for (var y = 0; y < height; y += _sampleStep) {
    for (var x = 0; x < width; x += _sampleStep) {
      brightnessSum += _brightness(image.getPixel(x, y));
      pixelCount++;
    }
  }
  if (pixelCount == 0) return null;
  final meanBrightness = brightnessSum / pixelCount;

  // Ink is meaningfully darker than the page average. On a dark card the
  // lettering is usually lighter, which this pass will not find — reported
  // honestly as low confidence rather than guessed at.
  final inkThreshold = meanBrightness - _inkContrast;

  var inkPixels = 0;
  var redSum = 0, greenSum = 0, blueSum = 0;
  final runLengths = <int>[];

  for (var y = 0; y < height; y++) {
    var run = 0;
    for (var x = 0; x < width; x++) {
      final pixel = image.getPixel(x, y);
      final isInk = _brightness(pixel) < inkThreshold;

      if (isInk) {
        run++;
        inkPixels++;
        redSum += pixel.r.toInt();
        greenSum += pixel.g.toInt();
        blueSum += pixel.b.toInt();
      } else if (run > 0) {
        // Runs the width of a letter stroke. Anything longer is a rule, a
        // border or a block of artwork, and would swamp the statistic.
        if (run >= _minRun && run <= _maxRun) runLengths.add(run);
        run = 0;
      }
    }
    if (run >= _minRun && run <= _maxRun) runLengths.add(run);
  }

  final totalPixels = width * height;
  final inkRatio = inkPixels / totalPixels;

  // Too little ink to be lettering, or so much that the page is artwork
  // rather than type.
  if (runLengths.length < _minSamples ||
      inkRatio < _minInkRatio ||
      inkRatio > _maxInkRatio) {
    return null;
  }

  final colorValue = 0xFF000000 |
      ((redSum ~/ inkPixels) << 16) |
      ((greenSum ~/ inkPixels) << 8) |
      (blueSum ~/ inkPixels);

  // Coefficient of variation of stroke widths: scale-free, so it reads the
  // same on a small thumbnail and a large scan.
  final mean = runLengths.reduce((a, b) => a + b) / runLengths.length;
  if (mean <= 0) return null;
  final variance = runLengths
          .map((run) => (run - mean) * (run - mean))
          .reduce((a, b) => a + b) /
      runLengths.length;
  final spread = math.sqrt(variance) / mean;

  final TextStyleClass styleClass;
  if (inkRatio > _decorativeInkRatio) {
    styleClass = TextStyleClass.decorative;
  } else if (spread < _sansSpread) {
    styleClass = TextStyleClass.sansSerif;
  } else if (spread < _serifSpread) {
    styleClass = TextStyleClass.serif;
  } else {
    styleClass = TextStyleClass.script;
  }

  // Confident when there is plenty of lettering to measure and the reading
  // is not sitting on a boundary between two classes.
  final distanceFromBoundary = [
    (spread - _sansSpread).abs(),
    (spread - _serifSpread).abs(),
  ].reduce(math.min);

  final SuggestionConfidence confidence;
  if (runLengths.length >= _strongSamples &&
      distanceFromBoundary >= _clearMargin) {
    confidence = SuggestionConfidence.high;
  } else if (runLengths.length >= _minSamples * 2) {
    confidence = SuggestionConfidence.medium;
  } else {
    confidence = SuggestionConfidence.low;
  }

  return <int>[styleClass.index, colorValue, confidence.index];
}

double _brightness(img.Pixel pixel) {
  // Rec. 601 luma, matching how the eye weights the channels, normalised to
  // 0..1 so the thresholds below are resolution and format independent.
  return (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b) / 255.0;
}

const int _analysisWidth = 600;
const int _sampleStep = 4;
const double _inkContrast = 0.18;
const int _minRun = 1;
const int _maxRun = 30;
const int _minSamples = 60;
const int _strongSamples = 400;
const double _minInkRatio = 0.002;
const double _maxInkRatio = 0.60;
const double _decorativeInkRatio = 0.22;
const double _sansSpread = 0.42;
const double _serifSpread = 0.78;
const double _clearMargin = 0.08;
