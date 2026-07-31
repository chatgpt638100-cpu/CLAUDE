import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../smart_font_matching/domain/entities/font_suggestion.dart';
import '../../../smart_font_matching/presentation/providers/font_suggestion_provider.dart';
import '../../../smart_font_matching/presentation/widgets/font_suggestion_banner.dart';
import '../../domain/entities/invitation_source_file.dart';
import '../../domain/entities/text_element.dart';
import '../../domain/entities/text_format.dart';
import '../providers/editor_canvas_provider.dart';
import '../text_element_style.dart';
import 'font_picker_sheet.dart';
import 'formatting_controls.dart';
import 'text_colour_picker.dart';

/// The formatting panel (Screen 4).
///
/// Sits in the layout beneath the canvas rather than floating over it as
/// a modal sheet. That is deliberate: a modal would cover the very text
/// being restyled, and the spec asks for live preview. Here the canvas
/// simply gets shorter, the selected box stays in view, and every change
/// lands on it immediately.
///
/// Reads the element straight from the provider on each build, so the
/// preview and the controls always reflect committed state — there is no
/// second copy of the styling to fall out of step.
class FormattingPanel extends ConsumerWidget {
  final String elementId;

  /// The invitation being edited, so Smart Font Matching can offer a style
  /// read from its artwork. Null on a blank card, where there is nothing to
  /// read.
  final InvitationSourceFile? sourceFile;

  final VoidCallback onClose;

