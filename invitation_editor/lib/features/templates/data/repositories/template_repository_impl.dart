import 'dart:typed_data';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/invitation_template.dart';
import '../../domain/repositories/template_repository.dart';
import '../datasources/template_local_data_source.dart';

/// [TemplateRepository] backed by the local Hive store.
///
/// Its job is the boundary: turn whatever storage throws into a [Failure]
/// carrying wording that can be shown to a user.
class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateLocalDataSource localDataSource;

  const TemplateRepositoryImpl(this.localDataSource);

  @override
  Future<List<InvitationTemplate>> getAll() async {
    try {
      return await localDataSource.readAll();
    } catch (_) {
      throw const StorageFailure('Could not open your saved templates.');
    }
  }

  @override
  Future<InvitationTemplate?> getById(String id) async {
    try {
      return await localDataSource.read(id);
    } catch (_) {
      throw const StorageFailure('Could not open that template.');
    }
  }

  @override
  Future<InvitationTemplate> save(
    InvitationTemplate template, {
    Uint8List? thumbnailBytes,
  }) async {
    try {
      return await localDataSource.write(
        template,
        thumbnailBytes: thumbnailBytes,
      );
    } catch (_) {
      throw const StorageFailure('Could not save your template.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await localDataSource.delete(id);
    } catch (_) {
      throw const StorageFailure('Could not delete that template.');
    }
  }

  @override
  Future<InvitationTemplate> rename(String id, {required String name}) async {
    try {
      final existing = await localDataSource.read(id);
      if (existing == null) {
        throw const StorageFailure('That template is no longer there.');
      }
      return await localDataSource.write(existing.copyWith(name: name));
    } on Failure {
      rethrow;
    } catch (_) {
      throw const StorageFailure('Could not rename that template.');
    }
  }
}
