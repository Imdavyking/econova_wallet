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

// ── Insights model ────────────────────────────────────────────────────────────

class _TxInsights {
  final double totalSent;
  final double totalReceived;
  final int txCount;
  final String? mostActiveDay;
  final _TopTx? biggestSend;
  final List<_Recipient> topRecipients;

  const _TxInsights({
    required this.totalSent,
    required this.totalReceived,
    required this.txCount,
    required this.mostActiveDay,
    required this.biggestSend,
    required this.topRecipients,
  });

  static _TxInsights compute(List<WalletTransaction> txs, String symbol) {
    if (txs.isEmpty) {
      return const _TxInsights(
        totalSent: 0,
        totalReceived: 0,
        txCount: 0,
        mostActiveDay: null,
        biggestSend: null,
        topRecipients: [],
      );
    }

    final sent = txs.where((t) => t.isSent).toList();
    final received = txs.where((t) => t.isReceived).toList();

    final totalSent =
        sent.fold(0.0, (s, t) => s + (double.tryParse(t.amount) ?? 0));
    final totalReceived =
        received.fold(0.0, (s, t) => s + (double.tryParse(t.amount) ?? 0));

    // Most active day of week
    final dayCounts = <int, int>{};
    for (final tx in txs) {
      final day = tx.timestamp.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    String? mostActiveDay;
    if (dayCounts.isNotEmpty) {
      final topDay =
          dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      mostActiveDay = days[topDay - 1];
    }

    // Biggest send
    _TopTx? biggestSend;
    if (sent.isNotEmpty) {
      final top = sent.reduce((a, b) =>
          (double.tryParse(a.amount) ?? 0) > (double.tryParse(b.amount) ?? 0)
              ? a
              : b);
      biggestSend = _TopTx(
        amount: double.tryParse(top.amount) ?? 0,
        address: top.to,
        date: top.timestamp,
        symbol: symbol,
      );
    }

    // Top recipients
    final recipientMap = <String, _Recipient>{};
    for (final tx in sent) {
      final addr = tx.to;
      final amt = double.tryParse(tx.amount) ?? 0;
      if (recipientMap.containsKey(addr)) {
        recipientMap[addr] = _Recipient(
          address: addr,
          count: recipientMap[addr]!.count + 1,
          total: recipientMap[addr]!.total + amt,
          symbol: symbol,
        );
      } else {
        recipientMap[addr] =
            _Recipient(address: addr, count: 1, total: amt, symbol: symbol);
      }
    }
    final topRecipients = recipientMap.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return _TxInsights(
      totalSent: totalSent,
      totalReceived: totalReceived,
      txCount: txs.length,
      mostActiveDay: mostActiveDay,
      biggestSend: biggestSend,
      topRecipients: topRecipients.take(3).toList(),
    );
  }
}

class _TopTx {
  final double amount;
  final String address;
  final DateTime date;
  final String symbol;
  const _TopTx({
    required this.amount,
    required this.address,
    required this.date,
    required this.symbol,
  });
}

class _Recipient {
  final String address;
  final int count;
  final double total;
  final String symbol;
  const _Recipient({
    required this.address,
    required this.count,
    required this.total,
    required this.symbol,
  });

  String get shortAddress => address.length > 12
      ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
      : address;
}

// ── Export service ────────────────────────────────────────────────────────────

class TransactionExportService {
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final _fileDate = DateFormat('yyyyMMdd_HHmmss');
  static final _shortDate = DateFormat('MMM d');

  // ── PDF ─────────────────────────────────────────────────────────────────

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
          pw.Text(
            'EcoNova — $tokenSymbol Transaction History',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Exported: ${_dateFormat.format(DateTime.now().toUtc())} UTC',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.Text(
            '⚠️ Based on locally cached history — may not reflect full on-chain activity.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange),
          ),
          if (walletAddress != null)
            pw.Text(
              'Wallet: $walletAddress',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          pw.SizedBox(height: 16),
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

  // ── CSV ──────────────────────────────────────────────────────────────────

  static Future<void> exportCsv({
    required List<WalletTransaction> transactions,
    required String tokenSymbol,
    String? walletAddress,
  }) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export for $tokenSymbol');
    }

    final rows = <List<dynamic>>[
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

  // ── TXT ──────────────────────────────────────────────────────────────────

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
    if (walletAddress != null) buffer.writeln('  Wallet: $walletAddress');
    buffer.writeln('  Total transactions: ${transactions.length}');
    buffer.writeln(
        '  ⚠️  Based on locally cached history — may not reflect full on-chain activity.');
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

  // ── Share ────────────────────────────────────────────────────────────────

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
      debugPrint('Export error: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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

  static String _ellipsis(String str) => str.length > 12
      ? '${str.substring(0, 6)}...${str.substring(str.length - 4)}'
      : str;

  static String shortDate(DateTime dt) => _shortDate.format(dt);
}

// ── Export + insights bottom sheet ───────────────────────────────────────────

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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => TransactionExportSheet(
          transactions: transactions,
          tokenSymbol: tokenSymbol,
          walletAddress: walletAddress,
        ),
      ),
    );
  }

  @override
  State<TransactionExportSheet> createState() => _TransactionExportSheetState();
}

