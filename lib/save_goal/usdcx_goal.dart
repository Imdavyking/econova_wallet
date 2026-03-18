import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/coins/fungible_tokens/stack_ft_coin.dart';
import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/c32check.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:wallet_app/utils/stack_tx_utils.dart';

// ─── Contract config ──────────────────────────────────────────────────────────
// Deploy usdcx-savings-goals.clar once via the demo testbed, then paste the
// contractId here. Format: "ST2VR...address.contract-name"

const _savingsContractId =
    'ST2VRPAPFN63CWA9HZQF8TNK678JCZAX71JJJQWGS.usdcx-savings-goals';

String get _savingsContractAddress => _savingsContractId.split('.').first;
String get _savingsContractName => _savingsContractId.split('.').last;

// ─── Goal model ───────────────────────────────────────────────────────────────

class SavingsGoal {
  final String name;
  final double balance; // in USDCx display units
  final double target; // in USDCx display units
  final int createdAt; // block height

  const SavingsGoal({
    required this.name,
    required this.balance,
    required this.target,
    required this.createdAt,
  });

  double get percent => target > 0 ? (balance / target).clamp(0.0, 1.0) : 0.0;
  bool get reached => balance >= target;
}

// ─── USDCx Goals Page ─────────────────────────────────────────────────────────
// Entry point — shows existing goals with progress + FAB to create new.

class USDCxGoalsPage extends StatefulWidget {
  final SIP010Coin coin;

  const USDCxGoalsPage({super.key, required this.coin});

  @override
  State<USDCxGoalsPage> createState() => _USDCxGoalsPageState();
}

class _USDCxGoalsPageState extends State<USDCxGoalsPage> {
  List<SavingsGoal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final goals = await _fetchGoals(widget.coin);
      setState(() => _goals = goals);
    } catch (_) {
      // silently ignore — user may have no goals yet
    } finally {
      setState(() => _loading = false);
    }
  }

  // Reads all goals for the connected address via Hiro read-only API
  Future<List<SavingsGoal>> _fetchGoals(SIP010Coin coin) async {
    final data = WalletService.getActiveKey(walletImportType)!.data;
    final keyPair = await coin.importData(data);
    final address = keyPair.address;
    final api = stacksApiUrl(coin.isTestnet);

    // We store goal names in local prefs for now — the contract doesn't
    // have an enumeration function. Call get-progress for each stored name.
    final storedNames = _loadStoredGoalNames(address);
    final goals = <SavingsGoal>[];

    for (final name in storedNames) {
      try {
        final res = await http.post(
          Uri.parse(
              '$api/v2/contracts/call-read/$_savingsContractAddress/$_savingsContractName/get-progress'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sender': address,
            'arguments': [
              _hexSerialize(clarityStandardPrincipalFromAddress(address)),
              _hexSerialize(_clarityStringAscii(name)),
            ],
          }),
        );
        if (res.statusCode ~/ 100 != 2) continue;
        final body = jsonDecode(res.body) as Map;
        if (body['okay'] != true) continue;
        final result = body['result'] as String;
        final goal = _parseProgressResult(name, result);
        if (goal != null) goals.add(goal);
      } catch (_) {
        continue;
      }
    }
    return goals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USDCx Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateUSDCxGoal(coin: widget.coin),
            ),
          );
          if (created == true) _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
        backgroundColor: appBackgroundblue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? _emptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _goals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _GoalCard(
                    goal: _goals[i],
                    coin: widget.coin,
                    onChanged: _load,
                  ),
                ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No savings goals yet',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CreateUSDCxGoal(coin: widget.coin)),
                );
                if (created == true) _load();
              },
              child: const Text('Create your first goal'),
            ),
          ],
        ),
      );
}

