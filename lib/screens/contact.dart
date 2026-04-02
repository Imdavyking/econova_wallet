import 'package:wallet_app/screens/add_contact.dart';
import 'package:wallet_app/screens/select_blockchain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../interface/coin.dart';
import '../service/contact_service.dart';
import '../utils/app_config.dart';
import '../utils/rpc_urls.dart';

class Contact extends StatefulWidget {
  final bool showAdd;

  /// When set, only contacts whose [ContactParams.caip2ChainId] matches
  /// [filterCoin.caip2ChainId] are shown.
  final Coin? filterCoin;

  const Contact({
    super.key,
    this.showAdd = true,
    this.filterCoin,
  });

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  late final ValueNotifier<List<ContactParams>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = ValueNotifier(_filteredContacts());
  }

  List<ContactParams> _filteredContacts() {
    final all = ContactService.getContacts();
    final filterCoin = widget.filterCoin;
    if (filterCoin == null) return all;
    return all.where((c) => c.matchesCoin(filterCoin)).toList();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _addContact() async {
    final coin = await Navigator.push<Coin>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SelectBlockchain(filterFn: (coin) => coin.tokenAddress() == null),
      ),
    );
    if (coin == null || !mounted) return;

    final updated = await Navigator.push<List<ContactParams>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddContact(
          params: ContactParams.create(
            coin: coin,
            name: '',
            address: '',
          ),
        ),
      ),
    );

    if (updated != null) _contacts.value = _filteredContacts();
  }

  Future<void> _editContact(ContactParams params) async {
    final updated = await Navigator.push<List<ContactParams>>(
      context,
      MaterialPageRoute(builder: (_) => AddContact(params: params)),
    );
    if (updated != null) _contacts.value = _filteredContacts();
  }

  Future<bool> _deleteContact(ContactParams contact) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (!await authenticate(context)) return false;

    await ContactService.deleteContact(contact.id);
    _contacts.value = _filteredContacts();
    return true;
  }

  @override
  void dispose() {
    _contacts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isFiltered = widget.filterCoin != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFiltered
              ? '${localization.contact} · ${widget.filterCoin!.getName().split('(')[0].trim()}'
              : localization.contact,
        ),
        actions: [
          if (widget.showAdd)
            IconButton(
              icon: const Icon(FontAwesomeIcons.plus),
              onPressed: _addContact,
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _contacts.value = _filteredContacts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: ValueListenableBuilder<List<ContactParams>>(
                valueListenable: _contacts,
                builder: (_, contacts, __) {
                  if (contacts.isEmpty) {
                    return _EmptyState(
                      onAdd: widget.showAdd ? _addContact : null,
                      filterCoin: widget.filterCoin,
                    );
                  }
                  return Column(
                    children: [
                      for (final contact in contacts) ...[
                        _ContactTile(
                          contact: contact,
                          onTap: () {
                            if (widget.showAdd) {
                              _editContact(contact);
                            } else {
                              Navigator.pop(context, contact);
                            }
                          },
                          onDelete: () => _deleteContact(contact),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  final Coin? filterCoin;

  const _EmptyState({this.onAdd, this.filterCoin});

  @override
  Widget build(BuildContext context) {
    final label = filterCoin != null
        ? 'No ${filterCoin!.getName().split('(')[0].trim()} contacts yet'
        : 'No contacts yet';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.contact_page_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(FontAwesomeIcons.plus, size: 14),
              label: const Text('Add Contact'),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Contact tile ──────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final ContactParams contact;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;

  const _ContactTile({
    required this.contact,
    required this.onTap,
    required this.onDelete,
  });

  // Kept — still needed for the badge
  String? _chainImage() {
    try {
      return supportedChains
          .firstWhere((c) =>
              c.caip2ChainId == contact.caip2ChainId &&
              c.tokenAddress() == null)
          .getImage();
    } catch (_) {
      return null;
    }
  }

  // ADD — resolves the coin for getIdenticon()
  Coin? _resolveCoin() {
    try {
      return supportedChains.firstWhere(
        (c) =>
            c.caip2ChainId == contact.caip2ChainId && c.tokenAddress() == null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chainImage = _chainImage();
    final coin = _resolveCoin(); // ADD

    return Dismissible(
      key: ValueKey(contact.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onDelete(),
      background: const _SwipeBackground(
        color: Colors.blue,
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: const _SwipeBackground(
        color: Colors.red,
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      onDismissed: (_) {},
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  // REPLACE the trailing chain logo Row with this leading avatar
                  _ContactAvatar(
                    contact: contact,
                    coin: coin,
                    chainImage: chainImage,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ellipsify(str: contact.name, maxLength: 20),
                          style: const TextStyle(fontSize: 16),
                        ),
                        // ADD — show truncated address below name
                        Text(
                          ellipsify(str: contact.address),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (contact.memo != null && contact.memo!.isNotEmpty)
                          Text(
                            'Tag: ${contact.memo}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ADD — new widget at the bottom of the file
class _ContactAvatar extends StatelessWidget {
  final ContactParams contact;
  final Coin? coin;
  final String? chainImage;

  const _ContactAvatar({
    required this.contact,
    required this.coin,
    this.chainImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        coin != null
            ? coin!.getIdenticon(contact.address, size: 36)
            : const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, size: 18),
              ),
        if (chainImage != null)
          Positioned(
            bottom: -2,
            right: -2,
            child: CircleAvatar(
              radius: 8,
              backgroundImage: AssetImage(chainImage!),
            ),
          ),
      ],
    );
  }
}
// ── Swipe background ──────────────────────────────────────────────────────────

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
