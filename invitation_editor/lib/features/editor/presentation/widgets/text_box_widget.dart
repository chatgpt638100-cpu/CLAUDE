import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/text_element.dart';

/// Which handle a drag started on.
enum _DragTarget { body, resize, rotate }

/// One text box on the Editor canvas (Screen 4).
///
/// Selected, it shows a soft gold outline, four corner handles for
/// resizing, and a rotation handle above the top edge.
///
/// Gesture maths deliberately avoids `DragUpdateDetails.delta`. Inside a
/// zoomed [InteractiveViewer] and a rotated [Transform], a raw delta is
/// in the wrong frame of reference. Instead every drag converts the
/// pointer's global position into page coordinates via [toPageLocal], so
/// dragging, resizing and rotating behave identically at any zoom level
/// and at any rotation.
class TextBoxWidget extends StatefulWidget {
  final TextElement element;
  final bool isSelected;

  /// Pixel size of the rendered page — the frame all normalised geometry
  /// is measured against.
  final Size pageSize;

  /// Free space kept around the page so handles on a box at the very
  /// edge stay inside the hit-testable area.
  final double gutter;

  /// Converts a global pointer position into page-space pixels, or null
  /// if the canvas is not laid out yet.
  final Offset? Function(Offset globalPosition) toPageLocal;

  final VoidCallback onSelect;
  final void Function(double deltaX, double deltaY) onMove;
  final void Function(double factor) onResize;
  final void Function(double rotation) onRotate;

  const TextBoxWidget({
    super.key,
    required this.element,
    required this.isSelected,
    required this.pageSize,
    required this.gutter,
    required this.toPageLocal,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
    required this.onRotate,
  });

  @override
  State<TextBoxWidget> createState() => _TextBoxWidgetState();
}

class _TextBoxWidgetState extends State<TextBoxWidget> {
  /// Previous pointer position in page space; drags are applied
  /// incrementally from it.
  Offset? _lastPoint;

  /// Below this the box is treated as having no meaningful extent, and
  /// scale/angle maths would divide by something near zero.
  static const double _minDragDistance = 0.5;

  Offset get _centreInPage => Offset(
        widget.element.centreX * widget.pageSize.width,
        widget.element.centreY * widget.pageSize.height,
      );

  void _onDragStart(DragStartDetails details) {
    _lastPoint = widget.toPageLocal(details.globalPosition);
  }

  void _onDragEnd(_) => _lastPoint = null;

  void _onDragUpdate(DragUpdateDetails details, _DragTarget target) {
    final previous = _lastPoint;
    final current = widget.toPageLocal(details.globalPosition);
    if (previous == null || current == null) {
      _lastPoint = current;
      return;
    }

    final centre = _centreInPage;

    if (target == _DragTarget.body) {
      widget.onMove(
        (current.dx - previous.dx) / widget.pageSize.width,
        (current.dy - previous.dy) / widget.pageSize.height,
      );
    } else if (target == _DragTarget.resize) {
      // How much further from the centre the finger moved is the scale
      // factor — which works the same whatever the box's rotation.
      final previousDistance = (previous - centre).distance;
      final currentDistance = (current - centre).distance;
      if (previousDistance > _minDragDistance) {
        widget.onResize(currentDistance / previousDistance);
      }
    } else {
      // Rotation is the change in the finger's bearing around the centre.
      if ((previous - centre).distance > _minDragDistance &&
          (current - centre).distance > _minDragDistance) {
        final previousAngle =
            math.atan2(previous.dy - centre.dy, previous.dx - centre.dx);
        final currentAngle =
            math.atan2(current.dy - centre.dy, current.dx - centre.dx);
        widget.onRotate(
          widget.element.rotation + (currentAngle - previousAngle),
        );
      }
    }

    _lastPoint = current;
  }

