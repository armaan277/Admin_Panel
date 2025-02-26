import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:new_admin_panel/screens/user_reviews_screen.dart';

class GroupCardsScreen extends StatefulWidget {
  const GroupCardsScreen({super.key});

  @override
  State<GroupCardsScreen> createState() => _GroupCardsScreenState();
}

class _GroupCardsScreenState extends State<GroupCardsScreen> {
  List products = [];
  List reviews = [];
  bool isReviewLoaded = true;

  @override
  void initState() {
    getProducts();
    getReviewData();
    super.initState();
  }

  double calculateReviews(int productId) {
    final productReviews =
        reviews.where((review) => review['product_id'] == productId).toList();
    debugPrint('productReviews : $productReviews');

    if (productReviews.isEmpty) {
      return 0.0; // Return 0.0 if there are no reviews
    }

    final totalRating = productReviews.fold(0.0, (sum, review) {
      final rating = review['rating'];
      debugPrint('rating : $rating');
      return sum + (rating is int ? rating.toDouble() : rating);
    });

    final averageRating = totalRating / productReviews.length;
    debugPrint('Product ID: $productId, Average Rating: $averageRating');
    return averageRating;
  }

  List demo(int id) {
    return reviews.where((product) => product['product_id'] == id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isReviewLoaded
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    if (demo(products[index]['id']).isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).canvasColor,
                              blurRadius: 0.2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    child: Image.network(
                                      products[index]['thumbnail'] ?? '',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          products[index]['title'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: 700,
                                          child: AutoSizeText(
                                            textAlign: TextAlign.justify,
                                            products[index]['description'] ??
                                                '',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return UserReviewsScreen(
                                              id: products[index]['id'],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Color(0xffffffff).withOpacity(0.1)
                                            : Color(0xffDB3022)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'See All Reviews (${demo(products[index]['id']).length})',
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Color(0xffffffff)
                                              : Color(0xffDB3022),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'RATING:',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          RatingBarIndicator(
                                            rating: calculateReviews(
                                              products[index]['id'],
                                            ),
                                            itemBuilder: (context, index) =>
                                                Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5, // Max rating value
                                            itemSize: 22.0, // Star size
                                            direction: Axis
                                                .horizontal, // Horizontal layout
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  void getProducts() async {
    final url = Uri.parse('https://ecommerce-rendered.onrender.com/products');
    final response = await http.get(url);
    final listResponse = jsonDecode(response.body);
    products = listResponse;
    isReviewLoaded = false;
    setState(() {});
  }

  Future<void> getReviewData() async {
    try {
      // Construct the API URL
      final url = Uri.parse('https://ecommerce-rendered.onrender.com/reviews');

      // Send GET request
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the response body
        final reviewsResponse = jsonDecode(response.body);
        reviews = reviewsResponse;
        isReviewLoaded = false;
        setState(() {});
        debugPrint('Reviews: $reviews'); // Debugging log
      } else if (response.statusCode == 404) {
        reviews = [];
        setState(() {});
      } else {
        debugPrint(
            'Failed to load reviews. Status code: ${response.statusCode}');
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e'); // Handle errors
    }
  }
}
