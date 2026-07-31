import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../domain/entities/template_category.dart';
import 'template_category_labels.dart';

/// What the user entered in the Save as Template dialog.
class SaveTemplateRequest {
  final String name;
  final TemplateCategory category;

  const SaveTemplateRequest({required this.name, required this.category});
}

/// Screen 5 — Save as Template.
///
/// The spec describes one field and Save/Cancel. A category picker is added
/// because templates are filterable by category, and asking here — once,
/// while the user is already naming the thing — is kinder than making them
/// hunt for a way to file it afterwards.
///
/// Returns null if cancelled or left unnamed.
Future<SaveTemplateRequest?> showSaveAsTemplateDialog(
  BuildContext context, {
  required String suggestedName,
}) {
  final controller = TextEditingController(text: suggestedName);
  var category = TemplateCategory.other;

  return showDialog<SaveTemplateRequest>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (builderContext, setState) {
          void submit() {
            final name = controller.text.trim();
            if (name.isEmpty) {
              Navigator.of(dialogContext).pop();
              return;
            }
            Navigator.of(dialogContext).pop(
              SaveTemplateRequest(name: name, category: category),
            );
          }

          return AppDialog(
            title: 'Name this template',
            confirmLabel: 'Save',
            onConfirm: submit,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                    style: Theme.of(builderContext).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'For example: Wedding — gold script',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(AppDimensions.spaceM),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceL),
                  Text(
                    'Occasion',
                    style: Theme.of(builderContext)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppDimensions.spaceS),
                  Wrap(
                    spacing: AppDimensions.spaceS,
                    runSpacing: AppDimensions.spaceS,
                    children: [
                      for (final option in TemplateCategory.values)
                        _CategoryChoice(
                          label: templateCategoryLabel(option),
                          isSelected: category == option,
                          onTap: () => setState(() => category = option),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(controller.dispose);
}

class _CategoryChoice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChoice({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primaryAccent.withValues(alpha: 0.22)
          : AppColors.cardSurface,
      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTouchTarget,
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.textSecondary.withValues(alpha: 0.35),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.secondaryAccent
                        : AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
