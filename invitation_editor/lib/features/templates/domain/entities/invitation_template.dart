import 'package:equatable/equatable.dart';

import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../../editor/domain/entities/text_element.dart';
import 'template_category.dart';

/// A saved design the user can start new invitations from (Screen 3 —
/// Template Library, saved via Screen 5).
///
/// Deliberately a separate type from `InvitationProject` rather than a
/// flag on it. They diverge in what they mean: a project is one
/// invitation with a last-edited time, a template is a reusable starting
/// point with a category. Sharing one type would mean every screen
/// checking which kind it was holding.
///
/// The text boxes keep their exact position, size, rotation and styling,
/// so reusing a template needs no repositioning or reformatting — only
/// the words change.
class InvitationTemplate extends Equatable {
  final String id;
  final String name;
  final TemplateCategory category;
  final DateTime createdAt;

  /// The template's own copy of the artwork, kept in `templates/` so it
  /// survives the invitation it was created from being deleted.
  final InvitationSourceFile? sourceFile;

  final List<TextElement> textElements;

  final int pageWidthPx;
  final int pageHeightPx;

  /// File name only, never a full path — see AppPaths.
  final String? thumbnailFileName;

  /// Resolved at read time by the data layer. Not persisted.
  final String? thumbnailPath;

  const InvitationTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.sourceFile,
    required this.textElements,
    required this.pageWidthPx,
    required this.pageHeightPx,
    this.thumbnailFileName,
    this.thumbnailPath,
  });

  static const String untitled = 'Untitled template';

  bool get hasSourceFile => sourceFile != null;

  InvitationTemplate copyWith({
    String? id,
    String? name,
    TemplateCategory? category,
    DateTime? createdAt,
    InvitationSourceFile? sourceFile,
    bool clearSourceFile = false,
    List<TextElement>? textElements,
    int? pageWidthPx,
    int? pageHeightPx,
    String? thumbnailFileName,
    String? thumbnailPath,
  }) {
    return InvitationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      sourceFile: clearSourceFile ? null : (sourceFile ?? this.sourceFile),
      textElements: textElements ?? this.textElements,
      pageWidthPx: pageWidthPx ?? this.pageWidthPx,
      pageHeightPx: pageHeightPx ?? this.pageHeightPx,
      thumbnailFileName: thumbnailFileName ?? this.thumbnailFileName,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        createdAt,
        sourceFile,
        textElements,
        pageWidthPx,
        pageHeightPx,
        thumbnailFileName,
        thumbnailPath,
      ];
}
