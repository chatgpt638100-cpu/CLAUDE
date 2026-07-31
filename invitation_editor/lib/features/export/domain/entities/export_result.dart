import 'package:equatable/equatable.dart';

/// A PDF that has been written to disk (Screen 6 — the "Saved!" state,
/// which shows the file name and offers to share or print it).
class ExportResult extends Equatable {
  /// Absolute path to the written file. Not persisted anywhere — it is
  /// only handed straight to the share sheet or print dialog.
  final String filePath;

  /// Name shown to the user, e.g. "Amara's Birthday.pdf".
  final String fileName;

  const ExportResult({required this.filePath, required this.fileName});

  @override
  List<Object?> get props => [filePath, fileName];
}
