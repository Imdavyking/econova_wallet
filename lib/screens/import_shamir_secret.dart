import 'package:wallet_app/ntcdcrypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pinput/pinput.dart';
import '../utils/app_config.dart';

import '../utils/qr_scan_view.dart';

class ImportShamirSecret extends StatefulWidget {
  const ImportShamirSecret({Key? key}) : super(key: key);

  @override
  State createState() => _ImportShamirSecretState();
}

class _ImportShamirSecretState extends State {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _sssShares = [''];

  late AppLocalizations localization;

  ValueNotifier<bool> isBase64 = ValueNotifier(true);
  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Import Shamir Secrets')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _sssShares.length,
                  itemBuilder: (context, index) => Row(
                    children: [
                      Expanded(
                        child: ImportShamirTextField(
                          key: UniqueKey(),
                          initialValue: _sssShares[index],
                          onChanged: (v) => _sssShares[index] = v,
                        ),
                      ),
                      const SizedBox(width: 20),
                      _textfieldBtn(index),
                    ],
                  ),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 20,
                  ),
                ),
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
                height: 10,
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
                      try {
                        final mnemonics =
                            SSS().combine(_sssShares, isBase64.value);

                        Navigator.pop(context, mnemonics);
                      } catch (e) {
                        debugPrint(e.toString());
                        final snack = ScaffoldMessenger.of(context);
                        snack.showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            dismissDirection: DismissDirection.up,
                            content: Text(
                              e.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
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
            ],
          ),
        ),
      ),
    );
  }

  /// last textfield will have an add button, tapping which will add a new textfield below
  /// and all other textfields will have a remove button, tapping which will remove the textfield at the index
  Widget _textfieldBtn(int index) {
    bool isLast = index == _sssShares.length - 1;

    return InkWell(
      onTap: () => setState(
        () => isLast ? _sssShares.add('') : _sssShares.removeAt(index),
      ),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isLast ? Colors.green : Colors.red,
        ),
        child: Icon(
          isLast ? Icons.add : Icons.remove,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ImportShamirTextField extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onChanged;

  const ImportShamirTextField({
    Key? key,
    this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State createState() => _ImportShamirTextFieldState();
}

class _ImportShamirTextFieldState extends State<ImportShamirTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    localization = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        filled: true,
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide.none),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide.none),
        enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide.none), // you
        hintText: "Enter your secret share",
        suffixIcon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.qr_code_scanner,
              ),
              onPressed: () async {
                String? share = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const QRScanView(),
                  ),
                );
                if (share == null) return;
                _controller.setText(share);
                widget.onChanged(share);
              },
            ),
            InkWell(
              onTap: () async {
                ClipboardData? cdata =
                    await Clipboard.getData(Clipboard.kTextPlain);
                if (cdata == null) return;
                if (cdata.text == null) return;
                _controller.setText(cdata.text!);
                widget.onChanged(cdata.text!);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  localization.paste,
                ),
              ),
            ),
          ],
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter something';
        return null;
      },
    );
  }
}
