import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/primary_button.dart';

/// First-launch empty state for the Library (Home) screen.
/// Per spec: "centered illustration of an elegant blank card,
/// with text 'Create your first invitation' and one large gold button."
class EmptyLibraryState extends StatelessWidget {
  final VoidCallback onCreatePressed;

  const EmptyLibraryState({super.key, required this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Placeholder illustration — real artwork to be added later.
            Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(color: AppColors.primaryAccent, width: 1.5),
              ),
              child: const Icon(
                Icons.card_giftcard_outlined,
                size: 56,
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Create your first invitation',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            PrimaryButton(
              label: '+ New Invitation',
              onPressed: onCreatePressed,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
