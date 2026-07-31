import '../entities/invitation_page.dart';
import '../entities/invitation_source_file.dart';

/// Domain-level contract for turning a picked file into something the
/// Editor canvas can display (Screen 4).
///
/// The implementation decides *how* that happens — which package
/// rasterises a PDF page, how bytes are read off disk — and lives
/// entirely in the data layer.
///
/// Throws a [Failure] (see core/errors/failures.dart) if the file is
/// missing or cannot be rendered.
abstract class InvitationPreviewRepository {
  /// Renders the first page of [sourceFile].
  ///
  /// For a PDF this rasterises page 1; for a JPG/PNG the image itself
  /// is the only page. Later phases may add multi-page support.
  Future<InvitationPage> renderFirstPage(InvitationSourceFile sourceFile);
}
