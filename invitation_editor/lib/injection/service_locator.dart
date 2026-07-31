import 'package:get_it/get_it.dart';

import '../features/editor/data/repositories/invitation_preview_repository_impl.dart';
import '../features/editor/domain/repositories/invitation_preview_repository.dart';
import '../features/editor/domain/usecases/load_invitation_preview.dart';
import '../features/source_selection/data/repositories/file_picker_repository_impl.dart';
import '../features/source_selection/domain/repositories/file_picker_repository.dart';
import '../features/source_selection/domain/usecases/pick_image_file.dart';
import '../features/source_selection/domain/usecases/pick_pdf_file.dart';

/// Wires the layers together (repositories, use-cases, etc.).
/// Called once from main() so the wiring point already exists for
/// later phases.
final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Source Selection — file picking
  sl.registerLazySingleton<FilePickerRepository>(
    () => const FilePickerRepositoryImpl(),
  );
  sl.registerLazySingleton(() => PickPdfFile(sl()));
  sl.registerLazySingleton(() => PickImageFile(sl()));

  // Editor — rendering the selected invitation onto the canvas
  sl.registerLazySingleton<InvitationPreviewRepository>(
    () => const InvitationPreviewRepositoryImpl(),
  );
  sl.registerLazySingleton(() => LoadInvitationPreview(sl()));
}
