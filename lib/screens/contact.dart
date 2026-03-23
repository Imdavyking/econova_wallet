import 'package:wallet_app/screens/add_contact.dart';
import 'package:wallet_app/screens/select_blockchain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../interface/coin.dart';
import '../service/contact_service.dart';
import '../utils/rpc_urls.dart';

class Contact extends StatefulWidget {
  final bool showAdd;
  const Contact({super.key, this.showAdd = true});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final ValueNotifier<List<ContactParams>> _contacts =
      ValueNotifier(ContactService.getContacts());

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

    if (updated != null) _contacts.value = updated;
  }

  Future<void> _editContact(ContactParams params) async {
    final updated = await Navigator.push<List<ContactParams>>(
      context,
      MaterialPageRoute(builder: (_) => AddContact(params: params)),
    );
    if (updated != null) _contacts.value = updated;
  }

  Future<bool> _deleteContact(ContactParams contact) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (!await authenticate(context)) return false;

    final updated = await ContactService.deleteContact(contact.id);
    _contacts.value = updated;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.contact),
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
            _contacts.value = ContactService.getContacts();
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
  const _EmptyState({this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.contact_page_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No contacts yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ellipsify(str: contact.name, maxLength: 20),
                          style: const TextStyle(fontSize: 16),
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(contact.coin.getImage()),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
