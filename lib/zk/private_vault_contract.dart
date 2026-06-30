// lib/utils/private_vault_contract.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stellar;
import 'package:wallet_app/coins/stellar_coin.dart';
import 'package:wallet_app/utils/zkproof.dart';
import 'package:wallet_app/zk/private_vault.dart';

// ── Client ────────────────────────────────────────────────────────────────────

class PrivateVaultClient {
  PrivateVaultClient._();
  static final PrivateVaultClient instance = PrivateVaultClient._();

  late final stellar.SorobanServer _soroban;
  late final stellar.StellarSDK _sdk;
  late final stellar.Network _network;

  bool _initialized = false;

  void init({required bool testnet}) {
    if (_initialized) return;
    _network = testnet ? stellar.Network.TESTNET : stellar.Network.PUBLIC;
    _sdk = testnet ? stellar.StellarSDK.TESTNET : stellar.StellarSDK.PUBLIC;
    _soroban = stellar.SorobanServer(
      testnet
          ? 'https://soroban-testnet.stellar.org'
          : 'https://soroban.stellar.org',
    );
    _initialized = true;
  }

  static stellar.XdrSCVal _u256FromHex(String hex) {
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    final padded = clean.padLeft(64, '0');

    int chunkToInt(String chunk) =>
        BigInt.parse(chunk, radix: 16).toUnsigned(64).toSigned(64).toInt();

    final hiHi = chunkToInt(padded.substring(0, 16));
    final hiLo = chunkToInt(padded.substring(16, 32));
    final loHi = chunkToInt(padded.substring(32, 48));
    final loLo = chunkToInt(padded.substring(48, 64));

    final val = stellar.XdrSCVal(stellar.XdrSCValType.SCV_U256);
    val.u256 =
        stellar.XdrUInt256Parts.forHiHiHiLoLoHiLoLo(hiHi, hiLo, loHi, loLo);
    return val;
  } // ── Helpers ───────────────────────────────────────────────────────────────

  stellar.XdrSCVal _addressVal(String accountId) =>
      stellar.Address.forAccountId(accountId).toXdrSCVal();

  stellar.XdrSCVal _contractAddressVal(String contractId) =>
      stellar.Address.forContractId(contractId).toXdrSCVal();

  stellar.XdrSCVal _i128Val(int amount) {
    final big = BigInt.from(amount).toSigned(128);
    final hi = (big >> 64).toSigned(64).toInt();
    final lo =
        (big & BigInt.parse('0xFFFFFFFFFFFFFFFF')).toUnsigned(64).toInt();
    return stellar.XdrSCVal.forI128Parts(hi, lo);
  }

  /// Hex string → U256 SCVal (commitment / nullifier hash field elements)
  String _u256ValToHex(stellar.XdrSCVal val) {
    final u256 = val.u256;
    if (u256 == null) return '0x0';
    final hex = [
      u256.hiHi.uint64,
      u256.hiLo.uint64,
      u256.loHi.uint64,
      u256.loLo.uint64,
    ].map((p) => p.toUnsigned(64).toRadixString(16).padLeft(16, '0')).join('');
    return '0x$hex';
  }

  stellar.XdrSCVal _bytesVal(Uint8List bytes) =>
      stellar.XdrSCVal.forBytes(bytes);

