import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/invitation_thumbnail_card.dart';
import '../widgets/empty_state.dart';

/// Screen 1 — Home / My Invitations (Library).
/// UI ONLY for Phase 1: static sample data, no storage, no real
/// navigation logic beyond simple route pushes for scaffolding.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  // Static sample data — to be replaced by real storage in a later phase.
  static const List<Map<String, String>> _sampleInvitations = [
    {'title': "Amara's Birthday", 'date': 'Edited Jul 28'},
    {'title': 'Diwali Card', 'date': 'Edited Jul 20'},
    {'title': 'Wedding — Priya & Dev', 'date': 'Edited Jul 12'},
  ];

  // Flip to `true` to preview the first-launch empty state.
  static const bool _showEmptyState = false;

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.all(4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings_outlined, color: AppColors.secondaryAccent),
                    Text(
                      'Settings',
                      style: TextStyle(fontSize: 11, color: AppColors.secondaryAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _showEmptyState
            ? EmptyLibraryState(
                onCreatePressed: () => context.push('/new-invitation'),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spaceM,
                  AppDimensions.spaceS,
                  AppDimensions.spaceM,
                  AppDimensions.spaceM,
                ),
                child: GridView.builder(
                  itemCount: _sampleInvitations.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppDimensions.spaceM,
                    crossAxisSpacing: AppDimensions.spaceM,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final item = _sampleInvitations[index];
                    return InvitationThumbnailCard(
                      title: item['title']!,
                      lastEditedLabel: item['date']!,
                      onTap: () => context.push('/editor'),
                      onOptionsTap: () {},
                    );
                  },
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