class _TransactionExportSheetState extends State<TransactionExportSheet> {
  bool _loading = false;
  WalletTxDirection? _directionFilter;
  WalletTxStatus? _statusFilter;

  List<WalletTransaction> get _filtered {
    return widget.transactions.where((tx) {
      if (_directionFilter != null && tx.direction != _directionFilter) {
        return false;
      }
      if (_statusFilter != null && tx.status != _statusFilter) return false;
      return true;
    }).toList();
  }

  Future<void> _export(ExportFormat format) async {
    setState(() => _loading = true);
    try {
      final txs = _filtered;
      switch (format) {
        case ExportFormat.csv:
          await TransactionExportService.exportCsv(
            transactions: txs,
            tokenSymbol: widget.tokenSymbol,
            walletAddress: widget.walletAddress,
          );
          break;
        case ExportFormat.pdf:
          await TransactionExportService.exportPdf(
            transactions: txs,
            tokenSymbol: widget.tokenSymbol,
            walletAddress: widget.walletAddress,
          );
          break;
        case ExportFormat.txt:
          await TransactionExportService.exportTxt(
            transactions: txs,
            tokenSymbol: widget.tokenSymbol,
            walletAddress: widget.walletAddress,
          );
          break;
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final insights = _TxInsights.compute(filtered, widget.tokenSymbol);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 16),

            // Title
            Text(
              '${widget.tokenSymbol} Transactions',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),

            // Local history disclaimer
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 13, color: Colors.orange.shade400),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Based on locally cached history — may not reflect full on-chain activity.',
                    style:
                        TextStyle(fontSize: 11, color: Colors.orange.shade400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Insights ─────────────────────────────────────────────────
            _InsightsCard(insights: insights, symbol: widget.tokenSymbol),
            const SizedBox(height: 20),

            // ── Filters ──────────────────────────────────────────────────
            const _SectionLabel(text: 'TYPE'),
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

            const _SectionLabel(text: 'STATUS'),
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
            const SizedBox(height: 20),

            // ── Export buttons ────────────────────────────────────────────
            const _SectionLabel(text: 'EXPORT'),
            const SizedBox(height: 8),
            Text(
              '${filtered.length} transactions selected',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ExportButton(
                      label: 'PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      subtitle: 'Printable report',
                      onTap: () => _export(ExportFormat.pdf),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ExportButton(
                      label: 'TXT',
                      icon: Icons.article_outlined,
                      subtitle: 'Plain text',
                      onTap: () => _export(ExportFormat.txt),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Insights card ─────────────────────────────────────────────────────────────

class _InsightsCard extends StatelessWidget {
  final _TxInsights insights;
  final String symbol;

  const _InsightsCard({required this.insights, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: 'Total sent',
                  value: '${insights.totalSent.toStringAsFixed(2)} $symbol',
                ),
              ),
              Expanded(
                child: _StatCell(
                  label: 'Total received',
                  value: '${insights.totalReceived.toStringAsFixed(2)} $symbol',
                ),
              ),
              Expanded(
                child: _StatCell(
                  label: 'Transactions',
                  value: '${insights.txCount}',
                ),
              ),
            ],
          ),

          if (insights.mostActiveDay != null || insights.biggestSend != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

          if (insights.mostActiveDay != null)
            _InsightRow(
              icon: Icons.calendar_today_outlined,
              label: 'Most active day',
              value: insights.mostActiveDay!,
            ),

          if (insights.biggestSend != null) ...[
            const SizedBox(height: 8),
            _InsightRow(
              icon: Icons.arrow_upward,
              label: 'Biggest send',
              value:
                  '${insights.biggestSend!.amount.toStringAsFixed(2)} $symbol'
                  ' to ${_short(insights.biggestSend!.address)}'
                  ' on ${TransactionExportService.shortDate(insights.biggestSend!.date)}',
            ),
          ],

          if (insights.topRecipients.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            const Text(
              'TOP RECIPIENTS',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            ...insights.topRecipients.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.shortAddress,
                        style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${r.count}x',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${r.total.toStringAsFixed(2)} ${r.symbol}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _short(String addr) => addr.length > 12
      ? '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}'
      : addr;
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 1.5),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InsightRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '$label  ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

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
