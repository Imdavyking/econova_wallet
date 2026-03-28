import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/service/dms_relay_service.dart';
import 'package:wallet_app/service/drand_service.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/auth_utils.dart';

class DeadManSwitchScreen extends StatefulWidget {
  const DeadManSwitchScreen({super.key});

  @override
  State<DeadManSwitchScreen> createState() => _DeadManSwitchScreenState();
}

class _DeadManSwitchScreenState extends State<DeadManSwitchScreen> {
  DmsState _state = DmsState.inactive;
  DmsConfig? _config;
  List<EncryptedShare>? _encryptedShares;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _state = DeadManSwitchService.state;
      _config = DeadManSwitchService.config;
      _encryptedShares = DeadManSwitchService.encryptedShares;
    });
  }

  Future<void> _activate(DmsConfig cfg) async {
    if (!WalletService.isPharseKey()) return;

    final authed = await authenticate(context);
    if (!authed) {
      if (!context.mounted) return;
      _showSnack('Authentication failed', isError: true);
      return;
    }

    final mnemonic = WalletService.getActiveKey(walletImportType)!.data;

    setState(() => _loading = true);
    final result = await DeadManSwitchService.activate(
      mnemonic: mnemonic,
      cfg: cfg,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case DmsOk(:final encryptedShares):
        _refresh();
        if (encryptedShares != null) {
          _showSharesDialog(encryptedShares, cfg.threshold);
        }
      case DmsErr(:final message):
        _showSnack(message, isError: true);
    }
  }

  Future<void> _heartbeat() async {
    final result = await DeadManSwitchService.heartbeat();
    if (!mounted) return;
    switch (result) {
      case DmsOk():
        _refresh();
        _showSnack('Heartbeat recorded — timer reset');
      case DmsErr(:final message):
        _showSnack(message, isError: true);
    }
  }

  Future<void> _cancel() async {
    final authed = await authenticate(context);
    if (!authed) {
      if (!context.mounted) return;
      _showSnack('Authentication failed', isError: true);
      return;
    }
    final result = await DeadManSwitchService.cancel();
    if (!mounted) return;
    switch (result) {
      case DmsOk():
        _refresh();
        _showSnack('Dead man\'s switch cancelled');
      case DmsErr(:final message):
        _showSnack(message, isError: true);
    }
  }

  Future<void> _reset() async {
    await DeadManSwitchService.reset();
    if (!mounted) return;
    _refresh();
  }

  void _showSharesDialog(List<EncryptedShare> shares, int threshold) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SharesDialog(shares: shares, threshold: threshold),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dead Man\'s Switch')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DmsStatusCard(state: _state),
              const SizedBox(height: 20),
              if (!WalletService.isPharseKey())
                const _NotSupportedCard()
              else
                _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Encrypting shares…', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return switch (_state) {
      DmsState.inactive => _DmsSetupForm(onActivate: _activate),
      DmsState.active => _DmsActiveView(
          config: _config!,
          encryptedShares: _encryptedShares,
          onHeartbeat: _heartbeat,
          onCancel: _cancel,
          onViewShares: _encryptedShares != null
              ? () => _showSharesDialog(
                    _encryptedShares!,
                    _config!.threshold,
                  )
              : null,
        ),
      DmsState.triggered => _DmsTriggeredView(
          encryptedShares: _encryptedShares,
          config: _config,
        ),
      DmsState.cancelled => _DmsCancelledView(onReset: _reset),
    };
  }
}

// ── Status card ───────────────────────────────────────────────────────────────

