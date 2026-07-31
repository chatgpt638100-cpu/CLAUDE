import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/usecases/apply_voice_input.dart';
import '../../../../injection/service_locator.dart';
import '../providers/voice_input_provider.dart';

/// The microphone, plus the live caption strip and retry prompt that go with
/// it (Screen 4 — voice typing).
///
/// Sits inside the text dialog rather than in a menu, because the spec is
/// explicit that voice typing belongs "exactly where text is created". While
/// listening the mic turns solid gold and pulses; the words appear above it
/// as they are recognised.
///
/// [onTranscript] receives the finished text already merged with whatever
/// was in the field.
class VoiceInputControl extends ConsumerWidget {
  /// Current field contents, so dictation adds to them rather than
  /// replacing them.
  final String currentText;

  final ValueChanged<String> onTranscript;

  const VoiceInputControl({
    super.key,
    required this.currentText,
    required this.onTranscript,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(voiceInputProvider);
    final notifier = ref.read(voiceInputProvider.notifier);

    // Hand the finished words back once a session settles with something to
    // show, then clear so the next tap starts fresh.
    ref.listen(voiceInputProvider, (previous, next) {
      final wasListening = previous?.isListening ?? false;
      if (wasListening &&
          next.status == VoiceInputStatus.idle &&
          next.transcript.trim().isNotEmpty) {
        onTranscript(
          sl<ApplyVoiceInput>()(
            existing: currentText,
            transcript: next.transcript,
          ),
        );
        notifier.reset();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (voice.isListening && voice.transcript.isNotEmpty)
          _CaptionStrip(text: voice.transcript),
        if (voice.status == VoiceInputStatus.heardNothing)
          _RetryPrompt(onRetry: notifier.startListening),
        if (voice.status == VoiceInputStatus.unavailable &&
            voice.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
            child: Text(
              voice.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: _MicButton(
            isListening: voice.isListening,
            onPressed: () {
              // A brief tap confirms the mic changed state, which matters
              // when the room is noisy and nothing is on screen yet.
              HapticFeedback.selectionClick();
              if (voice.isListening) {
                notifier.stopListening();
              } else {
                notifier.startListening();
              }
            },
          ),
        ),
      ],
    );
  }
}

/// Live transcription, shown above the mic as the words arrive.
class _CaptionStrip extends StatelessWidget {
  final String text;

  const _CaptionStrip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      padding: const EdgeInsets.all(AppDimensions.spaceS),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// The spec's exact wording for silence — a question, not an error.
class _RetryPrompt extends StatelessWidget {
  final VoidCallback onRetry;

  const _RetryPrompt({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "I didn't catch that — try again?",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Solid gold and gently pulsing while listening, outlined when idle.
/// Always paired with a text label.
class _MicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const _MicButton({required this.isListening, required this.onPressed});

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppDimensions.animationPulse,
  );

  @override
  void initState() {
    super.initState();
    if (widget.isListening) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Driven by state rather than started once, so stopping mid-session
    // actually settles the animation instead of leaving it running.
    if (widget.isListening && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isListening && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.isListening;

    return FadeTransition(
      opacity: isListening
          ? Tween<double>(begin: 0.55, end: 1).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            )
          // Explicit type argument: without it this infers
          // AlwaysStoppedAnimation<int>, which FadeTransition rejects.
          : const AlwaysStoppedAnimation<double>(1),
      child: TextButton.icon(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isListening
              ? AppColors.primaryAccent
              : Colors.transparent,
          foregroundColor: isListening
              ? AppColors.secondaryAccent
              : AppColors.primaryAccent,
          minimumSize: const Size(0, AppDimensions.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            side: BorderSide(
              color: AppColors.primaryAccent.withValues(
                alpha: isListening ? 1 : 0.6,
              ),
            ),
          ),
        ),
        icon: Icon(isListening ? Icons.stop : Icons.mic_none),
        label: Text(isListening ? 'Done' : 'Speak'),
      ),
    );
  }
}
