import '../entities/invitation_project.dart';
import '../repositories/invitation_repository.dart';

/// Renames an invitation (Screen 1 — Options → Rename, and tapping the
/// title in the Editor's top bar).
class RenameInvitation {
  final InvitationRepository repository;

  const RenameInvitation(this.repository);

  Future<InvitationProject> call(String id, {required String title}) {
    final trimmed = title.trim();
    return repository.rename(
      id,
      // An empty name would leave a blank label under the thumbnail with
      // no way to tell the invitations apart.
      title: trimmed.isEmpty ? InvitationProject.untitled : trimmed,
    );
  }
}
