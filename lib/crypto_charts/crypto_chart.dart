// ignore_for_file: implementation_imports, library_prefixes

import 'dart:convert';
import 'dart:math';

import 'package:wallet_app/components/loader.dart';
import 'package:wallet_app/crypto_charts/chart_price.dart';
import 'package:wallet_app/utils/format_money.dart';
import 'package:wallet_app/utils/rpc_urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:charts_flutter/src/text_element.dart' as TextElement;
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../interface/coin.dart';
import '../main.dart';
import '../utils/app_config.dart';

// ── URL builder ───────────────────────────────────────────────────────────────

String _marketDataUrl({
  required int days,
  required String coinGeckoId,
  required String currency,
}) =>
    '$coinGeckoBaseurl/coins/$coinGeckoId/market_chart'
    '?vs_currency=$currency&days=$days';

// ── Day range config ──────────────────────────────────────────────────────────

class _DayRange {
  final String label;
  final int days;
  const _DayRange(this.label, this.days);
}

const _dayRanges = [
  _DayRange('1D', 1),
  _DayRange('1W', 7),
  _DayRange('1M', 30),
  _DayRange('1Y', 365),
];

// ── Root widget ───────────────────────────────────────────────────────────────

class CryptoChart extends StatefulWidget {
  final Coin coin;
  const CryptoChart({super.key, required this.coin});

  @override
  State<CryptoChart> createState() => _CryptoChartState();
}

class _CryptoChartState extends State<CryptoChart> {
  int _days = 1;
  final Map<int, String> _cache = {};

  // Separate notifiers so only the relevant widget rebuilds
  final ValueNotifier<String> _priceNotifier = ValueNotifier('');
  final ValueNotifier<String> _dateNotifier = ValueNotifier('');
  final ValueNotifier<_PeriodChange?> _changeNotifier = ValueNotifier(null);

  Future<_ChartResult>? _chartFuture;

  @override
  void initState() {
    super.initState();
    _chartFuture = _fetchChart(_days);
  }

  Future<_ChartResult> _fetchChart(int days) async {
    final defaultCurrency = pref.get(defaultCurrencyKey) as String? ?? 'usd';
    final currencyWithSymbol = jsonDecode(currencyJson) as Map;
    final symbol =
        currencyWithSymbol[defaultCurrency.toUpperCase()]['symbol'] as String;

    if (_cache[days] == null) {
      final res = await http
          .get(Uri.parse(_marketDataUrl(
            days: days,
            coinGeckoId: widget.coin.getGeckoId(),
            currency: defaultCurrency,
          )))
          .timeout(networkTimeOutDuration);

      if (res.statusCode ~/ 100 != 2) throw Exception('Request failed');
      _cache[days] = res.body;
    }

    final prices =
        (jsonDecode(_cache[days]!)['prices'] as List).cast<List<dynamic>>();

    if (prices.isEmpty) throw Exception('No data');

    double xMin = double.infinity,
        xMax = double.negativeInfinity,
        yMin = double.infinity,
        yMax = double.negativeInfinity;

    final points = prices.map((e) {
      final x = (e[0] as num).toDouble();
      final y = (e[1] as num).toDouble();
      if (x < xMin) xMin = x;
      if (x > xMax) xMax = x;
      if (y < yMin) yMin = y;
      if (y > yMax) yMax = y;
      return [x, y];
    }).toList();

    final firstPrice = points.first[1];
    final lastPrice = points.last[1];
    final change = lastPrice - firstPrice;
    final changePct = firstPrice > 0 ? (change / firstPrice) * 100 : 0.0;
    final isPositive = change >= 0;

    // Set initial display values
    _priceNotifier.value = '$symbol${formatMoney(lastPrice)}';
    _dateNotifier.value = '';
    _changeNotifier.value = _PeriodChange(
      amount:
          '${isPositive ? '+' : ''}$symbol${formatMoney(change.abs(), true)}',
      percent: '${isPositive ? '+' : ''}${formatMoney(changePct.abs(), true)}%',
      isPositive: isPositive,
    );

    final lineColor = isPositive ? appPrimaryColor : Colors.red;

    final series = [
      charts.Series<List, num>(
        id: 'price',
        data: points,
        domainFn: (p, _) => p[0],
        measureFn: (p, _) => p[1],
        labelAccessorFn: (p, _) => '${p[0]}',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(lineColor),
        areaColorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(lineColor.withOpacity(0.08)),
      ),
    ];

    return _ChartResult(
      series: series,
      xMin: xMin,
      xMax: xMax,
      yMin: yMin - (yMax - yMin) * 0.05, // 5% padding below
      yMax: yMax + (yMax - yMin) * 0.05, // 5% padding above
      symbol: symbol,
      isPositive: isPositive,
    );
  }

