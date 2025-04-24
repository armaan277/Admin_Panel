import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:new_admin_panel/config/endpoints.dart';

class UserReviewsScreen extends StatefulWidget {
  final int id;
  const UserReviewsScreen({
    super.key,
    required this.id,
  });

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  List reviews = [];

  @override
  void initState() {
    super.initState();
    getReviewData();
  }

  @override
  Widget build(BuildContext context) {
    // Filter reviews by the widget's id
    final filterReviews =
        reviews.where((review) => review['product_id'] == widget.id).toList();
    debugPrint('filterReviews: $filterReviews');

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
          'User Reviews',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: filterReviews.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1.2,
              ),
              itemCount: filterReviews.length,
              itemBuilder: (context, index) {
                final filterReviewsIndex = filterReviews[index];
                return IntrinsicHeight(
                  child: Container(
                    margin: EdgeInsets.only(left: 20, top: 20, right: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Star Rating
                        RatingBarIndicator(
                          rating: filterReviewsIndex['rating']
                              .toDouble(), // Assuming 'rating' field exists
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 22.0,
                          direction: Axis.horizontal,
                        ),
                        SizedBox(height: 10),
                        filterReviewsIndex['reviewer_images'] != null &&
                                filterReviewsIndex['reviewer_images'].isNotEmpty
                            ? SizedBox(
                                height: 60.0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      filterReviewsIndex['reviewer_images']
                                          .length,
                                  itemBuilder: (context, imgIndex) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Image.network(
                                          filterReviewsIndex['reviewer_images']
                                              [imgIndex],
                                          fit: BoxFit.cover,
                                          height: 60.0,
                                          width: 60.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text('NP'),

                        SizedBox(height: 10),

                        // Review Text
                        Text(
                          filterReviewsIndex['comment'] ??
                              'No comment available',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 6,
                        ),
                        const SizedBox(height: 16),
                        // Author Info
                        Row(
                          children: [
                            // Avatar (Placeholder for now)
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffDB3022), // Placeholder color
                              ),
                              child: Center(
                                child: Text(
                                  newName(
                                    filterReviewsIndex['reviewer_name'] ?? 'A',
                                  ), // Placeholder for initials
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Author Name and Date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filterReviewsIndex['reviewer_name'] ??
                                        'Anonymous',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    filterReviewsIndex['date'] ??
                                        'No date available',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> getReviewData() async {
    try {
      final url = Uri.parse(EndPoints.reviewsEndPoint);

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final reviewsResponse = jsonDecode(response.body);
        setState(() {
          reviews = reviewsResponse;
        });
        debugPrint('Reviews: $reviews');
      } else {
        debugPrint(
            'Failed to load reviews. Status code: ${response.statusCode}');
        setState(() {
          reviews = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
    }
  }

  String newName(String name) {
    String newName = name[0];

    for (int i = 0; i < name.length - 1; i++) {
      if (name[i] == ' ') {
        newName = newName + name[i + 1];
      }
    }
    return newName;
  }
}
