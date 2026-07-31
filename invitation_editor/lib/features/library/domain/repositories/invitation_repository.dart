import 'dart:typed_data';

import '../entities/invitation_project.dart';

/// Domain contract for storing and retrieving saved invitations.
///
/// Implementations decide *where* things live — Hive, files on disk — and
/// that detail never leaks past this boundary. Throws a `Failure` (see
/// core/errors/failures.dart) when storage cannot be read or written.
abstract class InvitationRepository {
  /// Every saved invitation, newest edit first.
  Future<List<InvitationProject>> getAll();

  Future<InvitationProject?> getById(String id);

  /// Creates or updates [project], stamping `updatedAt`.
  ///
  /// [thumbnailBytes], when supplied, replaces the cached thumbnail. The
  /// returned project carries any file names the storage layer assigned,
  /// so the caller can keep working with an accurate copy.
  Future<InvitationProject> save(
    InvitationProject project, {
    Uint8List? thumbnailBytes,
  });

  /// Removes the record along with its thumbnail and source artwork.
  Future<void> delete(String id);

  /// Copies an invitation under a new id, including its artwork, so
  /// editing the copy cannot affect the original.
  Future<InvitationProject> duplicate(String id, {required String newId});

  Future<InvitationProject> rename(String id, {required String title});
}
