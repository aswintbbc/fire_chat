import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareHtmlToPdfWidget extends StatefulWidget {
  const ShareHtmlToPdfWidget({
    super.key,
    required this.htmlContent,
    this.child,
    this.htmlUrl,
    this.filename,
  }) : assert(
          htmlContent != null || htmlUrl != null,
          'content or url must be provided',
        );

  /// [filename] is the name of the file to be shared.
  final String? filename;

  /// Creates a widget that shares a PDF document generated from HTML content.
  /// [htmlContent] is the HTML content to convert to PDF.
  /// instead of using the provided [htmlContent].
  final String? htmlContent;

  /// [child] is an optional widget to display instead of the default icon.
  final Widget? child;

  /// [htmlUrl] is an optional URL to download HTML content from.
  /// If [htmlUrl] is provided, it will be used to download the HTML content
  final String? htmlUrl;

  @override
  State<ShareHtmlToPdfWidget> createState() => _ShareHtmlToPdfWidgetState();
}

class _ShareHtmlToPdfWidgetState extends State<ShareHtmlToPdfWidget> {
  /// A notifier to indicate whether the PDF generation is in progress.
  /// It is used to show a loading indicator while the PDF is being generated.
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  /// A plugin instance for converting HTML to PDF.
  /// It is used to perform the conversion and generate the PDF file.
  final flutterNativeHtmlToPdfPlugin = FlutterNativeHtmlToPdf();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ValueListenableBuilder(
          valueListenable: isLoadingNotifier,
          builder: (context, value, child) {
            return value
                ? const CircularProgressIndicator()
                : (child ?? const Icon(Icons.share, size: 30));
          }),
      onTap: () async {
        // Check if the PDF generation is already in progress
        // to prevent multiple taps from triggering the process again.
        if (isLoadingNotifier.value) {
          return;
        }
        isLoadingNotifier.value = true;

        // Check if the HTML content is provided or if a URL is provided.
        // If a URL is provided, download the HTML content from the URL.
        if (widget.htmlUrl != null) {
          final htmlContent =
              await _downloadAndPrintHtmlAsPdf(context, widget.htmlUrl!);
          if (htmlContent == null) {
            isLoadingNotifier.value = false;
            return;
          }
          final generatedPdfFilePath = await generateDocument(htmlContent);
          isLoadingNotifier.value = false;
          await SharePlus.instance.share(ShareParams(
            previewThumbnail: XFile(generatedPdfFilePath!),
            files: [XFile(generatedPdfFilePath)],
            text: 'pdf file',
          ));
        } else {
          // If only HTML content is provided, use it directly to generate the PDF.
          // This is useful when the HTML content is already available in the app.
          // Generate the PDF document from the provided HTML content.
          final generatedPdfFilePath =
              await generateDocument(widget.htmlContent);
          isLoadingNotifier.value = false;
          await SharePlus.instance.share(ShareParams(
            previewThumbnail: XFile(generatedPdfFilePath!),
            files: [XFile(generatedPdfFilePath)],
            text: 'pdf file',
          ));
        }
      },
    );
  }

  /// Generates a PDF document from the provided HTML content and saves it to the
  /// application's documents directory.
  /// Returns the path of the generated PDF file.
  /// [widget.htmlContent] is the HTML content to convert to PDF.
  Future<String?> generateDocument(String? content) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final targetPath = appDocDir.path;
    final targetFileName = widget.filename ?? "mytext";
    final generatedPdfFile =
        await flutterNativeHtmlToPdfPlugin.convertHtmlToPdf(
      html: content!,
      targetDirectory: targetPath,
      targetName: targetFileName,
    );
    return generatedPdfFile?.path;
  }

  /// Downloads HTML content from the given URL and returns it as a string.
  /// If the download fails, it shows a SnackBar with an error message.
  /// Throws an exception if the download fails.
  /// [context] is used to show the SnackBar.
  /// [htmlUrl] is the URL of the HTML content to download.
  /// Returns the HTML content as a string if successful, or null if it fails.
  Future<String?> _downloadAndPrintHtmlAsPdf(
    BuildContext context,
    String htmlUrl,
  ) async {
    try {
      final response = await http.get(Uri.parse(htmlUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
          'Failed to load HTML. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
