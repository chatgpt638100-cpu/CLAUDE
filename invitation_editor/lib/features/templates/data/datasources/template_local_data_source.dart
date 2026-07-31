import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_paths.dart';
import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../domain/entities/invitation_template.dart';
import '../models/invitation_template_model.dart';

/// Reads and writes templates to Hive, and owns their artwork and
/// thumbnails.
///
/// Template artwork lives in `templates/`, separate from an invitation's
/// `sources/`. That separation is the point: deleting the invitation a
/// template was created from must not strip the template of its artwork.
abstract class TemplateLocalDataSource {
  Future<List<InvitationTemplate>> readAll();

  Future<InvitationTemplate?> read(String id);

  Future<InvitationTemplate> write(
    InvitationTemplate template, {
    Uint8List? thumbnailBytes,
  });

  Future<void> delete(String id);
}

class TemplateLocalDataSourceImpl implements TemplateLocalDataSource {
  final AppPaths appPaths;

  TemplateLocalDataSourceImpl(this.appPaths);

  Box<String> get _box => LocalStorage.box(LocalStorage.templatesBox);

  String? _templatesPath;
  String? _thumbnailsPath;

  Future<void> _primePathCache() async {
    _templatesPath ??= (await appPaths.templatesDirectory()).path;
    _thumbnailsPath ??= (await appPaths.thumbnailsDirectory()).path;
  }

  String _join(String directory, String fileName) =>
      '$directory${Platform.pathSeparator}$fileName';

  @override
  Future<List<InvitationTemplate>> readAll() async {
    await _primePathCache();

    final templates = <InvitationTemplate>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final template = _decode(raw);
      // One unreadable record must not hide every other template.
      if (template != null) templates.add(template);
    }

    templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return templates;
  }

  @override
  Future<InvitationTemplate?> read(String id) async {
    await _primePathCache();
    final raw = _box.get(id);
    return raw == null ? null : _decode(raw);
  }

  InvitationTemplate? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      return InvitationTemplateModel.fromJson(
        decoded.cast<String, dynamic>(),
        resolveSourcePath: (fileName) {
          final path = _join(_templatesPath!, fileName);
          return File(path).existsSync() ? path : null;
        },
        resolveThumbnailPath: (fileName) {
          final path = _join(_thumbnailsPath!, fileName);
          return File(path).existsSync() ? path : null;
        },
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<InvitationTemplate> write(
    InvitationTemplate template, {
    Uint8List? thumbnailBytes,
  }) async {
    await _primePathCache();

    var stored = template;

    // Take the template's own copy of the artwork. Without this the
    // template would point at the invitation's file, and deleting that
    // invitation would quietly empty the template.
    final source = template.sourceFile;
    if (source != null && !source.path.startsWith(_templatesPath!)) {
      final copiedName = await _copyArtwork(template.id, source);
      if (copiedName != null) {
        stored = stored.copyWith(
          sourceFile: InvitationSourceFile(
            path: _join(_templatesPath!, copiedName),
            fileName: copiedName,
            type: source.type,
          ),
        );
      } else {
        // The original has vanished; keep the layout as a blank template
        // rather than storing a broken reference.
        stored = stored.copyWith(clearSourceFile: true);
      }
    }

    if (thumbnailBytes != null) {
      final fileName = '${template.id}.png';
      final file = File(_join(_thumbnailsPath!, fileName));
      await file.writeAsBytes(thumbnailBytes, flush: true);
      stored = stored.copyWith(
        thumbnailFileName: fileName,
        thumbnailPath: file.path,
      );
    }

    await _box.put(
      stored.id,
      jsonEncode(InvitationTemplateModel.toJson(stored)),
    );
    return stored;
  }

  Future<String?> _copyArtwork(
    String templateId,
    InvitationSourceFile source,
  ) async {
    final original = File(source.path);
    if (!await original.exists()) return null;

    // Keep the real extension so the PDF rasteriser and image decoders
    // still recognise the file.
    final dot = source.fileName.lastIndexOf('.');
    final extension = (dot > 0 && dot < source.fileName.length - 1)
        ? source.fileName.substring(dot).toLowerCase()
        : (source.type == InvitationFileType.pdf ? '.pdf' : '.png');

    final fileName = '$templateId$extension';
    await original.copy(_join(_templatesPath!, fileName));
    return fileName;
  }

  @override
  Future<void> delete(String id) async {
    await _primePathCache();

    final template = await read(id);
    // Files first, so a failure leaves a retryable template rather than
    // orphaned artwork nothing will ever clean up.
    if (template != null) {
      await appPaths.deleteIfExists(template.sourceFile?.path);
      await appPaths.deleteIfExists(template.thumbnailPath);
    }
    await _box.delete(id);
  }
}
