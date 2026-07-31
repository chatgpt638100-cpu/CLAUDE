import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/service_locator.dart';
import '../../domain/repositories/voice_input_repository.dart';

/// Where a dictation session currently stands.
enum VoiceInputStatus { idle, listening, unavailable, heardNothing }

/// Immutable view of the microphone.
class VoiceInputState {
  final VoiceInputStatus status;

  /// What has been heard so far, updated live while listening.
  final String transcript;

  final String? errorMessage;

  const VoiceInputState({
    this.status = VoiceInputStatus.idle,
    this.transcript = '',
    this.errorMessage,
  });

  bool get isListening => status == VoiceInputStatus.listening;

  VoiceInputState copyWith({
    VoiceInputStatus? status,
    String? transcript,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoiceInputState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Drives the microphone for the text dialog (Screen 4 — voice typing).
///
/// Auto-disposed, and cancels any live session on dispose: a recogniser left
/// running after its dialog closed would hold the microphone and keep
/// draining battery.
class VoiceInputNotifier extends AutoDisposeNotifier<VoiceInputState> {
  VoiceInputRepository get _repository => sl<VoiceInputRepository>();

  @override
  VoiceInputState build() {
    ref.onDispose(() {
      if (_repository.isListening) _repository.cancel();
    });
    return const VoiceInputState();
  }

  Future<void> startListening() async {
    if (state.isListening) return;

    state = const VoiceInputState(status: VoiceInputStatus.listening);

    await _repository.start(
      onTranscript: (transcript, isFinal) {
        // Guard against a late callback arriving after the dialog closed.
        if (!ref.mounted) return;
        state = state.copyWith(transcript: transcript);
        if (isFinal) _settle();
      },
      onError: (message) {
        if (!ref.mounted) return;
        state = state.copyWith(
          status: VoiceInputStatus.unavailable,
          errorMessage: message,
        );
      },
    );
  }

  Future<void> stopListening() async {
    await _repository.stop();
    if (!ref.mounted) return;
    _settle();
  }

  /// Silence gets the spec's warm retry prompt rather than an error.
  void _settle() {
    if (state.transcript.trim().isEmpty) {
      state = state.copyWith(status: VoiceInputStatus.heardNothing);
      return;
    }
    state = state.copyWith(status: VoiceInputStatus.idle);
  }

  /// Clears the last result so the same dialog can dictate again.
  void reset() {
    state = const VoiceInputState();
  }
}

final voiceInputProvider =
    AutoDisposeNotifierProvider<VoiceInputNotifier, VoiceInputState>(
  VoiceInputNotifier.new,
);
