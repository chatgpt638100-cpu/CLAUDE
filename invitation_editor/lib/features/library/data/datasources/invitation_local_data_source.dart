import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/app_paths.dart';
import '../../../editor/domain/entities/invitation_source_file.dart';
import '../../domain/entities/invitation_project.dart';
import '../models/invitation_project_model.dart';

/// Reads and writes invitations to Hive, and owns the files that go with
/// them (source artwork, thumbnails).
///
/// Two responsibilities that must stay together: a record and its files
/// have to be created and destroyed as one, or the library ends up with
/// entries pointing at missing artwork, or orphaned files nothing will
/// ever clean up.
abstract class InvitationLocalDataSource {
  Future<List<InvitationProject>> readAll();

  Future<InvitationProject?> read(String id);

  Future<InvitationProject> write(
    InvitationProject project, {
    Uint8List? thumbnailBytes,
  });

  Future<void> delete(String id);

  Future<InvitationProject> copy(String id, {required String newId});
}

class InvitationLocalDataSourceImpl implements InvitationLocalDataSource {
  final AppPaths appPaths;

  InvitationLocalDataSourceImpl(this.appPaths);

  Box<String> get _box => LocalStorage.box(LocalStorage.invitationsBox);

  /// Cached so path resolution during a read does not hit the file system
  /// once per record.
  String? _sourcesPath;
  String? _thumbnailsPath;

  Future<void> _primePathCache() async {
    _sourcesPath ??= (await appPaths.sourcesDirectory()).path;
    _thumbnailsPath ??= (await appPaths.thumbnailsDirectory()).path;
  }

  String _join(String directory, String fileName) =>
      '$directory${Platform.pathSeparator}$fileName';

  @override
  Future<List<InvitationProject>> readAll() async {
    await _primePathCache();

    final projects = <InvitationProject>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;

      final project = _decode(raw);
      // Skip anything unreadable rather than failing the whole library —
      // one corrupt record must not hide every other invitation.
      if (project != null) projects.add(project);
    }

    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  @override
  Future<InvitationProject?> read(String id) async {
    await _primePathCache();
    final raw = _box.get(id);
    return raw == null ? null : _decode(raw);
  }

  InvitationProject? _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      return InvitationProjectModel.fromJson(
        decoded.cast<String, dynamic>(),
        resolveSourcePath: (fileName) {
          final path = _join(_sourcesPath!, fileName);
          // Confirmed synchronously: an async check per record would make
          // loading the library needlessly slow, and a stale entry is
          // handled by treating the invitation as blank.
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
  Future<InvitationProject> write(
    InvitationProject project, {
    Uint8List? thumbnailBytes,
  }) async {
    await _primePathCache();

    var stored = project;

    // Bring the uploaded artwork inside the app's own storage. Picked
    // files usually sit in an OS cache that can be purged at any time, so
    // without this an invitation would open to a missing page days later.
    final source = project.sourceFile;
    if (source != null && !_isInsideSources(source.path)) {
      final copiedName = await _copySourceFile(project.id, source);
      if (copiedName != null) {
        stored = stored.copyWith(
          sourceFile: InvitationSourceFile(
            path: _join(_sourcesPath!, copiedName),
            fileName: copiedName,
            type: source.type,
          ),
        );
      }
    }

    if (thumbnailBytes != null) {
      final fileName = '${project.id}.png';
      final file = File(_join(_thumbnailsPath!, fileName));
      await file.writeAsBytes(thumbnailBytes, flush: true);
      stored = stored.copyWith(
        thumbnailFileName: fileName,
        thumbnailPath: file.path,
      );
    }

    await _box.put(
      stored.id,
      jsonEncode(InvitationProjectModel.toJson(stored)),
    );
    return stored;
  }

  bool _isInsideSources(String path) => path.startsWith(_sourcesPath!);

  /// Returns the stored file name, or null if the original has vanished.
  Future<String?> _copySourceFile(
    String projectId,
    InvitationSourceFile source,
  ) async {
    final original = File(source.path);
    if (!await original.exists()) return null;

    // Keep the real extension so the platform PDF rasteriser and image
    // decoders still recognise the file.
    final extension = _extensionOf(source.fileName, source.type);
    final fileName = '$projectId$extension';
    await original.copy(_join(_sourcesPath!, fileName));
    return fileName;
  }

  static String _extensionOf(String fileName, InvitationFileType type) {
    final dot = fileName.lastIndexOf('.');
    if (dot > 0 && dot < fileName.length - 1) {
      return fileName.substring(dot).toLowerCase();
    }
    return type == InvitationFileType.pdf ? '.pdf' : '.png';
  }

  @override
  Future<void> delete(String id) async {
    await _primePathCache();

    final project = await read(id);
    // Files first: if this throws, the record survives and the user can
    // try again, rather than the invitation vanishing while its artwork
    // stays behind forever.
    if (project != null) {
      await appPaths.deleteIfExists(project.sourceFile?.path);
      await appPaths.deleteIfExists(project.thumbnailPath);
    }
    await _box.delete(id);
  }

  @override
  Future<InvitationProject> copy(String id, {required String newId}) async {
    await _primePathCache();

    final original = await read(id);
    if (original == null) {
      throw StateError('Cannot duplicate an invitation that does not exist');
    }

    final now = DateTime.now();
    var copy = original.copyWith(
      id: newId,
      title: '${original.title} (copy)',
      createdAt: now,
      updatedAt: now,
      // Cleared so the copy gets files of its own below; sharing them
      // would mean deleting one invitation broke the other.
      thumbnailFileName: null,
      thumbnailPath: null,
    );

    final source = original.sourceFile;
    if (source != null) {
      final extension = _extensionOf(source.fileName, source.type);
      final fileName = '$newId$extension';
      final originalFile = File(source.path);
      if (await originalFile.exists()) {
        await originalFile.copy(_join(_sourcesPath!, fileName));
        copy = copy.copyWith(
          sourceFile: InvitationSourceFile(
            path: _join(_sourcesPath!, fileName),
            fileName: fileName,
            type: source.type,
          ),
        );
      } else {
        copy = copy.copyWith(clearSourceFile: true);
      }
    }

    final thumbnail = original.thumbnailPath;
    if (thumbnail != null) {
      final thumbnailFile = File(thumbnail);
      if (await thumbnailFile.exists()) {
        final fileName = '$newId.png';
        await thumbnailFile.copy(_join(_thumbnailsPath!, fileName));
        copy = copy.copyWith(
          thumbnailFileName: fileName,
          thumbnailPath: _join(_thumbnailsPath!, fileName),
        );
      }
    }

    await _box.put(copy.id, jsonEncode(InvitationProjectModel.toJson(copy)));
    return copy;
  }
}
