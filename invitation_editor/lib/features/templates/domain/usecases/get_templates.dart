import '../entities/invitation_template.dart';
import '../entities/template_category.dart';
import '../repositories/template_repository.dart';

/// Loads saved templates for the Template Library grid (Screen 3),
/// optionally narrowed to one category.
///
/// A null [category] means "All" — the default tab.
class GetTemplates {
  final TemplateRepository repository;

  const GetTemplates(this.repository);

  Future<List<InvitationTemplate>> call({TemplateCategory? category}) async {
    final templates = await repository.getAll();
    if (category == null) return templates;
    return [
      for (final template in templates)
        if (template.category == category) template,
    ];
  }
}
