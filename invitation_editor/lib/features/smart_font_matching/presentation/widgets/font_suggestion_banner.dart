import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../domain/entities/font_suggestion.dart';

/// The "Suggested to match your invitation" tag inside the formatting panel
/// (Feature 6.2).
///
/// Shows what was read, how sure the app is, and applies it in one tap.
/// Nothing is changed without that tap: per the design principle for both
/// smart features, the behaviour has to be "visible and reversible through
/// the same simple controls" — never a hidden automation.
class FontSuggestionBanner extends StatelessWidget {
  final FontSuggestion suggestion;

  /// True once the text box already matches the suggestion, so the button
  /// stops offering something that would do nothing.
  final bool isApplied;

  final VoidCallback onApply;

  const FontSuggestionBanner({
    super.key,
    required this.suggestion,
    required this.isApplied,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceL),
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 20,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(width: AppDimensions.spaceS),
              Expanded(
                child: Text(
                  'Suggested to match your invitation',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Row(
            children: [
              // Previewed in the suggested font itself, so the choice can be
              // judged rather than taken on trust.
              Expanded(
                child: Text(
                  suggestion.fontFamily,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.resolve(
                    suggestion.fontFamily,
                    TextStyle(
                      fontSize: 20,
                      color: Color(suggestion.colorValue),
                    ),
                  ),
                ),
              ),
              _ColourDot(colorValue: suggestion.colorValue),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            '${_styleLabel(suggestion.styleClass)} lettering · '
            '${_confidenceLabel(suggestion.confidence)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: isApplied ? null : onApply,
              icon: Icon(isApplied ? Icons.check : Icons.brush_outlined),
              label: Text(isApplied ? 'Applied' : 'Use this style'),
            ),
          ),
        ],
      ),
    );
  }

  static String _styleLabel(TextStyleClass styleClass) => switch (styleClass) {
        TextStyleClass.serif => 'Serif',
        TextStyleClass.sansSerif => 'Sans serif',
        TextStyleClass.script => 'Script',
        TextStyleClass.decorative => 'Decorative',
      };

  /// Plain words rather than a percentage: "72% confident" invites a
  /// precision the analysis does not have.
  static String _confidenceLabel(SuggestionConfidence confidence) =>
      switch (confidence) {
        SuggestionConfidence.high => 'a close match',
        SuggestionConfidence.medium => 'a rough match',
        SuggestionConfidence.low => 'not sure',
      };
}

class _ColourDot extends StatelessWidget {
  final int colorValue;

  const _ColourDot({required this.colorValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.colourSwatchSize,
      height: AppDimensions.colourSwatchSize,
      decoration: BoxDecoration(
        color: Color(colorValue),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

/// The "Reading your invitation…" indicator (Feature 6.2) — a calm pulsing
/// gold dot, shown briefly while analysis runs and never blocking anything.
class ReadingInvitationIndicator extends StatelessWidget {
  const ReadingInvitationIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceL),
      child: Row(
        children: [
          const SizedBox(
            width: AppDimensions.loaderDotSize,
            height: AppDimensions.loaderDotSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Text(
            'Reading your invitation…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
