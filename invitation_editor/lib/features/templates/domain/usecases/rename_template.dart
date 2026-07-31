import '../entities/invitation_template.dart';
import '../repositories/template_repository.dart';

/// Renames a saved template (Screen 3).
class RenameTemplate {
  final TemplateRepository repository;

  const RenameTemplate(this.repository);

  Future<InvitationTemplate> call(String id, {required String name}) {
    final trimmed = name.trim();
    return repository.rename(
      id,
      name: trimmed.isEmpty ? InvitationTemplate.untitled : trimmed,
    );
  }
}
