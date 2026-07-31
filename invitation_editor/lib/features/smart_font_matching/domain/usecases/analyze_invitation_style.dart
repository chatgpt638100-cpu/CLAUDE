import 'dart:typed_data';

import '../entities/font_suggestion.dart';
import '../repositories/style_analysis_repository.dart';

/// Reads an uploaded invitation and suggests matching text styling
/// (Feature 6.2 — Smart Font Matching).
///
/// Never throws: analysis is a convenience, and a failed guess must not
/// interrupt someone who only wanted to add a name. A null result means
/// "carry on with the app's normal default".
class AnalyzeInvitationStyle {
  final StyleAnalysisRepository repository;

  const AnalyzeInvitationStyle(this.repository);

  Future<FontSuggestion?> call(Uint8List pageImageBytes) async {
    try {
      final suggestion = await repository.analyse(pageImageBytes);
      // An unconfident reading is treated as no reading at all, so the
      // formatting panel never presents a guess it does not stand behind.
      return (suggestion?.isUsable ?? false) ? suggestion : null;
    } catch (_) {
      return null;
    }
  }
}