  Uint8List _hexToBytes(String hex) {
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    final result = Uint8List(clean.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  stellar.InvokeHostFuncOpBuilder _invokeOp({
    required String contractId,
    required String functionName,
    required List<stellar.XdrSCVal> args,
  }) {
    final hostFn = stellar.InvokeContractHostFunction(
      contractId,
      functionName,
      arguments: args,
    );
    return stellar.InvokeHostFuncOpBuilder(hostFn);
  }

  /// Simulate → attach Soroban data → sign → submit → poll
  Future<String> _prepareSignAndSubmit({
    required stellar.KeyPair keyPair,
    required stellar.AbstractTransaction tx,
  }) async {
    final simRequest =
        stellar.SimulateTransactionRequest(tx as stellar.Transaction);
    final simResponse = await _soroban.simulateTransaction(simRequest);

    if (simResponse.error != null) {
      throw Exception('Simulate failed: ${simResponse.error}');
    }

    final prepared = tx;
    prepared.sorobanTransactionData = simResponse.transactionData;
    prepared.addResourceFee(simResponse.minResourceFee!);

    final authEntries = simResponse.sorobanAuth;
    if (authEntries != null && authEntries.isNotEmpty) {
      prepared.setSorobanAuth(authEntries);
    }

    prepared.sign(keyPair, _network);

    final sendResponse = await _soroban.sendTransaction(prepared);
    if (sendResponse.error != null) {
      throw Exception('Send failed: ${sendResponse.error?.message}');
    }

    final hash = sendResponse.hash!;
    return _pollForSuccess(hash);
  }

  Future<String> _pollForSuccess(String hash) async {
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final resp = await _soroban.getTransaction(hash);
      if (resp.status == stellar.GetTransactionResponse.STATUS_SUCCESS) {
        return hash;
      }
      if (resp.status == stellar.GetTransactionResponse.STATUS_FAILED) {
        throw Exception('Transaction failed on-chain: $hash');
      }
    }
    throw Exception('Transaction timed out: $hash');
  }

  Future<VaultNote> withdrawWithProof({
    required stellar.KeyPair callerKeyPair,
    required VaultNote note,
    required ZkProofResult proof,
    required String recipientAddress,
  }) async {
    final account = await _sdk.accounts.account(callerKeyPair.accountId);
    final proofBytes = _hexToBytes(proof.proofBytesHex);
    final publicInputBytes = _hexToBytes(proof.publicInputsHex);

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _invokeOp(
            contractId: privateVaultContractId,
            functionName: 'zk_withdraw',
            args: [
              _addressVal(recipientAddress),
              _bytesVal(proofBytes),
              _bytesVal(publicInputBytes),
            ],
          ).build(),
        )
        .build();

    final hash = await _prepareSignAndSubmit(keyPair: callerKeyPair, tx: tx);

    final updated = note.copyWith(
      status: VaultNoteStatus.spent,
      spentAt: DateTime.now(),
      withdrawTxHash: hash,
      spentToAddress: recipientAddress,
    );
    await VaultNoteStore.instance.updateNote(updated);
    return updated;
  }

  // ── Step 1: Approve ───────────────────────────────────────────────────────

  /// Approve the vault contract to spend DEPOSIT_AMOUNT of USDC on behalf
  /// of [callerKeyPair]. Must be called before [deposit].
  ///
  /// [expirationLedger] — how many ledgers the approval is valid for.
  /// Default 720 ≈ 1 hour at ~5s/ledger.
  Future<String> approveUsdc({
    required stellar.KeyPair callerKeyPair,
    int dollarCount = 1, // ← how many $1 notes to approve for
    int expirationLedger = 720,
  }) async {
    debugPrint('PrivateVault: approving USDC spend for $dollarCount note(s)…');

    final account = await _sdk.accounts.account(callerKeyPair.accountId);

    final ledgerResponse = await _soroban.getLatestLedger();
    final currentLedger = ledgerResponse.sequence ?? 0;
    final expiry = currentLedger + expirationLedger;

    final totalAmount =
        privateVaultDepositAmount * dollarCount; // e.g. 3 × 10_000_000

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _invokeOp(
            contractId: privateVaultUsdcContractId,
            functionName: 'approve',
            args: [
              _addressVal(callerKeyPair.accountId),
              _contractAddressVal(privateVaultContractId),
              _i128Val(totalAmount), // ← total not per-note
              stellar.XdrSCVal.forU32(expiry),
            ],
          ).build(),
        )
        .build();

