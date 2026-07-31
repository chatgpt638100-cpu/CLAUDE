import '../../../editor/domain/entities/invitation_source_file.dart';
import '../repositories/file_picker_repository.dart';

/// Lets the user pick a PDF file to start an invitation from
/// (Screen 2 — "Upload a PDF").
class PickPdfFile {
  final FilePickerRepository repository;

  const PickPdfFile(this.repository);

  Future<InvitationSourceFile?> call() => repository.pickPdf();
}
