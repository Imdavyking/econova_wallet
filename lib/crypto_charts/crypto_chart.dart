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

String getMarketInfo(String coinGeckoId) {
  return "$coinGeckoBaseurl/coins/$coinGeckoId";
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
                              child:
                                  FutureBuilder<_ChartResult>(future: () async {
                                String defaultCurrency =
                                    pref.get('defaultCurrency') ?? "usd";

                                Map viewportY = {
                                  'min': 0,
                                  'max': 0,
                                };
                                Map viewportX = {
                                  'min': 0,
                                  'max': 0,
                                };

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

                                int currentIndex = 0;

                                final jsonDecodedPrices =
                                    jsonDecode(savedData[days])['prices'];

                                priceNotifier.value = '$symbol${formatMoney([
                                  jsonDecodedPrices[
                                      (jsonDecodedPrices as List).length - 1]
                                ][0][1])}';

                                chartData =
                                    (jsonDecodedPrices as Iterable).map((e) {
                                  if (currentIndex == 0) {
                                    viewportX['max'] = e[0];
                                    viewportX['min'] = e[0];
                                    viewportY['min'] = e[0];
                                    viewportY['min'] = e[0];
                                  }
                                  if (viewportX['max'] < e[0]) {
                                    viewportX['max'] = e[0];
                                  }
                                  if (viewportX['min'] > e[0]) {
                                    viewportX['min'] = e[0];
                                  }
                                  if (viewportY['max'] < e[1]) {
                                    viewportY['max'] = e[1];
                                  }
                                  if (viewportY['min'] > e[1]) {
                                    viewportY['min'] = e[1];
                                  }
                                  currentIndex++;
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
                                  viewportY: viewportY,
                                  viewportX: viewportX,
                                  symbol: symbol,
                                );
                              }(), builder: (context, snapshot) {
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
                                              final millis = model
                                                  .selectedDatum[0].datum[0];

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
                                          })
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
                                        snapshot.data!.viewportX['min'],
                                        snapshot.data!.viewportX['max'],
                                      ),
                                    ),
                                    primaryMeasureAxis: charts.NumericAxisSpec(
                                      renderSpec: const charts.NoneRenderSpec(),
                                      viewport: charts.NumericExtents(
                                        snapshot.data!.viewportY['min'],
                                        snapshot.data!.viewportY['max'],
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
                              }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        days = 1;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 5,
                                            color: days == 1
                                                ? appPrimaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                      width: 50,
                                      height: 30,
                                      child: const Center(
                                        child: Text(
                                          '1D',
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        days = 7;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 5,
                                            color: days == 7
                                                ? appPrimaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                      width: 50,
                                      height: 30,
                                      child: const Center(
                                        child: Text(
                                          '1W',
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        days = 30;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 5,
                                            color: days == 30
                                                ? appPrimaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                      width: 50,
                                      height: 30,
                                      child: const Center(
                                        child: Text(
                                          '1M',
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        days = 365;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 5,
                                            color: days == 365
                                                ? appPrimaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                      width: 50,
                                      height: 30,
                                      child: const Center(
                                        child: Text(
                                          '1Y',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

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

class _ChartResult {
  final Map viewportY;
  final Map viewportX;
  final String symbol;

  const _ChartResult({
    required this.viewportX,
    required this.viewportY,
    required this.symbol,
  });
}
