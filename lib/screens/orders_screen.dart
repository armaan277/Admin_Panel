import 'dart:convert';
// import 'package:admin_panel/all_orders_items.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_admin_panel/screens/orders_items_screen.dart';

class OrdersScreen extends StatefulWidget {
  final String? filters;
  const OrdersScreen({super.key, this.filters});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  DateTime? selectedDate;

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default date
      firstDate: DateTime(2000), // Earliest date the user can select
      lastDate: DateTime(2100), // Latest date the user can select
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<dynamic> orders = [];
  bool isLoading = true;
  Map<String, bool> isOrderUpdating = {};

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  String formatDate(DateTime? date) {
    return selectedDate == null
        ? DateFormat('d MMM yyyy').format(DateTime.now())
        : DateFormat('d MMM yyyy').format(date!);
  }

  // Fetch orders from the backend
  Future<void> fetchOrders() async {
    final url = Uri.parse(
      'https://ecommerce-rendered.onrender.com/orderslist',
    ); // Backend URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('data : $data');
        setState(() {
          orders = data; // Extract orders from the response
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text('Failed to load orders!'),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Error fetching orders: $e'),
          ),
        ),
      );
    }
  }

  String? formattedDate;

  @override
  Widget build(BuildContext context) {
// Get today's date and format it to match 'order_booking_date'
    final String todayDate = DateFormat('d-M-yyyy').format(DateTime.now());
    debugPrint('Today\'s Date: $todayDate');

// Format the selected date to match the 'order_booking_date' format
    formattedDate = todayDate; // Default to today's date
    if (selectedDate != null) {
      formattedDate = DateFormat('d-M-yyyy').format(selectedDate!);
      debugPrint('Formatted Selected Date: $formattedDate');
    }

    List filtersOdersLength(List orders, String status) {
      return orders
          .where(
            (order) => status == ''
                ? order['order_booking_date'] == formattedDate
                : order['order_status'] == status &&
                    order['order_booking_date'] == formattedDate,
          )
          .toList();
    }

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: TabBar(
                    dividerHeight: 2,
                    dividerColor:
                        isDarkMode ? Colors.grey : Colors.grey.shade300,
                    isScrollable: true,
                    labelColor: isDarkMode ? Colors.white : Color(0xffdb3022),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor:
                        isDarkMode ? Colors.white : Color(0xffdb3022),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        text:
                            'All Orders (${filtersOdersLength(orders, '').length})',
                      ),
                      Tab(
                        text:
                            'Confirmed (${filtersOdersLength(orders, 'Confirmed').length})',
                      ),
                      Tab(
                        text:
                            'Out for Delivery (${filtersOdersLength(orders, 'Out for Delivery').length})',
                      ),
                      Tab(
                        text:
                            'Delivered (${filtersOdersLength(orders, 'Delivered').length})',
                      ),
                      Tab(
                        text:
                            'Cancelled (${filtersOdersLength(orders, 'Canceled').length})',
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    formatDate(selectedDate),
                  ),
                  IconButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    icon: Icon(Icons.date_range_sharp),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildOrdersList(
                    orders
                        .where(
                          (order) =>
                              order['order_booking_date'] == formattedDate,
                        )
                        .toList(),
                  ), // All orders
                  _buildOrdersList(
                    orders
                        .where(
                          (order) =>
                              order['order_status'] == 'Confirmed' &&
                              order['order_booking_date'] == formattedDate,
                        )
                        .toList(),
                  ),
                  _buildOrdersList(
                    orders
                        .where(
                          (order) =>
                              order['order_status'] == 'Out for Delivery' &&
                              order['order_booking_date'] == formattedDate,
                        )
                        .toList(),
                  ),
                  _buildOrdersList(
                    orders
                        .where(
                          (order) =>
                              order['order_status'] == 'Delivered' &&
                              order['order_booking_date'] == formattedDate,
                        )
                        .toList(),
                  ),
                  _buildOrdersList(
                    orders
                        .where(
                          (order) =>
                              order['order_status'] == 'Canceled' &&
                              order['order_booking_date'] == formattedDate,
                        )
                        .toList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrdersList(List<dynamic> filteredOrders) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return filteredOrders.isEmpty
        ? Center(
            child: Text(
            '${selectedDate != null ? DateFormat('d MMM yyyy').format(selectedDate!) : formatDate(DateTime.now())}, No orders found',
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.grey,
              fontSize: 20,
            ),
          ))
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Table Headers
                SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white60.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(2, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: Center(child: Text('Id'))),
                      Expanded(flex: 3, child: Text('Name')),
                      Expanded(flex: 8, child: Text('Address')),
                      Expanded(flex: 2, child: Text('Phone')),
                      Expanded(flex: 2, child: Center(child: Text('Time'))),
                      Expanded(flex: 2, child: Center(child: Text('Price'))),
                      Expanded(flex: 2, child: Center(child: Text('Status'))),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 7.0),
                            child: Text('Action'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];

                      // Parse and format the order booking time
                      String formattedOrderTime =
                          formatOrderTime(order['order_booking_time']);

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return OrdersItemsScreen(
                                  orderItemsId: order['order_items_id'],
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(order['orders_id'].toString()),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(order['name']),
                              ),
                              Expanded(
                                flex: 8,
                                child: Text(
                                  order['address'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  order['phone'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    formattedOrderTime,
                                  ), // Display formatted time
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    '${order['price'].toStringAsFixed(2)}',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.white.withOpacity(0.2)
                                          : order['order_status'] == 'Delivered'
                                              ? Colors.green.withOpacity(0.2)
                                              : order['order_status'] ==
                                                      'Confirmed'
                                                  ? Colors.orange
                                                      .withOpacity(0.2)
                                                  : order['order_status'] ==
                                                          'Canceled'
                                                      ? Colors.red
                                                          .withOpacity(0.2)
                                                      : Colors.blue
                                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: isOrderUpdating[
                                                order['order_items_id']] ==
                                            true
                                        ? CircularProgressIndicator()
                                        : Text(
                                            order['order_status'],
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : order['order_status'] ==
                                                          'Delivered'
                                                      ? Colors.green
                                                      : order['order_status'] ==
                                                              'Confirmed'
                                                          ? Colors.orange
                                                          : order['order_status'] ==
                                                                  'Canceled'
                                                              ? Colors
                                                                  .red.shade900
                                                              : Colors.blue,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: order['order_status'] == "Confirmed" ||
                                        order['order_status'] ==
                                            "Out for Delivery"
                                    ? PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert),
                                        onSelected: (String value) {
                                          order['order_status'] = value;
                                          debugPrint(
                                            'order["order_status"]: ${order['order_status']}',
                                          );
                                          updateStatusInDatabase(
                                            order['order_items_id'],
                                            order['order_status'],
                                          );
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem(
                                            value: 'Canceled',
                                            child: Text('Cancel Order'),
                                          ),
                                        ],
                                      )
                                    : Text(''),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

// Function to format the order time
  String formatOrderTime(String timeString) {
    try {
      // Removing the timezone part (split the string at the '+' sign and take the first part)
      String cleanedTimeString = timeString.split('+')[0];

      // Parse the cleaned time string into a DateTime object
      DateTime parsedTime = DateTime.parse("2025-01-28 " +
          cleanedTimeString); // Adding a date to parse correctly

      // Formatting the time in a desired format (e.g., 24-hour format)
      String formattedTime =
          DateFormat('h:mm a').format(parsedTime); // Change to desired format

      return formattedTime;
    } catch (e) {
      return 'Invalid Time Format'; // In case of an error
    }
  }

  Future<bool> updateStatusInDatabase(
    String orderId,
    String orderStatus,
  ) async {
    final url =
        Uri.parse('https://ecommerce-rendered.onrender.com/orderlist/$orderId');

    setState(() {
      isOrderUpdating[orderId] = true;
    });

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': orderStatus}),
      );

      if (response.statusCode == 200) {
        debugPrint('Status updated successfully: $orderStatus');
        return true;
      } else {
        debugPrint('Failed to update status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      setState(() {});
      debugPrint('Error updating status: $e');
      return false;
    } finally {
      setState(() {
        isOrderUpdating[orderId] = false; // Remove loading for specific order
      });
    }
  }
}
