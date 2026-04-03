import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewerScreen({required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.shareXFiles(
              [XFile(path, mimeType: 'application/pdf')],
            ),
          ),
        ],
      ),
      body: PDFView(filePath: path),
    );
  }
}