  void _selectDay(int days) {
    if (_days == days) return;
    setState(() {
      _days = days;
      _chartFuture = _fetchChart(days);
    });
  }

  @override
  void dispose() {
    _priceNotifier.dispose();
    _dateNotifier.dispose();
    _changeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.coin.getName()} (${widget.coin.getSymbol()})'),
      ),
      body: SizedBox(
        height: double.infinity,
        child: RefreshIndicator(
          onRefresh: () async {
            _cache.clear();
            setState(() => _chartFuture = _fetchChart(_days));
          },
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Price display
                          ValueListenableBuilder<String>(
                            valueListenable: _priceNotifier,
                            builder: (_, value, __) => ChartPrice(
                              chartPriceData: ChartPriceParam(price: value),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Period change badge + scrub date
                          _PeriodChangeRow(
                            changeNotifier: _changeNotifier,
                            dateNotifier: _dateNotifier,
                          ),
                          const SizedBox(height: 8),
                          // Chart
                          SizedBox(
                            width: double.infinity,
                            height: 220,
                            child: FutureBuilder<_ChartResult>(
                              future: _chartFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  if (kDebugMode) print(snapshot.error);
                                  return Center(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .couldNotFetchData,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return const Center(child: Loader());
                                }
                                return _ChartView(
                                  result: snapshot.data!,
                                  onSelect: (price, date, symbol) {
                                    _priceNotifier.value =
                                        '$symbol${formatMoney(price)}';
                                    _dateNotifier.value = date;
                                  },
                                  onDeselect: (lastPrice, symbol) {
                                    _priceNotifier.value =
                                        '$symbol${formatMoney(lastPrice)}';
                                    _dateNotifier.value = '';
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Day range selector
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _dayRanges
                                  .map((r) => _DayButton(
                                        range: r,
                                        selected: _days == r.days,
                                        onTap: () => _selectDay(r.days),
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chart view ────────────────────────────────────────────────────────────────

class _ChartView extends StatelessWidget {
  final _ChartResult result;
  final void Function(num price, String date, String symbol) onSelect;
  final void Function(num lastPrice, String symbol) onDeselect;

  const _ChartView({
    required this.result,
    required this.onSelect,
    required this.onDeselect,
  });

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      result.series,
      defaultRenderer: charts.LineRendererConfig(includeArea: true),
      selectionModels: [
        charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          changedListener: (model) {
            if (model.hasDatumSelection) {
              final millis = model.selectedDatum[0].datum[0] as num;
              final dt = DateTime.fromMillisecondsSinceEpoch(millis.toInt());
              final date =
                  '${DateFormat('hh:mm a').format(dt)} · ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
              final price = model.selectedSeries[0]
                  .measureFn(model.selectedDatum[0].index);

              CustomCircleSymbolRenderer.backgroundColor =
                  Theme.of(context).textTheme.bodyMedium!.color!;
              CustomCircleSymbolRenderer.textColor =
                  Theme.of(context).scaffoldBackgroundColor;
              CustomCircleSymbolRenderer.value = date;

              onSelect(price ?? 0, date, result.symbol);
            } else {
              // deselect — restore latest price
              final lastY = (result.series.first.data.last as List)[1] as num;
              onDeselect(lastY, result.symbol);
            }
          },
        ),
      ],
      behaviors: [
        charts.SelectNearest(
          eventTrigger: charts.SelectionTrigger.tapAndDrag,
        ),
        charts.LinePointHighlighter(
          symbolRenderer: CustomCircleSymbolRenderer(),
        ),
      ],
      domainAxis: charts.NumericAxisSpec(
        tickProviderSpec: const charts.BasicNumericTickProviderSpec(
            desiredTickCount: 10, zeroBound: false),
        renderSpec: const charts.NoneRenderSpec(),
        viewport: charts.NumericExtents(result.xMin, result.xMax),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: const charts.NoneRenderSpec(),
        viewport: charts.NumericExtents(result.yMin, result.yMax),
      ),
      animate: true,
      animationDuration: const Duration(milliseconds: 400),
    );
  }
}

// ── Period change row ─────────────────────────────────────────────────────────

class _PeriodChange {
  final String amount;
  final String percent;
  final bool isPositive;
  const _PeriodChange(
      {required this.amount, required this.percent, required this.isPositive});
}

class _PeriodChangeRow extends StatelessWidget {
  final ValueNotifier<_PeriodChange?> changeNotifier;
  final ValueNotifier<String> dateNotifier;

  const _PeriodChangeRow({
    required this.changeNotifier,
    required this.dateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<_PeriodChange?>(
          valueListenable: changeNotifier,
          builder: (_, change, __) {
            if (change == null) return const SizedBox();
            final color = change.isPositive ? green : red;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${change.amount}  (${change.percent})',
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder<String>(
          valueListenable: dateNotifier,
          builder: (_, date, __) {
            if (date.isEmpty) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Day button ────────────────────────────────────────────────────────────────

class _DayButton extends StatelessWidget {
  final _DayRange range;
  final bool selected;
  final VoidCallback onTap;

  const _DayButton({
    required this.range,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 32,
        decoration: BoxDecoration(
          color:
              selected ? appPrimaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              selected ? Border.all(color: appPrimaryColor, width: 1.5) : null,
        ),
        child: Center(
          child: Text(
            range.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? appPrimaryColor : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tooltip renderer ──────────────────────────────────────────────────────────

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  static String value = '';
  static Color textColor = Colors.black;
  static Color backgroundColor = Colors.white;

  @override
  void paint(
    charts.ChartCanvas canvas,
    Rectangle<num> bounds, {
    List<int>? dashPattern,
    charts.Color? fillColor,
    charts.FillPatternType? fillPattern,
    charts.Color? strokeColor,
    double? strokeWidthPx,
  }) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    final tooltipWidth = (value.length * 7.5).clamp(80.0, 220.0);

    canvas.drawRRect(
      Rectangle(
        bounds.left - 5,
        bounds.top - 35,
        tooltipWidth,
        30,
      ),
      radius: 6,
      roundTopLeft: true,
      roundTopRight: true,
      roundBottomRight: true,
      roundBottomLeft: true,
      fill: charts.ColorUtil.fromDartColor(backgroundColor),
    );

    final textStyle = style.TextStyle()
      ..color = charts.ColorUtil.fromDartColor(textColor)
      ..fontSize = 12;

    canvas.drawText(
      TextElement.TextElement(value, style: textStyle),
      (bounds.left).round(),
      (bounds.top - 30).round(),
    );
  }
}

// ── Chart result ──────────────────────────────────────────────────────────────

class _ChartResult {
  final List<charts.Series<List, num>> series;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final String symbol;
  final bool isPositive;

  const _ChartResult({
    required this.series,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.symbol,
    required this.isPositive,
  });
}
