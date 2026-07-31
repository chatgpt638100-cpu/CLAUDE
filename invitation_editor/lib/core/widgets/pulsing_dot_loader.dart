import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// A calm, slowly pulsing gold dot with a text label.
///
/// Per spec, Section 1 — Animation Philosophy: "No spinning loaders
/// where avoidable — use a calm pulsing gold dot instead." Used
/// anywhere the app is briefly busy.
///
/// The label is always shown, never an animation on its own, so the
/// user is told what is happening rather than left guessing.
class PulsingDotLoader extends StatefulWidget {
  final String label;

  const PulsingDotLoader({super.key, required this.label});

  @override
  State<PulsingDotLoader> createState() => _PulsingDotLoaderState();
}

class _PulsingDotLoaderState extends State<PulsingDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDimensions.animationPulse,
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.35,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Container(
              width: AppDimensions.loaderDotSize,
              height: AppDimensions.loaderDotSize,
              decoration: const BoxDecoration(
                color: AppColors.primaryAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
