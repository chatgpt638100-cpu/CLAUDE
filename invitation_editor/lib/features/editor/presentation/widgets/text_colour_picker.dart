import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_dialog.dart';

/// Colour chooser for text (Screen 4 — "a row of large circular colour
/// swatches (curated palette, ~12 elegant colours) plus one 'More
/// Colours' option").
class TextColourPicker extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColourSelected;

  const TextColourPicker({
    super.key,
    required this.selectedColorValue,
    required this.onColourSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppDimensions.spaceM,
          runSpacing: AppDimensions.spaceM,
          children: [
            for (final colour in AppColors.textPalette)
              _Swatch(
                colour: colour,
                isSelected: colour.toARGB32() == selectedColorValue,
                onTap: () => onColourSelected(colour.toARGB32()),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceM),
        TextButton.icon(
          onPressed: () => _openFullPicker(context),
          icon: const Icon(Icons.palette_outlined),
          label: const Text('More Colours'),
        ),
      ],
    );
  }

  Future<void> _openFullPicker(BuildContext context) async {
    // Held locally so the canvas is not restyled on every pixel of drag
    // across the colour wheel; it commits once on Choose.
    var draft = Color(selectedColorValue);

    final chosen = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: 'Pick a colour',
        confirmLabel: 'Choose',
        onConfirm: () => Navigator.of(dialogContext).pop(draft),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: draft,
            onColorChanged: (colour) => draft = colour,
            enableAlpha: false,
            displayThumbColor: true,
            portraitOnly: true,
            labelTypes: const [],
          ),
        ),
      ),
    );

    if (chosen != null) onColourSelected(chosen.toARGB32());
  }
}

/// One large circular colour option. Selection is shown by a ring plus a
/// tick, never by colour alone.
class _Swatch extends StatelessWidget {
  final Color colour;
  final bool isSelected;
  final VoidCallback onTap;

  const _Swatch({
    required this.colour,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pick a tick colour that stays visible on both pale and dark
    // swatches.
    final tickColour = ThemeData.estimateBrightnessForColor(colour) ==
            Brightness.dark
        ? Colors.white
        : AppColors.secondaryAccent;

    return Semantics(
      label: 'Text colour',
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          // Visual swatch is smaller than this box, which exists to keep
          // the touch target at the accessibility minimum.
          width: AppDimensions.minTouchTarget,
          height: AppDimensions.minTouchTarget,
          child: Center(
            child: Container(
              width: AppDimensions.colourSwatchSize,
              height: AppDimensions.colourSwatchSize,
              decoration: BoxDecoration(
                color: colour,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryAccent
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 18, color: tickColour)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
