import 'dart:typed_data';

import '../entities/invitation_template.dart';

/// Domain contract for storing and retrieving saved templates.
///
/// Throws a `Failure` (see core/errors/failures.dart) when storage cannot
/// be read or written.
abstract class TemplateRepository {
  /// Every saved template, newest first.
  Future<List<InvitationTemplate>> getAll();

  Future<InvitationTemplate?> getById(String id);

  /// Creates or updates [template]. [thumbnailBytes], when supplied,
  /// replaces the cached preview. The returned template carries any file
  /// names the storage layer assigned.
  Future<InvitationTemplate> save(
    InvitationTemplate template, {
    Uint8List? thumbnailBytes,
  });

  Future<void> delete(String id);

  Future<InvitationTemplate> rename(String id, {required String name});
}