class _DmsStatusCard extends StatelessWidget {
  final DmsState state;
  const _DmsStatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label, desc) = switch (state) {
      DmsState.inactive => (
          Colors.grey,
          FontAwesomeIcons.heartCircleXmark,
          'Inactive',
          'Set up a dead man\'s switch to protect your seed phrase.'
        ),
      DmsState.active => (
          Colors.green,
          FontAwesomeIcons.heartPulse,
          'Active',
          'Armed. Shares time-locked via drand & encrypted to beneficiary key.'
        ),
      DmsState.triggered => (
          Colors.red,
          FontAwesomeIcons.triangleExclamation,
          'Triggered',
          'Deadline passed. drand randomness unlocks shares for beneficiary.'
        ),
      DmsState.cancelled => (
          Colors.orange,
          FontAwesomeIcons.heartCircleMinus,
          'Cancelled',
          'The switch was cancelled. You can set up a new one.'
        ),
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Not supported card ────────────────────────────────────────────────────────

class _NotSupportedCard extends StatelessWidget {
  const _NotSupportedCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dead man\'s switch requires a seed phrase wallet. '
                'Switch to a seed phrase wallet in All Wallets.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Setup form ────────────────────────────────────────────────────────────────

class _DmsSetupForm extends StatefulWidget {
  final Future<void> Function(DmsConfig) onActivate;
  const _DmsSetupForm({required this.onActivate});

  @override
  State<_DmsSetupForm> createState() => _DmsSetupFormState();
}

class _DmsSetupFormState extends State<_DmsSetupForm> {
  final _addressController = TextEditingController();
  final _pubKeyController = TextEditingController();
  int _timeoutDays = 30;
  int _threshold = 2;
  int _totalShares = 3;

  static const _timeoutOptions = [7, 14, 30, 90, 180, 365];

  @override
  void dispose() {
    _addressController.dispose();
    _pubKeyController.dispose();
    super.dispose();
  }

  bool get _valid {
    final addr = _addressController.text.trim();
    final pub = _pubKeyController.text.trim().replaceFirst('0x', '');
    // Compressed secp256k1 public key = 33 bytes = 66 hex chars.
    final pubValid =
        pub.length == 66 && (pub.startsWith('02') || pub.startsWith('03'));
    return addr.isNotEmpty && pubValid && _threshold <= _totalShares;
  }

  void _submit() {
    if (!_valid) return;
    widget.onActivate(DmsConfig(
      beneficiaryAddress: _addressController.text.trim(),
      beneficiaryPublicKey: _pubKeyController.text.trim(),
      timeoutDays: _timeoutDays,
      threshold: _threshold,
      totalShares: _totalShares,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── How it works banner ──────────────────────────────────────────────
        _InfoBanner(
          color: Colors.blue,
          text: 'Your seed phrase is split via Shamir\'s Secret Sharing. Each '
              'share is time-locked using drand (a distributed randomness '
              'beacon) so it cannot be decrypted before your deadline, then '
              'encrypted to the beneficiary\'s public key so only they can '
              'read it.',
        ),
        const SizedBox(height: 20),

        // ── Beneficiary address ──────────────────────────────────────────────
        const _FormLabel('Beneficiary Wallet Address'),
        const SizedBox(height: 6),
        TextField(
          controller: _addressController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '0x...',
            prefixIcon: const Icon(Icons.account_circle_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 20),

        // ── Beneficiary public key ───────────────────────────────────────────
        const _FormLabel('Beneficiary secp256k1 Public Key'),
        const SizedBox(height: 4),
        const Text(
          'Compressed hex (03... or 02..., 66 characters). '
          'Only the matching private key can decrypt the shares.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _pubKeyController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            hintText: '02a1b2c3...  (66 hex chars)',
            prefixIcon: const Icon(Icons.vpn_key_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: _pubKeyController.text.isNotEmpty && !_pubKeyHint
                ? 'Must be 66 hex chars starting with 02 or 03'
                : null,
          ),
        ),
        const SizedBox(height: 20),

        // ── Timeout ──────────────────────────────────────────────────────────
        const _FormLabel('Inactivity Timeout'),
        const SizedBox(height: 6),
        _TimeoutPicker(
          selected: _timeoutDays,
          options: _timeoutOptions,
          onChanged: (v) => setState(() => _timeoutDays = v),
        ),
        const SizedBox(height: 4),
        // Show the drand round that will be used.
        _DrandRoundPreview(timeoutDays: _timeoutDays),
        const SizedBox(height: 20),

        // ── Shares config ─────────────────────────────────────────────────────
        _SharesConfig(
          threshold: _threshold,
          total: _totalShares,
          onThresholdChanged: (v) => setState(() {
            _threshold = v;
            if (_totalShares < _threshold) _totalShares = _threshold;
          }),
          onTotalChanged: (v) => setState(() {
            _totalShares = v;
            if (_threshold > _totalShares) _threshold = _totalShares;
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Any $_threshold of $_totalShares shares can reconstruct your seed phrase.',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // ── Activate ─────────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _valid ? _submit : null,
            icon: const Icon(FontAwesomeIcons.heartPulse, size: 16),
            label: const Text('Arm Switch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  bool get _pubKeyHint {
    final pub = _pubKeyController.text.trim().replaceFirst('0x', '');
    return pub.isEmpty ||
        (pub.length == 66 && (pub.startsWith('02') || pub.startsWith('03')));
  }
}

// ── drand round preview ───────────────────────────────────────────────────────

class _DrandRoundPreview extends StatelessWidget {
  final int timeoutDays;
  const _DrandRoundPreview({required this.timeoutDays});

  @override
  Widget build(BuildContext context) {
    final deadline = DateTime.now().add(Duration(days: timeoutDays));
    final round = DrandService.roundForTime(deadline);
    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'drand lock round: #$round  '
            '(≈ ${deadline.day}/${deadline.month}/${deadline.year})',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

// ── Active view ───────────────────────────────────────────────────────────────

class _DmsActiveView extends StatelessWidget {
  final DmsConfig config;
  final List<EncryptedShare>? encryptedShares;
  final VoidCallback onHeartbeat;
  final VoidCallback onCancel;
  final VoidCallback? onViewShares;

  const _DmsActiveView({
    required this.config,
    required this.encryptedShares,
    required this.onHeartbeat,
    required this.onCancel,
    this.onViewShares,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = DeadManSwitchService.timeRemaining;
    final last = DeadManSwitchService.lastActivity;
    final dl = DeadManSwitchService.deadline;
    final round = DeadManSwitchService.drandRound;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CountdownCard(remaining: remaining, deadline: dl),
        const SizedBox(height: 16),
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Beneficiary',
            value: config.beneficiaryAddress,
          ),
          _InfoRow(
            icon: Icons.schedule,
            label: 'Last activity',
            value: last != null ? _fmt(last) : '—',
          ),
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Timeout',
            value: '${config.timeoutDays} days',
          ),
          _InfoRow(
            icon: Icons.lock_outline,
            label: 'Shares',
            value: '${config.threshold}-of-${config.totalShares}',
          ),
          if (round != null)
            _InfoRow(
              icon: Icons.shuffle,
              label: 'drand round',
              value: '#$round',
            ),
        ]),
        const SizedBox(height: 20),

        // ── Heartbeat ─────────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onHeartbeat,
            icon: const Icon(FontAwesomeIcons.heartPulse, size: 16),
            label: const Text('I\'m alive — reset timer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Send via relay ────────────────────────────────────────────────────
        if (encryptedShares != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openRelaySheet(context),
              icon: const Icon(Icons.send_outlined, size: 16),
              label: const Text('Send shares via EcoNova relay'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        const SizedBox(height: 10),

        // ── View shares ───────────────────────────────────────────────────────
        if (onViewShares != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewShares,
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('View encrypted shares'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        const SizedBox(height: 10),

        // ── Cancel ────────────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(FontAwesomeIcons.heartCircleXmark,
                size: 16, color: Colors.red),
            label: const Text('Cancel switch',
                style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  void _openRelaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _RelayBottomSheet(
        encryptedShares: encryptedShares!,
        threshold: config.threshold,
      ),
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

// ── Relay bottom sheet ────────────────────────────────────────────────────────

class _RelayBottomSheet extends StatefulWidget {
  final List<EncryptedShare> encryptedShares;
  final int threshold;
  const _RelayBottomSheet(
      {required this.encryptedShares, required this.threshold});

  @override
  State<_RelayBottomSheet> createState() => _RelayBottomSheetState();
}

class _RelayBottomSheetState extends State<_RelayBottomSheet> {
  final _roomController = TextEditingController();
  bool _connected = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _roomController.dispose();
    DmsRelayService.disconnect();
    super.dispose();
  }

  Future<void> _connect() async {
    final roomId = _roomController.text.trim();
    if (roomId.isEmpty) return;
    try {
      await DmsRelayService.connect(roomId: roomId, role: 'sender');
      if (!mounted) return;
      setState(() {
        _connected = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Connection failed: $e');
    }
  }

  void _send() {
    DmsRelayService.sendShares(
      shares: widget.encryptedShares,
      threshold: widget.threshold,
    );
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Shares via EcoNova Relay',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Both devices must use the same Room ID. The beneficiary opens '
            'EcoNova → DMS → Receive Shares and enters the same room.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (!_connected) ...[
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: 'Room ID',
                hintText: 'e.g. alice-to-bob-2026',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _connect,
                child: const Text('Connect'),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
          ] else if (!_sent) ...[
            _InfoBanner(
              color: Colors.green,
              text: 'Connected to room "${_roomController.text.trim()}". '
                  'Tap Send to push ${widget.encryptedShares.length} encrypted '
                  'shares to the receiver. They can only decrypt them after '
                  'the drand deadline.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send),
                label: Text(
                    'Send ${widget.encryptedShares.length} encrypted shares'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            _InfoBanner(
              color: Colors.green,
              text: 'All ${widget.encryptedShares.length} shares sent! '
                  'The receiver now holds them encrypted — only unlockable '
                  'with their private key after the drand deadline.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Triggered view ────────────────────────────────────────────────────────────

class _DmsTriggeredView extends StatelessWidget {
  final List<EncryptedShare>? encryptedShares;
  final DmsConfig? config;
  const _DmsTriggeredView({this.encryptedShares, this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          color: Colors.red,
          text: 'Deadline exceeded. The drand randomness for round '
              '#${DeadManSwitchService.drandRound ?? "?"} is now public. '
              'Any ${config?.threshold ?? "?"}/${config?.totalShares ?? "?"} '
              'shares + beneficiary private key can reconstruct the seed phrase.',
        ),
        const SizedBox(height: 16),
        if (encryptedShares != null)
          ...encryptedShares!.asMap().entries.map(
                (e) => _EncryptedShareTile(index: e.key, share: e.value),
              ),
      ],
    );
  }
}

// ── Cancelled view ────────────────────────────────────────────────────────────

class _DmsCancelledView extends StatelessWidget {
  final VoidCallback onReset;
  const _DmsCancelledView({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'The dead man\'s switch was cancelled. '
          'You can arm a new one at any time.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text('Set up new switch'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shares dialog ─────────────────────────────────────────────────────────────

class _SharesDialog extends StatelessWidget {
  final List<EncryptedShare> shares;
  final int threshold;
  const _SharesDialog({required this.shares, required this.threshold});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encrypted Shares',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Each share is AES-locked until the drand deadline and '
              'ECIES-encrypted to the beneficiary\'s public key. '
              'Safe to store or transmit. Distribute to $threshold+ trusted parties.',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: shares
                      .asMap()
                      .entries
                      .map((e) =>
                          _EncryptedShareTile(index: e.key, share: e.value))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Encrypted share tile ──────────────────────────────────────────────────────

class _EncryptedShareTile extends StatelessWidget {
  final int index;
  final EncryptedShare share;
  const _EncryptedShareTile({required this.index, required this.share});

  @override
  Widget build(BuildContext context) {
    final ct = share.ciphertext;
    final preview = ct.length > 20
        ? '${ct.substring(0, 10)}…${ct.substring(ct.length - 10)}'
        : ct;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.blue),
              child: Center(
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Share ${index + 1}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(preview,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontFamily: 'monospace')),
                  Text('drand round #${share.drandRound}',
                      style: const TextStyle(
                          fontSize: 10, color: Colors.blueGrey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy share',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: share.ciphertext));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Encrypted share copied'),
                      duration: Duration(seconds: 1)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Countdown card ────────────────────────────────────────────────────────────

class _CountdownCard extends StatelessWidget {
  final Duration? remaining;
  final DateTime? deadline;
  const _CountdownCard({this.remaining, this.deadline});

  @override
  Widget build(BuildContext context) {
    final days = remaining?.inDays ?? 0;
    final hours = (remaining?.inHours ?? 0) % 24;
    final color = days < 3 ? Colors.red : Colors.green;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Remaining',
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(FontAwesomeIcons.hourglassHalf, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  remaining == null ? '—' : '$days days, $hours hours',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            if (deadline != null) ...[
              const SizedBox(height: 4),
              Text(
                'Triggers: ${deadline!.day}/${deadline!.month}/${deadline!.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final Color color;
  final String text;
  const _InfoBanner({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(text, style: TextStyle(fontSize: 13, color: color)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Spacer(),
          Flexible(
            child: Text(value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

class _TimeoutPicker extends StatelessWidget {
  final int selected;
  final List<int> options;
  final ValueChanged<int> onChanged;

  const _TimeoutPicker(
      {required this.selected, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((days) {
        final isSelected = days == selected;
        return ChoiceChip(
          label: Text(days >= 365 ? '1 year' : '${days}d'),
          selected: isSelected,
          onSelected: (_) => onChanged(days),
          selectedColor: appBackgroundblue,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}

class _SharesConfig extends StatelessWidget {
  final int threshold;
  final int total;
  final ValueChanged<int> onThresholdChanged;
  final ValueChanged<int> onTotalChanged;

  const _SharesConfig({
    required this.threshold,
    required this.total,
    required this.onThresholdChanged,
    required this.onTotalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                    child:
                        Text('Total shares', style: TextStyle(fontSize: 14))),
                _Counter(
                    value: total, min: 2, max: 10, onChanged: onTotalChanged),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                const Expanded(
                    child: Text('Required to recover',
                        style: TextStyle(fontSize: 14))),
                _Counter(
                    value: threshold,
                    min: 2,
                    max: total,
                    onChanged: onThresholdChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Counter(
      {required this.value,
      required this.min,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(
          width: 32,
          child: Text('$value',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey));
  }
}