    final hash = await _prepareSignAndSubmit(keyPair: callerKeyPair, tx: tx);
    debugPrint('PrivateVault: USDC approved ✅ tx=$hash');
    return hash;
  }
  // ── Step 2: Generate note ─────────────────────────────────────────────────

  /// Generates a fresh note via the ZK bridge (Poseidon2 in JS).
  /// Stores it locally as [VaultNoteStatus.pending].
  Future<VaultNote> generateNote({
    required String ownerAddress,
  }) async {
    debugPrint('PrivateVault: generating note…');

    final zkNote = await ZkProofBridge.instance.generateNote();

    final note = VaultNote(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      nullifier: zkNote.nullifier,
      secret: zkNote.secret,
      commitment: zkNote.commitment,
      ownerAddress: ownerAddress,
      status: VaultNoteStatus.pending,
    );

    await VaultNoteStore.instance.addNote(note);
    debugPrint(
        'PrivateVault: note generated — ${note.commitment.substring(0, 14)}…');
    return note;
  }

  // ── Step 3: Deposit ───────────────────────────────────────────────────────

  /// Deposits one note into the on-chain Merkle tree.
  /// Assumes [approveUsdc] was already called.
  /// Updates note status to [VaultNoteStatus.deposited] on success.
  Future<VaultNote> deposit({
    required stellar.KeyPair callerKeyPair,
    required VaultNote note,
  }) async {
    debugPrint(
        'PrivateVault: depositing commitment ${note.commitment.substring(0, 14)}…');

    final account = await _sdk.accounts.account(callerKeyPair.accountId);
    final scVal = _u256FromHex(note.commitment);
    final roundTripped = _u256ValToHex(scVal);
    final originalClean = (note.commitment.startsWith('0x')
            ? note.commitment.substring(2)
            : note.commitment)
        .padLeft(64, '0')
        .toLowerCase();
    final roundTrippedClean = (roundTripped.startsWith('0x')
            ? roundTripped.substring(2)
            : roundTripped)
        .toLowerCase();

    if (originalClean != roundTrippedClean) {
      debugPrint('PrivateVault: ⚠️ ROUND-TRIP MISMATCH');
      debugPrint('  original:      0x$originalClean');
      debugPrint('  round-tripped: 0x$roundTrippedClean');
      throw Exception('failed');
    } else {
      debugPrint('PrivateVault: ✅ round-trip OK — 0x$originalClean');
    }

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _invokeOp(
            contractId: privateVaultContractId,
            functionName: 'deposit',
            args: [
              _addressVal(callerKeyPair.accountId), // caller
              _u256FromHex(note.commitment), // commitment as U256
            ],
          ).build(),
        )
        .build();

    final hash = await _prepareSignAndSubmit(
      keyPair: callerKeyPair,
      tx: tx,
    );

    // Mark note as deposited
    final updated = note.copyWith(
      status: VaultNoteStatus.deposited,
      depositedAt: DateTime.now(),
      depositTxHash: hash,
    );
    await VaultNoteStore.instance.updateNote(updated);

    debugPrint('PrivateVault: deposit confirmed ✅ tx=$hash');
    return updated;
  }

  // ── Approve + Deposit combined ────────────────────────────────────────────

  /// Convenience: approve → generate note → deposit in one call.
  /// Returns the confirmed note.
  Future<VaultNote> approveAndDeposit({
    required stellar.KeyPair callerKeyPair,
  }) async {
    await approveUsdc(callerKeyPair: callerKeyPair);
    final note = await generateNote(ownerAddress: callerKeyPair.accountId);
    return deposit(callerKeyPair: callerKeyPair, note: note);
  }

  // ── Step 4: Withdraw ──────────────────────────────────────────────────────

  /// Withdraws a note to [recipientAddress] using a ZK proof.
  ///
  /// Flow:
  /// 1. Fetches all on-chain commitments
  /// 2. Generates proof via ZK bridge (Merkle + UltraHonk)
  /// 3. Calls zk_withdraw on the contract
  /// 4. Marks note as spent
  Future<VaultNote> withdraw({
    required stellar.KeyPair callerKeyPair,
    required VaultNote note,
    required String recipientAddress,
  }) async {
    debugPrint('PrivateVault: withdrawing note to $recipientAddress…');

    // ── 1. Fetch all commitments from chain ───────────────────────────────
    final commitments = await fetchAllCommitments();
    debugPrint('PrivateVault: fetched ${commitments.length} commitments');

    // ── 2. Generate ZK proof ──────────────────────────────────────────────
    debugPrint('PrivateVault: generating ZK proof…');
    final proofResult = await ZkProofBridge.instance.generateProof({
      'nullifier': note.nullifier,
      'secret': note.secret,
      'commitment': note.commitment,
      'recipient': recipientAddress,
      'commitments': commitments,
    });
    debugPrint('PrivateVault: proof generated ✅');

    // ── 3. Submit zk_withdraw ─────────────────────────────────────────────
    final account = await _sdk.accounts.account(callerKeyPair.accountId);

    final proofBytes = _hexToBytes(proofResult.proofBytesHex);
    final publicInputBytes = _hexToBytes(proofResult.publicInputsHex);

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _invokeOp(
            contractId: privateVaultContractId,
            functionName: 'zk_withdraw',
            args: [
              _addressVal(recipientAddress), // recipient
              _bytesVal(proofBytes), // proof_bytes
              _bytesVal(publicInputBytes), // public_inputs
            ],
          ).build(),
        )
        .build();

    final hash = await _prepareSignAndSubmit(
      keyPair: callerKeyPair,
      tx: tx,
    );

    // ── 4. Mark note spent ────────────────────────────────────────────────
    final updated = note.copyWith(
      status: VaultNoteStatus.spent,
      spentAt: DateTime.now(),
      withdrawTxHash: hash,
      spentToAddress: recipientAddress,
    );
    await VaultNoteStore.instance.updateNote(updated);

    debugPrint('PrivateVault: withdrawal confirmed ✅ tx=$hash');
    return updated;
  }

  // ── Views ─────────────────────────────────────────────────────────────────

  /// Fetches all deposit commitments from the on-chain log.
  /// Used to rebuild the Merkle tree for proof generation.
  Future<List<String>> fetchAllCommitments() async {
    // Use a dummy account for simulation — any valid G... works
    // We use the USDC issuer as a stable known account
    const dummyCaller =
        'GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5';

    final account = await _sdk.accounts.account(dummyCaller);

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _invokeOp(
            contractId: privateVaultContractId,
            functionName: 'get_all_deposits',
            args: [],
          ).build(),
        )
        .build();

    final simRequest = stellar.SimulateTransactionRequest(tx);
    final simResponse = await _soroban.simulateTransaction(simRequest);

    if (simResponse.error != null) {
      throw Exception('get_all_deposits failed: ${simResponse.error}');
    }

    final resultXdr = simResponse.results?.first.xdr;
    if (resultXdr == null) return [];

    print(resultXdr);

    final decoded = stellar.XdrSCVal.decode(
      stellar.XdrDataInputStream(
        _decodeXdrBytes(resultXdr),
      ),
    );

    // Result is Vec<DepositEntry { commitment: U256, leaf_index: u32 }>
    final entries = decoded.vec ?? [];
    return entries.map((entry) {
      final commitmentVal = entry.map?.first.val;

      if (commitmentVal == null) return '0';
      print('id');
      print(commitmentVal.u256?.hiHi.uint64);
      print(commitmentVal.u256?.hiLo.uint64);
      print(commitmentVal.u256?.loHi.uint64);
      print(commitmentVal.u256?.loLo.uint64);
      print('id end');
      final hex = _u256ValToHex(commitmentVal); // '0x2a3f...'
      print("Hex commitms:$hex");
      // Strip 0x and parse as bigint decimal string — what Noir expects
      final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
      return BigInt.parse(clean, radix: 16).toString();
    }).toList();
  }

  Future<int> fetchNextLeafIndex() async {
    const dummyCaller =
        'GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5';
    final account = await _sdk.accounts.account(dummyCaller);

    final tx = stellar.TransactionBuilder(account)
        .addOperation(
          _invokeOp(
            contractId: privateVaultContractId,
            functionName: 'next_leaf_index',
            args: [],
          ).build(),
        )
        .build();

    final simRequest = stellar.SimulateTransactionRequest(tx);
    final simResponse = await _soroban.simulateTransaction(simRequest);

    if (simResponse.error != null) return 0;

    final resultXdr = simResponse.results?.first.xdr;
    if (resultXdr == null) return 0;

    final decoded = stellar.XdrSCVal.decode(
      stellar.XdrDataInputStream(_decodeXdrBytes(resultXdr)),
    );

    return decoded.u32?.uint32 ?? 0;
  }

  // ── Internal XDR utils ────────────────────────────────────────────────────

  Uint8List _decodeXdrBytes(String xdr) {
    try {
      return base64Decode(xdr);
    } catch (e) {
      return stellar.Util.hexToBytes(xdr);
    }
  }
}
