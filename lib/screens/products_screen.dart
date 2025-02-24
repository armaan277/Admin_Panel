import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:new_admin_panel/screens/add_new_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int? selectedIndex; // Track the selected card index
  int? editIndex;
  List products = [];

  final productsSearchController = TextEditingController();
  final thumbnailController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final categoryController = TextEditingController();

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productsSearch = productsSearchController.text.isEmpty
        ? products
        : products
            .where(
              (product) => product['title'].toString().toLowerCase().contains(
                    productsSearchController.text.toLowerCase(),
                  ),
            )
            .toList();
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: productsSearchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return AddNewProductScreen();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                      ),
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Add New Product',
                        // style: TextStyle(
                        //   color: Colors.white,
                        //   letterSpacing: 1.2,
                        // ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffdb3022),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3 / 4,
                          ),
                          itemCount: productsSearch.length,
                          itemBuilder: (context, index) {
                            final product = productsSearch[index];
                            return InkWell(
                              onTap: () {
                                thumbnailController.text = product['thumbnail'];
                                titleController.text = product['title'];
                                descriptionController.text =
                                    product['description'];
                                priceController.text =
                                    product['price'].toString();
                                stockController.text =
                                    product['stock'].toString();
                                categoryController.text = product['category'];
                                selectedIndex = selectedIndex == index
                                    ? null // Deselect if already selected
                                    : index; // Set selected index to the tapped card
                                selectedIndex == null ? clearFields() : null;
                                editIndex = index;
                                setState(() {});
                              },
                              child: Card(
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: selectedIndex == index
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                elevation: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // color: Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Center(
                                          child: Image.network(
                                            height: 190.0,
                                            product['thumbnail'] ??
                                                '', // Replace with the product image URL
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            overflow: TextOverflow.ellipsis,
                                            product['title'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$ ${product['price'] ?? 0.0}',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Stock: ${product['stock'] ?? 0}',
                                          ),
                                        ],
                                      ),
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
          ),
        ),
        Expanded(
          child: temp(),
        ),
      ],
    );
  }

  void getProducts() async {
    final url = Uri.parse('http://localhost:3000/productss');
    final response = await http.get(url);
    final listResponse = jsonDecode(response.body);
    products = listResponse;
    setState(() {});
  }

  Widget temp() {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Edit Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: thumbnailController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 12,
                    ),
                    hintText: 'Thumbnail URL',
                    labelText: 'Product Thumbnail URL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 12,
                    ),
                    hintText: 'Title',
                    labelText: 'Product Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 12,
                    ),
                    hintText: 'Description',
                    labelText: 'Product Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                  ), // Numeric keyboard with decimal
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*'),
                    ), // Allow digits and one decimal point
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 12,
                    ),
                    hintText: 'Price',
                    labelText: 'Product Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 12,
                    ),
                    hintText: 'Stock',
                    labelText: 'Product Stock',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 12,
                    ),
                    hintText: 'Category',
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        clearFields();
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        minimumSize: const Size(50, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Optional: Rounded corners
                        ),
                      ),
                      icon: const Icon(
                        color: Color(0xffdb3022),
                        size: 16,
                        Icons.cancel,
                      ),
                      label: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xffdb3022),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (editIndex != null) {
                          debugPrint(
                              'products[editIndex!]["id"] : ${products[editIndex!]['id']} ');
                          await updateProduct(
                            products[editIndex!]['id'],
                          );
                          products[editIndex!] = {
                            'thumbnail': thumbnailController.text,
                            'title': titleController.text,
                            'description': descriptionController.text,
                            'price': priceController.text,
                            'stock': stockController.text,
                            'category': categoryController.text,
                          };
                          debugPrint(
                              'products[editIndex!] : ${products[editIndex!]}');
                          clearFields();
                          debugPrint(
                              'After the Update Button is Clicked editIndex : $editIndex');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(50, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Optional: Rounded corners
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      icon: const Icon(
                        size: 16,
                        Icons.edit,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Update Product',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Update a product
  Future<void> updateProduct(int id) async {
    final Map<String, dynamic> updatedProduct = {
      "thumbnail": thumbnailController.text,
      "title": titleController.text,
      "description": descriptionController.text,
      "price": double.tryParse(priceController.text) ?? 0,
      "stock": int.tryParse(stockController.text) ?? 0,
      "category": categoryController.text,
    };

    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/product/$id'),
        body: jsonEncode(updatedProduct),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('Product updated successfully');
        getProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        throw Exception('Failed to update product');
      }
    } catch (error) {
      debugPrint('Error updating product: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product.')), // Feedback
      );
    }
  }

  void clearFields() {
    thumbnailController.clear();
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    stockController.clear();
    categoryController.clear();
    editIndex = null;
    selectedIndex = null;
    setState(() {});
  }

  // Future<void> todoUpdate(
  //   int id,
  //   String thumbnail,
  //   String newTitle,
  //   String newDescription,
  //   double price,
  //   int stock,
  //   String category,
  // ) async {
  //   final url = Uri.parse(
  //       'http://localhost:3000/product/$id'); // Use 10.0.2.2 for Android emulator

  //   final updatedTodo = jsonEncode({
  //     'thumbnail': thumbnail,
  //     'title': newTitle,
  //     'description': newDescription,
  //     'price': price,
  //     'stock': stock,
  //     'category': category,
  //   });

  //   try {
  //     final response = await http.patch(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: updatedTodo,
  //     );

  //     if (response.statusCode == 200) {
  //       debugPrint('Todo updated successfully: ${response.body}');
  //     } else {
  //       debugPrint('Failed to update Todo: ${response.statusCode}');
  //       debugPrint('Error response: ${response.body}');
  //     }
  //   } catch (e) {
  //     debugPrint('Error: $e');
  //   }
  // }
}
