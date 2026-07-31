import 'dart:typed_data';

import '../entities/invitation_project.dart';
import '../repositories/invitation_repository.dart';

/// Writes an invitation to storage — used both by the explicit "Save"
/// button and by the Editor's auto-save.
class SaveInvitation {
  final InvitationRepository repository;

  const SaveInvitation(this.repository);

  Future<InvitationProject> call(
    InvitationProject project, {
    Uint8List? thumbnailBytes,
  }) {
    return repository.save(project, thumbnailBytes: thumbnailBytes);
  }
}