  @override
  Widget build(BuildContext context) {
    final pad = widget.gutter;
    final contentWidth = widget.element.width * widget.pageSize.width;
    final contentHeight = widget.element.height * widget.pageSize.height;

    return Positioned(
      // The outer box is the content inflated by `pad` on every side.
      // Padding is uniform so Transform.rotate, which pivots on the
      // widget's centre, pivots on the content's centre too.
      left: widget.element.x * widget.pageSize.width,
      top: widget.element.y * widget.pageSize.height,
      width: contentWidth + pad * 2,
      height: contentHeight + pad * 2,
      child: Transform.rotate(
        angle: widget.element.rotation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: pad,
              top: pad,
              width: contentWidth,
              height: contentHeight,
              child: _body(context),
            ),
            // Positioned.fill matters: a bare Stack child holding only
            // positioned children would collapse to zero size, leaving
            // the handles invisible and untappable.
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !widget.isSelected,
                child: AnimatedOpacity(
                  opacity: widget.isSelected ? 1 : 0,
                  duration: AppDimensions.animationFast,
                  curve: Curves.easeInOut,
                  child: Stack(
                    children: _selectionAffordances(
                      pad: pad,
                      contentWidth: contentWidth,
                      contentHeight: contentHeight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The text itself, plus the gold outline when selected. This is also
  /// the drag surface for moving the box.
  Widget _body(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onSelect,
      onPanStart: _onDragStart,
      onPanUpdate: (details) => _onDragUpdate(details, _DragTarget.body),
      onPanEnd: _onDragEnd,
      onPanCancel: () => _lastPoint = null,
      child: Semantics(
        label: 'Text box: ${widget.element.content}',
        selected: widget.isSelected,
        child: AnimatedContainer(
          duration: AppDimensions.animationFast,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryAccent
                  : Colors.transparent,
              width: AppDimensions.textBoxBorderWidth,
            ),
          ),
          child: ClipRect(
            child: Center(
              child: Text(
                widget.element.content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  // The spec's fallback style for text on an invitation:
                  // serif, charcoal. Font, colour and alignment become
                  // user-controllable with the formatting panel.
                  fontFamily: 'PlayfairDisplay',
                  color: AppColors.textPrimary,
                  fontSize:
                      widget.element.fontSize * widget.pageSize.height,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Four corner resize handles and one rotation handle.
  List<Widget> _selectionAffordances({
    required double pad,
    required double contentWidth,
    required double contentHeight,
  }) {
    const touch = AppDimensions.textBoxHandleTouchSize;
    final half = touch / 2;

    // Corner centres, in the outer box's coordinate space.
    final corners = <Offset>[
      Offset(pad, pad),
      Offset(pad + contentWidth, pad),
      Offset(pad, pad + contentHeight),
      Offset(pad + contentWidth, pad + contentHeight),
    ];

    final rotationCentre = Offset(
      pad + contentWidth / 2,
      pad - AppDimensions.textBoxRotationHandleGap,
    );

    return [
      // Stem connecting the box to its rotation handle, so the handle
      // reads as part of the box rather than a stray dot.
      Positioned(
        left: pad + contentWidth / 2 - AppDimensions.textBoxBorderWidth / 2,
        top: rotationCentre.dy,
        width: AppDimensions.textBoxBorderWidth,
        height: AppDimensions.textBoxRotationHandleGap,
        child: const ColoredBox(color: AppColors.primaryAccent),
      ),
      for (final corner in corners)
        Positioned(
          left: corner.dx - half,
          top: corner.dy - half,
          width: touch,
          height: touch,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _onDragStart,
            onPanUpdate: (d) => _onDragUpdate(d, _DragTarget.resize),
            onPanEnd: _onDragEnd,
            onPanCancel: () => _lastPoint = null,
            child: const Center(child: _Handle(isRound: false)),
          ),
        ),
      Positioned(
        left: rotationCentre.dx - half,
        top: rotationCentre.dy - half,
        width: touch,
        height: touch,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _onDragStart,
          onPanUpdate: (d) => _onDragUpdate(d, _DragTarget.rotate),
          onPanEnd: _onDragEnd,
          onPanCancel: () => _lastPoint = null,
          child: const Center(child: _Handle(isRound: true)),
        ),
      ),
    ];
  }
}

/// A grab handle. Small enough to keep the design quiet, sitting inside a
/// much larger invisible touch target so it stays easy to hit.
class _Handle extends StatelessWidget {
  final bool isRound;

  const _Handle({required this.isRound});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.textBoxHandleVisualSize,
      height: AppDimensions.textBoxHandleVisualSize,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        shape: isRound ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isRound ? null : BorderRadius.circular(3),
        border: Border.all(color: AppColors.cardSurface, width: 2),
      ),
    );
  }
}
