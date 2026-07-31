import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/widgets/app_bar_widget.dart';
import '../../../../core/widgets/item_options_sheet.dart';
import '../../../../core/widgets/pulsing_dot_loader.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/invitation_template.dart';
import '../../domain/usecases/create_invitation_from_template.dart';
import '../providers/template_library_provider.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/template_card.dart';

/// Screen 3 — Template Library.
///
/// Lists the templates the user has saved from their own designs, filtered
/// by occasion, plus a blank-card tile. Tapping a template creates a new
/// invitation from it and opens the Editor.
class TemplateLibraryScreen extends ConsumerStatefulWidget {
  const TemplateLibraryScreen({super.key});

  @override
  ConsumerState<TemplateLibraryScreen> createState() =>
      _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState
    extends ConsumerState<TemplateLibraryScreen> {
  bool _isCreating = false;

  Future<void> _useTemplate(InvitationTemplate template) async {
    // Creating copies artwork on disk, so guard against a double tap
    // producing two invitations.
    if (_isCreating) return;
    setState(() => _isCreating = true);

    try {
      final project = await sl<CreateInvitationFromTemplate>()(
        template.id,
        newInvitationId: sl<IdGenerator>().next('invitation'),
      );
      if (!mounted) return;

      if (project == null) {
        _showMessage('That template is no longer there.');
        await ref.read(templateLibraryProvider.notifier).reload();
        return;
      }

      // Replaces this screen so Back from the Editor lands on the Library
      // rather than stepping back through the template picker.
      context.pushReplacement('/editor', extra: project.id);
    } on Failure catch (failure) {
      if (mounted) _showMessage(failure.message);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _handleOptions(InvitationTemplate template) async {
    final choice = await showItemOptionsSheet(
      context,
      title: template.name,
      // Duplicating a template adds little: using it already produces an
      // independent invitation.
      includeDuplicate: false,
      deleteDescription: 'Remove this template for good',
    );
    if (choice == null || !mounted) return;

    final notifier = ref.read(templateLibraryProvider.notifier);

    try {
      switch (choice) {
        case ItemOption.rename:
          final name = await showRenameDialog(
            context,
            dialogTitle: 'Rename template',
            currentValue: template.name,
          );
          if (name != null) await notifier.rename(template.id, name);

        // Not offered for templates, so nothing to do.
        case ItemOption.duplicate:
          break;

        case ItemOption.delete:
          final confirmed = await confirmDeletionDialog(
            context,
            title: template.name,
            description: 'Invitations you already made from it are safe.',
          );
          if (confirmed) await notifier.delete(template.id);
      }
    } on Failure catch (failure) {
      if (mounted) _showMessage(failure.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(templateLibraryProvider);
    final selectedCategory = ref.watch(selectedTemplateCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Templates', showBackLabel: true),
      body: SafeArea(
        child: templates.when(
          loading: () => const Center(
            child: PulsingDotLoader(label: 'Opening your templates…'),
          ),
          error: (error, _) => _TemplateError(
            message: error is Failure
                ? error.message
                : const StorageFailure().message,
            onRetry: () => ref.read(templateLibraryProvider.notifier).reload(),
          ),
          data: (_) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceM),
                child: CategoryFilterBar(
                  selected: selectedCategory,
                  onSelected: (category) => ref
                      .read(selectedTemplateCategoryProvider.notifier)
                      .state = category,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _TemplateGrid(
                  onUse: _useTemplate,
                  onOptions: _handleOptions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateGrid extends ConsumerWidget {
  final void Function(InvitationTemplate template) onUse;
  final void Function(InvitationTemplate template) onOptions;

  const _TemplateGrid({required this.onUse, required this.onOptions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(visibleTemplatesProvider);
    final category = ref.watch(selectedTemplateCategoryProvider);

    return Column(
      children: [
        // Explains the gap without hiding the grid, so the blank-card tile
        // stays reachable.
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceL,
              vertical: AppDimensions.spaceM,
            ),
            child: Text(
              category == null
                  ? 'Save a design as a template from the Editor menu and it '
                      'will appear here.'
                  : 'No templates filed under this occasion yet.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppDimensions.spaceM,
              crossAxisSpacing: AppDimensions.spaceM,
              childAspectRatio: 0.72,
            ),
            // The blank tile is always first, so there is a way forward even
            // before any template has been saved.
            itemCount: visible.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return BlankTemplateCard(
                  onTap: () => context.pushReplacement('/editor'),
                );
              }

              final template = visible[index - 1];
              return TemplateCard(
                key: ValueKey(template.id),
                template: template,
                onTap: () => onUse(template),
                onOptionsTap: () => onOptions(template),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TemplateError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TemplateError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmark_remove_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            SecondaryButton(
              label: 'Try Again',
              icon: Icons.refresh,
              fullWidth: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
