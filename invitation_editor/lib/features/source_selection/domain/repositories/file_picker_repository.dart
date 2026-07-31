import '../../../editor/domain/entities/invitation_source_file.dart';

/// Domain-level contract for picking a file to start an invitation
/// from. The implementation (which package is used, how paths are
/// resolved) lives entirely in the data layer.
///
/// Returns `null` if the user cancels the picker without choosing a
/// file. Throws a [Failure] (see core/errors/failures.dart) if the
/// pick operation itself fails.
abstract class FilePickerRepository {
  Future<InvitationSourceFile?> pickPdf();

  Future<InvitationSourceFile?> pickImage();
}
