import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';

class DeadManSwitchScreen extends StatefulWidget {
  const DeadManSwitchScreen({super.key});

  @override
  State<DeadManSwitchScreen> createState() => _DeadManSwitchScreenState();
}

class _DeadManSwitchScreenState extends State<DeadManSwitchScreen> {
  DmsState _state = DmsState.inactive;
  DmsConfig? _config;
  List<String>? _shares;
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
      _shares = DeadManSwitchService.shares;
    });
  }

  // ── Activate ────────────────────────────────────────────────────────────────

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
      case DmsOk(:final shares):
        _refresh();
        if (shares != null) _showSharesDialog(shares);
      case DmsErr(:final message):
        _showSnack(message, isError: true);
    }
  }

  // ── Heartbeat ────────────────────────────────────────────────────────────────

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

  // ── Cancel ───────────────────────────────────────────────────────────────────

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

  // ── Reset ────────────────────────────────────────────────────────────────────

  Future<void> _reset() async {
    await DeadManSwitchService.reset();
    if (!mounted) return;
    _refresh();
  }

  // ── Show shares dialog ───────────────────────────────────────────────────────

  void _showSharesDialog(List<String> s) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SharesDialog(shares: s),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
      ));
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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
          child: CircularProgressIndicator(),
        ),
      );
    }

    return switch (_state) {
      DmsState.inactive => _DmsSetupForm(onActivate: _activate),
      DmsState.active => _DmsActiveView(
          config: _config!,
          shares: _shares,
          onHeartbeat: _heartbeat,
          onCancel: _cancel,
          onViewShares:
              _shares != null ? () => _showSharesDialog(_shares!) : null,
        ),
      DmsState.triggered => _DmsTriggeredView(
          shares: _shares,
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
          'Your switch is armed. Check in regularly to prevent trigger.'
        ),
      DmsState.triggered => (
          Colors.red,
          FontAwesomeIcons.triangleExclamation,
          'Triggered',
          'Inactivity deadline exceeded. Shares are now available.'
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
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
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
  int _timeoutDays = 30;
  int _threshold = 2;
  int _totalShares = 3;

  static const _timeoutOptions = [7, 14, 30, 90, 180, 365];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  bool get _valid =>
      _addressController.text.trim().isNotEmpty && _threshold <= _totalShares;

  void _submit() {
    if (!_valid) return;
    widget.onActivate(DmsConfig(
      beneficiaryAddress: _addressController.text.trim(),
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
        // ── Info banner ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: const Text(
            'Your seed phrase will be split using Shamir\'s Secret Sharing. '
            'If you stop checking in, your beneficiary can reconstruct it '
            'from the shares you distribute.',
            style: TextStyle(fontSize: 13, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 20),

        // ── Beneficiary address ──────────────────────────────────────────────
        const _FormLabel('Beneficiary Address'),
        const SizedBox(height: 6),
        TextField(
          controller: _addressController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '0x... or wallet address',
            prefixIcon: const Icon(Icons.account_circle_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
        const SizedBox(height: 20),

        // ── Threshold / total shares ─────────────────────────────────────────
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

        // ── Summary ──────────────────────────────────────────────────────────
        Text(
          'Any $_threshold of $_totalShares shares can reconstruct your seed phrase.',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // ── Activate button ──────────────────────────────────────────────────
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
}

// ── Active view ───────────────────────────────────────────────────────────────

class _DmsActiveView extends StatelessWidget {
  final DmsConfig config;
  final List<String>? shares;
  final VoidCallback onHeartbeat;
  final VoidCallback onCancel;
  final VoidCallback? onViewShares;

  const _DmsActiveView({
    required this.config,
    required this.shares,
    required this.onHeartbeat,
    required this.onCancel,
    this.onViewShares,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = DeadManSwitchService.timeRemaining;
    final last = DeadManSwitchService.lastActivity;
    final dl = DeadManSwitchService.deadline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Countdown card ───────────────────────────────────────────────────
        _CountdownCard(remaining: remaining, deadline: dl),
        const SizedBox(height: 16),

        // ── Info rows ────────────────────────────────────────────────────────
        _InfoCard(children: [
          _InfoRow(
            icon: Icons.account_circle_outlined,
            label: 'Beneficiary',
            value: config.beneficiaryAddress,
          ),
          _InfoRow(
            icon: Icons.schedule,
            label: 'Last activity',
            value: last != null ? _formatDateTime(last) : '—',
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
        ]),
        const SizedBox(height: 20),

        // ── Heartbeat button ─────────────────────────────────────────────────
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

        // ── View shares button ───────────────────────────────────────────────
        if (onViewShares != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewShares,
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: const Text('View shares'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        const SizedBox(height: 10),

        // ── Cancel button ────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(FontAwesomeIcons.heartCircleXmark,
                size: 16, color: Colors.red),
            label: const Text(
              'Cancel switch',
              style: TextStyle(color: Colors.red),
            ),
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Triggered view ────────────────────────────────────────────────────────────

class _DmsTriggeredView extends StatelessWidget {
  final List<String>? shares;
  final DmsConfig? config;

  const _DmsTriggeredView({this.shares, this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Text(
            'Inactivity deadline exceeded. The shares below can reconstruct '
            'the seed phrase. Any ${config?.threshold ?? '?'}-of-'
            '${config?.totalShares ?? '?'} shares are sufficient.',
            style: const TextStyle(fontSize: 13, color: Colors.red),
          ),
        ),
        const SizedBox(height: 16),
        if (shares != null)
          ...shares!.asMap().entries.map(
                (e) => _ShareTile(index: e.key, share: e.value),
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
  final List<String> shares;
  const _SharesDialog({required this.shares});

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
            const Text(
              'Distribute Shares',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Distribute each share to a separate trusted party. '
              'Never give all shares to the same person.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  children: shares
                      .asMap()
                      .entries
                      .map(
                        (e) => _ShareTile(index: e.key, share: e.value),
                      )
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

// ── Share tile ────────────────────────────────────────────────────────────────

class _ShareTile extends StatelessWidget {
  final int index;
  final String share;
  const _ShareTile({required this.index, required this.share});

  @override
  Widget build(BuildContext context) {
    // Show first/last 8 chars for readability
    final preview = share.length > 20
        ? '${share.substring(0, 8)}...${share.substring(share.length - 8)}'
        : share;

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
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share ${index + 1}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    preview,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy share',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: share));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share copied'),
                    duration: Duration(seconds: 1),
                  ),
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
            Text(
              'Time Remaining',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(FontAwesomeIcons.hourglassHalf, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  remaining == null ? '—' : '$days days, $hours hours',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
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

// ── Info card ─────────────────────────────────────────────────────────────────

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
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeout picker ────────────────────────────────────────────────────────────

class _TimeoutPicker extends StatelessWidget {
  final int selected;
  final List<int> options;
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

// ── Shares config ─────────────────────────────────────────────────────────────

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
                  value: total,
                  min: 2,
                  max: 10,
                  onChanged: onTotalChanged,
                ),
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
                  onChanged: onThresholdChanged,
                ),
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
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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

// ── Form label ────────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
    );
  }
}
