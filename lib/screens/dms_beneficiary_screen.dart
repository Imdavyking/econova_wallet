import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wallet_app/coins/ethereum_coin.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/service/dead_man_switch_service.dart';
import 'package:wallet_app/service/drand_service.dart';
import 'package:wallet_app/service/wallet_service.dart';
import 'package:wallet_app/main.dart';
import 'package:wallet_app/utils/auth_utils.dart';

class DmsBeneficiaryScreen extends StatefulWidget {
  final EthereumCoin coin;
  const DmsBeneficiaryScreen({super.key, required this.coin});

  @override
  State<DmsBeneficiaryScreen> createState() => _DmsBeneficiaryScreenState();
}

class _DmsBeneficiaryScreenState extends State<DmsBeneficiaryScreen> {
  _BeneficiaryStep _step = _BeneficiaryStep.idle;
  String? _error;

  // All sessions loaded from storage
  Map<String, DmsSessionData>? _sessions;

  // The session the user selected (or auto-selected)
  DmsSessionData? _selectedSession;

  String? _decryptedMnemonic;
  String? _pubKeyHex;
  String? _privKeyHex;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    try {
      if (!WalletService.isBip39PhraseOrSeedHexKey() &&
          !WalletService.isPrivateKey()) {
        setState(() => _error = 'Unsupported wallet type');
        return;
      }
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final AccountData accountData;
      if (WalletService.isBip39PhraseOrSeedHexKey()) {
        accountData =
            await widget.coin.fromBip39PhraseOrSeed(bip39PhraseOrSeedHex: data);
      } else {
        accountData = await widget.coin.fromPrivateKey(data);
      }
      setState(() {
        _pubKeyHex = accountData.publicKey;
        _privKeyHex = accountData.privateKey;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load wallet keys: $e');
    }
  }

  Future<void> _fetchShares() async {
    if (_pubKeyHex == null) return;

    final authed = await authenticate(context);
    if (!authed) {
      if (!context.mounted) return;
      _showSnack('Authentication failed', isError: true);
      return;
    }

    setState(() {
      _step = _BeneficiaryStep.fetching;
      _error = null;
    });

    try {
      final sessions = await DeadManSwitchService.fetchAllShares();

      if (!mounted) return;

      if (sessions == null || sessions.isEmpty) {
        setState(() {
          _step = _BeneficiaryStep.idle;
          _error = 'No shares found locally. Make sure the app has been '
              'opened while online so shares can be received in the '
              'background, then try again.';
        });
        return;
      }

      _sessions = sessions;

      // If we already had a session open, refresh it in-place with the
      // latest data (new drandRound after a heartbeat) instead of
      // dropping back to the session picker.
      if (_selectedSession != null) {
        final refreshed = sessions.values.firstWhere(
          (s) => s.senderAddress == _selectedSession!.senderAddress,
          orElse: () => sessions.values.first,
        );
        _selectSession(refreshed);
        return;
      }

      if (sessions.length == 1) {
        _selectSession(sessions.values.first);
      } else {
        setState(() => _step = _BeneficiaryStep.selectSession);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _BeneficiaryStep.idle;
        _error = 'Failed to load shares: $e';
      });
    }
  }

  void _selectSession(DmsSessionData session) {
    setState(() {
      _selectedSession = session;
      _step = _BeneficiaryStep.sharesReceived;
    });
  }

