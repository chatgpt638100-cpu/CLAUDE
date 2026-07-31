import 'package:file_picker/file_picker.dart';

import '../../../../core/errors/failures.dart';
import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../domain/repositories/file_picker_repository.dart';

/// Concrete [FilePickerRepository] backed by the `file_picker` package.
/// This is the only place that knows about `file_picker` — the rest of
/// the app depends only on the domain contract.
class FilePickerRepositoryImpl implements FilePickerRepository {
  const FilePickerRepositoryImpl();

  @override
  Future<InvitationSourceFile?> pickPdf() async {
    return _pick(
      allowedExtensions: const ['pdf'],
      type: InvitationFileType.pdf,
    );
  }

  @override
  Future<InvitationSourceFile?> pickImage() async {
    return _pick(
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      type: InvitationFileType.image,
    );
  }

  Future<InvitationSourceFile?> _pick({
    required List<String> allowedExtensions,
    required InvitationFileType type,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled the picker.
        return null;
      }

      final picked = result.files.single;
      final path = picked.path;
      if (path == null) {
        throw const FileLoadFailure();
      }

      return InvitationSourceFile(
        path: path,
        fileName: picked.name,
        type: type,
      );
    } on FileLoadFailure {
      rethrow;
    } catch (_) {
      throw const FileLoadFailure();
    }
  }
}
