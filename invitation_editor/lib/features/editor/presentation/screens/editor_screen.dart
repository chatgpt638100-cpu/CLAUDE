import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_bar_widget.dart';
import '../../domain/entities/invitation_source_file.dart';
import '../widgets/canvas_view.dart';

/// Screen 4 — The Editor.
///
/// This phase covers the canvas only: the first page of the selected
/// invitation is displayed, with a calm loading state while it renders
/// and a friendly message if it cannot be opened.
///
/// Still to come in later phases: the bottom toolbar ("Add Text",
/// "Voice Type", "Templates", "Print / Export", "Menu"), the "Save"
/// action and tap-to-rename in the top bar, and pinch-to-zoom /
/// drag-to-pan on the canvas. No disabled controls are shown for those
/// yet — an empty toolbar would only invite taps that do nothing.
///
/// [sourceFile] arrives from the Source Selection screen. It is null on
/// the "Blank Card" route, in which case an empty canvas is shown.
class EditorScreen extends StatelessWidget {
  final InvitationSourceFile? sourceFile;

  const EditorScreen({super.key, this.sourceFile});

  @override
  Widget build(BuildContext context) {
    final file = sourceFile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Editor', showBackLabel: true),
      body: SafeArea(
        child: file == null
            ? const BlankCanvasView()
            : CanvasView(sourceFile: file),
      ),
    );
  }
}
