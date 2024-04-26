import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../services/saving.dart';

class PiggyScreen extends StatefulWidget {
  const PiggyScreen({Key? key});

  @override
  State<PiggyScreen> createState() => _PiggyScreenState();
}

class _PiggyScreenState extends State<PiggyScreen> {
  final myBox = Hive.box('myBox');
  List<FlSpot> _spotsMonth = [];
  List<FlSpot> _spotsWeek = [];
  List<dynamic> _moneySendList = [];
  int _totalMoney = 0;
  late int _daysInMonth;

  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  String _idUser = '';

  void _createChartData(Map<String, dynamic> response) {
    _spotsMonth.clear();
    final List<dynamic> moneySendListByMonth = response['listMoneySendByMonth'];
    final List<dynamic> moneySendListByWeek = response['listMoneySendByWeek'];
    print(moneySendListByWeek);
    for (var i = 0; i < moneySendListByMonth.length; i++) {
      final List<dynamic> moneySend = moneySendListByMonth[i];
      final int day = moneySend[0];
      final double money = (moneySend[1] as int) / 10000;
      _spotsMonth.add(FlSpot(day.toDouble(), money));
    }
    for (var i = 0; i < moneySendListByWeek.length; i++) {
      final List<dynamic> moneySend = moneySendListByWeek[i];
      final int day = moneySend[0];
      final double money = (moneySend[1] as int) / 10000;
      _spotsWeek.add(FlSpot(day.toDouble(), money));
    }
    _totalMoney = response['totalMoney'];
    print(_spotsMonth);
  }

  // Future<void> _getPiggy() async {
  //   final Map<String, dynamic> response =
  //       await GetTotalMoneyService.getTotalMoney(_idUser);
  //
  //   print('Response status: ${response['status']}');
  //   print('Response body: ${response['message']}');
  //
  //   if (response['status'] == 'success') {
  //     _moneySendList = response['listMoneySendByMonth'];
  //     if (_moneySendList.isNotEmpty) {
  //       _createChartData(response);
  //       setState(() {});
  //     }
  //   }
  // }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');
    return formatter.format(amount);
  }

  void _calculateDaysInMonth() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    setState(() {
      _daysInMonth = daysInMonth;
      print('Days in month: $_daysInMonth');
    });
  }

  Future<Map<String, dynamic>> _getPiggyData() async {
    final Map<String, dynamic> response =
        await GetTotalMoneyService.getTotalMoney(_idUser);
    return response;
  }

  @override
  void initState() {
    super.initState();
    _idUser = myBox.get('id', defaultValue: '');
    //_getPiggy();
    _calculateDaysInMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _getPiggyData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final Map<String, dynamic> response = snapshot.data!;
              if (response['listMoneySendByMonth'] != null && response['listMoneySendByWeek'] != null) {
                _moneySendList = response['listMoneySendByMonth'];
                _createChartData(response);
              } else {
                _moneySendList = [];
              }

              return _moneySendList.isNotEmpty
                  ? SingleChildScrollView(
                      child: SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width, // Set width to full width of screen
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                '\$${_formatCurrency(_totalMoney)}₫',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  textStyle:
                                      const TextStyle(color: Color(0xFF000000)),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Monthly ${DateTime.now().month}/${DateTime.now().year}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSansKawi(
                                  textStyle:
                                      const TextStyle(color: Color(0xFF000000)),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height *
                                  0.5, // Set height to a specific value
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                color: const Color(0xff020227),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: LineChart(
                                    LineChartData(
                                      minX: 25,
                                      maxX: _daysInMonth.toDouble(),
                                      minY: 0,
                                      maxY: _totalMoney / 10000,
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 35,
                                          getTextStyles: (value) =>
                                              const TextStyle(
                                            color: Color(0xff68737d),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          margin: 8,
                                        ),
                                        leftTitles: SideTitles(
                                          showTitles: true,
                                          getTextStyles: (value) =>
                                              const TextStyle(
                                            color: Color(0xff67727d),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          getTitles: (value) {
                                            for (var spot in _spotsMonth) {
                                              if (spot.y.toInt() ==
                                                  value.toInt()) {
                                                return spot.y
                                                        .toInt()
                                                        .toString() +
                                                    '0k';
                                              }
                                            }
                                            return '';
                                          },
                                          reservedSize: 35,
                                          margin: 12,
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: const Color(0xff37434d),
                                            strokeWidth: 1,
                                          );
                                        },
                                        drawVerticalLine: true,
                                        getDrawingVerticalLine: (value) {
                                          return FlLine(
                                            color: const Color(0xff37434d),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(
                                            color: const Color(0xff37434d),
                                            width: 1),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _spotsMonth,
                                          isCurved: true,
                                          colors: gradientColors,
                                          barWidth: 5,
                                          //dotData: FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            colors: gradientColors
                                                .map((color) =>
                                                    color.withOpacity(0.3))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Text(
                                'Weekly',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSansKawi(
                                  textStyle:
                                      const TextStyle(color: Color(0xFF000000)),
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height *
                                  0.5, // Set height to a specific value
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                color: const Color(0xff020227),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: LineChart(
                                    LineChartData(
                                      minX: 0,
                                      maxX: 7,
                                      minY: 0,
                                      maxY: _totalMoney / 10000,
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 35,
                                          getTextStyles: (value) =>
                                              const TextStyle(
                                            color: Color(0xff68737d),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          getTitles: (value) {
                                            switch (value.toInt()) {
                                              case 0:
                                                return 'Mon';
                                              case 1:
                                                return 'Tue';
                                              case 2:
                                                return 'Web';
                                              case 3:
                                                return 'Thur';
                                              case 4:
                                                return 'Fri';
                                              case 5:
                                                return 'Sat';
                                              case 6:
                                                return 'Sun';
                                            }
                                            return '';
                                          },
                                          margin: 8,
                                        ),
                                        leftTitles: SideTitles(
                                          showTitles: true,
                                          getTextStyles: (value) =>
                                              const TextStyle(
                                            color: Color(0xff67727d),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          getTitles: (value) {
                                            for (var spot in _spotsWeek) {
                                              if (spot.y.toInt() ==
                                                  value.toInt()) {
                                                return spot.y
                                                        .toInt()
                                                        .toString() +
                                                    '0k';
                                              }
                                            }
                                            return '';
                                          },
                                          reservedSize: 35,
                                          margin: 12,
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: const Color(0xff37434d),
                                            strokeWidth: 1,
                                          );
                                        },
                                        drawVerticalLine: true,
                                        getDrawingVerticalLine: (value) {
                                          return FlLine(
                                            color: const Color(0xff37434d),
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: Border.all(
                                            color: const Color(0xff37434d),
                                            width: 1),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _spotsWeek,
                                          isCurved: true,
                                          colors: gradientColors,
                                          barWidth: 5,
                                          //dotData: FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            colors: gradientColors
                                                .map((color) =>
                                                    color.withOpacity(0.3))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Text('No data to display'),
                    );
            }
          }
        },
      ),
    );
  }
}
