import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pulsing_dot_loader.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/invitation_source_file.dart';
import '../providers/invitation_preview_provider.dart';

/// Screen 4 — the Editor canvas.
///
/// Shows the first page of the selected invitation: a rasterised page
/// for a PDF, or the picture itself for a JPG/PNG. The page opens at a
/// comfortable fit and supports pinch-to-zoom and drag-to-pan, the only
/// two gestures the spec allows here beyond tap.
///
/// Still out of scope for this phase: text boxes, the formatting panel,
/// templates, Smart Font Matching, voice typing, and export/print.
class CanvasView extends ConsumerStatefulWidget {
  final InvitationSourceFile sourceFile;

  const CanvasView({super.key, required this.sourceFile});

  @override
  ConsumerState<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView>
    with SingleTickerProviderStateMixin {
  /// Treat anything above this as "the user has zoomed in", with a
  /// small tolerance so floating-point drift doesn't flicker the footer.
  static const double _zoomedEpsilon = 0.01;

  final TransformationController _transformation = TransformationController();

  late final AnimationController _resetController = AnimationController(
    vsync: this,
    duration: AppDimensions.animationSlow,
  );

  Animation<Matrix4>? _resetAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformation.addListener(_handleTransformChanged);
  }

  @override
  void dispose() {
    _transformation.removeListener(_handleTransformChanged);
    _resetAnimation?.removeListener(_applyResetFrame);
    _resetController.dispose();
    _transformation.dispose();
    super.dispose();
  }

  void _handleTransformChanged() {
    final zoomed = _transformation.value.getMaxScaleOnAxis() >
        AppDimensions.canvasMinScale + _zoomedEpsilon;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  /// Eases the page back to its original fit. A zoomed-in user must
  /// always have a plainly labeled way back — pinching out to exactly
  /// 100% is fiddly, and being stranded zoomed in is exactly the kind
  /// of dead end this audience should never hit.
  void _resetView() {
    _resetAnimation?.removeListener(_applyResetFrame);

    final animation = Matrix4Tween(
      begin: _transformation.value,
      end: Matrix4.identity(),
    ).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeInOut),
    );

    animation.addListener(_applyResetFrame);
    _resetAnimation = animation;
    _resetController.forward(from: 0);
  }

  void _applyResetFrame() {
    final animation = _resetAnimation;
    if (animation != null) {
      _transformation.value = animation.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(invitationPreviewProvider(widget.sourceFile));

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      child: preview.when(
        loading: () => const Center(
          child: PulsingDotLoader(label: 'Opening your invitation…'),
        ),
        error: (error, _) => Center(
          child: _CanvasMessage(
            message: _friendlyMessage(error),
            onRetry: () => ref.invalidate(
              invitationPreviewProvider(widget.sourceFile),
            ),
          ),
        ),
        data: (page) => Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                transformationController: _transformation,
                minScale: AppDimensions.canvasMinScale,
                maxScale: AppDimensions.canvasMaxScale,
                child: Center(
                  child: _PageSurface(imageBytes: page.imageBytes),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            _CanvasFooter(isZoomed: _isZoomed, onResetView: _resetView),
          ],
        ),
      ),
    );
  }

  /// Never surface a raw exception to a 50+ audience. Known [Failure]s
  /// already carry warm, non-technical wording; anything unexpected
  /// falls back to the same friendly default.
  String _friendlyMessage(Object error) {
    if (error is Failure) return error.message;
    return const PreviewRenderFailure().message;
  }
}

/// Below the canvas: a quiet hint about the available gestures, which
/// swaps to a labeled "Reset View" button once the user has zoomed.
///
/// Fixed height so the canvas above never shifts as it changes, and a
/// soft cross-fade rather than a pop.
class _CanvasFooter extends StatelessWidget {
  final bool isZoomed;
  final VoidCallback onResetView;

  const _CanvasFooter({required this.isZoomed, required this.onResetView});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      child: Center(
        child: AnimatedSwitcher(
          duration: AppDimensions.animationFast,
          child: isZoomed
              ? SecondaryButton(
                  key: const ValueKey('reset'),
                  label: 'Reset View',
                  icon: Icons.zoom_out_map,
                  fullWidth: false,
                  onPressed: onResetView,
                )
              : Text(
                  'Pinch to zoom · Drag to move',
                  key: const ValueKey('hint'),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}

/// An empty canvas, used for the "Blank Card" route into the Editor
/// where there is no file to render.
class BlankCanvasView extends StatelessWidget {
  const BlankCanvasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AspectRatio(
                aspectRatio: AppDimensions.blankPageAspectRatio,
                child: const AppCard(
                  padding: EdgeInsets.zero,
                  child: SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Blank card — text tools arrive in a later phase.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// The invitation page itself, presented like a real card resting on the
/// ivory background — white surface, soft shadow, rounded corners.
class _PageSurface extends StatelessWidget {
  final Uint8List imageBytes;

  const _PageSurface({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          // Catches bytes that decode badly (a corrupt or truncated
          // image) — the repository can only detect a missing or
          // unreadable file, not one that fails at decode time.
          errorBuilder: (context, error, stackTrace) => _CanvasMessage(
            message: const PreviewRenderFailure().message,
          ),
        ),
      ),
    );
  }
}

/// A calm, friendly failure state — a quiet line of explanation and an
/// optional labeled way forward. No error codes, no stack traces.
class _CanvasMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _CanvasMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppDimensions.spaceL),
          SecondaryButton(
            label: 'Try Again',
            icon: Icons.refresh,
            fullWidth: false,
            onPressed: onRetry,
          ),
        ],
      ],
    );
  }
}
