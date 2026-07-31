import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/pulsing_dot_loader.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/invitation_page.dart';
import '../../domain/entities/invitation_source_file.dart';
import '../../domain/entities/text_element.dart';
import '../providers/editor_canvas_provider.dart';
import '../providers/editor_session_provider.dart';
import '../providers/invitation_preview_provider.dart';
import 'formatting_panel.dart';
import 'text_box_widget.dart';
import 'text_element_toolbar.dart';
import 'text_input_dialog.dart';

/// Screen 4 — the Editor canvas.
///
/// Shows the first page of the selected invitation and the text boxes
/// laid over it. Supports pinch-to-zoom and drag-to-pan, tap-to-add
/// text, and selecting a box to move, resize, rotate, duplicate,
/// restack or delete it.
///
/// Still out of scope: the formatting panel (font, size, colour,
/// alignment, bold/italic), voice typing, templates, Smart Font
/// Matching, and export/print.
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

  /// Identifies the padded page area, so pointer positions can be
  /// converted into page coordinates regardless of zoom or pan.
  final GlobalKey _pageAreaKey = GlobalKey();

  late final AnimationController _resetController = AnimationController(
    vsync: this,
    duration: AppDimensions.animationSlow,
  );

  Animation<Matrix4>? _resetAnimation;
  bool _isZoomed = false;

  /// Whether the formatting panel is open. Local widget state rather than
  /// a provider: it is pure view state with no bearing on the invitation
  /// itself, and nothing outside this screen needs to read it.
  bool _isFormattingPanelOpen = false;

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

  /// Converts a global pointer position into page-space pixels, with the
  /// gutter around the page removed so (0,0) is the page's top-left
  /// corner. Returns null before the first layout.
  Offset? _toPageLocal(Offset globalPosition) {
    final renderObject = _pageAreaKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;

    final local = renderObject.globalToLocal(globalPosition);
    return local - const Offset(
      AppDimensions.canvasGutter,
      AppDimensions.canvasGutter,
    );
  }

  /// Largest size that fits [image]'s proportions inside [available]
  /// without cropping.
  Size _fitPage(Size image, Size available) {
    if (image.width <= 0 || image.height <= 0) return available;

    final scale = math.min(
      available.width / image.width,
      available.height / image.height,
    );
    return Size(image.width * scale, image.height * scale);
  }

  EditorCanvasNotifier get _canvas => ref.read(editorCanvasProvider.notifier);

  /// Tapping the page adds a text box — unless something is selected, in
  /// which case the tap means "I'm done with that one". Without this,
  /// every attempt to deselect would litter the page with new boxes.
  Future<void> _handlePageTap(Offset localPosition, Size pageSize) async {
    if (ref.read(editorCanvasProvider).selectedElementId != null) {
      _canvas.select(null);
      setState(() => _isFormattingPanelOpen = false);
      return;
    }
    await _addTextAt(localPosition, pageSize);
  }

  Future<void> _addTextAt(Offset localPosition, Size pageSize) async {
    final content = await showTextInputDialog(context);
    if (content == null || !mounted) return;

    _canvas.addTextAt(
      content: content,
      centreX: localPosition.dx / pageSize.width,
      centreY: localPosition.dy / pageSize.height,
    );
  }

  Future<void> _editSelected(String id, String currentContent) async {
    final content = await showTextInputDialog(
      context,
      initialValue: currentContent,
    );
    if (content == null || !mounted) return;

    _canvas.updateContent(id: id, content: content);
  }

  /// Per the spec, deleting text is undoable from a snackbar rather than
  /// guarded by a confirmation dialog — safer for an accidental tap and
  /// far less alarming for a cautious user.
  void _deleteSelected(String id) {
    _canvas.delete(id);
    setState(() => _isFormattingPanelOpen = false);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Text deleted.'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _canvas.undoDelete(),
        ),
      ),
    );
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
        data: _buildCanvas,
      ),
    );
  }

  Widget _buildCanvas(InvitationPage page) {
    final canvas = ref.watch(editorCanvasProvider);
    final selected = canvas.selectedElement;

    // Hand the page's true pixel size to the session so exports and
    // thumbnails can reproduce its proportions. Deferred a frame because
    // this runs during build. The setter ignores unchanged values, so this
    // settles after the first paint rather than looping.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(editorSessionProvider.notifier).setPageSize(
            widthPx: page.widthPx,
            heightPx: page.heightPx,
          );
    });

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gutter = AppDimensions.canvasGutter;

              // Fit the page inside the space that remains once the
              // gutter is reserved, so the padded area never exceeds the
              // viewport — InteractiveViewer would otherwise clamp it.
              final pageSize = _fitPage(
                Size(page.widthPx.toDouble(), page.heightPx.toDouble()),
                Size(
                  math.max(constraints.maxWidth - gutter * 2, 1),
                  math.max(constraints.maxHeight - gutter * 2, 1),
                ),
              );

              return InteractiveViewer(
                transformationController: _transformation,
                minScale: AppDimensions.canvasMinScale,
                maxScale: AppDimensions.canvasMaxScale,
                child: Center(
                  child: SizedBox(
                    key: _pageAreaKey,
                    width: pageSize.width + gutter * 2,
                    height: pageSize.height + gutter * 2,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: gutter,
                          top: gutter,
                          width: pageSize.width,
                          height: pageSize.height,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (details) => _handlePageTap(
                              details.localPosition,
                              pageSize,
                            ),
                            child: _PageSurface(imageBytes: page.imageBytes),
                          ),
                        ),
                        for (final element in canvas.elements)
                          TextBoxWidget(
                            key: ValueKey(element.id),
                            element: element,
                            isSelected: element.id == canvas.selectedElementId,
                            pageSize: pageSize,
                            gutter: gutter,
                            toPageLocal: _toPageLocal,
                            onSelect: () => _canvas.select(element.id),
                            onMove: (dx, dy) => _canvas.move(
                              id: element.id,
                              deltaX: dx,
                              deltaY: dy,
                            ),
                            onResize: (factor) => _canvas.resize(
                              id: element.id,
                              factor: factor,
                            ),
                            onRotate: (rotation) => _canvas.rotate(
                              id: element.id,
                              rotation: rotation,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        // One animated container for all three footer states, so opening
        // the panel or selecting a box eases the canvas into its new
        // height rather than snapping.
        AnimatedSize(
          duration: AppDimensions.animationSlow,
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _buildFooter(selected),
        ),
      ],
    );
  }

  Widget _buildFooter(TextElement? selected) {
    if (selected == null) {
      return _IdleFooter(isZoomed: _isZoomed, onResetView: _resetView);
    }

    if (_isFormattingPanelOpen) {
      return FormattingPanel(
        elementId: selected.id,
        onClose: () => setState(() => _isFormattingPanelOpen = false),
      );
    }

    return TextElementToolbar(
      onEdit: () => _editSelected(selected.id, selected.content),
      onFormat: () => setState(() => _isFormattingPanelOpen = true),
      onDuplicate: () => _canvas.duplicate(selected.id),
      onBringToFront: () => _canvas.bringToFront(selected.id),
      onSendToBack: () => _canvas.sendToBack(selected.id),
      onDelete: () => _deleteSelected(selected.id),
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

/// Shown when no text box is selected: how to add text and work the
/// canvas, or a way back from a zoomed-in view.
class _IdleFooter extends StatelessWidget {
  final bool isZoomed;
  final VoidCallback onResetView;

  const _IdleFooter({required this.isZoomed, required this.onResetView});

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
                  'Tap the invitation to add text · Pinch to zoom',
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
