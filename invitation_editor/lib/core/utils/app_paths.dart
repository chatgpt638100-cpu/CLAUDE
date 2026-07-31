import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Resolves the on-device folders the app writes to.
///
/// ## Why nothing stores an absolute path
///
/// An app's documents directory is not stable — the container path
/// changes between installs and can change on OS upgrade. Persisting an
/// absolute path is therefore a slow-acting bug: the library still lists
/// the invitation, but its artwork has silently gone missing.
///
/// Records store only a *file name*; this class turns it back into a full
/// path at read time.
class AppPaths {
  Directory? _documents;

  static const String _sourcesFolder = 'sources';
  static const String _templatesFolder = 'templates';
  static const String _thumbnailsFolder = 'thumbnails';
  static const String _exportsFolder = 'exports';

  Future<Directory> _documentsDirectory() async {
    return _documents ??= await getApplicationDocumentsDirectory();
  }

  Future<Directory> _subDirectory(String name) async {
    final root = await _documentsDirectory();
    final directory = Directory('${root.path}${Platform.pathSeparator}$name');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Where a project's original PDF/image is kept.
  ///
  /// Picked files often live in a cache the OS is free to purge, so the
  /// upload is copied here and read from here from then on.
  Future<Directory> sourcesDirectory() => _subDirectory(_sourcesFolder);

  /// Artwork belonging to saved templates.
  ///
  /// Separate from `sources/` so deleting an invitation can never remove
  /// the artwork a template still depends on.
  Future<Directory> templatesDirectory() => _subDirectory(_templatesFolder);

  Future<Directory> thumbnailsDirectory() => _subDirectory(_thumbnailsFolder);

  Future<Directory> exportsDirectory() => _subDirectory(_exportsFolder);

  /// Total bytes held by the folders this class owns, for the Settings
  /// screen's storage figure.
  Future<int> storageUsedInBytes() async {
    var total = 0;
    for (final directory in [
      await sourcesDirectory(),
      await templatesDirectory(),
      await thumbnailsDirectory(),
      await exportsDirectory(),
    ]) {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    }
    return total;
  }

  /// Removes generated files that can be rebuilt on demand — thumbnails
  /// and past exports. Never touches `sources/` or `templates/`, which
  /// hold the only copy of the user's uploaded artwork.
  Future<void> clearRegeneratableFiles() async {
    for (final directory in [
      await thumbnailsDirectory(),
      await exportsDirectory(),
    ]) {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
