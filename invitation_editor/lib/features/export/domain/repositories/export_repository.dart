import '../../../library/domain/entities/invitation_project.dart';
import '../entities/export_result.dart';

/// Domain contract for turning an invitation into a PDF and handing it to
/// the platform.
///
/// Throws a `Failure` (see core/errors/failures.dart) when rendering or
/// writing fails.
abstract class ExportRepository {
  /// Renders [project] and writes it as a PDF.
  Future<ExportResult> exportToPdf(InvitationProject project);

  /// Opens Android's native print dialog for an already-written PDF.
  ///
  /// The platform owns printer selection, paper size and copies, so there
  /// is no custom print UI to build.
  Future<void> print(ExportResult result);

  /// Hands the PDF to the system share sheet.
  Future<void> share(ExportResult result);
}
