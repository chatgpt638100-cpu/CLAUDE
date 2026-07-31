import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/service_locator.dart';
import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../../editor/presentation/providers/invitation_preview_provider.dart';
import '../../domain/entities/font_suggestion.dart';
import '../../domain/usecases/analyze_invitation_style.dart';

/// The analyser's reading of the invitation currently open (Feature 6.2).
///
/// Chained off the preview rather than re-reading the file: the page has
/// already been decoded for the canvas, so this reuses those bytes instead of
/// doing the work twice.
///
/// Resolves to null — never an error — when there is nothing confident to
/// say. The spec is explicit that an uncertain reading must not feel like a
/// failure, so there is no error state for the UI to render.
final fontSuggestionProvider = FutureProvider.autoDispose
    .family<FontSuggestion?, InvitationSourceFile>((ref, sourceFile) async {
  final page = await ref.watch(invitationPreviewProvider(sourceFile).future);
  return sl<AnalyzeInvitationStyle>()(page.imageBytes);
});
