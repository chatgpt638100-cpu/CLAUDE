import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

/// Shared top bar used across screens. Supports an optional labeled
/// back button and an optional labeled trailing action — per spec,
/// "no icon-only buttons anywhere in the app."
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackLabel;
  final Widget? trailing;

  const AppTopBar({
    super.key,
    required this.title,
    this.showBackLabel = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackLabel
          ? TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.secondaryAccent),
              label: const Text('Back', style: TextStyle(color: AppColors.secondaryAccent)),
            )
          : null,
      leadingWidth: showBackLabel ? 100 : null,
      title: Text(title),
      actions: trailing == null ? null : [trailing!, const SizedBox(width: 8)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
