import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/item_options_sheet.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/pulsing_dot_loader.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/invitation_project.dart';
import '../providers/library_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/invitation_thumbnail_card.dart';
import '../widgets/library_search_field.dart';

/// Screen 1 — Home / My Invitations (Library).
///
/// Reads real saved invitations from storage. Reloads whenever the screen
/// is returned to, because auto-save in the Editor will have changed
/// titles, thumbnails and edit times while the user was away.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  /// Searching only earns its screen space once the grid is long enough to
  /// be worth filtering.
  static const int _searchVisibleThreshold = 4;

  Future<void> _openEditor(String? projectId) async {
    await context.push('/editor', extra: projectId);
    if (!mounted) return;
    // Back from the Editor: pick up whatever auto-save wrote.
    await ref.read(libraryProvider.notifier).reload();
  }

  Future<void> _handleOptions(InvitationProject project) async {
    final choice = await showItemOptionsSheet(
      context,
      title: project.title,
      deleteDescription: 'Remove this invitation for good',
    );
    if (choice == null || !mounted) return;

    final notifier = ref.read(libraryProvider.notifier);

    try {
      switch (choice) {
        case ItemOption.rename:
          final title = await showRenameDialog(
            context,
            dialogTitle: 'Rename invitation',
            currentValue: project.title,
          );
          if (title != null) await notifier.rename(project.id, title);

        case ItemOption.duplicate:
          await notifier.duplicate(project.id);

        case ItemOption.delete:
          final confirmed = await confirmDeletionDialog(
            context,
            title: project.title,
          );
          if (confirmed) await notifier.delete(project.id);
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
    final library = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Invitations'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spaceS),
            child: InkWell(
              onTap: () => context.push('/settings'),
              borderRadius: BorderRadius.circular(AppDimensions.spaceS),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      color: AppColors.secondaryAccent,
                    ),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: library.when(
          loading: () => const Center(
            child: PulsingDotLoader(label: 'Opening your invitations…'),
          ),
          error: (error, _) => _LibraryError(
            message: error is Failure
                ? error.message
                : const StorageFailure().message,
            onRetry: () => ref.read(libraryProvider.notifier).reload(),
          ),
          data: (invitations) => invitations.isEmpty
              ? EmptyLibraryState(
                  onCreatePressed: () => context.push('/new-invitation'),
                )
              : _LibraryBody(
                  totalCount: invitations.length,
                  showSearch: invitations.length >= _searchVisibleThreshold,
                  onOpen: (project) => _openEditor(project.id),
                  onOptions: _handleOptions,
                ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spaceM,
          AppDimensions.spaceS,
          AppDimensions.spaceM,
          AppDimensions.spaceM,
        ),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: '+ New Invitation',
            onPressed: () => context.push('/new-invitation'),
          ),
        ),
      ),
    );
  }
}

class _LibraryBody extends ConsumerWidget {
  final int totalCount;
  final bool showSearch;
  final void Function(InvitationProject project) onOpen;
  final void Function(InvitationProject project) onOptions;

  const _LibraryBody({
    required this.totalCount,
    required this.showSearch,
    required this.onOpen,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(filteredInvitationsProvider);
    final recent = ref.watch(recentInvitationsProvider);
    final query = ref.watch(librarySearchQueryProvider);

    // A "Recent" strip only says something when it is a genuine shortcut
    // into a longer list, and it would be noise while searching.
    final showRecent = query.trim().isEmpty &&
        totalCount > recent.length &&
        recent.isNotEmpty;

    return CustomScrollView(
      slivers: [
        if (showSearch)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spaceM,
              AppDimensions.spaceS,
              AppDimensions.spaceM,
              AppDimensions.spaceS,
            ),
            sliver: SliverToBoxAdapter(
              child: LibrarySearchField(
                value: query,
                onChanged: (value) => ref
                    .read(librarySearchQueryProvider.notifier)
                    .state = value,
              ),
            ),
          ),
        if (showRecent) ...[
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceM,
              AppDimensions.spaceS,
              AppDimensions.spaceM,
              0,
            ),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Recent')),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppDimensions.recentStripHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceM,
                  vertical: AppDimensions.spaceS,
                ),
                itemCount: recent.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.spaceM),
                itemBuilder: (context, index) {
                  final project = recent[index];
                  return SizedBox(
                    width: AppDimensions.recentStripItemWidth,
                    child: InvitationThumbnailCard(
                      project: project,
                      onTap: () => onOpen(project),
                      onOptionsTap: () => onOptions(project),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceM,
              AppDimensions.spaceM,
              AppDimensions.spaceM,
              0,
            ),
            sliver: SliverToBoxAdapter(child: _SectionLabel('All invitations')),
          ),
        ],
        if (visible.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _NoSearchResults(query: query),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppDimensions.spaceM,
                crossAxisSpacing: AppDimensions.spaceM,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                childCount: visible.length,
                (context, index) {
                  final project = visible[index];
                  return InvitationThumbnailCard(
                    key: ValueKey(project.id),
                    project: project,
                    onTap: () => onOpen(project),
                    onOptionsTap: () => onOptions(project),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  final String query;

  const _NoSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Text(
              'Nothing found for "${query.trim()}"',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LibraryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_off_outlined,
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
