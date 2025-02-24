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
  
  // Initialize with last 10 days
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Set default dates to last 10 days
    endDate = DateTime.now();
    startDate = endDate!.subtract(const Duration(days: 10));
    getOrders();
  }

  String formatDate(DateTime? date) {
    if (date == null) return DateFormat('d MMM yyyy').format(DateTime.now());
    return DateFormat('d MMM yyyy').format(date);
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? startDate! : endDate!,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

      if (picked != null) {
        setState(() {
          if (isStartDate) {
            if (endDate != null && picked.isAfter(endDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Start date cannot be after end date'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            startDate = picked;
          } else {
            if (startDate != null && picked.isBefore(startDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End date cannot be before start date'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            endDate = picked;
          }

          // Calculate the difference in days
          final difference = endDate!.difference(startDate!).inDays;
          if (difference > 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Date range cannot exceed 15 days'),
                backgroundColor: Colors.red,
              ),
            );
            // Reset to previous date
            if (isStartDate) {
              startDate = endDate!.subtract(const Duration(days: 10));
            } else {
              endDate = startDate!.add(const Duration(days: 10));
            }
          }

          // Refresh data with new date range
          dailyOrderCounts.clear();
          dailyPriceSum.clear();
          getOrders();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid date range'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int getDaysBetween() {
    if (startDate == null || endDate == null) return 10;
    return endDate!.difference(startDate!).inDays + 1;
  }

  // Your existing build method remains exactly the same
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: orders.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xffdb3022),
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Start Date: ${formatDate(startDate)}',
                        ),
                        IconButton(
                          onPressed: () => selectDate(context, true),
                          icon: Icon(Icons.date_range_sharp),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'End Date: ${formatDate(endDate)}',
                        ),
                        IconButton(
                          onPressed: () => selectDate(context, false),
                          icon: Icon(Icons.date_range_sharp),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    children: [
                      // Your existing UI code remains exactly the same
                      // Just update the date display in the titles
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
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
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
                                              padding: const EdgeInsets.only(top: 8.0),
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
                                    barGroups: List.generate(getDaysBetween(), (index) {
                                      final date = startDate?.add(Duration(days: index));
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
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
                                              padding: const EdgeInsets.only(top: 8.0),
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
                                    gridData:
                                        FlGridData(show: true, drawVerticalLine: false),
                                    barGroups: List.generate(getDaysBetween(), (index) {
                                      final date = startDate?.add(Duration(days: index));
                                      final dateString = date != null
                                          ? DateFormat('d-M-yyyy').format(date)
                                          : '';
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void getOrders() async {
    if (startDate == null || endDate == null) return;

    try {
      final url = Uri.parse('http://localhost:3000/orderslist');
      final response = await http.get(url);
      final listResponse = jsonDecode(response.body);
      orders = listResponse;

      // Clear existing data
      dailyOrderCounts.clear();
      dailyPriceSum.clear();

      // Process orders and count by date
      for (var order in orders) {
        final orderDate = DateFormat('d-M-yyyy').parse(order['order_booking_date']);
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
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }
}

