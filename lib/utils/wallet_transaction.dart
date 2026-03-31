import 'dart:math';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum WalletTxStatus { confirmed, pending, failed }

enum WalletTxDirection { sent, received }

// ── Model ─────────────────────────────────────────────────────────────────────

class WalletTransaction {
  final String hash;
  final String from;
  final String to;
  final String amount; // human-readable e.g. "1.500000"
  final String symbol;
  final int decimals;
  final DateTime timestamp;
  final WalletTxStatus status;
  final WalletTxDirection direction;
  final String? memo;
  final String explorerUrl;

  const WalletTransaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.amount,
    required this.symbol,
    required this.decimals,
    required this.timestamp,
    required this.status,
    required this.direction,
    required this.explorerUrl,
    this.memo,
  });

  // ── Convenience getters ───────────────────────────────────────────────────

  bool get isSent => direction == WalletTxDirection.sent;
  bool get isReceived => direction == WalletTxDirection.received;
  bool get isConfirmed => status == WalletTxStatus.confirmed;
  bool get isPending => status == WalletTxStatus.pending;
  bool get isFailed => status == WalletTxStatus.failed;

  /// Raw integer amount for TokenTransaction compatibility.
  /// e.g. amount = "1.5", decimals = 6 → 1500000
  num get rawValue {
    final parsed = double.tryParse(amount) ?? 0.0;
    return (parsed * pow(10, decimals)).round();
  }

  // ── TokenTransaction bridge ───────────────────────────────────────────────

  /// Converts to the map shape that [TokenTransaction.fromJson] expects
  /// so existing UI keeps working without modification.
  Map<String, dynamic> toTokenTransactionJson() => {
        'from': from,
        'to': to,
        'transactionHash': hash,
        // TokenTransaction parses time with DateFormat('yyyy-MM-dd hh:mm:ss')
        'time': _formatTime(timestamp),
        'value': rawValue,
        'decimal': decimals,
      };

  static String _formatTime(DateTime dt) {
    final utc = dt.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final mo = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    final h = utc.hour.toString().padLeft(2, '0');
    final mi = utc.minute.toString().padLeft(2, '0');
    final s = utc.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }

  // ── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletTransaction && other.hash == hash);

  @override
  int get hashCode => hash.hashCode;

  @override
  String toString() =>
      'WalletTransaction($direction $amount $symbol | $hash | $status)';
}

// ── Fetcher interface ─────────────────────────────────────────────────────────

abstract class TransactionFetcher {
  /// Fetch transactions for [address]. Returns newest first.
  /// Throws on network/parse error — caller should catch.
  Future<List<WalletTransaction>> fetch({
    required String address,
    int limit = 25,
  });
}
