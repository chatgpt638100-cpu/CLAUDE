import '../entities/invitation_project.dart';
import '../repositories/invitation_repository.dart';

/// Copies an invitation (Screen 1 — Options → Duplicate).
///
/// [newId] is supplied by the caller so id generation stays in one place
/// rather than being reinvented inside the storage layer.
class DuplicateInvitation {
  final InvitationRepository repository;

  const DuplicateInvitation(this.repository);

  Future<InvitationProject> call(String id, {required String newId}) {
    return repository.duplicate(id, newId: newId);
  }
}
