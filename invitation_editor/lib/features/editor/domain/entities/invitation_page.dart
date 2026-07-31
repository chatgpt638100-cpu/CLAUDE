import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A single page of an invitation, already rendered to displayable
/// image bytes and ready to be shown on the Editor canvas (Screen 4).
///
/// Whether the original file was a PDF or a JPG/PNG is irrelevant by
/// this point — the data layer normalises both into plain image bytes,
/// so the canvas only ever deals with one shape of data.
///
/// Pure domain object: `dart:typed_data` is part of the Dart SDK, so
/// this stays free of any Flutter or package dependency.
class InvitationPage extends Equatable {
  /// Encoded image bytes (PNG for rasterised PDF pages, or the
  /// original bytes for an uploaded JPG/PNG).
  final Uint8List imageBytes;

  const InvitationPage({required this.imageBytes});

  /// Compared by identity rather than by content: every render produces
  /// a fresh instance, and comparing megabytes of pixels on every
  /// rebuild would be wasteful.
  @override
  List<Object?> get props => [imageBytes];
}
