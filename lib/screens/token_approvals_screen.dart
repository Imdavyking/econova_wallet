import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_app/interface/coin.dart';
import 'package:wallet_app/model/token_approvals.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
//
// Works for any coin that overrides getApprovals() and revokeApproval()
// in the Coin base class — EthereumCoin, SolanaCoin, TronCoin etc.
//
// Usage:
//   Navigator.push(context, MaterialPageRoute(
//     builder: (_) => TokenApprovalsScreen(coin: coin),
//   ));

class TokenApprovalsScreen extends StatefulWidget {
  final Coin coin;

  const TokenApprovalsScreen({super.key, required this.coin});

  @override
  State<TokenApprovalsScreen> createState() => _TokenApprovalsScreenState();
}

class _TokenApprovalsScreenState extends State<TokenApprovalsScreen> {
  late Future<List<TokenApproval>> _approvalsFuture;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _approvalsFuture = _fetchApprovals();
  }

  Future<List<TokenApproval>> _fetchApprovals() async {
    _address = await widget.coin.getAddress();
    final future = widget.coin.getApprovals(_address);

    if (future == null) return []; // coin doesn't support approvals
    return future;
  }

  Future<void> _revoke(TokenApproval approval) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke approval'),
        content: Text(
          'Remove ${approval.spenderName}\'s access to your '
          '${approval.tokenSymbol}?\n\nThis will cost a small network fee.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revoke', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final result = await widget.coin.revokeApproval(approval);

      if (!mounted) return;

      if (result == null) {
        _showError('Revoke not supported for ${widget.coin.getSymbol()}');
        return;
      }

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Revoked ${approval.spenderName}\'s access '
              'to ${approval.tokenSymbol}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(_load);
      } else {
        _showError('Failed to revoke approval');
      }
    } catch (e) {
      _showError('Failed to revoke: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.coin.getSymbol()} Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_load),
          ),
        ],
      ),
      body: FutureBuilder<List<TokenApproval>>(
        future: _approvalsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return snapshot.hasError
                ? _ErrorView(error: snapshot.error.toString())
                : const _LoadingView();
          }

          final approvals = snapshot.data!;
          if (approvals.isEmpty) return const _EmptyView();

          final dangerous = approvals.where((a) => a.isDangerous).toList();
          final safe = approvals.where((a) => !a.isDangerous).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DisclaimerBanner(),
              const SizedBox(height: 16),
              if (dangerous.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Unlimited approvals',
                  subtitle: '${dangerous.length} — high risk',
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                ...dangerous.map((a) => _ApprovalCard(
                      approval: a,
                      onRevoke: () => _revoke(a),
                    )),
                const SizedBox(height: 20),
              ],
              if (safe.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Limited approvals',
                  subtitle: '${safe.length} — fixed amount',
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                ...safe.map((a) => _ApprovalCard(
                      approval: a,
                      onRevoke: () => _revoke(a),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Approval card ─────────────────────────────────────────────────────────────

class _ApprovalCard extends StatelessWidget {
  final TokenApproval approval;
  final VoidCallback onRevoke;

  const _ApprovalCard({required this.approval, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: approval.isDangerous
              ? Colors.red.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Token avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  approval.tokenSymbol
                      .substring(0, approval.tokenSymbol.length.clamp(0, 2)),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        approval.tokenSymbol,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      if (approval.isDangerous)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'UNLIMITED',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: approval.spenderAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      approval.spenderName,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ),
                  if (approval.lastUpdated != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(approval.lastUpdated!),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ],
              ),
            ),

            // Revoke
            TextButton(
              onPressed: onRevoke,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Revoke',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _DisclaimerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 16, color: Colors.orange.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unlimited approvals let DApps spend your tokens at any time. '
              'Revoke any you no longer use.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 8),
        Text(subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Fetching approvals...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined,
              size: 48, color: Colors.green.shade400),
          const SizedBox(height: 16),
          const Text('No active approvals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'You have not approved any DApps\nto spend your tokens.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text('Failed to load approvals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
