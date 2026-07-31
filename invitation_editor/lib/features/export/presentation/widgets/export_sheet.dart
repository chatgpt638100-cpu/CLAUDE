import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/pulsing_dot_loader.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../injection/service_locator.dart';
import '../../../library/domain/entities/invitation_project.dart';
import '../../domain/entities/export_result.dart';
import '../../domain/usecases/export_to_pdf.dart';
import '../../domain/usecases/print_invitation.dart';
import '../../domain/usecases/share_invitation.dart';

/// Screen 6 — Export / Print.
///
/// A bottom sheet rather than a route, as the spec describes: it opens over
/// the Editor so the invitation stays visible behind the choice.
Future<void> showExportSheet(
  BuildContext context, {
  required InvitationProject project,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cardSurface,
    isScrollControlled: true,
    // Exporting writes a file and may open the print dialog; dismissing
    // mid-way would leave the user unsure whether it worked.
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.cardRadius),
      ),
    ),
    builder: (sheetContext) => _ExportSheet(project: project),
  );
}

class _ExportSheet extends StatefulWidget {
  final InvitationProject project;

  const _ExportSheet({required this.project});

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  bool _isWorking = false;
  String? _statusLabel;
  ExportResult? _result;
  String? _errorMessage;

  /// Exports once and reuses the file: both Print and Share need a PDF on
  /// disk, and rendering it twice would be slow for no gain.
  Future<ExportResult?> _ensureExported(String workingLabel) async {
    final existing = _result;
    if (existing != null) return existing;

    setState(() {
      _isWorking = true;
      _statusLabel = workingLabel;
      _errorMessage = null;
    });

    try {
      final result = await sl<ExportToPdf>()(widget.project);
      if (!mounted) return null;
      setState(() => _result = result);
      return result;
    } on Failure catch (failure) {
      if (mounted) setState(() => _errorMessage = failure.message);
      return null;
    } catch (_) {
      if (mounted) setState(() => _errorMessage = const ExportFailure().message);
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isWorking = false;
          _statusLabel = null;
        });
      }
    }
  }

  Future<void> _handleSavePdf() async {
    await _ensureExported('Making your PDF…');
  }

  Future<void> _handlePrint() async {
    final result = await _ensureExported('Preparing to print…');
    if (result == null || !mounted) return;

    try {
      await sl<PrintInvitation>()(result);
    } on Failure catch (failure) {
      if (mounted) setState(() => _errorMessage = failure.message);
    }
  }

  Future<void> _handleShare() async {
    final result = await _ensureExported('Preparing to share…');
    if (result == null || !mounted) return;

    try {
      await sl<ShareInvitation>()(result);
    } on Failure catch (failure) {
      if (mounted) setState(() => _errorMessage = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceM),
        child: AnimatedSize(
          duration: AppDimensions.animationFast,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Print or save',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spaceL),
              if (_isWorking)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spaceXL,
                  ),
                  child: PulsingDotLoader(
                    label: _statusLabel ?? 'Working…',
                  ),
                )
              else ...[
                if (_result != null) _SavedBanner(result: _result!),
                _ExportOptionCard(
                  icon: Icons.picture_as_pdf_outlined,
                  label: _result == null ? 'Save as PDF' : 'PDF ready',
                  description: _result == null
                      ? 'Keep a copy on this device'
                      : 'Saved as ${_result!.fileName}',
                  onTap: _result == null ? _handleSavePdf : null,
                ),
                const SizedBox(height: AppDimensions.spaceM),
                _ExportOptionCard(
                  icon: Icons.print_outlined,
                  label: 'Print',
                  description: 'Choose a printer on the next screen',
                  onTap: _handlePrint,
                ),
                const SizedBox(height: AppDimensions.spaceM),
                _ExportOptionCard(
                  icon: Icons.ios_share,
                  label: 'Share',
                  description: 'Send by message, email or another app',
                  onTap: _handleShare,
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: AppDimensions.spaceL),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.danger,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppDimensions.spaceL),
              SecondaryButton(
                label: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The spec's "Saved!" confirmation, with a soft gold tick.
class _SavedBanner extends StatelessWidget {
  final ExportResult result;

  const _SavedBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: Text(
              'Saved! ${result.fileName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// One large stacked card, per spec — "two large stacked cards rather than
/// tiny buttons, so the choice is unmistakable".
class _ExportOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onTap;

  const _ExportOptionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: AppColors.cardSurface,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.optionCardHeight,
          ),
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: AppColors.primaryAccent.withValues(
                alpha: isEnabled ? 0.6 : 0.25,
              ),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: isEnabled
                    ? AppColors.primaryAccent
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppDimensions.spaceXS),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
