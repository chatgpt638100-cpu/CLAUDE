import '../entities/export_result.dart';
import '../repositories/export_repository.dart';

/// Hands an exported PDF to the system share sheet (Screen 6 — "Share").
class ShareInvitation {
  final ExportRepository repository;

  const ShareInvitation(this.repository);

  Future<void> call(ExportResult result) => repository.share(result);
}
