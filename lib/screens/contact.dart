import 'package:wallet_app/screens/add_contact.dart';
import 'package:wallet_app/screens/select_blockchain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../interface/coin.dart';
import '../service/contact_service.dart';
import '../utils/rpc_urls.dart';

class Contact extends StatefulWidget {
  final bool? showAdd;

  const Contact({
    super.key,
    this.showAdd,
  });

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  late List languages;
  late String languageCode;
  ValueNotifier<List<ContactParams>> contacts =
      ValueNotifier<List<ContactParams>>([]);
  late AppLocalizations localization;
  @override
  void initState() {
    super.initState();
    contacts.value = ContactService.getContacts();
  }

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.contact,
        ),
        actions: [
          if (widget.showAdd ?? true)
            IconButton(
                onPressed: () async {
                  Coin? coin = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const SelectBlockchain(),
                    ),
                  );

                  if (coin == null) return;
                  if (context.mounted) {
                    List<ContactParams>? updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => AddContact(
                          params: ContactParams(coin: coin),
                        ),
                      ),
                    );

                    if (updatedData == null) return;

                    contacts.value = updatedData;
                  }
                },
                icon: const Icon(FontAwesomeIcons.plus)),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ValueListenableBuilder(
                valueListenable: contacts,
                builder: (context, List<ContactParams> _, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contacts.value.isEmpty)
                        const Text(
                          'No Contact Yet',
                          style: TextStyle(fontSize: 18),
                        )
                      else
                        for (ContactParams params in contacts.value) ...[
                          Dismissible(
                            secondaryBackground: Container(
                              color: Colors.red,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            background: Container(
                              color: Colors.blue,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.centerLeft,
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onDismissed: (DismissDirection direction) {},
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (DismissDirection direction) async {
                              if (direction.name == 'endToStart') {
                                return await _deleteContact(params);
                              }
                              return false;
                            },
                            child: GestureDetector(
                              onTap: () async {
                                if (widget.showAdd ?? true) {
                                  List<ContactParams>? updatedData =
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => AddContact(
                                        params: params,
                                      ),
                                    ),
                                  );
                                  if (updatedData == null) return;

                                  contacts.value = updatedData;
                                } else {
                                  Navigator.pop(context, params);
                                }
                              },
                              child: Card(
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  width: double.infinity,
                                  height: 60,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ellipsify(
                                          str: params.name!,
                                          maxLength: 20,
                                        ),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage: AssetImage(
                                              params.coin.getImage(),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.grey,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ]
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

  Future<bool> _deleteContact(ContactParams contact) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (await authenticate(context)) {
      await ContactService.deleteData(contact);

      contacts.value = [...contacts.value]
        ..removeWhere((element) => element == contact);

      return true;
    } else {
      return false;
    }
  }
}