// ─── Goal Card ────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final SIP010Coin coin;
  final VoidCallback onChanged;

  const _GoalCard({
    required this.goal,
    required this.coin,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (goal.percent * 100).toStringAsFixed(1);
    final balStr = goal.balance.toStringAsFixed(2);
    final tgtStr = goal.target.toStringAsFixed(2);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                if (goal.reached)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Reached 🎉',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.percent,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(
                    goal.reached ? Colors.green : appBackgroundblue),
              ),
            ),
            const SizedBox(height: 8),

            // Balance / target
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$balStr / $tgtStr USDCx',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text('$pct%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SaveToUSDCxGoal(coin: coin, goalName: goal.name),
                        ),
                      );
                      onChanged();
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: goal.balance > 0
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WithdrawFromGoal(coin: coin, goal: goal),
                              ),
                            );
                            onChanged();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_downward, size: 16),
                    label: const Text('Withdraw'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
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

// ─── Create Goal Screen ───────────────────────────────────────────────────────

class CreateUSDCxGoal extends StatefulWidget {
  final SIP010Coin coin;

  const CreateUSDCxGoal({super.key, required this.coin});

  @override
  State<CreateUSDCxGoal> createState() => _CreateUSDCxGoalState();
}

class _CreateUSDCxGoalState extends State<CreateUSDCxGoal> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final targetStr = _targetCtrl.text.trim();
    if (name.isEmpty) return _err('Goal name is required');
    final target = double.tryParse(targetStr);
    if (target == null || target <= 0)
      return _err('Enter a valid target amount');

    final targetUnits = BigInt.from((target * 1e6).round());
    _isLoading.value = true;
    try {
      await _contractCall(
        coin: widget.coin,
        functionName: 'create-goal',
        args: [_clarityStringAscii(name), clarityUInt(targetUnits)],
      );
      // Persist goal name locally so we can fetch progress later
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final keyPair = await widget.coin.importData(data);
      _saveGoalName(keyPair.address, name);
      if (!mounted) return;
      _ok('Goal "$name" created!');
      Navigator.pop(context, true);
    } catch (e) {
      _err(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Savings Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input(
                _nameCtrl, 'Goal name (e.g. Holiday fund)', TextInputType.text),
            const SizedBox(height: 16),
            _input(_targetCtrl, 'Target amount in USDCx',
                const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 32),
            _btn(),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, TextInputType type) =>
      TextFormField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide.none),
        ),
      );

  Widget _btn() => ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (_, loading, __) => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(appBackgroundblue),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
            ),
            onPressed: loading ? null : _submit,
            child: loading
                ? const Loader()
                : const Text('Create Goal',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ),
      );

  void _err(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg, style: const TextStyle(color: Colors.white))));
  }

  void _ok(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(msg, style: const TextStyle(color: Colors.white))));
  }
}

// ─── Save To Goal Screen ──────────────────────────────────────────────────────

class SaveToUSDCxGoal extends StatefulWidget {
  final SIP010Coin coin;
  final String goalName;

  const SaveToUSDCxGoal(
      {super.key, required this.coin, required this.goalName});

  @override
  State<SaveToUSDCxGoal> createState() => _SaveToUSDCxGoalState();
}

class _SaveToUSDCxGoalState extends State<SaveToUSDCxGoal> {
  final _amountCtrl = TextEditingController();
  final _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _amountCtrl.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return _err('Enter a valid amount');

    final units = BigInt.from((amount * 1e6).round());
    _isLoading.value = true;
    try {
      await _contractCall(
        coin: widget.coin,
        functionName: 'save',
        args: [_clarityStringAscii(widget.goalName), clarityUInt(units)],
      );
      if (!mounted) return;
      _ok('Saved ${_amountCtrl.text} USDCx to "${widget.goalName}"!');
      Navigator.pop(context, true);
    } catch (e) {
      _err(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Save to "${widget.goalName}"')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Amount in USDCx',
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (_, loading, __) => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(appBackgroundblue),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const Loader()
                        : const Text('Save',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _err(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg, style: const TextStyle(color: Colors.white))));
  }

  void _ok(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(msg, style: const TextStyle(color: Colors.white))));
  }
}

// ─── Withdraw From Goal Screen ────────────────────────────────────────────────

class WithdrawFromGoal extends StatefulWidget {
  final SIP010Coin coin;
  final SavingsGoal goal;

  const WithdrawFromGoal({super.key, required this.coin, required this.goal});

  @override
  State<WithdrawFromGoal> createState() => _WithdrawFromGoalState();
}

class _WithdrawFromGoalState extends State<WithdrawFromGoal> {
  final _amountCtrl = TextEditingController();
  final _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _amountCtrl.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) return _err('Enter a valid amount');
    if (amount > widget.goal.balance) {
      return _err(
          'Insufficient balance (max ${widget.goal.balance.toStringAsFixed(2)} USDCx)');
    }

    final units = BigInt.from((amount * 1e6).round());
    _isLoading.value = true;
    try {
      await _contractCall(
        coin: widget.coin,
        functionName: 'withdraw',
        args: [_clarityStringAscii(widget.goal.name), clarityUInt(units)],
      );
      if (!mounted) return;
      _ok('Withdrew ${_amountCtrl.text} USDCx from "${widget.goal.name}"!');
      Navigator.pop(context, true);
    } catch (e) {
      _err(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Withdraw from "${widget.goal.name}"')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Available balance chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: appBackgroundblue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Available: ${widget.goal.balance.toStringAsFixed(2)} USDCx',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Amount to withdraw',
                  filled: true,
                  suffixIcon: TextButton(
                    onPressed: () => _amountCtrl.text =
                        widget.goal.balance.toStringAsFixed(6),
                    child: const Text('MAX'),
                  ),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none),
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (_, loading, __) => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.red.shade400),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                    ),
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const Loader()
                        : const Text('Withdraw',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _err(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg, style: const TextStyle(color: Colors.white))));
  }

  void _ok(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(msg, style: const TextStyle(color: Colors.white))));
  }
}

