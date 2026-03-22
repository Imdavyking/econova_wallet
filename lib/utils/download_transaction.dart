import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet_app/utils/wallet_transaction.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ── Export format ─────────────────────────────────────────────────────────────

enum ExportFormat { csv, txt, pdf }

// ── Service ───────────────────────────────────────────────────────────────────

class TransactionExportService {
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _fileDate = DateFormat('yyyyMMdd_HHmmss');

  static Future<void> exportPdf({
    required List<WalletTransaction> transactions,
    required String tokenSymbol,
    String? walletAddress,
  }) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export for $tokenSymbol');
    }

    final pdf = pw.Document();

    final sent = transactions.where((t) => t.isSent).toList();
    final received = transactions.where((t) => t.isReceived).toList();
    final totalSent =
        sent.fold(0.0, (s, t) => s + (double.tryParse(t.amount) ?? 0));
    final totalReceived =
        received.fold(0.0, (s, t) => s + (double.tryParse(t.amount) ?? 0));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Text(
            'EcoNova — $tokenSymbol Transaction History',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Exported: ${_dateFormat.format(DateTime.now().toUtc())} UTC',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          if (walletAddress != null)
            pw.Text(
              'Wallet: $walletAddress',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          pw.SizedBox(height: 16),

          // Summary box
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total sent',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey)),
                      pw.Text('$totalSent $tokenSymbol',
                          style: pw.TextStyle(
                              fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total received',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey)),
                      pw.Text('$totalReceived $tokenSymbol',
                          style: pw.TextStyle(
                              fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Transactions',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey)),
                      pw.Text('${transactions.length}',
                          style: pw.TextStyle(
                              fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ]),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Table
          pw.TableHelper.fromTextArray(
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 28,
            headers: ['Date', 'Type', 'Amount', 'From', 'To', 'Status', 'Memo'],
            data: transactions
                .map((tx) => [
                      _dateFormat.format(tx.timestamp.toUtc()),
                      tx.isSent ? 'SENT' : 'RECEIVED',
                      '${tx.amount} ${tx.symbol}',
                      _ellipsis(tx.from),
                      _ellipsis(tx.to),
                      _statusLabel(tx.status),
                      tx.memo ?? '',
                    ])
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        '${tokenSymbol}_transactions_${_fileDate.format(DateTime.now())}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: '$tokenSymbol Transaction History — EcoNova',
    );
  }

  static String _ellipsis(String str) => str.length > 12
      ? '${str.substring(0, 6)}...${str.substring(str.length - 4)}'
      : str;

  // ── CSV export ──────────────────────────────────────────────────────────

  static Future<void> exportCsv({
    required List<WalletTransaction> transactions,
    required String tokenSymbol,
    String? walletAddress,
  }) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export for $tokenSymbol');
    }

    final rows = <List<dynamic>>[
      // Header
      [
        'Date (UTC)',
        'Type',
        'Amount',
        'Token',
        'From',
        'To',
        'Status',
        'Memo',
        'Tx Hash',
        'Explorer',
      ],
      // Data rows
      ...transactions.map((tx) => [
            _dateFormat.format(tx.timestamp.toUtc()),
            tx.isSent ? 'SENT' : 'RECEIVED',
            tx.amount,
            tx.symbol,
            tx.from,
            tx.to,
            _statusLabel(tx.status),
            tx.memo ?? '',
            tx.hash,
            tx.explorerUrl,
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);

    final fileName =
        '${tokenSymbol}_transactions_${_fileDate.format(DateTime.now())}.csv';

    await _shareFile(
      content: csv,
      fileName: fileName,
      mimeType: 'text/csv',
      subject: '$tokenSymbol Transaction History — EcoNova',
    );
  }

  // ── Plain text export ───────────────────────────────────────────────────

  static Future<void> exportTxt({
    required List<WalletTransaction> transactions,
    required String tokenSymbol,
    String? walletAddress,
  }) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export for $tokenSymbol');
    }

    final buffer = StringBuffer();

    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('  EcoNova — $tokenSymbol Transaction History');
    buffer.writeln(
        '  Exported: ${_dateFormat.format(DateTime.now().toUtc())} UTC');
    if (walletAddress != null) {
      buffer.writeln('  Wallet: $walletAddress');
    }
    buffer.writeln('  Total transactions: ${transactions.length}');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln();

    for (final tx in transactions) {
      final arrow = tx.isSent ? '↑ SENT' : '↓ RECEIVED';
      buffer.writeln('$arrow  ${tx.amount} ${tx.symbol}');
      buffer.writeln(
          '  Date:    ${_dateFormat.format(tx.timestamp.toUtc())} UTC');
      buffer.writeln('  Status:  ${_statusLabel(tx.status)}');
      buffer.writeln('  From:    ${tx.from}');
      buffer.writeln('  To:      ${tx.to}');
      if (tx.memo != null && tx.memo!.isNotEmpty) {
        buffer.writeln('  Memo:    ${tx.memo}');
      }
      buffer.writeln('  Hash:    ${tx.hash}');
      buffer.writeln('  Explorer: ${tx.explorerUrl}');
      buffer.writeln('───────────────────────────────────────────');
    }

    // Summary
    final sent = transactions.where((t) => t.isSent).toList();
    final received = transactions.where((t) => t.isReceived).toList();
    final totalSent =
        sent.fold(0.0, (s, t) => s + (double.tryParse(t.amount) ?? 0));
    final totalReceived =
        received.fold(0.0, (s, t) => s + (double.tryParse(t.amount) ?? 0));

    buffer.writeln();
    buffer.writeln('SUMMARY');
    buffer.writeln(
        '  Total sent:     $totalSent $tokenSymbol (${sent.length} transactions)');
    buffer.writeln(
        '  Total received: $totalReceived $tokenSymbol (${received.length} transactions)');

    final fileName =
        '${tokenSymbol}_transactions_${_fileDate.format(DateTime.now())}.txt';

    await _shareFile(
      content: buffer.toString(),
      fileName: fileName,
      mimeType: 'text/plain',
      subject: '$tokenSymbol Transaction History — EcoNova',
    );
  }

  // ── Share file ──────────────────────────────────────────────────────────

  static Future<void> _shareFile({
    required String content,
    required String fileName,
    required String mimeType,
    required String subject,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        subject: subject,
      );
    } catch (e) {
      print(e);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static String _statusLabel(WalletTxStatus status) {
    switch (status) {
      case WalletTxStatus.confirmed:
        return 'Confirmed';
      case WalletTxStatus.pending:
        return 'Pending';
      case WalletTxStatus.failed:
        return 'Failed';
    }
  }
}

// ── Export bottom sheet ───────────────────────────────────────────────────────
//
// Usage:
//   TransactionExportSheet.show(
//     context: context,
//     transactions: transactions,
//     tokenSymbol: coin.getSymbol(),
//     walletAddress: address,
//   );

class TransactionExportSheet extends StatefulWidget {
  final List<WalletTransaction> transactions;
  final String tokenSymbol;
  final String? walletAddress;

  const TransactionExportSheet({
    super.key,
    required this.transactions,
    required this.tokenSymbol,
    this.walletAddress,
  });

  static Future<void> show({
    required BuildContext context,
    required List<WalletTransaction> transactions,
    required String tokenSymbol,
    String? walletAddress,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionExportSheet(
        transactions: transactions,
        tokenSymbol: tokenSymbol,
        walletAddress: walletAddress,
      ),
    );
  }

  @override
  State<TransactionExportSheet> createState() => _TransactionExportSheetState();
}

class _TransactionExportSheetState extends State<TransactionExportSheet> {
  bool _loading = false;
  // Filter state
  WalletTxDirection? _directionFilter; // null = all
  WalletTxStatus? _statusFilter; // null = all

  List<WalletTransaction> get _filtered {
    return widget.transactions.where((tx) {
      if (_directionFilter != null && tx.direction != _directionFilter) {
        return false;
      }
      if (_statusFilter != null && tx.status != _statusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _export(ExportFormat format) async {
    setState(() => _loading = true);
    try {
      final txs = _filtered;
      if (format == ExportFormat.csv) {
        await TransactionExportService.exportCsv(
          transactions: txs,
          tokenSymbol: widget.tokenSymbol,
          walletAddress: widget.walletAddress,
        );
      } else {
        await TransactionExportService.exportTxt(
          transactions: txs,
          tokenSymbol: widget.tokenSymbol,
          walletAddress: widget.walletAddress,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Export ${widget.tokenSymbol} History',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${filtered.length} transactions',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),

          // Direction filter
          const Text(
            'TYPE',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _directionFilter == null,
                onTap: () => setState(() => _directionFilter = null),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Sent',
                selected: _directionFilter == WalletTxDirection.sent,
                onTap: () => setState(() => _directionFilter =
                    _directionFilter == WalletTxDirection.sent
                        ? null
                        : WalletTxDirection.sent),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Received',
                selected: _directionFilter == WalletTxDirection.received,
                onTap: () => setState(() => _directionFilter =
                    _directionFilter == WalletTxDirection.received
                        ? null
                        : WalletTxDirection.received),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status filter
          const Text(
            'STATUS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _statusFilter == null,
                onTap: () => setState(() => _statusFilter = null),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Confirmed',
                selected: _statusFilter == WalletTxStatus.confirmed,
                onTap: () => setState(() => _statusFilter =
                    _statusFilter == WalletTxStatus.confirmed
                        ? null
                        : WalletTxStatus.confirmed),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pending',
                selected: _statusFilter == WalletTxStatus.pending,
                onTap: () => setState(() => _statusFilter =
                    _statusFilter == WalletTxStatus.pending
                        ? null
                        : WalletTxStatus.pending),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Export buttons
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                    child: _ExportButton(
                  label: 'CSV',
                  icon: Icons.table_chart_outlined,
                  subtitle: 'Excel / Sheets',
                  onTap: () => _export(ExportFormat.csv),
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: _ExportButton(
                  label: 'PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  subtitle: 'Printable report',
                  onTap: () => _export(ExportFormat.pdf),
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: _ExportButton(
                  label: 'TXT',
                  icon: Icons.article_outlined,
                  subtitle: 'Plain text',
                  onTap: () => _export(ExportFormat.txt),
                )),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color:
                selected ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ExportButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 10),
            Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
