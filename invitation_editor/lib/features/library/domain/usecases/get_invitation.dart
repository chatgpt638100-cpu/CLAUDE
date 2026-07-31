import '../entities/invitation_project.dart';
import '../repositories/invitation_repository.dart';

/// Opens a saved invitation in the Editor (Screen 1 — "Tap any past
/// invitation → reopens in Editor").
///
/// Returns null when the id is unknown, which the caller treats as "this
/// invitation is gone" rather than as an error.
class GetInvitation {
  final InvitationRepository repository;

  const GetInvitation(this.repository);

  Future<InvitationProject?> call(String id) => repository.getById(id);
}
