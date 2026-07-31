import 'package:get_it/get_it.dart';

import '../core/utils/app_paths.dart';
import '../core/utils/id_generator.dart';
import '../features/library/data/datasources/invitation_local_data_source.dart';
import '../features/library/data/repositories/invitation_repository_impl.dart';
import '../features/library/domain/repositories/invitation_repository.dart';
import '../features/library/domain/usecases/delete_invitation.dart';
import '../features/library/domain/usecases/duplicate_invitation.dart';
import '../features/library/domain/usecases/get_all_invitations.dart';
import '../features/library/domain/usecases/get_invitation.dart';
import '../features/library/domain/usecases/get_recent_invitations.dart';
import '../features/library/domain/usecases/rename_invitation.dart';
import '../features/library/domain/usecases/save_invitation.dart';
import '../features/library/domain/usecases/search_invitations.dart';
import '../features/export/data/renderers/invitation_page_renderer.dart';
import '../features/export/data/repositories/export_repository_impl.dart';
import '../features/export/domain/repositories/export_repository.dart';
import '../features/export/domain/usecases/export_to_pdf.dart';
import '../features/export/domain/usecases/print_invitation.dart';
import '../features/export/domain/usecases/share_invitation.dart';
import '../features/templates/data/datasources/template_local_data_source.dart';
import '../features/templates/data/repositories/template_repository_impl.dart';
import '../features/templates/domain/repositories/template_repository.dart';
import '../features/templates/domain/usecases/create_invitation_from_template.dart';
import '../features/templates/domain/usecases/delete_template.dart';
import '../features/templates/domain/usecases/get_templates.dart';
import '../features/templates/domain/usecases/rename_template.dart';
import '../features/templates/domain/usecases/save_template.dart';
import '../features/editor/data/repositories/invitation_preview_repository_impl.dart';
import '../features/editor/domain/repositories/invitation_preview_repository.dart';
import '../features/editor/domain/usecases/add_text_element.dart';
import '../features/editor/domain/usecases/delete_text_element.dart';
import '../features/editor/domain/usecases/duplicate_text_element.dart';
import '../features/editor/domain/usecases/format_text_element.dart';
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
  sl.registerLazySingleton(() => AppPaths());

  // Library — saved invitations
  sl.registerLazySingleton<InvitationLocalDataSource>(
    () => InvitationLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAllInvitations(sl()));
  sl.registerLazySingleton(() => GetInvitation(sl()));
  sl.registerLazySingleton(() => SaveInvitation(sl()));
  sl.registerLazySingleton(() => DeleteInvitation(sl()));
  sl.registerLazySingleton(() => DuplicateInvitation(sl()));
  sl.registerLazySingleton(() => RenameInvitation(sl()));
  sl.registerLazySingleton(() => const SearchInvitations());
  sl.registerLazySingleton(() => const GetRecentInvitations());

  // Templates — saved designs
  sl.registerLazySingleton<TemplateLocalDataSource>(
    () => TemplateLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TemplateRepository>(
    () => TemplateRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetTemplates(sl()));
  sl.registerLazySingleton(() => SaveTemplate(sl()));
  sl.registerLazySingleton(() => DeleteTemplate(sl()));
  sl.registerLazySingleton(() => RenameTemplate(sl()));
  // Spans two features, so both repositories are named explicitly rather
  // than relying on positional inference.
  sl.registerLazySingleton(
    () => CreateInvitationFromTemplate(
      templateRepository: sl(),
      invitationRepository: sl(),
    ),
  );

  // Export — PDF, print, share
  sl.registerLazySingleton(() => const InvitationPageRenderer());
  sl.registerLazySingleton<ExportRepository>(
    () => ExportRepositoryImpl(
      previewRepository: sl(),
      renderer: sl(),
      appPaths: sl(),
    ),
  );
  sl.registerLazySingleton(() => ExportToPdf(sl()));
  sl.registerLazySingleton(() => PrintInvitation(sl()));
  sl.registerLazySingleton(() => ShareInvitation(sl()));

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
  sl.registerLazySingleton(() => const FormatTextElement());
  sl.registerLazySingleton(() => const SelectTextElement());
  sl.registerLazySingleton(() => const MoveTextElement());
  sl.registerLazySingleton(() => const ResizeTextElement());
  sl.registerLazySingleton(() => const RotateTextElement());
  sl.registerLazySingleton(() => const DuplicateTextElement());
  sl.registerLazySingleton(() => const ReorderTextElement());
  sl.registerLazySingleton(() => const DeleteTextElement());
  sl.registerLazySingleton(() => const RestoreTextElement());
}
