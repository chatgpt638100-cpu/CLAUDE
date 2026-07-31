import 'dart:typed_data';

import '../entities/font_suggestion.dart';

/// Domain contract for reading the lettering style off an invitation image.
///
/// Entirely offline and never networked. Returns null when nothing
/// text-like could be found — a blank card, or artwork that is all
/// photograph — which the caller treats as "use the app default", not as an
/// error.
abstract class StyleAnalysisRepository {
  Future<FontSuggestion?> analyse(Uint8List pageImageBytes);
}
