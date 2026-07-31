import '../../../library/data/models/invitation_project_model.dart';
import '../../../library/domain/entities/invitation_project.dart';
import '../../domain/entities/invitation_template.dart';
import '../../domain/entities/template_category.dart';

/// How a saved template looks in storage.
///
/// Text boxes and source files are encoded by [InvitationProjectModel]
/// rather than duplicated here. That matters: a template and an invitation
/// hold the *same* text boxes, so two independent encoders would be two
/// places to update and one chance to let them drift.
class InvitationTemplateModel {
  InvitationTemplateModel._();

  static const int schemaVersion = 1;

  static Map<String, dynamic> toJson(InvitationTemplate template) {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'id': template.id,
      'name': template.name,
      'category': template.category.name,
      'createdAt': template.createdAt.toIso8601String(),
      'pageWidthPx': template.pageWidthPx,
      'pageHeightPx': template.pageHeightPx,
      'thumbnailFileName': template.thumbnailFileName,
      'source': InvitationProjectModel.sourceToJson(template.sourceFile),
      'textElements': [
        for (final element in template.textElements)
          InvitationProjectModel.elementToJson(element),
      ],
    };
  }

  static InvitationTemplate fromJson(
    Map<String, dynamic> json, {
    required String? Function(String fileName) resolveSourcePath,
    required String? Function(String fileName) resolveThumbnailPath,
  }) {
    final thumbnailFileName =
        InvitationProjectModel.stringOrNull(json['thumbnailFileName']);

    return InvitationTemplate(
      id: InvitationProjectModel.string(json['id'], ''),
      name: InvitationProjectModel.string(
        json['name'],
        InvitationTemplate.untitled,
      ),
      category: InvitationProjectModel.enumValue(
        json['category'],
        TemplateCategory.values,
        TemplateCategory.other,
      ),
      createdAt: InvitationProjectModel.dateTime(json['createdAt']),
      pageWidthPx: InvitationProjectModel.integer(
        json['pageWidthPx'],
        InvitationProject.blankPageWidthPx,
      ),
      pageHeightPx: InvitationProjectModel.integer(
        json['pageHeightPx'],
        InvitationProject.blankPageHeightPx,
      ),
      thumbnailFileName: thumbnailFileName,
      thumbnailPath: thumbnailFileName == null
          ? null
          : resolveThumbnailPath(thumbnailFileName),
      sourceFile: InvitationProjectModel.sourceFromJson(
        json['source'],
        resolveSourcePath,
      ),
      textElements: [
        for (final raw in InvitationProjectModel.list(json['textElements']))
          if (raw is Map)
            InvitationProjectModel.elementFromJson(raw.cast<String, dynamic>()),
      ],
    );
  }
}


