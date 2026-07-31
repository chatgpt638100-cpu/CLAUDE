import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/service_locator.dart';
import '../../domain/entities/invitation_page.dart';
import '../../domain/entities/invitation_source_file.dart';
import '../../domain/usecases/load_invitation_preview.dart';

/// Renders the first page of the given source file for the Editor canvas
/// (Screen 4).
///
/// A [FutureProvider] gives us the three states the canvas needs —
/// loading, error, and data — without hand-rolling any of them.
///
/// Keyed on the source file (`family`) so switching invitations loads
/// the right page, and `autoDispose` so the rendered bitmap is released
/// once the Editor is closed instead of being held for the whole
/// session.
///
/// The use case itself is resolved through GetIt, so this provider stays
/// a thin bridge between Riverpod and the domain layer.
final invitationPreviewProvider = FutureProvider.autoDispose
    .family<InvitationPage, InvitationSourceFile>((ref, sourceFile) {
  return sl<LoadInvitationPreview>()(sourceFile);
});
