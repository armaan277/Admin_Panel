import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersItemsScreen extends StatefulWidget {
  final String orderItemsId;

  const OrdersItemsScreen({super.key, required this.orderItemsId});

  @override
  OrdersItemsScreenState createState() => OrdersItemsScreenState();
}

class OrdersItemsScreenState extends State<OrdersItemsScreen> {
  List<dynamic> orderItems = [];
  bool isLoading = true;
  String errorMessage = '';

  String currentStatus = '';
  String bottomSheetStatus = 'Out for Delivery';

  @override
  void initState() {
    super.initState();
    fetchOrderItems(widget.orderItemsId);
    getOrderStatus(widget.orderItemsId);
  }

  void fetchOrderItems(String orderIdItems) async {
    final url = Uri.parse('http://localhost:3000/bookingcarts/$orderIdItems');

    debugPrint('Fetching items for orderItemsId: $orderIdItems');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        debugPrint('Response Data: $data');

        setState(() {
          orderItems = data;
          isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'No items found for the given order ID.';
          isLoading = false;
        });
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        setState(() {
          errorMessage = 'Failed to load data. Please try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        errorMessage = 'An error occurred. Please check your connection.';
        isLoading = false;
      });
    }
  }

  Future<bool> updateStatusInDatabase(
      String orderId, String orderStatus) async {
    final url = Uri.parse('http://localhost:3000/orderlist/$orderId');

    try {
      final response = await http.put(
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
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  void getOrderStatus(String orderId) async {
    final url = Uri.parse('http://localhost:3000/orderlist/status/$orderId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          currentStatus = data['order_status'] ?? '';
          bottomSheetStatus =
              currentStatus == 'Confirmed' ? 'Out for Delivery' : 'Delivered';
        });

        debugPrint('Current status fetched: $currentStatus');
      } else {
        debugPrint('Failed to fetch status: ${response.statusCode}');
        setState(() {
          currentStatus = '';
          bottomSheetStatus = 'Out for Delivery';
        });
      }
    } catch (e) {
      debugPrint('Error fetching order status: $e');
      setState(() {
        currentStatus = '';
        bottomSheetStatus = 'Out for Delivery';
      });
    }
  }

  void updatedStatus() async {
    // Check current status and toggle it
    if (bottomSheetStatus == 'Out for Delivery') {
      setState(() {
        bottomSheetStatus = 'Delivered'; // Change the UI text
      });
      // Update the database to "Delivered"
      await status(widget.orderItemsId, 'Out for Delivery');
    } else if (bottomSheetStatus == 'Delivered') {
      setState(() {
        bottomSheetStatus = 'Delivered'; // Change the UI text
      });
      // Update the database to "Out for Delivery"
      await status(widget.orderItemsId, 'Delivered');
    }
  }

  // Function to update status in the database
  Future<void> status(String orderId, String newStatus) async {
    final url = Uri.parse('http://localhost:3000/orderlist/$orderId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': newStatus}),
      );

      if (response.statusCode == 200) {
        debugPrint('Status updated successfully to: $newStatus');
      } else {
        debugPrint('Failed to update status: ${response.statusCode}');
        // Revert the status change if the update fails
        setState(() {
          bottomSheetStatus =
              newStatus == 'Delivered' ? 'Out for Delivery' : 'Delivered';
        });
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      // Revert the status change if there's an error
      setState(() {
        bottomSheetStatus =
            newStatus == 'Delivered' ? 'Out for Delivery' : 'Delivered';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'User Products Order',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                )
              : orderItems.isEmpty
                  ? const Center(
                      child: Text('No items found'),
                    )
                  : Container(
                      margin: const EdgeInsets.only(
                        top: 24,
                        left: 24,
                        right: 24,
                        bottom: 60,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: orderItems.length,
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index == 0)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Order details',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${orderItems.length}',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            currentStatus,
                                            style: TextStyle(
                                              color: Color(0xffdb3022),
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Divider(height: 1, color: Colors.grey),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Product Details
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              // Product Image
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        item['thumbnail']),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['title'],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Price and Quantity
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    'Price',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Text(
                                                    '\$${item['price'].toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Column(
                                                children: [
                                                  Text(
                                                    'Qty',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Text(
                                                    '${item['quantity']}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Column(
                                                children: [
                                                  Text(
                                                    'Total Price',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Text(
                                                    '\$${item['price'] * item['quantity']}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      bottomSheet: GestureDetector(
        onTap: () {
          updatedStatus();
        },
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Center(
            child: Text(
              bottomSheetStatus,
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
