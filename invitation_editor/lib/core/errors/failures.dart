import 'package:equatable/equatable.dart';

/// Base type for all "something went wrong" cases across the app.
/// Kept deliberately minimal for Phase 1 — no business logic yet.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class FileLoadFailure extends Failure {
  const FileLoadFailure([super.message = 'Could not load the file.']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Could not save your data.']);
}

/// The file was found but could not be turned into a viewable page
/// (an unreadable PDF, a corrupt image). Worded warmly and without
/// jargon, per the spec's tone for the 50+ audience.
class PreviewRenderFailure extends Failure {
  const PreviewRenderFailure([
    super.message = "We couldn't open this invitation. Try another file?",
  ]);
}

/// Something went wrong while making the PDF, printing, or sharing.
class ExportFailure extends Failure {
  const ExportFailure([
    super.message = "We couldn't create the PDF. Please try again.",
  ]);
}


