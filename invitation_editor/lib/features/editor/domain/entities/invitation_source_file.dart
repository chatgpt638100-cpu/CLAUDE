import 'package:equatable/equatable.dart';

/// The type of file an invitation was created from.
enum InvitationFileType { pdf, image }

/// A file the user picked to start an invitation from (Screen 2 →
/// Editor). Pure domain object — no dependency on Flutter or the
/// file_picker package.
class InvitationSourceFile extends Equatable {
  final String path;
  final String fileName;
  final InvitationFileType type;

  const InvitationSourceFile({
    required this.path,
    required this.fileName,
    required this.type,
  });

  @override
  List<Object?> get props => [path, fileName, type];
}