  Future<void> _decrypt() async {
    final session = _selectedSession;
    if (session == null || _privKeyHex == null) return;

    final round = session.shares.first.drandRound;

    if (!DrandService.isRoundPast(round)) {
      final unlockTime = DrandService.timeForRound(round).toLocal();
      _showSnack(
        'Shares are still time-locked until ${_formatDateTime(unlockTime)}',
        isError: true,
      );
      return;
    }

    setState(() {
      _step = _BeneficiaryStep.decrypting;
      _error = null;
    });

    try {
      final mnemonic = await DeadManSwitchService.decryptAndRecombine(
        encryptedShares: session.shares,
        beneficiaryPrivateKeyHex: _privKeyHex!,
        threshold: session.threshold,
      );

      if (!mounted) return;
      setState(() {
        _decryptedMnemonic = mnemonic;
        _step = _BeneficiaryStep.decrypted;
      });
    } on DrandNotYetAvailableException {
      if (!mounted) return;
      setState(() {
        _step = _BeneficiaryStep.sharesReceived;
        _error =
            'Shares are still time-locked — drand round has not fired yet.';
      });
    } catch (e) {
      // flutter: Decryption error: Instance of 'InvalidCipherTextException'
      debugPrint('Decryption error: $e');
      if (!mounted) return;
      setState(() {
        _step = _BeneficiaryStep.sharesReceived;
        _error = 'Decryption failed: $e';
      });
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
      ));
  }

  String _formatDateTime(DateTime dt) => '${dt.day}/${dt.month}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  String _shortId(String id) => id.length >= 16
      ? '${id.substring(0, 8)}…${id.substring(id.length - 8)}'
      : id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMS — Beneficiary'),
        leading: _step == _BeneficiaryStep.sharesReceived &&
                (_sessions?.length ?? 0) > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    setState(() => _step = _BeneficiaryStep.selectSession),
              )
            : null,
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
              _WalletInfoCard(coin: widget.coin, pubKeyHex: _pubKeyHex),
              const SizedBox(height: 20),
              if (_error != null) ...[
                _Banner(
                  color: Colors.red,
                  icon: Icons.error_outline,
                  text: _error!,
                ),
                const SizedBox(height: 16),
              ],
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_step) {
      _BeneficiaryStep.idle => _buildIdle(),
      _BeneficiaryStep.fetching => _buildFetching(),
      _BeneficiaryStep.selectSession => _buildSelectSession(),
      _BeneficiaryStep.sharesReceived => _buildSharesReceived(),
      _BeneficiaryStep.decrypting => _buildDecrypting(),
      _BeneficiaryStep.decrypted => _buildDecrypted(),
    };
  }

  // ── Idle ──────────────────────────────────────────────────────────────────

  Widget _buildIdle() {
    final isReady = _pubKeyHex != null && _privKeyHex != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Banner(
          color: Colors.blue,
          icon: Icons.info_outline,
          text: 'If someone has armed a Dead Man\'s Switch with your wallet '
              'as the beneficiary, their encrypted shares are stored locally '
              'on this device. Tap below to load them.',
        ),
        const SizedBox(height: 24),
        if (!isReady)
          const Center(child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fetchShares,
              icon: const Icon(Icons.folder_open_outlined, size: 18),
              label: const Text('Load shares'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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

  // ── Fetching ──────────────────────────────────────────────────────────────

  Widget _buildFetching() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading shares from local storage…',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ── Session picker ────────────────────────────────────────────────────────

  Widget _buildSelectSession() {
    final sessions = _sessions!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Banner(
          color: Colors.blue,
          icon: Icons.layers_outlined,
          text: '${sessions.length} senders found. '
              'Select a session to decrypt.',
        ),
        const SizedBox(height: 16),
        ...sessions.values.map((session) {
          final round = session.shares.isNotEmpty
              ? session.shares.first.drandRound
              : null;
          final isUnlocked = round != null && DrandService.isRoundPast(round);
          final unlockTime =
              round != null ? DrandService.timeForRound(round).toLocal() : null;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (isUnlocked) {
                  _selectSession(session);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isUnlocked ? Colors.green : Colors.orange)
                            .withOpacity(0.15),
                      ),
                      child: Icon(
                        isUnlocked ? Icons.lock_open : Icons.lock_outline,
                        color: isUnlocked ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _shortId(session.sessionId),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${session.shares.length} share${session.shares.length == 1 ? '' : 's'}'
                            '  •  threshold ${session.threshold}'
                            '${round != null ? '  •  drand #$round' : ''}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _shortId(session.pubKeyHex),
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontFamily: 'monospace'),
                          ),
                          if (unlockTime != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              isUnlocked
                                  ? '✓ Unlocked'
                                  : 'Unlocks ${_formatDateTime(unlockTime)}',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isUnlocked ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _fetchShares,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reload from storage'),
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

  // ── Shares received ───────────────────────────────────────────────────────

  Widget _buildSharesReceived() {
    final session = _selectedSession!;
    final shares = session.shares;
    final round = shares.first.drandRound;
    final unlockTime = DrandService.timeForRound(round).toLocal();
    final isUnlocked = DrandService.isRoundPast(round);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session metadata strip
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              _MetaRow(
                icon: Icons.tag,
                label: 'Session',
                value: _shortId(session.sessionId),
              ),
              const SizedBox(height: 4),
              _MetaRow(
                icon: Icons.vpn_key_outlined,
                label: 'Sender pubkey',
                value: _shortId(session.pubKeyHex),
              ),
              const SizedBox(height: 4),
              _MetaRow(
                icon: Icons.shield_outlined,
                label: 'Threshold',
                value: '${session.threshold} of ${shares.length}',
              ),
            ],
          ),
        ),

        _Banner(
          color: isUnlocked ? Colors.green : Colors.orange,
          icon: isUnlocked ? Icons.lock_open : Icons.lock_outline,
          text: isUnlocked
              ? '✓ Shares are unlocked — drand round #$round has fired.\n'
                  'You can now decrypt and recover the seed phrase.'
              : '⏳ Shares are time-locked until ${_formatDateTime(unlockTime)}.\n'
                  'Come back after the deadline to decrypt.',
        ),
        const SizedBox(height: 16),
        ...shares.asMap().entries.map(
              (e) => _ShareTile(
                index: e.key,
                share: e.value,
                isUnlocked: isUnlocked,
              ),
            ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isUnlocked ? _decrypt : null,
            icon: const Icon(FontAwesomeIcons.unlockKeyhole, size: 16),
            label: const Text('Decrypt & Recover Seed Phrase'),
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _fetchShares,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reload from storage'),
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

  // ── Decrypting ────────────────────────────────────────────────────────────

  Widget _buildDecrypting() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching drand randomness & decrypting…',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ── Decrypted ─────────────────────────────────────────────────────────────

  Widget _buildDecrypted() {
    final words = _decryptedMnemonic!.trim().split(RegExp(r'\s+'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Banner(
          color: Colors.green,
          icon: Icons.check_circle_outline,
          text: '✓ Seed phrase successfully recovered! '
              'Write it down and store it securely.',
        ),
        const SizedBox(height: 20),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seed Phrase',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy all words',
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _decryptedMnemonic!));
                        _showSnack('Seed phrase copied');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: words.length,
                  itemBuilder: (_, i) =>
                      _WordTile(index: i + 1, word: words[i]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _Banner(
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
          text: '⚠️ Never share this seed phrase with anyone. '
              'Anyone with these words has full access to the wallet.',
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

// ── Step enum ─────────────────────────────────────────────────────────────────

enum _BeneficiaryStep {
  idle,
  fetching,
  selectSession,
  sharesReceived,
  decrypting,
  decrypted,
}

// ── Wallet info card ──────────────────────────────────────────────────────────

class _WalletInfoCard extends StatelessWidget {
  final EthereumCoin coin;
  final String? pubKeyHex;

  const _WalletInfoCard({required this.coin, this.pubKeyHex});

  @override
  Widget build(BuildContext context) {
    final roomId = pubKeyHex != null
        ? DeadManSwitchService.roomIdFromPubKey(pubKeyHex!)
        : null;
    final shortRoom = roomId != null
        ? '${roomId.substring(0, 8)}…${roomId.substring(roomId.length - 8)}'
        : '…';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.15),
                  ),
                  child: ClipOval(
                    child: Image.asset(coin.getImage(), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coin.getName(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(coin.getSymbol(),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Text('Beneficiary',
                      style: TextStyle(fontSize: 11, color: Colors.blue)),
                ),
              ],
            ),
            if (pubKeyHex != null) ...[
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.vpn_key_outlined,
                label: 'Public Key',
                value:
                    '${pubKeyHex!.substring(0, 8)}…${pubKeyHex!.substring(pubKeyHex!.length - 6)}',
              ),
              _InfoRow(
                icon: Icons.meeting_room_outlined,
                label: 'Room ID',
                value: shortRoom,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Share tile ────────────────────────────────────────────────────────────────

class _ShareTile extends StatelessWidget {
  final int index;
  final EncryptedShare share;
  final bool isUnlocked;

  const _ShareTile({
    required this.index,
    required this.share,
    required this.isUnlocked,
  });

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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? Colors.green : Colors.orange,
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? Icons.lock_open : Icons.lock_outline,
                  color: Colors.white,
                  size: 16,
                ),
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
                      style: TextStyle(
                          fontSize: 10,
                          color: isUnlocked ? Colors.green : Colors.orange)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy ciphertext',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: share.ciphertext));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Share ciphertext copied'),
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

// ── Word tile ─────────────────────────────────────────────────────────────────

class _WordTile extends StatelessWidget {
  final int index;
  final String word;

  const _WordTile({required this.index, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Text(
            '$index.',
            style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              word,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner ────────────────────────────────────────────────────────────────────

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ── Meta row (compact, used in shares received header) ────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
