import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

enum _FileType { csv, txt, unknown }

class FileViewerScreen extends StatefulWidget {
  final String path;
  final String title;

  const FileViewerScreen({super.key, required this.path, required this.title});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late Future<String> _contentFuture;

  _FileType get _fileType {
    final ext = widget.path.split('.').last.toLowerCase();
    if (ext == 'csv') return _FileType.csv;
    if (ext == 'txt') return _FileType.txt;
    return _FileType.unknown;
  }

  @override
  void initState() {
    super.initState();
    _contentFuture = File(widget.path).readAsString();
  }

  void _share() => Share.shareXFiles([
        XFile(
          widget.path,
          mimeType: _fileType == _FileType.csv ? 'text/csv' : 'text/plain',
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _share),
        ],
      ),
      body: FutureBuilder<String>(
        future: _contentFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Failed to load file.\n${snap.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final content = snap.data!;
          return switch (_fileType) {
            _FileType.csv => _CsvView(content: content),
            _FileType.txt => _TxtView(content: content),
            _FileType.unknown =>
              _TxtView(content: content), // graceful fallback
          };
        },
      ),
    );
  }
}

// ── CSV viewer ────────────────────────────────────────────────────────────────

class _CsvView extends StatelessWidget {
  final String content;
  const _CsvView({required this.content});

  @override
  Widget build(BuildContext context) {
    final rows = const CsvToListConverter(eol: '\n').convert(content);
    if (rows.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final headers = rows.first.map((c) => c.toString()).toList();
    final dataRows = rows.skip(1).toList();
    final colCount = headers.length;

    // Fixed column width; horizontal scroll handles overflow.
    const colWidth = 140.0;

    final headerBg = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).dividerColor;
    final altRowBg = Theme.of(context).colorScheme.surface;
    final altRowBg2 =
        Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4);

    Widget cell(
      String text, {
      bool isHeader = false,
      Color? bg,
    }) =>
        Container(
          width: colWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              right: BorderSide(color: borderColor, width: 0.5),
              bottom: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
              fontFamily: isHeader ? null : 'monospace',
            ),
          ),
        );

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: colWidth * colCount,
          child: Column(
            children: [
              // Header row — sticky via CustomScrollView is overkill here;
              // a plain Row at the top is sufficient.
              Row(
                children: headers
                    .map((h) => cell(h, isHeader: true, bg: headerBg))
                    .toList(),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: dataRows.length,
                  itemBuilder: (context, i) {
                    final row = dataRows[i];
                    final bg = i.isEven ? altRowBg : altRowBg2;
                    return Row(
                      children: List.generate(
                        colCount,
                        (j) => cell(
                          j < row.length ? row[j].toString() : '',
                          bg: bg,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── TXT viewer ────────────────────────────────────────────────────────────────

class _TxtView extends StatelessWidget {
  final String content;
  const _TxtView({required this.content});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          content,
          style: const TextStyle(
              fontSize: 12, fontFamily: 'monospace', height: 1.6),
        ),
      ),
    );
  }
}
