import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/repositories/voice_input_repository.dart';

/// [VoiceInputRepository] backed by the `speech_to_text` package.
///
/// The only place in the app that knows about that package.
///
/// Recognition is requested with `onDevice: true`. That is not merely a
/// preference: with no INTERNET permission a network recogniser would fail,
/// so forcing on-device turns a confusing mid-dictation failure into a
/// clear "not available on this phone" before listening starts.
class VoiceInputRepositoryImpl implements VoiceInputRepository {
  final SpeechToText _speech = SpeechToText();

  bool _isInitialised = false;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> initialise() async {
    if (_isInitialised) return _speech.isAvailable;

    try {
      // Also triggers the microphone permission prompt on first use.
      _isInitialised = await _speech.initialize(
        // Errors and status changes during setup are surfaced per-session
        // in [start] instead, where there is a listener to tell.
        onError: (_) {},
        onStatus: (_) {},
        debugLogging: false,
      );
      return _isInitialised;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> start({
    required void Function(String transcript, bool isFinal) onTranscript,
    required void Function(String message) onError,
  }) async {
    final available = await initialise();
    if (!available) {
      onError(
        'Voice typing needs microphone permission. You can still type '
        'instead.',
      );
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) => onTranscript(
          result.recognizedWords,
          result.finalResult,
        ),
        listenOptions: SpeechListenOptions(
          onDevice: true,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
    } on SpeechRecognitionError catch (_) {
      onError(_unavailableMessage);
    } catch (_) {
      onError(_unavailableMessage);
    }
  }

  /// Warm and non-technical, per the spec's tone. Never mentions engines,
  /// locales or permissions APIs.
  static const String _unavailableMessage =
      'Voice typing is not available on this phone. You can still type '
      'instead.';

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {
      // Already stopped, or the engine went away — nothing the user needs
      // to hear about.
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (_) {
      // As above.
    }
  }
}
