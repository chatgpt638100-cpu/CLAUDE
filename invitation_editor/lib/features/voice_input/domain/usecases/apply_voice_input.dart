/// Works out what a text box should say once dictation finishes (Screen 4
/// — "text is inserted into the box").
///
/// Appends rather than replaces, so speaking after already typing adds to
/// the line instead of wiping it — losing text someone has just written is
/// the worse mistake of the two. Spacing is tidied so the result never has
/// a double space or a leading gap.
class ApplyVoiceInput {
  const ApplyVoiceInput();

  String call({required String existing, required String transcript}) {
    final spoken = transcript.trim();
    if (spoken.isEmpty) return existing;

    final current = existing.trim();
    if (current.isEmpty) return spoken;

    return '$current $spoken';
  }
}
