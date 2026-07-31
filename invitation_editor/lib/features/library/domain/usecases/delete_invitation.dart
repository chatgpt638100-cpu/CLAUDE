import '../repositories/invitation_repository.dart';

/// Permanently removes an invitation and its files (Screen 1 — Options →
/// Delete).
///
/// Unlike deleting a text box, this is irreversible, so the spec requires
/// the caller to confirm first with a dialog.
class DeleteInvitation {
  final InvitationRepository repository;

  const DeleteInvitation(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
