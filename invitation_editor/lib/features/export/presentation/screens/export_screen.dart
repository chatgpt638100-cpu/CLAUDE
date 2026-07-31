import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bar_widget.dart';

/// Screen 6 — Export / Print.
/// Placeholder only — PDF export and printing are explicitly out
/// of scope for this phase.
class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Export / Print', showBackLabel: true),
      body: const Center(child: Text('Export / Print — coming in a later phase')),
    );
  }
}
