/// Domain contract for on-device speech recognition (Screen 4 — "Voice
/// Type").
///
/// Which engine does the work stays in the data layer. Implementations must
/// recognise **on-device only**: the app ships without INTERNET permission,
/// so a cloud recogniser could not work even if one were wired up.
abstract class VoiceInputRepository {
  /// Prepares the recogniser and asks for microphone permission if it has
  /// not been granted.
  ///
  /// Returns false when voice typing is unavailable — permission refused,
  /// or no on-device recogniser installed. Callers treat that as "offer
  /// typing instead", never as a crash.
  Future<bool> initialise();

  /// Begins listening.
  ///
  /// [onTranscript] fires repeatedly as words are recognised, with
  /// `isFinal` true on the last result. [onError] carries wording already
  /// fit to show a user.
  Future<void> start({
    required void Function(String transcript, bool isFinal) onTranscript,
    required void Function(String message) onError,
  });

  /// Stops listening and keeps whatever was heard.
  Future<void> stop();

  /// Stops listening and discards the result.
  Future<void> cancel();

  bool get isListening;
}