// ─── Shared contract call helper ──────────────────────────────────────────────

Future<String> _contractCall({
  required SIP010Coin coin,
  required String functionName,
  required List<Uint8List> args,
}) async {
  final data = WalletService.getActiveKey(walletImportType)!.data;
  final keyPair = await coin.importData(data);
  final privBytes = txDataToUintList(keyPair.privateKey!);
  final senderHash160 = stacksHash160(stacksCompressedPubKey(privBytes));
  final isTestnet = coin.isTestnet;

  final nonce = await stacksFetchNonce(isTestnet, keyPair.address);
  final feeRate = await stacksFetchFeeRate(isTestnet);
  final fee = BigInt.from(feeRate * stacksEstimatedContractCallBytes);

  final contractDecoded = c32checkDecode(_savingsContractAddress.substring(1));
  final contractVersion = contractDecoded[0] as int;
  final contractHash160 =
      Uint8List.fromList(HEX.decode(contractDecoded[1] as String));

  final payload = stacksBuildContractCallPayload(
    contractVersion: contractVersion,
    contractHash160: contractHash160,
    contractName: _savingsContractName,
    functionName: functionName,
    args: args,
  );

  final txBytes = stacksBuildSignedTx(
    txVersion: stacksTxVersion(isTestnet),
    chainId: stacksChainId(isTestnet),
    privKey: privBytes,
    senderHash160: senderHash160,
    nonce: BigInt.from(nonce),
    fee: fee,
    payload: payload,
  );

  final res = await http.post(
    Uri.parse('${stacksApiUrl(isTestnet)}/v2/transactions'),
    headers: {'Content-Type': 'application/octet-stream'},
    body: txBytes,
  );

  if (res.statusCode ~/ 100 != 2) {
    throw Exception('Contract call failed: ${res.body}');
  }
  return jsonDecode(res.body) as String;
}

// ─── Clarity helpers ──────────────────────────────────────────────────────────

Uint8List _clarityStringAscii(String value) {
  final bytes = utf8.encode(value);
  return (BytesBuilder()
        ..addByte(0x0d)
        ..add(stacksU32BE(bytes.length))
        ..add(bytes))
      .toBytes();
}

// Serialize a Clarity value to hex string for read-only call arguments
String _hexSerialize(Uint8List bytes) => '0x${HEX.encode(bytes)}';

// Build a Clarity standard-principal from a Stacks address string
Uint8List clarityStandardPrincipalFromAddress(String address) {
  final decoded = c32checkDecode(address.substring(1));
  final version = decoded[0] as int;
  final hash160 = Uint8List.fromList(HEX.decode(decoded[1] as String));
  return clarityStandardPrincipal(version, hash160);
}

// Parse the hex result of get-progress into a SavingsGoal
SavingsGoal? _parseProgressResult(String name, String hexResult) {
  try {
    // Result is (ok { balance: uint, target: uint, percent: uint })
    // We parse the tuple fields from the Clarity hex
    final clean =
        hexResult.startsWith('0x') ? hexResult.substring(2) : hexResult;
    final bytes = Uint8List.fromList(HEX.decode(clean));
    final parsed = clarityReadValue(bytes, 0);
    final display = parsed.display;

    // Extract balance and target from display string e.g. "balance: u1000000\ntarget: u100000000\npercent: u1"
    BigInt extract(String key) {
      final match = RegExp('$key: u(\\d+)').firstMatch(display);
      return match != null ? BigInt.parse(match.group(1)!) : BigInt.zero;
    }

    final balanceUnits = extract('balance');
    final targetUnits = extract('target');

    return SavingsGoal(
      name: name,
      balance: balanceUnits / BigInt.from(1000000),
      target: targetUnits / BigInt.from(1000000),
      createdAt: 0,
    );
  } catch (_) {
    return null;
  }
}

// ─── Local goal name persistence ─────────────────────────────────────────────
// Stores created goal names per address in prefs so we can fetch their progress.

List<String> _loadStoredGoalNames(String address) {
  final key = 'stx_savings_goals_$address';
  final raw = pref.get(key) as String?;
  if (raw == null) return [];
  return List<String>.from(jsonDecode(raw));
}

void _saveGoalName(String address, String name) {
  final key = 'stx_savings_goals_$address';
  final names = _loadStoredGoalNames(address);
  if (!names.contains(name)) {
    names.add(name);
    pref.put(key, jsonEncode(names));
  }
}
