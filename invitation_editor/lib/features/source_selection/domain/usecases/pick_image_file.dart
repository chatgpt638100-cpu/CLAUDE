import '../../../editor/domain/entities/invitation_source_file.dart';
import '../repositories/file_picker_repository.dart';

/// Lets the user pick a JPG/PNG image to start an invitation from
/// (Screen 2 — "Upload an Image").
class PickImageFile {
  final FilePickerRepository repository;

  const PickImageFile(this.repository);

  Future<InvitationSourceFile?> call() => repository.pickImage();
}
