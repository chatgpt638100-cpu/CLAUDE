import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bar_widget.dart';

/// Screen 7 — Settings.
/// Placeholder only — content to be built in a later phase.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Settings', showBackLabel: true),
      body: const Center(child: Text('Settings — coming in a later phase')),
    );
  }
}
