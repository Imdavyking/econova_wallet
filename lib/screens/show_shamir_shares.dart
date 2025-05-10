import 'package:cryptowallet/ntcdcrypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../utils/app_config.dart';

class ShowShamirShares extends StatefulWidget {
  final String data;

  const ShowShamirShares({Key? key, required this.data}) : super(key: key);

  @override
  State<ShowShamirShares> createState() => _ShowShamirSharesState();
}

class _ShowShamirSharesState extends State<ShowShamirShares> {
  final ValueNotifier<List<String>> sharesList = ValueNotifier([]);

  final TextEditingController _thrsContrl = TextEditingController();

  final TextEditingController _shsContrl = TextEditingController();

  ValueNotifier<bool> isBase64 = ValueNotifier(true);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int maxShares = 8;
  int minShares = 2;

  void _createShares() {
    final int minimum = int.parse(_thrsContrl.text.trim());
    final int shares = int.parse(_shsContrl.text.trim());
    sharesList.value =
        SSS().create(minimum, shares, widget.data, isBase64.value);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.exportAsShamirShares,
        ),
      ),
      body: SizedBox(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: sharesList,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          validator: (v) {
                            final error = localization.enterValidthresholdCount;
                            if (v == null || v.trim().isEmpty) {
                              return error;
                            }
                            int? thresholdCount = int.tryParse(v);
                            if (thresholdCount == null) return error;
                            int? sharesCount =
                                int.tryParse(_shsContrl.text.trim());
                            final shareserror =
                                localization.enterValidsharesCount;
                            if (sharesCount == null) return shareserror;
                            if (thresholdCount > sharesCount) return error;
                            if (thresholdCount <= 0) return error;
                            return null;
                          },
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: _thrsContrl,
                          decoration: InputDecoration(
                            hintText: localization.thresholdCount,
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none), // you
                            filled: true,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (v) {
                            final error = localization.enterValidsharesCount;
                            final maxError = localization.maxSharesError;
                            final minError = localization.minSharesError;
                            if (v == null || v.trim().isEmpty) {
                              return error;
                            }
                            int? shares = int.tryParse(v);
                            if (shares == null) return error;
                            if (shares > maxShares) return maxError;
                            if (shares < minShares) return minError;

                            return null;
                          },
                          controller: _shsContrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: localization.sharesCount,
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide.none), // you
                            filled: true,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ValueListenableBuilder<bool>(
                          valueListenable: isBase64,
                          builder: (context, value, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  localization.isBase64,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Transform.scale(
                                  scale: 1,
                                  child: CupertinoSwitch(
                                    value: isBase64.value,
                                    activeColor: appBackgroundblue,
                                    onChanged: (bool enable) async {
                                      isBase64.value = !isBase64.value;
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => appBackgroundblue,
                              ),
                              shape: WidgetStateProperty.resolveWith(
                                (states) => RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _createShares();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                localization.confirm,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        for (String share in sharesList.value) ...[
                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController()..text = share,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: localization.sharesCount,
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide.none),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide.none),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide.none), // you
                              filled: true,

                              suffixIcon: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final snack =
                                          ScaffoldMessenger.of(context);

                                      snack.clearSnackBars();
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text: share,
                                        ),
                                      );

                                      snack.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            localization.copiedToClipboard,
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.copy),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                        const SizedBox(
                          height: 20,
                        ),
                        if (sharesList.value.isNotEmpty)
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: Colors.red[100],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      localization.recoverWithNofYShares(
                                        _thrsContrl.text,
                                        _shsContrl.text,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      localization.neverShareYourShamirSecrets,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
