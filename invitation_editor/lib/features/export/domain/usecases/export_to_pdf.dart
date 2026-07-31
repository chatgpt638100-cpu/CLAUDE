import '../../../library/domain/entities/invitation_project.dart';
import '../entities/export_result.dart';
import '../repositories/export_repository.dart';

/// Renders an invitation and writes it as a PDF (Screen 6 — "Save as PDF").
class ExportToPdf {
  final ExportRepository repository;

  const ExportToPdf(this.repository);

  Future<ExportResult> call(InvitationProject project) =>
      repository.exportToPdf(project);
}
