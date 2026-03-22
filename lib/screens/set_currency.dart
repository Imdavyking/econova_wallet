// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:wallet_app/utils/app_config.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../main.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _CurrencyEntry {
  final String code;
  final String name;

  const _CurrencyEntry({required this.code, required this.name});

  String get flagAsset => 'assets/currency_flags/${code.toLowerCase()}.png';
}

// ── Screen data ───────────────────────────────────────────────────────────────

class _ScreenData {
  final List<_CurrencyEntry> currencies;
  final String selectedCode;

  const _ScreenData({
    required this.currencies,
    required this.selectedCode,
  });
}

// ── Root widget ───────────────────────────────────────────────────────────────

class SetCurrency extends StatefulWidget {
  const SetCurrency({super.key});

  @override
  _SetCurrencyState createState() => _SetCurrencyState();
}

class _SetCurrencyState extends State<SetCurrency> {
  final _searchController = TextEditingController();
  late final Future<_ScreenData> _dataFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    _searchController.addListener(
      () =>
          setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_ScreenData> _loadData() async {
    if (kDebugMode) print('loading currencies');

    final selectedCode = (pref.get(defaultCurrencyKey) ?? 'USD') as String;
    final raw = jsonDecode(await getCurrencyJson()) as Map;

    final currencies = raw.entries
        .map((e) =>
            _CurrencyEntry(code: e.key as String, name: e.value as String))
        .toList();

    return _ScreenData(currencies: currencies, selectedCode: selectedCode);
  }

  List<_CurrencyEntry> _filtered(List<_CurrencyEntry> all) {
    if (_query.isEmpty) return all;
    return all
        .where((c) =>
            c.code.toLowerCase().contains(_query) ||
            c.name.toLowerCase().contains(_query))
        .toList();
  }

  Future<void> _onSelect(_CurrencyEntry entry) async {
    try {
      List<dynamic> supported;

      final cached = pref.get(supportedCurrencyKey) as String?;
      if (cached != null) {
        supported = cached.split(',');
      } else {
        // fallback — only hits network if startup cache failed
        supported = jsonDecode(
          (await http.get(Uri.parse(coinGeckoSupportedCurrencies))).body,
        ) as List;
      }

      if (!mounted) return;

      if (supported.contains(entry.code.toLowerCase())) {
        await pref.put(defaultCurrencyKey, entry.code);
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        _showError('${entry.code} is not supported yet');
      }
    } catch (_) {
      _showError('Could not change currency, please try again later.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Colors.white)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localization.selectCurrency)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _CurrencySearchBar(controller: _searchController),
            ),
            Expanded(
              child: FutureBuilder<_ScreenData>(
                future: _dataFuture,
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return snapshot.hasError
                        ? const _ErrorView()
                        : const _LoadingView();
                  }

                  final data = snapshot.data!;
                  final filtered = _filtered(data.currencies);

                  final selected = data.currencies
                      .where((c) => c.code == data.selectedCode)
                      .firstOrNull;

                  final showSelected = selected != null && _query.isEmpty;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // ── Pinned selected currency ──
                      if (showSelected) ...[
                        const _ListLabel(text: 'SELECTED'),
                        _CurrencyTile(
                          entry: selected,
                          isSelected: true,
                          onTap: () => _onSelect(selected),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        const _ListLabel(text: 'ALL CURRENCIES'),
                      ],

                      // ── Filtered list ──
                      if (filtered.isEmpty)
                        _EmptySearch(query: _query)
                      else
                        ...filtered.map(
                          (c) => _CurrencyTile(
                            entry: c,
                            isSelected: c.code == data.selectedCode,
                            onTap: () => _onSelect(c),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _CurrencySearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _CurrencySearchBar({required this.controller});

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: 'Search currency...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, val, __) => val.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
              : const SizedBox.shrink(),
        ),
        filled: true,
        isDense: true,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// ── Currency tile ─────────────────────────────────────────────────────────────

class _CurrencyTile extends StatelessWidget {
  final _CurrencyEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: AssetImage(entry.flagAsset),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.code,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.name,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.check, size: 18, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _ListLabel extends StatelessWidget {
  final String text;
  const _ListLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Failed to load currencies.\nPlease try again.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No results for "$query"',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
