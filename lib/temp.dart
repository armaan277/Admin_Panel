import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class OrdersAnalytics extends StatefulWidget {
  @override
  _OrdersAnalyticsState createState() => _OrdersAnalyticsState();
}

class _OrdersAnalyticsState extends State<OrdersAnalytics> {
  List orders = [];
  Map<String, double> dailyPriceSum = {}; // Stores total price per day
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime(2025, 1, 15);
    endDate = DateTime(2025, 1, 25);
    getOrders();
  }

  Future<void> getOrders() async {
    try {
      final url = Uri.parse('http://localhost:3000/orderslist');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final listResponse = jsonDecode(response.body);

        if (listResponse is List) {
          orders = listResponse;
          dailyPriceSum.clear();

          for (var order in orders) {
            final orderDate = DateFormat('d-M-yyyy').parse(order['order_booking_date']);
            if (orderDate.isAfter(startDate.subtract(Duration(days: 1))) &&
                orderDate.isBefore(endDate.add(Duration(days: 1)))) {
              final dateString = DateFormat('d-M-yyyy').format(orderDate);
              double price = (order['price'] as num).toDouble();

              dailyPriceSum[dateString] = (dailyPriceSum[dateString] ?? 0) + price;
            }
          }

          print("Filtered Daily Price Sum: $dailyPriceSum");

          setState(() {});
        }
      } else {
        print('Failed to load orders.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders Price Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Price Analytics (15-1-2025 to 25-1-2025)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: dailyPriceSum.isEmpty
                      ? 100
                      : dailyPriceSum.values.reduce((a, b) => a > b ? a : b) + 500,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '₹${rod.toY.toStringAsFixed(2)}',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = startDate.add(Duration(days: value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('d-M').format(date),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('₹${value.toInt()}', style: TextStyle(fontSize: 12));
                        },
                        reservedSize: 50,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: List.generate(11, (index) {
                    final date = startDate.add(Duration(days: index));
                    final dateString = DateFormat('d-M-yyyy').format(date);
                    final totalPrice = dailyPriceSum[dateString] ?? 0.0;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: totalPrice,
                          color: Color(0xffdb3022),
                          width: 25,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Total Revenue: ₹${dailyPriceSum.values.fold(0.0, (prev, element) => prev + element).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
