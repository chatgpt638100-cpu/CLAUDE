import '../entities/invitation_page.dart';
import '../entities/invitation_source_file.dart';
import '../repositories/invitation_preview_repository.dart';

/// Loads the first page of the selected invitation so it can be shown
/// on the Editor canvas (Screen 4 — Canvas).
class LoadInvitationPreview {
  final InvitationPreviewRepository repository;

  const LoadInvitationPreview(this.repository);

  Future<InvitationPage> call(InvitationSourceFile sourceFile) =>
      repository.renderFirstPage(sourceFile);
}
