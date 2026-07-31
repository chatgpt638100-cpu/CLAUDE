import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../../editor/domain/entities/text_element.dart';
import '../../../editor/domain/entities/text_format.dart';
import '../../domain/entities/invitation_project.dart';

/// How a saved invitation looks in storage.
///
/// Hand-written JSON mapping rather than generated adapters — see
/// `core/storage/local_storage.dart` for why.
///
/// ## Forward compatibility
///
/// Every read goes through helpers that supply a default when a field is
/// absent or the wrong type. A record written by an older version of the
/// app therefore loads instead of throwing, and [schemaVersion] is
/// carried so a future migration can tell generations apart. Losing
/// someone's invitations to a schema change is not an acceptable failure.
class InvitationProjectModel {
  InvitationProjectModel._();

  /// Bump when the shape changes in a way a migration must know about.
  static const int schemaVersion = 1;

  static Map<String, dynamic> toJson(InvitationProject project) {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'id': project.id,
      'title': project.title,
      'createdAt': project.createdAt.toIso8601String(),
      'updatedAt': project.updatedAt.toIso8601String(),
      'pageWidthPx': project.pageWidthPx,
      'pageHeightPx': project.pageHeightPx,
      // File name only, never an absolute path — see AppPaths.
      'thumbnailFileName': project.thumbnailFileName,
      'source': sourceToJson(project.sourceFile),
      'textElements': [
        for (final element in project.textElements) elementToJson(element),
      ],
    };
  }

  /// [resolveSourcePath] and [resolveThumbnailPath] turn stored file names
  /// back into absolute paths, which only the data layer knows how to do.
  static InvitationProject fromJson(
    Map<String, dynamic> json, {
    required String? Function(String fileName) resolveSourcePath,
    required String? Function(String fileName) resolveThumbnailPath,
  }) {
    final thumbnailFileName = stringOrNull(json['thumbnailFileName']);

    return InvitationProject(
      id: string(json['id'], ''),
      title: string(json['title'], InvitationProject.untitled),
      createdAt: dateTime(json['createdAt']),
      updatedAt: dateTime(json['updatedAt']),
      pageWidthPx: integer(json['pageWidthPx'], InvitationProject.blankPageWidthPx),
      pageHeightPx:
          integer(json['pageHeightPx'], InvitationProject.blankPageHeightPx),
      thumbnailFileName: thumbnailFileName,
      thumbnailPath: thumbnailFileName == null
          ? null
          : resolveThumbnailPath(thumbnailFileName),
      sourceFile: sourceFromJson(json['source'], resolveSourcePath),
      textElements: [
        for (final raw in list(json['textElements']))
          if (raw is Map) elementFromJson(raw.cast<String, dynamic>()),
      ],
    );
  }

  // ---------------------------------------------------------------- source

  static Map<String, dynamic>? sourceToJson(InvitationSourceFile? source) {
    if (source == null) return null;
    return <String, dynamic>{
      // The path is intentionally not stored; the file name is enough to
      // rebuild it, and paths do not survive reinstalls.
      'fileName': source.fileName,
      'type': source.type.name,
    };
  }

  static InvitationSourceFile? sourceFromJson(
    Object? raw,
    String? Function(String fileName) resolvePath,
  ) {
    if (raw is! Map) return null;

    final json = raw.cast<String, dynamic>();
    final fileName = stringOrNull(json['fileName']);
    if (fileName == null) return null;

    final path = resolvePath(fileName);
    // The artwork has gone missing — treat it as a blank card rather than
    // opening an Editor pointed at a file that is not there.
    if (path == null) return null;

    return InvitationSourceFile(
      path: path,
      fileName: fileName,
      type: enumValue(
        json['type'],
        InvitationFileType.values,
        InvitationFileType.image,
      ),
    );
  }

  // --------------------------------------------------------------- element

  static Map<String, dynamic> elementToJson(TextElement element) {
    return <String, dynamic>{
      'id': element.id,
      'content': element.content,
      'x': element.x,
      'y': element.y,
      'width': element.width,
      'height': element.height,
      'rotation': element.rotation,
      'fontSize': element.fontSize,
      'fontFamily': element.fontFamily,
      'colorValue': element.colorValue,
      'isBold': element.isBold,
      'isItalic': element.isItalic,
      'isUnderlined': element.isUnderlined,
      'alignment': element.alignment.name,
      'letterSpacing': element.letterSpacing,
      'lineHeight': element.lineHeight,
      'opacity': element.opacity,
      'shadow': element.shadow.name,
    };
  }

  static TextElement elementFromJson(Map<String, dynamic> json) {
    return TextElement(
      id: string(json['id'], ''),
      content: string(json['content'], ''),
      x: decimal(json['x'], 0),
      y: decimal(json['y'], 0),
      width: decimal(json['width'], TextElement.defaultWidth),
      height: decimal(json['height'], TextElement.defaultHeight),
      rotation: decimal(json['rotation'], 0),
      fontSize: decimal(json['fontSize'], TextElement.defaultFontSize),
      fontFamily: string(json['fontFamily'], 'Playfair Display'),
      colorValue: integer(json['colorValue'], TextElement.defaultColorValue),
      isBold: boolean(json['isBold']),
      isItalic: boolean(json['isItalic']),
      isUnderlined: boolean(json['isUnderlined']),
      alignment: enumValue(
        json['alignment'],
        TextAlignmentOption.values,
        TextAlignmentOption.centre,
      ),
      letterSpacing:
          decimal(json['letterSpacing'], TextElement.defaultLetterSpacing),
      lineHeight: decimal(json['lineHeight'], TextElement.defaultLineHeight),
      opacity: decimal(json['opacity'], TextElement.defaultOpacity),
      shadow: enumValue(
        json['shadow'],
        TextShadowStyle.values,
        TextShadowStyle.none,
      ),
    );
  }

  // --------------------------------------------------------------- helpers
  // Every reader is total: it returns a usable value for any input,
  // including null and the wrong type.
  //
  // Public because the template model reuses them: a template holds the
  // same text boxes as an invitation, so encoding them twice would be two
  // places to update and one chance to let them drift apart.

  static String string(Object? value, String fallback) =>
      value is String && value.isNotEmpty ? value : fallback;

  static String? stringOrNull(Object? value) =>
      value is String && value.isNotEmpty ? value : null;

  static double decimal(Object? value, double fallback) =>
      value is num ? value.toDouble() : fallback;

  static int integer(Object? value, int fallback) =>
      value is num ? value.toInt() : fallback;

  static bool boolean(Object? value) => value is bool && value;

  static List<Object?> list(Object? value) =>
      value is List ? value : const <Object?>[];

  static DateTime dateTime(Object? value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    // A record with an unreadable date still belongs in the library; it
    // simply sorts as if edited now.
    return DateTime.now();
  }

  static T enumValue<T extends Enum>(Object? value, List<T> values, T fallback) {
    if (value is String) {
      for (final candidate in values) {
        if (candidate.name == value) return candidate;
      }
    }
    return fallback;
  }
}
