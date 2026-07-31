import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/app_bar_widget.dart';
import '../../../../injection/service_locator.dart';
import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../domain/usecases/pick_image_file.dart';
import '../../domain/usecases/pick_pdf_file.dart';
import '../widgets/source_option_card.dart';

/// Screen 2 — New Invitation (Source Selection).
///
/// Wires the "Upload a PDF" and "Upload an Image" cards to the file
/// picker use cases and navigates to the Editor with the selected file.
/// "Choose from Saved Templates" is not wired up yet — that arrives
/// with the Templates feature.
class SourceSelectionScreen extends StatefulWidget {
  const SourceSelectionScreen({super.key});

  @override
  State<SourceSelectionScreen> createState() => _SourceSelectionScreenState();
}

class _SourceSelectionScreenState extends State<SourceSelectionScreen> {
  bool _isPicking = false;

  Future<void> _handlePickPdf() => _pick(() => sl<PickPdfFile>()());

  Future<void> _handlePickImage() => _pick(() => sl<PickImageFile>()());

  Future<void> _pick(Future<InvitationSourceFile?> Function() pickFn) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final file = await pickFn();
      if (!mounted) return;

      if (file == null) {
        // User cancelled the picker — stay on this screen.
        return;
      }

      context.push('/editor', extra: file);
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'New Invitation', showBackLabel: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How would you like to start?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              SourceOptionCard(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Upload a PDF',
                description: 'Use a PDF invitation you already have',
                onTap: _isPicking ? null : _handlePickPdf,
              ),
              const SizedBox(height: AppDimensions.spaceM),
              SourceOptionCard(
                icon: Icons.image_outlined,
                label: 'Upload an Image',
                description: 'Choose a JPG or PNG photo of your invitation',
                onTap: _isPicking ? null : _handlePickImage,
              ),
              const SizedBox(height: AppDimensions.spaceM),
              SourceOptionCard(
                icon: Icons.bookmarks_outlined,
                label: 'Choose from Saved Templates',
                description: 'Start from one of your saved templates',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
