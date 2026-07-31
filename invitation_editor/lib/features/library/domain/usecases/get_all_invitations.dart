import '../entities/invitation_project.dart';
import '../repositories/invitation_repository.dart';

/// Loads every saved invitation for the Library grid (Screen 1),
/// newest edit first.
class GetAllInvitations {
  final InvitationRepository repository;

  const GetAllInvitations(this.repository);

  Future<List<InvitationProject>> call() => repository.getAll();
}
