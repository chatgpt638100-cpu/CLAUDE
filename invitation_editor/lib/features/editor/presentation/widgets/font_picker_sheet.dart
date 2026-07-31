import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_fonts.dart';

/// Font chooser (Screen 4 — "Font: large scrollable list of font names,
/// each rendered in its own actual font so the user can see, not
/// guess").
///
/// Each row previews the user's own text in that family, which is more
/// use than previewing the font's name. Opens as a bottom sheet so the
/// list gets real height instead of being squeezed into the panel.
///
/// Returns the chosen family, or null if dismissed.
Future<String?> showFontPickerSheet(
  BuildContext context, {
  required String currentFamily,
  required String sampleText,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.cardSurface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.cardRadius),
      ),
    ),
    builder: (sheetContext) => _FontPickerSheet(
      currentFamily: currentFamily,
      sampleText: sampleText,
    ),
  );
}

class _FontPickerSheet extends StatelessWidget {
  final String currentFamily;
  final String sampleText;

  const _FontPickerSheet({
    required this.currentFamily,
    required this.sampleText,
  });

  @override
  Widget build(BuildContext context) {
    // A short sample keeps every row the same height; long invitation
    // text would make the list ragged and hard to compare.
    final sample = sampleText.trim().isEmpty
        ? 'Your text'
        : (sampleText.trim().length > 22
            ? '${sampleText.trim().substring(0, 22)}…'
            : sampleText.trim());

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceM),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose a font',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spaceS,
                ),
                itemCount: AppFonts.catalogue.length,
                itemBuilder: (context, index) {
                  final family = AppFonts.catalogue[index];
                  final isSelected = family == currentFamily;

                  return ListTile(
                    onTap: () => Navigator.of(context).pop(family),
                    selected: isSelected,
                    selectedTileColor:
                        AppColors.primaryAccent.withValues(alpha: 0.12),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceS,
                    ),
                    title: Text(
                      sample,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.resolve(
                        family,
                        const TextStyle(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      family,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    // Paired with the highlight so selection is never
                    // signalled by colour alone.
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primaryAccent,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
