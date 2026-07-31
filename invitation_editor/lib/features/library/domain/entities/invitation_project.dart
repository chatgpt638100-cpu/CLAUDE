import 'package:equatable/equatable.dart';

import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../../editor/domain/entities/text_element.dart';

/// One saved invitation — everything needed to reopen it exactly as the
/// user left it (Screen 1, Library).
///
/// This is the app's document type. It imports the editor's [TextElement]
/// and [InvitationSourceFile] rather than redefining them, because a
/// saved invitation *is* an editor document at rest; duplicating those
/// shapes here would guarantee they drift apart.
class InvitationProject extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The uploaded PDF/image this invitation is built on, or null for a
  /// blank card.
  final InvitationSourceFile? sourceFile;

  final List<TextElement> textElements;

  /// Pixel size of the rendered page the text was positioned against.
  ///
  /// Text coordinates are normalised, so these are not needed to place
  /// text — but they are needed to reproduce the page's proportions when
  /// exporting or regenerating a thumbnail without re-rendering the
  /// source first.
  final int pageWidthPx;
  final int pageHeightPx;

  /// File name (never a full path) of the cached thumbnail, if one has
  /// been generated yet.
  final String? thumbnailFileName;

  /// Absolute path to that thumbnail, resolved at read time by the data
  /// layer. Not persisted.
  final String? thumbnailPath;

  const InvitationProject({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.sourceFile,
    required this.textElements,
    required this.pageWidthPx,
    required this.pageHeightPx,
    this.thumbnailFileName,
    this.thumbnailPath,
  });

  /// Title used when the user has not named an invitation themselves.
  static const String untitled = 'Untitled invitation';

  /// A4 portrait, matching the blank-card canvas, used when there is no
  /// source page to measure.
  static const int blankPageWidthPx = 1240;
  static const int blankPageHeightPx = 1754;

  factory InvitationProject.blank({
    required String id,
    required DateTime now,
    InvitationSourceFile? sourceFile,
    String? title,
  }) {
    return InvitationProject(
      id: id,
      title: title ?? untitled,
      createdAt: now,
      updatedAt: now,
      sourceFile: sourceFile,
      textElements: const [],
      pageWidthPx: blankPageWidthPx,
      pageHeightPx: blankPageHeightPx,
    );
  }

  double get pageAspectRatio => (pageWidthPx <= 0 || pageHeightPx <= 0)
      ? 1
      : pageWidthPx / pageHeightPx;

  bool get hasSourceFile => sourceFile != null;

  InvitationProject copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    InvitationSourceFile? sourceFile,
    bool clearSourceFile = false,
    List<TextElement>? textElements,
    int? pageWidthPx,
    int? pageHeightPx,
    String? thumbnailFileName,
    String? thumbnailPath,
  }) {
    return InvitationProject(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceFile: clearSourceFile ? null : (sourceFile ?? this.sourceFile),
      textElements: textElements ?? this.textElements,
      pageWidthPx: pageWidthPx ?? this.pageWidthPx,
      pageHeightPx: pageHeightPx ?? this.pageHeightPx,
      thumbnailFileName: thumbnailFileName ?? this.thumbnailFileName,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Case-insensitive title match, used by the Library search field.
  bool matches(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return true;
    return title.toLowerCase().contains(trimmed);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        createdAt,
        updatedAt,
        sourceFile,
        textElements,
        pageWidthPx,
        pageHeightPx,
        thumbnailFileName,
        thumbnailPath,
      ];
}
