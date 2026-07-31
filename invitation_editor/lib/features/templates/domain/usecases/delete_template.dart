import '../repositories/template_repository.dart';

/// Removes a saved template and its files (Screen 3).
///
/// Irreversible, so the caller confirms with a dialog first. Invitations
/// already created from the template are untouched — each got its own copy
/// of the artwork when it was created.
class DeleteTemplate {
  final TemplateRepository repository;

  const DeleteTemplate(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
