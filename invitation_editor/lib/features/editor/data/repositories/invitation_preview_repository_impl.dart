import 'dart:io';
import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/invitation_page.dart';
import '../../domain/entities/invitation_source_file.dart';
import '../../domain/repositories/invitation_preview_repository.dart';

/// Concrete [InvitationPreviewRepository].
///
/// PDF rendering choice (project-architecture.pdf, Section 3 left this
/// "to be decided in the editor step"): we rasterise with the
/// `printing` package, which the architecture doc already lists for
/// "Printing & PDF preview — can render PDF pages for preview,
/// offline-compatible".
///
/// Why rasterise rather than embed a PDF viewer widget: the canvas will
/// later carry draggable text boxes on top of the page, so it needs a
/// plain static bitmap it fully controls — not a third-party viewer
/// bringing its own scroll and zoom gestures. It also keeps the app
/// free of an extra viewer dependency and its licensing.
///
/// This is the only place in the app that knows about `printing` or
/// touches `dart:io` for previews.
class InvitationPreviewRepositoryImpl implements InvitationPreviewRepository {
  const InvitationPreviewRepositoryImpl();

  /// Preview resolution. 150dpi keeps text on a rasterised page crisp
  /// on a phone screen without producing a needlessly large bitmap.
  static const double _previewDpi = 150;

  /// Page 1 of the document (`Printing.raster` page indexes are 0-based).
  static const List<int> _firstPageOnly = [0];

  @override
  Future<InvitationPage> renderFirstPage(
    InvitationSourceFile sourceFile,
  ) async {
    try {
      final file = File(sourceFile.path);

      if (!await file.exists()) {
        throw const FileLoadFailure();
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const PreviewRenderFailure();
      }

      switch (sourceFile.type) {
        case InvitationFileType.pdf:
          return InvitationPage(imageBytes: await _rasterisePdfFirstPage(bytes));
        case InvitationFileType.image:
          // A JPG/PNG is already displayable — no conversion needed.
          return InvitationPage(imageBytes: bytes);
      }
    } on Failure {
      // Already a friendly, user-facing failure — pass it through
      // untouched rather than flattening it into a generic message.
      rethrow;
    } catch (_) {
      throw const PreviewRenderFailure();
    }
  }

  /// Rasterises the first page of a PDF into PNG bytes.
  Future<Uint8List> _rasterisePdfFirstPage(Uint8List documentBytes) async {
    await for (final page in Printing.raster(
      documentBytes,
      pages: _firstPageOnly,
      dpi: _previewDpi,
    )) {
      return page.toPng();
    }

    // Stream completed without yielding a page — e.g. a PDF with no
    // pages, or one the platform rasteriser could not read.
    throw const PreviewRenderFailure();
  }
}
