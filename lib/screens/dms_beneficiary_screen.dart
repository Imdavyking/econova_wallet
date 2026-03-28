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

// ── Beneficiary screen ────────────────────────────────────────────────────────
/// Opened by the beneficiary on their device.
/// Uses [EthereumCoin] to derive the private key — only ETH wallets are
/// supported because the shares are ECIES-encrypted to a secp256k1 key.
class DmsBeneficiaryScreen extends StatefulWidget {
  /// Pass the EthereumCoin instance for the wallet that was set as beneficiary.
  final EthereumCoin coin;

  const DmsBeneficiaryScreen({super.key, required this.coin});

  @override
  State<DmsBeneficiaryScreen> createState() => _DmsBeneficiaryScreenState();
}

class _DmsBeneficiaryScreenState extends State<DmsBeneficiaryScreen> {
  // ── State machine ─────────────────────────────────────────────────────────
  _BeneficiaryStep _step = _BeneficiaryStep.idle;
  String? _error;

  // ── Fetched data ──────────────────────────────────────────────────────────
  List<EncryptedShare>? _shares;
  int? _threshold;
  String? _decryptedMnemonic;

  // ── Derived from coin ─────────────────────────────────────────────────────
  String? _pubKeyHex;
  String? _privKeyHex;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  // ── Load keys from coin ───────────────────────────────────────────────────

  Future<void> _loadKeys() async {
    try {
      if (!WalletService.isPharseKey() && !WalletService.isPrivateKey()) {
        setState(() => _error = 'Unsupported wallet type');
        return;
      }
      final data = WalletService.getActiveKey(walletImportType)!.data;
      final AccountData accountData;
      if (WalletService.isPharseKey()) {
        accountData = await widget.coin.fromMnemonic(mnemonic: data);
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

  // ── Fetch shares from relay ───────────────────────────────────────────────

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
      final shares = await DeadManSwitchService.fetchSharesFromRelay(
        beneficiaryPublicKeyHex: _pubKeyHex!,
      );

      if (!mounted) return;

      if (shares == null || shares.isEmpty) {
        setState(() {
          _step = _BeneficiaryStep.idle;
          _error =
              'No shares found. The sender may not have armed the switch yet.';
        });
        return;
      }

      setState(() {
        _shares = shares;
        _threshold = shares.length; // relay sends all shares; use all
        _step = _BeneficiaryStep.sharesReceived;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _step = _BeneficiaryStep.idle;
        _error = 'Fetch failed: $e';
      });
    }
  }

  // ── Decrypt shares ────────────────────────────────────────────────────────

  Future<void> _decrypt() async {
    if (_shares == null || _privKeyHex == null) return;

    final round = _shares!.first.drandRound;

    // Check if drand round has passed
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
        encryptedShares: _shares!,
        beneficiaryPrivateKeyHex: _privKeyHex!,
        threshold: _threshold!,
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
      if (!mounted) return;
      setState(() {
        _step = _BeneficiaryStep.sharesReceived;
        _error = 'Decryption failed: $e';
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMS — Beneficiary'),
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
              // ── Wallet info card ───────────────────────────────────────────
              _WalletInfoCard(coin: widget.coin, pubKeyHex: _pubKeyHex),
              const SizedBox(height: 20),

              // ── Error banner ───────────────────────────────────────────────
              if (_error != null) ...[
                _Banner(
                  color: Colors.red,
                  icon: Icons.error_outline,
                  text: _error!,
                ),
                const SizedBox(height: 16),
              ],

              // ── Body by step ───────────────────────────────────────────────
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
              'as the beneficiary, their encrypted shares are waiting for you. '
              'Tap below to check and retrieve them.',
        ),
        const SizedBox(height: 24),
        if (!isReady)
          const Center(child: CircularProgressIndicator())
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fetchShares,
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Check for shares'),
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
            Text('Connecting to relay & fetching shares…',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ── Shares received ───────────────────────────────────────────────────────

  Widget _buildSharesReceived() {
    final shares = _shares!;
    final round = shares.first.drandRound;
    final unlockTime = DrandService.timeForRound(round).toLocal();
    final isUnlocked = DrandService.isRoundPast(round);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Status banner ──────────────────────────────────────────────────
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

        // ── Share tiles ────────────────────────────────────────────────────
        ...shares.asMap().entries.map(
              (e) => _ShareTile(
                index: e.key,
                share: e.value,
                isUnlocked: isUnlocked,
              ),
            ),
        const SizedBox(height: 20),

        // ── Decrypt button ─────────────────────────────────────────────────
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

        // ── Re-fetch button ────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _fetchShares,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Re-fetch shares'),
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

        // ── Word grid ──────────────────────────────────────────────────────
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
                    const Text(
                      'Seed Phrase',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                  itemBuilder: (_, i) => _WordTile(
                    index: i + 1,
                    word: words[i],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Warning ────────────────────────────────────────────────────────
        const _Banner(
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
          text: '⚠️ Never share this seed phrase with anyone. '
              'Anyone with these words has full access to the wallet.',
        ),
        const SizedBox(height: 20),

        // ── Done button ────────────────────────────────────────────────────
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

enum _BeneficiaryStep { idle, fetching, sharesReceived, decrypting, decrypted }

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
