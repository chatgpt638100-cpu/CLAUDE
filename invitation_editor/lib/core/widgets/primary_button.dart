import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Solid gold fill, charcoal text — per spec, Section 1 — Buttons.
/// Every icon must be paired with a text label; no icon-only buttons.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: AppDimensions.spaceS),
              Text(label),
            ],
          );

    final button = ElevatedButton(
      onPressed: onPressed,
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
