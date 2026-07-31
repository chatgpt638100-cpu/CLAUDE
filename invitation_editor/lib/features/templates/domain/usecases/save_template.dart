import 'dart:typed_data';

import '../../../library/domain/entities/invitation_project.dart';
import '../entities/invitation_template.dart';
import '../entities/template_category.dart';
import '../repositories/template_repository.dart';

/// Turns the invitation currently open in the Editor into a reusable
/// template (Screen 5 — "Save as Template").
///
/// Everything about each text box is carried over untouched — position,
/// size, rotation, font, colour, alignment. That is the whole point:
/// reusing the template for the next guest should need a new name and
/// nothing else.
class SaveTemplate {
  final TemplateRepository repository;

  const SaveTemplate(this.repository);

  Future<InvitationTemplate> call({
    required String id,
    required InvitationProject project,
    required String name,
    required TemplateCategory category,
    Uint8List? thumbnailBytes,
  }) {
    final trimmed = name.trim();

    return repository.save(
      InvitationTemplate(
        id: id,
        name: trimmed.isEmpty ? InvitationTemplate.untitled : trimmed,
        category: category,
        createdAt: DateTime.now(),
        sourceFile: project.sourceFile,
        textElements: project.textElements,
        pageWidthPx: project.pageWidthPx,
        pageHeightPx: project.pageHeightPx,
      ),
      thumbnailBytes: thumbnailBytes,
    );
  }
}
