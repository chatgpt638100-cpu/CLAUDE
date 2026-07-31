import '../entities/editor_canvas.dart';
import '../entities/text_element.dart';
import '../entities/text_format.dart';

/// Restyles a text box (Screen 4 — the formatting panel). This is the
/// `FormatText` use case named in project-architecture.pdf, Section 2.
///
/// One use case covers every property rather than a dozen near-identical
/// ones: each is a single field assignment guarded by the same clamps,
/// and splitting them would multiply files without adding a rule. Any
/// argument left null means "leave that property alone".
///
/// Every numeric value is clamped here, in the domain, so no caller can
/// produce an illegible or invisible text box.
class FormatTextElement {
  const FormatTextElement();

  EditorCanvas call(
    EditorCanvas canvas, {
    required String id,
    String? fontFamily,
    double? fontSize,
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
    return canvas.copyWith(
      elements: [
        for (final element in canvas.elements)
          if (element.id == id)
            element.copyWith(
              fontFamily: fontFamily,
              colorValue: colorValue,
              isBold: isBold,
              isItalic: isItalic,
              isUnderlined: isUnderlined,
              alignment: alignment,
              shadow: shadow,
              fontSize: fontSize == null
                  ? null
                  : fontSize
                      .clamp(TextElement.minFontSize, TextElement.maxFontSize)
                      .toDouble(),
              letterSpacing: letterSpacing == null
                  ? null
                  : letterSpacing
                      .clamp(
                        TextElement.minLetterSpacing,
                        TextElement.maxLetterSpacing,
                      )
                      .toDouble(),
              lineHeight: lineHeight == null
                  ? null
                  : lineHeight
                      .clamp(
                        TextElement.minLineHeight,
                        TextElement.maxLineHeight,
                      )
                      .toDouble(),
              opacity: opacity == null
                  ? null
                  : opacity
                      .clamp(TextElement.minOpacity, TextElement.maxOpacity)
                      .toDouble(),
            )
          else
            element,
      ],
    );
  }
}
