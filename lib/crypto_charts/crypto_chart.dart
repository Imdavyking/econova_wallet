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

class CryptoChart extends StatefulWidget {
  final Coin coin;
  const CryptoChart({
    super.key,
    required this.coin,
  });

  @override
  State<CryptoChart> createState() => _CryptoChartState();
}

String getMarketData({
  required int days,
  required String coinGeckoId,
  required String defaultCurrency,
}) {
  return "$coinGeckoBaseurl/coins/$coinGeckoId/market_chart?vs_currency=$defaultCurrency&days=$days";
}

class _CryptoChartState extends State<CryptoChart> {
  late List<charts.Series<List, num>> series;
  List<List<dynamic>> chartData = [];
  int days = 1;
  Map savedData = {};
  late Coin coin;

  @override
  initState() {
    super.initState();
    coin = widget.coin;
  }

  ValueNotifier<String> priceNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${coin.getName()} (${coin.getSymbol()})'),
      ),
      body: SizedBox(
        height: double.infinity,
        child: RefreshIndicator(
          onRefresh: () async {
            // Clear cache so fresh data is fetched on refresh
            savedData.clear();
            await Future.delayed(const Duration(seconds: 2));
            setState(() {});
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ValueListenableBuilder<String>(
                              valueListenable: priceNotifier,
                              builder: ((context, value, child) {
                                return ChartPrice(
                                  chartPriceData: ChartPriceParam(
                                    price: value,
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 250,
                            child: FutureBuilder<_ChartResult>(
                              future: () async {
                                final String defaultCurrency =
                                    pref.get('defaultCurrency') ?? "usd";

                                double viewportYMin = double.infinity;
                                double viewportYMax = double.negativeInfinity;
                                double viewportXMin = double.infinity;
                                double viewportXMax = double.negativeInfinity;

                                final currencyWithSymbol =
                                    jsonDecode(currencyJson);

                                final symbol = currencyWithSymbol[
                                    defaultCurrency.toUpperCase()]['symbol'];

                                if (savedData[days] == null) {
                                  final request = await http
                                      .get(
                                        Uri.parse(
                                          getMarketData(
                                            days: days,
                                            coinGeckoId: coin.getGeckoId(),
                                            defaultCurrency: defaultCurrency,
                                          ),
                                        ),
                                      )
                                      .timeout(networkTimeOutDuration);

                                  if (request.statusCode ~/ 100 == 4 ||
                                      request.statusCode ~/ 100 == 5) {
                                    throw Exception('Request failed');
                                  }

                                  savedData[days] = request.body;
                                }

                                final jsonDecodedPrices =
                                    jsonDecode(savedData[days])['prices']
                                        as List;

                                // Set initial price display to latest price
                                priceNotifier.value =
                                    '$symbol${formatMoney(jsonDecodedPrices.last[1])}';

                                chartData = jsonDecodedPrices.map((e) {
                                  final double x = (e[0] as num).toDouble();
                                  final double y = (e[1] as num).toDouble();

                                  // ── FIX: correctly track both X and Y viewports ──
                                  if (x < viewportXMin) viewportXMin = x;
                                  if (x > viewportXMax) viewportXMax = x;
                                  if (y < viewportYMin) viewportYMin = y;
                                  if (y > viewportYMax) viewportYMax = y;

                                  return List<dynamic>.from(e);
                                }).toList();

                                series = [
                                  charts.Series(
                                    id: 'crypto chart',
                                    data: chartData,
                                    labelAccessorFn: (List series, _) =>
                                        '${series[0]}',
                                    domainFn: (List series, _) => series[0],
                                    measureFn: (List series, _) => series[1],
                                    colorFn: (List series, _) =>
                                        charts.ColorUtil.fromDartColor(
                                            appPrimaryColor),
                                  )
                                ];

                                return _ChartResult(
                                  viewportYMin: viewportYMin,
                                  viewportYMax: viewportYMax,
                                  viewportXMin: viewportXMin,
                                  viewportXMax: viewportXMax,
                                  symbol: symbol,
                                );
                              }(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  if (kDebugMode) {
                                    print(snapshot.error);
                                  }
                                  return Center(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .couldNotFetchData,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  );
                                }
                                if (snapshot.hasData) {
                                  return charts.LineChart(
                                    series,
                                    selectionModels: [
                                      charts.SelectionModelConfig(
                                        type: charts.SelectionModelType.info,
                                        changedListener:
                                            (charts.SelectionModel model) {
                                          if (model.hasDatumSelection) {
                                            final millis =
                                                model.selectedDatum[0].datum[0];

                                            final dt = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    millis);

                                            final date = DateFormat('hh:mm a')
                                                .format(dt);

                                            final price = model
                                                .selectedSeries[0]
                                                .measureFn(model
                                                    .selectedDatum[0].index);

                                            CustomCircleSymbolRenderer
                                                    .backgroundColor =
                                                Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color!;
                                            CustomCircleSymbolRenderer
                                                    .textColor =
                                                Theme.of(context)
                                                    .scaffoldBackgroundColor;

                                            priceNotifier.value =
                                                '${snapshot.data!.symbol}${formatMoney(price)}';

                                            CustomCircleSymbolRenderer.value =
                                                '$date\n${months[dt.month - 1]} ${dt.day}, ${dt.year}';
                                          }
                                        },
                                      )
                                    ],
                                    behaviors: [
                                      charts.SelectNearest(
                                        eventTrigger:
                                            charts.SelectionTrigger.tapAndDrag,
                                      ),
                                      charts.LinePointHighlighter(
                                        symbolRenderer:
                                            CustomCircleSymbolRenderer(),
                                      ),
                                    ],
                                    domainAxis: charts.NumericAxisSpec(
                                      tickProviderSpec: const charts
                                          .BasicNumericTickProviderSpec(
                                          desiredTickCount: 10,
                                          zeroBound: false),
                                      renderSpec: const charts.NoneRenderSpec(),
                                      viewport: charts.NumericExtents(
                                        snapshot.data!.viewportXMin,
                                        snapshot.data!.viewportXMax,
                                      ),
                                    ),
                                    primaryMeasureAxis: charts.NumericAxisSpec(
                                      renderSpec: const charts.NoneRenderSpec(),
                                      viewport: charts.NumericExtents(
                                        snapshot.data!.viewportYMin,
                                        snapshot.data!.viewportYMax,
                                      ),
                                    ),
                                    animate: false,
                                  );
                                } else {
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Loader(),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _DayButton(
                                  label: '1D',
                                  value: 1,
                                  selectedDays: days,
                                  onTap: () => setState(() => days = 1),
                                ),
                                _DayButton(
                                  label: '1W',
                                  value: 7,
                                  selectedDays: days,
                                  onTap: () => setState(() => days = 7),
                                ),
                                _DayButton(
                                  label: '1M',
                                  value: 30,
                                  selectedDays: days,
                                  onTap: () => setState(() => days = 30),
                                ),
                                _DayButton(
                                  label: '1Y',
                                  value: 365,
                                  selectedDays: days,
                                  onTap: () => setState(() => days = 365),
                                ),
                              ],
                            ),
                          ),
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

// ── Extracted day button widget to remove repetition ──────────────────────────

class _DayButton extends StatelessWidget {
  final String label;
  final int value;
  final int selectedDays;
  final VoidCallback onTap;

  const _DayButton({
    required this.label,
    required this.value,
    required this.selectedDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 5,
              color:
                  selectedDays == value ? appPrimaryColor : Colors.transparent,
            ),
          ),
        ),
        width: 50,
        height: 30,
        child: Center(child: Text(label)),
      ),
    );
  }
}

// ── Chart tooltip renderer ────────────────────────────────────────────────────

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  static late String value;
  static late Color textColor;
  static late Color backgroundColor;

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
    super.paint(
      canvas,
      bounds,
      dashPattern: dashPattern,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidthPx: strokeWidthPx,
    );
    canvas.drawRRect(
      Rectangle(
        bounds.left - 5,
        bounds.top - 31,
        bounds.width + (5 * value.length),
        bounds.height + 30,
      ),
      radius: 5,
      roundTopLeft: true,
      roundTopRight: true,
      roundBottomRight: true,
      roundBottomLeft: true,
      fill: charts.ColorUtil.fromDartColor(backgroundColor),
    );
    final textStyle = style.TextStyle();
    textStyle.color = charts.ColorUtil.fromDartColor(textColor);
    textStyle.fontSize = 15;
    canvas.drawText(
      TextElement.TextElement(value, style: textStyle),
      (bounds.left).round(),
      (bounds.top - 26).round(),
    );
  }
}

// ── Chart result data class ───────────────────────────────────────────────────

class _ChartResult {
  final double viewportYMin;
  final double viewportYMax;
  final double viewportXMin;
  final double viewportXMax;
  final String symbol;

  const _ChartResult({
    required this.viewportYMin,
    required this.viewportYMax,
    required this.viewportXMin,
    required this.viewportXMax,
    required this.symbol,
  });
}
