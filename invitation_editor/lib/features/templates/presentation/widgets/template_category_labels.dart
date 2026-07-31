import '../../domain/entities/template_category.dart';

/// User-facing names for the categories.
///
/// Kept in the presentation layer so the domain enum carries no display
/// copy — the same reason alignment and shadow labels live beside the
/// formatting panel rather than in the entity.
String templateCategoryLabel(TemplateCategory category) => switch (category) {
      TemplateCategory.wedding => 'Wedding',
      TemplateCategory.birthday => 'Birthday',
      TemplateCategory.holiday => 'Holiday',
      TemplateCategory.anniversary => 'Anniversary',
      TemplateCategory.other => 'Other',
    };
