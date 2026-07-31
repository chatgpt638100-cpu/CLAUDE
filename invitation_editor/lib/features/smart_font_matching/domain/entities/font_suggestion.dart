import 'package:equatable/equatable.dart';

/// Broad families of lettering the analyser can tell apart.
///
/// Deliberately four coarse buckets rather than named fonts. Identifying an
/// actual typeface from a photograph needs OCR and a font database; what can
/// be measured honestly offline is the *character* of the strokes. Being
/// upfront about that is what keeps the suggestion trustworthy.
enum TextStyleClass { serif, sansSerif, script, decorative }

/// How much the analyser trusts its own answer.
///
/// [low] means "do not preset anything" — the spec is explicit that an
/// uncertain guess should quietly fall back to the app's normal default
/// rather than presenting itself as a finding.
enum SuggestionConfidence { low, medium, high }

/// The analyser's reading of an uploaded invitation (Feature 6.2 — Smart
/// Font Matching).
class FontSuggestion extends Equatable {
  final TextStyleClass styleClass;

  /// Closest match from the app's bundled catalogue.
  final String fontFamily;

  /// Dominant colour of the existing lettering, as ARGB.
  final int colorValue;

  final SuggestionConfidence confidence;

  const FontSuggestion({
    required this.styleClass,
    required this.fontFamily,
    required this.colorValue,
    required this.confidence,
  });

  /// Worth showing to the user at all.
  bool get isUsable => confidence != SuggestionConfidence.low;

  @override
  List<Object?> get props => [styleClass, fontFamily, colorValue, confidence];
}
