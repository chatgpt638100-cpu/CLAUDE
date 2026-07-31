import 'package:get_it/get_it.dart';

import '../core/utils/id_generator.dart';
import '../features/editor/data/repositories/invitation_preview_repository_impl.dart';
import '../features/editor/domain/repositories/invitation_preview_repository.dart';
import '../features/editor/domain/usecases/add_text_element.dart';
import '../features/editor/domain/usecases/delete_text_element.dart';
import '../features/editor/domain/usecases/duplicate_text_element.dart';
import '../features/editor/domain/usecases/load_invitation_preview.dart';
import '../features/editor/domain/usecases/move_text_element.dart';
import '../features/editor/domain/usecases/reorder_text_element.dart';
import '../features/editor/domain/usecases/resize_text_element.dart';
import '../features/editor/domain/usecases/restore_text_element.dart';
import '../features/editor/domain/usecases/rotate_text_element.dart';
import '../features/editor/domain/usecases/select_text_element.dart';
import '../features/editor/domain/usecases/update_text_content.dart';
import '../features/source_selection/data/repositories/file_picker_repository_impl.dart';
import '../features/source_selection/domain/repositories/file_picker_repository.dart';
import '../features/source_selection/domain/usecases/pick_image_file.dart';
import '../features/source_selection/domain/usecases/pick_pdf_file.dart';

/// Wires the layers together (repositories, use-cases, etc.).
/// Called once from main() so the wiring point already exists for
/// later phases.
final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  sl.registerLazySingleton(() => IdGenerator());

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

  // Editor — text box editing. Each use case is a pure transformation of
  // the canvas state, so they hold no dependencies of their own.
  sl.registerLazySingleton(() => const AddTextElement());
  sl.registerLazySingleton(() => const UpdateTextContent());
  sl.registerLazySingleton(() => const SelectTextElement());
  sl.registerLazySingleton(() => const MoveTextElement());
  sl.registerLazySingleton(() => const ResizeTextElement());
  sl.registerLazySingleton(() => const RotateTextElement());
  sl.registerLazySingleton(() => const DuplicateTextElement());
  sl.registerLazySingleton(() => const ReorderTextElement());
  sl.registerLazySingleton(() => const DeleteTextElement());
  sl.registerLazySingleton(() => const RestoreTextElement());
}
