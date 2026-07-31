import 'dart:typed_data';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/invitation_project.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../datasources/invitation_local_data_source.dart';

/// [InvitationRepository] backed by the local Hive store.
///
/// Its job is the boundary: translate whatever the storage layer throws
/// into a [Failure] carrying wording that can be shown to a user, and
/// stamp `updatedAt` so no caller has to remember to.
class InvitationRepositoryImpl implements InvitationRepository {
  final InvitationLocalDataSource localDataSource;

  const InvitationRepositoryImpl(this.localDataSource);

  @override
  Future<List<InvitationProject>> getAll() async {
    try {
      return await localDataSource.readAll();
    } catch (_) {
      throw const StorageFailure('Could not open your saved invitations.');
    }
  }

  @override
  Future<InvitationProject?> getById(String id) async {
    try {
      return await localDataSource.read(id);
    } catch (_) {
      throw const StorageFailure('Could not open that invitation.');
    }
  }

  @override
  Future<InvitationProject> save(
    InvitationProject project, {
    Uint8List? thumbnailBytes,
  }) async {
    try {
      return await localDataSource.write(
        // Set here, in one place, so auto-save and the Save button cannot
        // disagree about what "last edited" means.
        project.copyWith(updatedAt: DateTime.now()),
        thumbnailBytes: thumbnailBytes,
      );
    } catch (_) {
      throw const StorageFailure('Could not save your invitation.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await localDataSource.delete(id);
    } catch (_) {
      throw const StorageFailure('Could not delete that invitation.');
    }
  }

  @override
  Future<InvitationProject> duplicate(String id, {required String newId}) async {
    try {
      return await localDataSource.copy(id, newId: newId);
    } catch (_) {
      throw const StorageFailure('Could not duplicate that invitation.');
    }
  }

  @override
  Future<InvitationProject> rename(String id, {required String title}) async {
    try {
      final existing = await localDataSource.read(id);
      if (existing == null) {
        throw const StorageFailure('That invitation is no longer there.');
      }
      return await localDataSource.write(
        existing.copyWith(title: title, updatedAt: DateTime.now()),
      );
    } on Failure {
      rethrow;
    } catch (_) {
      throw const StorageFailure('Could not rename that invitation.');
    }
  }
}
