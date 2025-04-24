import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:new_admin_panel/config/endpoints.dart';
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

  // double _scale = 1;
  Map<int, double> _hoveredScales = {};
  bool isUpdateProduct = false;

  @override
  void initState() {
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          cursorColor:
                              isDarkMode ? Colors.white : Color(0xffdb3022),
                          controller: productsSearchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black, // White text in dark mode
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            hoverColor: Colors.transparent,
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : productsSearch.isEmpty
                          ? Center(
                              child: Text(
                                'Products Not Found !!!',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
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
                                _hoveredScales.putIfAbsent(index, () => 1.0);
                                final product = productsSearch[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    thumbnailController.text =
                                        product['thumbnail'];
                                    titleController.text = product['title'];
                                    descriptionController.text =
                                        product['description'];
                                    priceController.text =
                                        product['price'].toString();
                                    stockController.text =
                                        product['stock'].toString();
                                    categoryController.text =
                                        product['category'];
                                    selectedIndex = selectedIndex == index
                                        ? null // Deselect if already selected
                                        : index; // Set selected index to the tapped card
                                    selectedIndex == null
                                        ? clearFields()
                                        : null;
                                    editIndex = index;
                                    setState(() {});
                                  },
                                  child: Card(
                                    color: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: selectedIndex == index
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    elevation: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              // color: Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: Center(
                                              child: MouseRegion(
                                                onEnter: (_) => setState(() =>
                                                    _hoveredScales[index] =
                                                        1.1), // Zoom in on hover
                                                onExit: (_) => setState(() =>
                                                    _hoveredScales[index] =
                                                        1.0), // Reset on exit
                                                child: TweenAnimationBuilder(
                                                  tween: Tween<double>(
                                                      begin: 1.0,
                                                      end: _hoveredScales[
                                                          index]),
                                                  duration: Duration(
                                                      milliseconds: 400),
                                                  builder:
                                                      (context, scale, child) {
                                                    return Transform.scale(
                                                      scale: scale,
                                                      child: child,
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Optional: rounded corners
                                                    child: Image.network(
                                                      height: 190.0,
                                                      product['thumbnail'] ??
                                                          '', // Replace with the product image URL
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
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
    final url = Uri.parse(EndPoints.getAllProductsEndPoint);

    final response = await http.get(url);
    final listResponse = jsonDecode(response.body);
    products = listResponse;
    setState(() {});
  }

  Widget temp() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isUpdateProduct ? 0.5 : 1,
          child: Container(
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
                        cursorColor:
                            isDarkMode ? Colors.white : Color(0xffdb3022),
                        controller: thumbnailController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            // This is the updated part
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.red,
                            ),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 12,
                          ),
                          hintText: 'Thumbnail URL',
                          labelText: 'Product Thumbnail URL',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        cursorColor:
                            isDarkMode ? Colors.white : Color(0xffdb3022),
                        controller: titleController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          focusedBorder: OutlineInputBorder(
                            // This is the updated part
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.red,
                            ),
                          ),
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
                        cursorColor:
                            isDarkMode ? Colors.white : Color(0xffdb3022),
                        controller: descriptionController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          focusedBorder: OutlineInputBorder(
                            // This is the updated part
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.red,
                            ),
                          ),
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
                        cursorColor:
                            isDarkMode ? Colors.white : Color(0xffdb3022),
                        controller: priceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ), // Numeric keyboard with decimal
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ), // Allow digits and one decimal point
                        ],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          focusedBorder: OutlineInputBorder(
                            // This is the updated part
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.red,
                            ),
                          ),
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
                        cursorColor:
                            isDarkMode ? Colors.white : Color(0xffdb3022),
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          focusedBorder: OutlineInputBorder(
                            // This is the updated part
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.red,
                            ),
                          ),
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
                        cursorColor:
                            isDarkMode ? Colors.white : Color(0xffdb3022),
                        controller: categoryController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          focusedBorder: OutlineInputBorder(
                            // This is the updated part
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.red,
                            ),
                          ),
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
                              backgroundColor: isDarkMode
                                  ? Colors.black87
                                  : Color(0xffdb3022),
                              minimumSize: const Size(50, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Optional: Rounded corners
                              ),
                            ),
                            icon: const Icon(
                              size: 16,
                              Icons.cancel,
                            ),
                            label: const Text(
                              'Clear',
                              style: TextStyle(),
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
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(
                                      child: Text(
                                        'Please Select Card to Update the Product Details',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? Colors.black87
                                  : Color(0xffdb3022),
                              minimumSize: const Size(50, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Optional: Rounded corners
                              ),
                            ),
                            icon: const Icon(
                              size: 16,
                              Icons.edit,
                            ),
                            label: const Text(
                              'Update Product',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isUpdateProduct) CircularProgressIndicator()
      ],
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

    setState(() {
      isUpdateProduct = true;
    });

    try {
      final response = await http.patch(
        Uri.parse('${EndPoints.getAllProductsEndPoint}/$id'),
        body: jsonEncode(updatedProduct),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('Product updated successfully');

        setState(() {
          isUpdateProduct = false;
        });

        getProducts(); // Fetch updated product list

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('Product updated successfully!'),
            ),
          ),
        );
      } else {
        throw Exception('Failed to update product');
      }
    } catch (error) {
      debugPrint('Error updating product: $error');

      setState(() {
        isUpdateProduct = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Failed to update product.'),
          ),
        ),
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
}
