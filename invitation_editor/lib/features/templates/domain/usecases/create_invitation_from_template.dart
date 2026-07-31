import '../../../library/domain/entities/invitation_project.dart';
import '../../../library/domain/repositories/invitation_repository.dart';
import '../repositories/template_repository.dart';

/// Starts a new invitation from a saved template (Screen 3 — "Tapping a
/// template → opens directly in Editor, pre-loaded").
///
/// Crosses two features on purpose: this is precisely the seam where a
/// template becomes an invitation, and putting it anywhere else would push
/// that knowledge into a screen.
///
/// The new invitation is saved immediately, which also copies the artwork
/// into the invitation's own `sources/` folder. From that moment the two
/// are independent: editing the invitation cannot alter the template, and
/// deleting the template cannot break the invitation.
class CreateInvitationFromTemplate {
  final TemplateRepository templateRepository;
  final InvitationRepository invitationRepository;

  const CreateInvitationFromTemplate({
    required this.templateRepository,
    required this.invitationRepository,
  });

  /// Returns null when the template has gone, so the caller can say so
  /// rather than opening an empty Editor.
  Future<InvitationProject?> call(
    String templateId, {
    required String newInvitationId,
  }) async {
    final template = await templateRepository.getById(templateId);
    if (template == null) return null;

    final now = DateTime.now();

    return invitationRepository.save(
      InvitationProject(
        id: newInvitationId,
        // Named after the template so the Library entry is recognisable
        // straight away; the user can rename it from the Editor's top bar.
        title: template.name,
        createdAt: now,
        updatedAt: now,
        sourceFile: template.sourceFile,
        textElements: template.textElements,
        pageWidthPx: template.pageWidthPx,
        pageHeightPx: template.pageHeightPx,
      ),
    );
  }
}
