import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:new_admin_panel/config/endpoints.dart';

class OrdersItemsScreen extends StatefulWidget {
  final String orderItemsId;
  final String status;

  const OrdersItemsScreen({
    super.key,
    required this.orderItemsId,
    required this.status,
  });

  @override
  OrdersItemsScreenState createState() => OrdersItemsScreenState();
}

class OrdersItemsScreenState extends State<OrdersItemsScreen> {
  List<dynamic> orderItems = [];
  bool isLoading = true;
  String errorMessage = '';

  String currentStatus = '';
  String bottomSheetStatus = 'Out for Delivery';
  bool isDelivered = false; // Flag to track delivered state

  @override
  void initState() {
    super.initState();
    fetchOrderItems(widget.orderItemsId);
    getOrderStatus(widget.orderItemsId);
    // Sync isDelivered with currentStatus on init
    isDelivered = currentStatus == 'Delivered';
    debugPrint('isDelivered : $isDelivered');
    if (isDelivered) {
      bottomSheetStatus = 'Already Delivered';
    }
  }

  void fetchOrderItems(String orderIdItems) async {
    // final url = Uri.parse('https://ecommerce-rendered.onrender.com/bookingcarts/$orderIdItems');
    final url = Uri.parse("${EndPoints.bookingCartsEndPoint}/$orderIdItems");
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

  // Future<bool> updateStatusInDatabase(
  //     String orderId, String orderStatus) async {
  //   final url = Uri.parse('http://localhost:3000/orderlist/$orderId');
  //   // final url = Uri.parse('https://ecommerce-rendered.onrender.com/orderlist/$orderId');
  //   try {
  //     final response = await http.put(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'order_status': orderStatus}),
  //     );
  //     if (response.statusCode == 200) {
  //       debugPrint('orderlist response: -> ${response.body}');
  //       debugPrint('Status updated successfully: $orderStatus');
  //       return true;
  //     } else {
  //       debugPrint('Failed to update status: ${response.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint('Error updating status: $e');
  //     return false;
  //   }
  // }

  void getOrderStatus(String orderId) async {
    final url = Uri.parse('${EndPoints.orderlistStatusEndPoint}/$orderId');
    // final url = Uri.parse('http://localhost:3000/orderlist/status/$orderId');
    // final url = Uri.parse('https://ecommerce-rendered.onrender.com/status/$orderId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentStatus = data['order_status'] ?? '';
          bottomSheetStatus = currentStatus == 'Confirmed'
              ? 'Out for Delivery'
              : currentStatus == 'Out for Delivery'
                  ? 'Delivered'
                  : currentStatus == 'Delivered'
                      ? 'Already Delivered'
                      : currentStatus;
          isDelivered = currentStatus == 'Delivered';
        });
        debugPrint('Current status fetched: $currentStatus');
      } else {
        debugPrint('Failed to fetch status: ${response.statusCode}');
        setState(() {
          currentStatus = '';
          bottomSheetStatus = 'Out for Delivery';
          isDelivered = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching order status: $e');
      setState(() {
        currentStatus = '';
        bottomSheetStatus = 'Out for Delivery';
        isDelivered = false;
      });
    }
  }

  void updatedStatus() async {
    if (currentStatus == 'Delivered') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order is already Delivered!')),
      );
      return;
    }
    if (bottomSheetStatus == 'Out for Delivery') {
      setState(() {
        bottomSheetStatus = 'Delivered';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Out for Delivery !!!')),
      );
      await status(widget.orderItemsId, 'Out for Delivery');
    } else if (bottomSheetStatus == 'Delivered') {
      setState(() {
        bottomSheetStatus = 'Already Delivered';
        isDelivered = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Delivered !!!')),
      );
      await status(widget.orderItemsId, 'Delivered');
    }
  }

  Future<void> stockUpdatePost(String title, int quantity) async {
    final url = Uri.parse(EndPoints.stockUpdateEndPoint);
    // final url = Uri.parse('http://localhost:3000/stock-update');
    // final url = Uri.parse('https://ecommerce-rendered.onrender.com/stock-update');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'quantity': quantity}),
      );
      if (response.statusCode == 200) {
        debugPrint('Stock updated successfully ${response.body}');
      } else {
        final error = jsonDecode(response.body)['message'] ?? 'Update failed';
        debugPrint('Error: $error');
      }
    } catch (e) {
      debugPrint('Exception: $e');
    }
  }

  Future<void> status(String orderId, String newStatus) async {
    final url = Uri.parse('${EndPoints.orderlistEndPoint}/$orderId');

    // final url = Uri.parse('http://localhost:3000/orderlist/$orderId');
    // final url = Uri.parse('https://ecommerce-rendered.onrender.com/orderlist/$orderId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': newStatus}),
      );
      debugPrint('newStatus Response : $newStatus');
      if (response.statusCode == 200) {
        setState(() {
          currentStatus = newStatus;
          if (newStatus == 'Delivered') {
            for (var orderItem in orderItems) {
              stockUpdatePost(orderItem['title'], orderItem['quantity']);
              debugPrint('orderItems : ${orderItem['quantity']}');
            }
            debugPrint('EK API CALL KARNA HAI !!!');
            debugPrint('orderItems : $orderItems');
          }
          debugPrint('Status response : ${response.body}');
        });
      } else {
        debugPrint('Failed to update status: ${response.statusCode}');
        setState(() {
          bottomSheetStatus = newStatus == 'Delivered'
              ? 'Out for Delivery'
              : newStatus == 'Out for Delivery'
                  ? 'Delivered'
                  : bottomSheetStatus;
          isDelivered = newStatus == 'Delivered';
        });
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      setState(() {
        bottomSheetStatus = newStatus == 'Delivered'
            ? 'Out for Delivery'
            : newStatus == 'Out for Delivery'
                ? 'Delivered'
                : bottomSheetStatus;
        isDelivered = newStatus == 'Delivered';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context, currentStatus),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text('User Products Order',
            style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : orderItems.isEmpty
                  ? const Center(child: Text('No items found'))
                  : Container(
                      margin: const EdgeInsets.only(
                          top: 24, left: 24, right: 24, bottom: 60),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2))
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
                                            const Text('Order details',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                  '${orderItems.length}',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14)),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(currentStatus,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  letterSpacing: 1.5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Divider(height: 1, color: Colors.grey),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          item['thumbnail']),
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(item['title'],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Text('Price',
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  SizedBox(height: 5.0),
                                                  Text(
                                                      '\$${item['price'].toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Column(
                                                children: [
                                                  Text('Qty',
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  SizedBox(height: 5.0),
                                                  Text('${item['quantity']}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Column(
                                                children: [
                                                  Text('Total Price',
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  SizedBox(height: 5.0),
                                                  Text(
                                                      '\$${item['price'] * item['quantity']}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500)),
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
      bottomSheet: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(right: BorderSide.none, left: BorderSide.none),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
          color: isDelivered || widget.status == 'Canceled'
              ? Colors.red.shade200
              : Color(0xffdb3022),
        ),
        child: GestureDetector(
          onTap: isDelivered ? null : updatedStatus,
          child: Center(
            child: Text(
              bottomSheetStatus,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: isDelivered ? Colors.white70 : Colors.white,
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
