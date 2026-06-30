// lib/utils/private_vault_note.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const privateVaultContractId =
    'CBBDZOHTM3QG3TXKZHQ2HLBPWGL6WT4CS5DOARKLQ4CHHM6LUUR44OTK';

/// 1 USDC — Stellar uses 7 decimal places
const privateVaultDepositAmount = 10000000;

/// Testnet USDC SAC
const privateVaultUsdcContractId =
    'CBIELTK6YBZJU5UP2WWQEUCYKLPU6AUNZ2BQ4WWFEIE3USCIHMXQDAMA';

// ── Note status ───────────────────────────────────────────────────────────────

enum VaultNoteStatus {
  /// Generated locally, deposit tx not yet submitted
  pending,

  /// Deposit confirmed on-chain — note is spendable
  deposited,

  /// Note has been withdrawn — cannot be reused
  spent,
}

// ── Note model ────────────────────────────────────────────────────────────────

class VaultNote {
  final String id; // local UUID — never touches chain
  final String nullifier;
  final String secret;
  final String commitment;
  final String ownerAddress; // G... address that deposited
  VaultNoteStatus status;
  DateTime createdAt;
  DateTime? depositedAt;
  DateTime? spentAt;
  String? depositTxHash;
  String? withdrawTxHash;
  String? spentToAddress; // recipient of the withdrawal

  VaultNote({
    required this.id,
    required this.nullifier,
    required this.secret,
    required this.commitment,
    required this.ownerAddress,
    this.status = VaultNoteStatus.pending,
    DateTime? createdAt,
    this.depositedAt,
    this.spentAt,
    this.depositTxHash,
    this.withdrawTxHash,
    this.spentToAddress,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isPending => status == VaultNoteStatus.pending;
  bool get isDeposited => status == VaultNoteStatus.deposited;
  bool get isSpent => status == VaultNoteStatus.spent;

  /// Always 1 USDC per note
  double get usdcValue => privateVaultDepositAmount / 1e7;

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'nullifier': nullifier,
        'secret': secret,
        'commitment': commitment,
        'ownerAddress': ownerAddress,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'depositedAt': depositedAt?.toIso8601String(),
        'spentAt': spentAt?.toIso8601String(),
        'depositTxHash': depositTxHash,
        'withdrawTxHash': withdrawTxHash,
        'spentToAddress': spentToAddress,
      };

  factory VaultNote.fromJson(Map<String, dynamic> json) => VaultNote(
        id: json['id'] as String,
        nullifier: json['nullifier'] as String,
        secret: json['secret'] as String,
        commitment: json['commitment'] as String,
        ownerAddress: json['ownerAddress'] as String,
        status: VaultNoteStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        depositedAt: json['depositedAt'] != null
            ? DateTime.parse(json['depositedAt'] as String)
            : null,
        spentAt: json['spentAt'] != null
            ? DateTime.parse(json['spentAt'] as String)
            : null,
        depositTxHash: json['depositTxHash'] as String?,
        withdrawTxHash: json['withdrawTxHash'] as String?,
        spentToAddress: json['spentToAddress'] as String?,
      );

  VaultNote copyWith({
    VaultNoteStatus? status,
    DateTime? depositedAt,
    DateTime? spentAt,
    String? depositTxHash,
    String? withdrawTxHash,
    String? spentToAddress,
  }) =>
      VaultNote(
        id: id,
        nullifier: nullifier,
        secret: secret,
        commitment: commitment,
        ownerAddress: ownerAddress,
        status: status ?? this.status,
        createdAt: createdAt,
        depositedAt: depositedAt ?? this.depositedAt,
        spentAt: spentAt ?? this.spentAt,
        depositTxHash: depositTxHash ?? this.depositTxHash,
        withdrawTxHash: withdrawTxHash ?? this.withdrawTxHash,
        spentToAddress: spentToAddress ?? this.spentToAddress,
      );

  @override
  String toString() =>
      'VaultNote(id=$id, status=${status.name}, commitment=${commitment.substring(0, 14)}…)';
}

// ── Note store ────────────────────────────────────────────────────────────────

/// Persists notes to Hive under a per-wallet key.
/// All crypto stays in zkworker — this class only handles storage.
class VaultNoteStore {
  VaultNoteStore._();
  static final VaultNoteStore instance = VaultNoteStore._();

  static const _boxKey = 'econovaVaultNotes_';

  String _storeKey(String ownerAddress) => '$_boxKey:$ownerAddress';

  Future<List<VaultNote>> loadNotes(String ownerAddress) async {
    final box = Hive.box(_boxKey);
    final raw = box.get(_storeKey(ownerAddress));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw as String) as List;
      return list
          .map((e) => VaultNote.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('VaultNoteStore: failed to parse notes: $e');
      return [];
    }
  }

  Future<void> saveNotes(String ownerAddress, List<VaultNote> notes) async {
    final box = Hive.box(_boxKey);
    await box.put(
      _storeKey(ownerAddress),
      jsonEncode(notes.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> addNote(VaultNote note) async {
    final notes = await loadNotes(note.ownerAddress);
    notes.add(note);
    await saveNotes(note.ownerAddress, notes);
  }

  Future<void> updateNote(VaultNote updated) async {
    final notes = await loadNotes(updated.ownerAddress);
    final idx = notes.indexWhere((n) => n.id == updated.id);
    if (idx == -1) {
      debugPrint('VaultNoteStore: note ${updated.id} not found for update');
      return;
    }
    notes[idx] = updated;
    await saveNotes(updated.ownerAddress, notes);
  }

  Future<void> deleteNote(String ownerAddress, String noteId) async {
    final notes = await loadNotes(ownerAddress);
    notes.removeWhere((n) => n.id == noteId);
    await saveNotes(ownerAddress, notes);
  }

  /// Deposited and unspent notes — ready to withdraw
  Future<List<VaultNote>> spendableNotes(String ownerAddress) async {
    final notes = await loadNotes(ownerAddress);
    return notes.where((n) => n.isDeposited).toList();
  }

  /// Pending notes — generated but deposit not yet confirmed
  Future<List<VaultNote>> pendingNotes(String ownerAddress) async {
    final notes = await loadNotes(ownerAddress);
    return notes.where((n) => n.isPending).toList();
  }

  /// Total spendable balance in USDC
  Future<double> spendableBalance(String ownerAddress) async {
    final notes = await spendableNotes(ownerAddress);
    return notes.length.toDouble(); // always 1 USDC per note
  }

  /// Open the Hive box — call once in main() alongside other Hive opens
  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(_boxKey)) {
      await Hive.openBox(_boxKey);
    }
  }
}