  const FormattingPanel({
    super.key,
    required this.elementId,
    required this.sourceFile,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvas = ref.watch(editorCanvasProvider);
    final element = canvas.selectedElement;

    // The box can disappear underneath the panel — deleted, or undone —
    // in which case there is nothing left to format.
    if (element == null || element.id != elementId) {
      return const SizedBox.shrink();
    }

    final notifier = ref.read(editorCanvasProvider.notifier);

    void format({
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
      notifier.format(
        id: element.id,
        fontFamily: fontFamily,
        fontSize: fontSize,
        colorValue: colorValue,
        isBold: isBold,
        isItalic: isItalic,
        isUnderlined: isUnderlined,
        alignment: alignment,
        letterSpacing: letterSpacing,
        lineHeight: lineHeight,
        opacity: opacity,
        shadow: shadow,
      );
    }

    return Material(
      color: AppColors.cardSurface,
      elevation: 8,
      shadowColor: AppColors.secondaryAccent.withValues(alpha: 0.2),
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.cardRadius),
      ),
      child: SizedBox(
        height: _panelHeight(context),
        child: Column(
          children: [
            _Header(onClose: onClose),
            const Divider(height: 1),
            _LivePreview(element: element),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spaceM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SmartSuggestion(
                      sourceFile: sourceFile,
                      element: element,
                      onApply: (suggestion) => format(
                        fontFamily: suggestion.fontFamily,
                        colorValue: suggestion.colorValue,
                      ),
                    ),
                    FormattingSection(
                      label: 'Font',
                      child: _FontRow(
                        element: element,
                        onPick: (family) => format(fontFamily: family),
                      ),
                    ),
                    FormattingSection(
                      label: 'Size',
                      child: FormattingStepper(
                        semanticLabel: 'Font size',
                        valueLabel: '${element.displayFontSize}',
                        onDecrease: element.fontSize > TextElement.minFontSize
                            ? () => format(
                                  fontSize: element.fontSize -
                                      TextElement.fontSizeStep,
                                )
                            : null,
                        onIncrease: element.fontSize < TextElement.maxFontSize
                            ? () => format(
                                  fontSize: element.fontSize +
                                      TextElement.fontSizeStep,
                                )
                            : null,
                      ),
                    ),
                    FormattingSection(
                      label: 'Colour',
                      child: TextColourPicker(
                        selectedColorValue: element.colorValue,
                        onColourSelected: (value) =>
                            format(colorValue: value),
                      ),
                    ),
                    FormattingSection(
                      label: 'Alignment',
                      child: Wrap(
                        spacing: AppDimensions.spaceS,
                        runSpacing: AppDimensions.spaceS,
                        children: [
                          for (final option in TextAlignmentOption.values)
                            FormattingChip(
                              label: _alignmentLabel(option),
                              icon: _alignmentIcon(option),
                              isSelected: element.alignment == option,
                              onPressed: () => format(alignment: option),
                            ),
                        ],
                      ),
                    ),
                    FormattingSection(
                      label: 'Style',
                      child: Wrap(
                        spacing: AppDimensions.spaceS,
                        runSpacing: AppDimensions.spaceS,
                        children: [
                          FormattingChip(
                            label: 'Bold',
                            isSelected: element.isBold,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                            onPressed: () => format(isBold: !element.isBold),
                          ),
                          FormattingChip(
                            label: 'Italic',
                            isSelected: element.isItalic,
                            labelStyle: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                            onPressed: () =>
                                format(isItalic: !element.isItalic),
                          ),
                          FormattingChip(
                            label: 'Underline',
                            isSelected: element.isUnderlined,
                            labelStyle: const TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                            onPressed: () =>
                                format(isUnderlined: !element.isUnderlined),
                          ),
                        ],
                      ),
                    ),
                    FormattingSection(
                      label: 'Letter spacing',
                      child: FormattingStepper(
                        semanticLabel: 'Letter spacing',
                        valueLabel: _percentLabel(element.letterSpacing),
                        onDecrease:
                            element.letterSpacing > TextElement.minLetterSpacing
                                ? () => format(
                                      letterSpacing: element.letterSpacing -
                                          TextElement.letterSpacingStep,
                                    )
                                : null,
                        onIncrease:
                            element.letterSpacing < TextElement.maxLetterSpacing
                                ? () => format(
                                      letterSpacing: element.letterSpacing +
                                          TextElement.letterSpacingStep,
                                    )
                                : null,
                      ),
                    ),
                    FormattingSection(
                      label: 'Line spacing',
                      child: FormattingStepper(
                        semanticLabel: 'Line spacing',
                        valueLabel: element.lineHeight.toStringAsFixed(1),
                        onDecrease:
                            element.lineHeight > TextElement.minLineHeight
                                ? () => format(
                                      lineHeight: element.lineHeight -
                                          TextElement.lineHeightStep,
                                    )
                                : null,
                        onIncrease:
                            element.lineHeight < TextElement.maxLineHeight
                                ? () => format(
                                      lineHeight: element.lineHeight +
                                          TextElement.lineHeightStep,
                                    )
                                : null,
                      ),
                    ),
                    FormattingSection(
                      label: 'Opacity',
                      child: FormattingStepper(
                        semanticLabel: 'Opacity',
                        valueLabel:
                            '${(element.opacity * 100).round()}%',
                        onDecrease: element.opacity > TextElement.minOpacity
                            ? () => format(
                                  opacity:
                                      element.opacity - TextElement.opacityStep,
                                )
                            : null,
                        onIncrease: element.opacity < TextElement.maxOpacity
                            ? () => format(
                                  opacity:
                                      element.opacity + TextElement.opacityStep,
                                )
                            : null,
                      ),
                    ),
                    FormattingSection(
                      label: 'Shadow',
                      child: Wrap(
                        spacing: AppDimensions.spaceS,
                        runSpacing: AppDimensions.spaceS,
                        children: [
                          for (final option in TextShadowStyle.values)
                            FormattingChip(
                              label: _shadowLabel(option),
                              isSelected: element.shadow == option,
                              onPressed: () => format(shadow: option),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tall enough to be usable, capped so the canvas above never shrinks
  /// to nothing on a small screen.
  double _panelHeight(BuildContext context) {
    final available = MediaQuery.sizeOf(context).height;
    final half = available * 0.46;
    return half.clamp(240.0, 420.0).toDouble();
  }

  static String _alignmentLabel(TextAlignmentOption option) =>
      switch (option) {
        TextAlignmentOption.left => 'Left',
        TextAlignmentOption.centre => 'Centre',
        TextAlignmentOption.right => 'Right',
      };

  static IconData _alignmentIcon(TextAlignmentOption option) =>
      switch (option) {
        TextAlignmentOption.left => Icons.format_align_left,
        TextAlignmentOption.centre => Icons.format_align_center,
        TextAlignmentOption.right => Icons.format_align_right,
      };

  static String _shadowLabel(TextShadowStyle style) => switch (style) {
        TextShadowStyle.none => 'None',
        TextShadowStyle.soft => 'Soft',
        TextShadowStyle.strong => 'Strong',
      };

  /// Letter spacing is stored as a fraction of the font size; shown as a
  /// percentage because "0.03" means nothing to a reader.
  static String _percentLabel(double value) =>
      '${(value * 100).round()}%';
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceM,
        AppDimensions.spaceS,
        AppDimensions.spaceS,
        AppDimensions.spaceS,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Text style',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.check),
            label: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

/// Shows the user's own words in the style being edited, at a fixed
/// readable size.
///
/// The canvas already updates live, but the selected box may be small,
/// rotated or partly behind another box. This gives an unambiguous,
/// upright reading of the current style — rendered through the same
/// mapper that paints the canvas, so it cannot disagree with it.
class _LivePreview extends StatelessWidget {
  final TextElement element;

  const _LivePreview({required this.element});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.formattingPreviewHeight,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AnimatedDefaultTextStyle(
            duration: AppDimensions.animationFast,
            curve: Curves.easeInOut,
            style: element.toTextStyle(
              fontSizePx: AppDimensions.formattingPreviewFontSize,
            ),
            child: Opacity(
              opacity: element.opacity,
              child: Text(
                element.content,
                maxLines: 2,
                textAlign: element.textAlign,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The font row: the current family, previewed in itself, and a labeled
/// way to change it.
class _FontRow extends StatelessWidget {
  final TextElement element;
  final ValueChanged<String> onPick;

  const _FontRow({required this.element, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            element.fontFamily,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: element.toTextStyle(fontSizePx: 20),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceS),
        TextButton.icon(
          onPressed: () async {
            final family = await showFontPickerSheet(
              context,
              currentFamily: element.fontFamily,
              sampleText: element.content,
            );
            if (family != null) onPick(family);
          },
          icon: const Icon(Icons.font_download_outlined),
          label: const Text('Change'),
        ),
      ],
    );
  }
}


/// Smart Font Matching's contribution to the panel (Feature 6.2).
///
/// Renders nothing at all when there is no artwork to read, or when the
/// analyser was not confident. That silence is deliberate: the spec requires
/// an uncertain reading to fall back to the app default "with no error or
/// interruption — this should never feel like a failure state to the user."
class _SmartSuggestion extends ConsumerWidget {
  final InvitationSourceFile? sourceFile;
  final TextElement element;
  final void Function(FontSuggestion suggestion) onApply;

  const _SmartSuggestion({
    required this.sourceFile,
    required this.element,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = sourceFile;
    if (file == null) return const SizedBox.shrink();

    return ref.watch(fontSuggestionProvider(file)).when(
          loading: () => const ReadingInvitationIndicator(),
          // Analysis is a convenience; a failure is simply nothing to show.
          error: (_, __) => const SizedBox.shrink(),
          data: (suggestion) {
            if (suggestion == null) return const SizedBox.shrink();
            return FontSuggestionBanner(
              suggestion: suggestion,
              isApplied: element.fontFamily == suggestion.fontFamily &&
                  element.colorValue == suggestion.colorValue,
              onApply: () => onApply(suggestion),
            );
          },
        );
  }
}
