import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrdersAnalytics extends StatefulWidget {
  const OrdersAnalytics({super.key});

  @override
  State<OrdersAnalytics> createState() => _OrdersAnalyticsState();
}

class _OrdersAnalyticsState extends State<OrdersAnalytics> {
  List<dynamic> orders = [];
  Map<String, int> dailyOrderCounts = {};
  Map<String, double> dailyPriceSum = {};

  // Initialize with default dates
  DateTime? startDate = DateTime.now().subtract(const Duration(days: 10));
  DateTime? endDate = DateTime.now();

  String formatDate(DateTime? date) {
    if (date == null) return DateFormat('d MMM yyyy').format(DateTime.now());
    return DateFormat('d MMM yyyy').format(date);
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: endDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        // Refresh data with new date range
        dailyOrderCounts.clear();
        dailyPriceSum.clear();
        getOrders();
      });
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
        // Refresh data with new date range
        dailyOrderCounts.clear();
        dailyPriceSum.clear();
        getOrders();
      });
    }
  }

  int getDaysBetween() {
    if (startDate == null || endDate == null) return 11; // default value
    return endDate!.difference(startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: orders.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xffdb3022),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Start Date: ${formatDate(startDate)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => selectStartDate(context),
                            icon: Icon(Icons.date_range_sharp),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Text(
                            'End Date: ${formatDate(endDate)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => selectEndDate(context),
                            icon: Icon(Icons.date_range_sharp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orders Analytics (${formatDate(startDate)} to ${formatDate(endDate)})',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: dailyOrderCounts.isEmpty
                                  ? 10
                                  : dailyOrderCounts.values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble(),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${rod.toY.round()} orders',
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final date = startDate!
                                          .add(Duration(days: value.toInt()));
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          DateFormat('dd').format(date),
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Color(0xffdb3022).withOpacity(0.5),
                                    strokeWidth: 0.8,
                                  );
                                },
                              ),
                              barGroups:
                                  List.generate(getDaysBetween(), (index) {
                                final date =
                                    startDate?.add(Duration(days: index));
                                final dateString = date != null
                                    ? DateFormat('d-M-yyyy').format(date)
                                    : '';
                                final count = dailyOrderCounts[dateString] ?? 0;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: count.toDouble(),
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
                        const SizedBox(height: 20),
                        // Legend
                        Text(
                          'Total Orders: ${dailyOrderCounts.values.fold(0, (prev, element) => prev + element)}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orders Price Analytics (${formatDate(startDate)} to ${formatDate(endDate)})',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 40),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: dailyPriceSum.isEmpty
                                  ? 100
                                  : dailyPriceSum.values
                                          .reduce((a, b) => a > b ? a : b) +
                                      10000,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '₹${rod.toY.toStringAsFixed(2)}',
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final date = startDate!
                                          .add(Duration(days: value.toInt()));
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          DateFormat('d').format(date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                      return Text(
                                        '₹${value.toInt()}',
                                        style: TextStyle(fontSize: 12),
                                      );
                                    },
                                    reservedSize: 50,
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                  show: true, drawVerticalLine: false),
                              barGroups:
                                  List.generate(getDaysBetween(), (index) {
                                final date =
                                    startDate?.add(Duration(days: index));
                                final dateString = date != null
                                    ? DateFormat('d-M-yyyy').format(date)
                                    : '';
                                final totalPrice =
                                    dailyPriceSum[dateString] ?? 0.0;
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void getOrders() async {
    if (startDate == null || endDate == null) return;

    final url = Uri.parse('http://localhost:3000/orderslist');
    final response = await http.get(url);
    final listResponse = jsonDecode(response.body);
    orders = listResponse;

    // Clear existing data
    dailyOrderCounts.clear();
    dailyPriceSum.clear();

    // Process orders and count by date
    for (var order in orders) {
      final orderDate =
          DateFormat('d-M-yyyy').parse(order['order_booking_date']);
      if (orderDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
          orderDate.isBefore(endDate!.add(const Duration(days: 1)))) {
        final dateString = DateFormat('d-M-yyyy').format(orderDate);

        // Update order counts
        dailyOrderCounts[dateString] = (dailyOrderCounts[dateString] ?? 0) + 1;

        // Update price sums
        double price = (order['price'] as num).toDouble();
        dailyPriceSum[dateString] = (dailyPriceSum[dateString] ?? 0) + price;
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }
}
