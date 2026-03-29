import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
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
    if (!WalletService.isPharseKey()) return;

    final authed = await authenticate(context);
    if (!authed) {
      if (!context.mounted) return;
      _showSnack('Authentication failed', isError: true);
      return;
    }

    final mnemonic = WalletService.getActiveKey(walletImportType)!.data;

    setState(() => _loading = true);
    final result = await DeadManSwitchService.heartbeat(mnemonic: mnemonic);
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case DmsOk():
        _refresh(); // ← pushes new deadline down to _CountdownCard
        _showSnack('Heartbeat recorded — timer reset & shares re-sent');
      case DmsErr(:final message):
        _showSnack(message, isError: true);
    }
  }

  Future<void> _acknowledge() async {
    await DeadManSwitchService.reset();
    if (!mounted) return;
    _refresh();
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
      appBar: AppBar(
        title: const Text('Dead Man\'s Switch'),
        actions: [
          if (kDmsTestMode)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TEST MODE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
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
              Text('Encrypting & sending shares…',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return switch (_state) {
      DmsState.inactive => FutureBuilder<String?>(
          future: (() async {
            final mnemonic = WalletService.getActiveKey(walletImportType)!.data;
            final eth = getChains<EthereumCoin>().first;
            final details = await eth.importData(mnemonic);
            return details.address;
          })(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const SizedBox.shrink();
            if (!snapshot.hasData) return const SizedBox.shrink();
            return _DmsSetupForm(
              onActivate: _activate,
              senderAddress: snapshot.data!,
            );
          },
        ),
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
          onAcknowledge: _acknowledge,
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
          'Armed. Shares sent to beneficiary & time-locked via drand.'
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
  final String senderAddress;
  const _DmsSetupForm({required this.onActivate, required this.senderAddress});

  @override
  State<_DmsSetupForm> createState() => _DmsSetupFormState();
}

class _DmsSetupFormState extends State<_DmsSetupForm> {
  final _pubKeyController = TextEditingController();
  int _timeoutSeconds = DmsTimeouts.defaultSeconds;
  int _threshold = 2;
  int _totalShares = 3;

  @override
  void dispose() {
    _pubKeyController.dispose();
    super.dispose();
  }

  bool get _pubKeyValid {
    final pub = _pubKeyController.text.trim().replaceFirst('0x', '');
    return pub.length == 66 && (pub.startsWith('02') || pub.startsWith('03'));
  }

  bool get _valid => _pubKeyValid && _threshold <= _totalShares;

  void _submit() {
    if (!_valid) return;
    widget.onActivate(DmsConfig(
      senderAddress: widget.senderAddress,
      beneficiaryPublicKey: _pubKeyController.text.trim(),
      timeoutSeconds: _timeoutSeconds,
      threshold: _threshold,
      totalShares: _totalShares,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Info banner ──────────────────────────────────────────────────────
        const _InfoBanner(
          color: Colors.blue,
          text: 'Your seed phrase is split via Shamir\'s Secret Sharing. '
              'Each share is time-locked using drand so it cannot be decrypted '
              'before your deadline, then encrypted to the beneficiary\'s public '
              'key and sent to them automatically.',
        ),
        const SizedBox(height: 20),

        // ── Debug banner ─────────────────────────────────────────────────────
        if (kDmsTestMode) ...[
          const _InfoBanner(
            color: Colors.orange,
            text: '⚠️ TEST MODE — short timeouts enabled. '
                'Run without --dart-define=DMS_TEST=true for production.',
          ),
          const SizedBox(height: 16),
        ],

        // ── Public key ───────────────────────────────────────────────────────
        const _FormLabel('Beneficiary Public Key'),
        const SizedBox(height: 4),
        const Text(
          'Compressed secp256k1 hex (02... or 03..., 66 chars). '
          'The beneficiary can find this in their EcoNova wallet. '
          'Shares are sent to them automatically on activation.',
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
            suffixIcon: IconButton(
              icon: const Icon(Icons.content_paste_outlined, size: 18),
              tooltip: 'Paste',
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text == null) return;
                _pubKeyController.setText(data!.text!.trim());
                setState(() {});
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: _pubKeyController.text.isNotEmpty && !_pubKeyValid
                ? 'Must be 66 hex chars starting with 02 or 03'
                : null,
          ),
        ),

        // ── Derived address preview ──────────────────────────────────────────
        if (_pubKeyValid) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Address: ${DmsConfig(
                    senderAddress: widget.senderAddress,
                    beneficiaryPublicKey: _pubKeyController.text.trim(),
                    timeoutSeconds: _timeoutSeconds,
                    threshold: _threshold,
                    totalShares: _totalShares,
                  ).beneficiaryAddress}',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),

        // ── Timeout ──────────────────────────────────────────────────────────
        const _FormLabel(
          kDmsTestMode ? 'Inactivity Timeout (Test)' : 'Inactivity Timeout',
        ),
        const SizedBox(height: 6),
        _TimeoutPicker(
          selected: _timeoutSeconds,
          options: DmsTimeouts.current,
          onChanged: (v) => setState(() => _timeoutSeconds = v),
        ),
        const SizedBox(height: 4),
        _DrandRoundPreview(timeoutSeconds: _timeoutSeconds),
        const SizedBox(height: 20),

        // ── Shares config ────────────────────────────────────────────────────
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
            label: const Text('Arm Switch & Send Shares'),
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
}

// ── drand round preview ───────────────────────────────────────────────────────

class _DrandRoundPreview extends StatelessWidget {
  final int timeoutSeconds;
  const _DrandRoundPreview({required this.timeoutSeconds});

  @override
  Widget build(BuildContext context) {
    final deadline = DateTime.now().add(Duration(seconds: timeoutSeconds));
    final round = DrandService.roundForTime(deadline);

    final deadlineLabel = timeoutSeconds < 86400
        ? '${deadline.hour.toString().padLeft(2, '0')}:'
            '${deadline.minute.toString().padLeft(2, '0')}:'
            '${deadline.second.toString().padLeft(2, '0')}'
        : '${deadline.day}/${deadline.month}/${deadline.year}';

    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'drand lock round: #$round  (≈ $deadlineLabel)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

// ── Active view ───────────────────────────────────────────────────────────────
// Stays StatelessWidget — only _CountdownCard ticks internally.

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
    final last = DeadManSwitchService.lastActivity;
    final round = DeadManSwitchService.drandRound;
    final roomId = DeadManSwitchService.roomIdFromPubKey(
      config.beneficiaryPublicKey,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Relay sent banner ─────────────────────────────────────────────────
        _InfoBanner(
          color: Colors.blue,
          text: '✓ Shares automatically sent to beneficiary.\n'
              'Room ID: ${roomId.substring(0, 8)}…${roomId.substring(roomId.length - 8)}',
        ),
        const SizedBox(height: 16),

        // ── Countdown — only this widget ticks ───────────────────────────────
        const _CountdownCard(),
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
            value: config.timeoutLabel,
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

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';
}

// ── Triggered view ────────────────────────────────────────────────────────────

class _DmsTriggeredView extends StatelessWidget {
  final List<EncryptedShare>? encryptedShares;
  final DmsConfig? config;
  final VoidCallback onAcknowledge;

  const _DmsTriggeredView({
    this.encryptedShares,
    this.config,
    required this.onAcknowledge,
  });

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
        const SizedBox(height: 24),

        // ── Acknowledge & clear ───────────────────────────────────────────────
        const _InfoBanner(
          color: Colors.orange,
          text: 'If you are still alive, you can dismiss this and set up '
              'a new switch. The beneficiary\'s shares remain valid until '
              'they decrypt them.',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmAcknowledge(context),
            icon: const Icon(Icons.refresh, color: Colors.orange),
            label: const Text(
              'I\'m alive — dismiss & reset',
              style: TextStyle(color: Colors.orange),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmAcknowledge(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dismiss triggered state?'),
        content: const Text(
          'This will clear the switch. The beneficiary\'s existing shares '
          'are still valid — you should send a new cancel message by '
          'arming and immediately cancelling a new switch.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAcknowledge();
            },
            child: const Text(
              'Yes, I\'m alive',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
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
              'Each share is ECIES-encrypted to the beneficiary\'s public key '
              'and time-locked via drand. '
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
// StatefulWidget with its own 1-second ticker.
// Only this widget re-renders every second — nothing else does.
// Receives deadline from parent; when heartbeat fires, parent calls
// _refresh() which pushes a new deadline down via didUpdateWidget.

class _CountdownCard extends StatefulWidget {
  const _CountdownCard();

  @override
  State<_CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<_CountdownCard> {
  Timer? _ticker;
  DateTime? deadline = DeadManSwitchService.deadline;
  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          deadline = DeadManSwitchService.deadline;
          debugPrint('Countdown tick: deadline is now $deadline');
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration? get _remaining {
    if (deadline == null) return null;
    final r = deadline!.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  bool _isUrgent(Duration? remaining) {
    if (remaining == null) return false;
    return remaining.inSeconds < 3 * 86400 || remaining.inMinutes < 1;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remaining;
    final color = _isUrgent(remaining) ? Colors.red : Colors.green;

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
                  remaining == null ? '—' : _formatRemaining(remaining),
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            if (deadline != null) ...[
              const SizedBox(height: 4),
              Text(
                'Triggers: ${_formatDeadline(deadline!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRemaining(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    if (d.inMinutes < 60) {
      final mins = d.inMinutes;
      final secs = d.inSeconds % 60;
      return '${mins}m ${secs}s';
    }
    if (d.inHours < 24) {
      final hrs = d.inHours;
      final mins = d.inMinutes % 60;
      return '${hrs}h ${mins}m';
    }
    final days = d.inDays;
    final hrs = d.inHours % 24;
    return '$days days, ${hrs}h';
  }

  String _formatDeadline(DateTime dt) {
    if (kDmsTestMode) {
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}:'
          '${dt.second.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
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
  final List<DmsTimeout> options;
  final ValueChanged<int> onChanged;

  const _TimeoutPicker({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt.seconds == selected;
        return ChoiceChip(
          label: Text(
            opt.label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(opt.seconds),
          selectedColor: appBackgroundblue,
          backgroundColor: Theme.of(context).cardColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color:
                  isSelected ? appBackgroundblue : Colors.grey.withOpacity(0.3),
            ),
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

  const _Counter({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

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
