import '../entities/export_result.dart';
import '../repositories/export_repository.dart';

/// Opens Android's native print dialog for an exported PDF (Screen 6 —
/// "Print").
class PrintInvitation {
  final ExportRepository repository;

  const PrintInvitation(this.repository);

  Future<void> call(ExportResult result) => repository.print(result);
}
