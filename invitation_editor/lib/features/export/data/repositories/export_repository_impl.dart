import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_paths.dart';
import '../../../editor/domain/repositories/invitation_preview_repository.dart';
import '../../../library/domain/entities/invitation_project.dart';
import '../../domain/entities/export_result.dart';
import '../../domain/repositories/export_repository.dart';
import '../renderers/invitation_page_renderer.dart';

/// Turns an invitation into a PDF and hands it to Android.
///
/// The PDF holds one full-page image: the invitation composed at print
/// resolution by [InvitationPageRenderer]. Text is not emitted as PDF text
/// because the app's fonts are bundled assets that would each need
/// embedding, and any font not bundled would silently fall back to a
/// different face in the output. A rendered page is guaranteed to match
/// what the user approved on screen, which matters more here than
/// selectable text in a card someone is going to print.
class ExportRepositoryImpl implements ExportRepository {
  final InvitationPreviewRepository previewRepository;
  final InvitationPageRenderer renderer;
  final AppPaths appPaths;

  const ExportRepositoryImpl({
    required this.previewRepository,
    required this.renderer,
    required this.appPaths,
  });

  @override
  Future<ExportResult> exportToPdf(InvitationProject project) async {
    try {
      // Re-rasterise the source at export resolution rather than reusing the
      // screen preview, which is deliberately sized for a phone.
      final source = project.sourceFile;
      final pageBytes = source == null
          ? null
          : (await previewRepository.renderFirstPage(
              source,
              dpi: InvitationPageRenderer.outputDpi,
            ))
              .imageBytes;

      final rendered = await renderer.render(
        project,
        pageImageBytes: pageBytes,
      );

      final document = pw.Document()
        ..addPage(
          pw.Page(
            pageFormat: PdfPageFormat(rendered.widthPt, rendered.heightPt),
            // No margin: the invitation is the page, edge to edge.
            margin: pw.EdgeInsets.zero,
            build: (context) => pw.Image(
              pw.MemoryImage(rendered.pngBytes),
              fit: pw.BoxFit.contain,
            ),
          ),
        );

      final fileName = '${_safeFileName(project.title)}.pdf';
      final directory = await appPaths.exportsDirectory();
      final file = File(
        '${directory.path}${Platform.pathSeparator}$fileName',
      );
      await file.writeAsBytes(await document.save(), flush: true);

      return ExportResult(filePath: file.path, fileName: fileName);
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ExportFailure();
    }
  }

  @override
  Future<void> print(ExportResult result) async {
    try {
      final file = File(result.filePath);
      if (!await file.exists()) throw const ExportFailure();

      final bytes = await file.readAsBytes();
      // Hands straight to Android's print dialog, which owns printer
      // choice, paper size and copies.
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: result.fileName,
      );
    } on Failure {
      rethrow;
    } catch (_) {
      throw const ExportFailure('Could not open the print dialog.');
    }
  }

  @override
  Future<void> share(ExportResult result) async {
    try {
      await Share.shareXFiles(
        [XFile(result.filePath, mimeType: 'application/pdf')],
        subject: result.fileName,
      );
    } catch (_) {
      throw const ExportFailure('Could not open the share options.');
    }
  }

  /// Strips anything the file system might object to, so an invitation
  /// titled "Priya & Dev — 12/08" still exports.
  static String _safeFileName(String title) {
    final cleaned = title
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? 'Invitation' : cleaned;
  }
}
