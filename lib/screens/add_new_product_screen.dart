import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({super.key});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  int selectedImage = 0;
  List<Uint8List?> listImages = [];
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        listImages.add(bytes);
      });
    } else {
      // Show error if no image selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final newProductTitleController = TextEditingController();
  final newProductDescriptionController = TextEditingController();
  final newProductStockController = TextEditingController();
  final newProductCategoryController = TextEditingController();
  final newProductShippingInformationController = TextEditingController();
  final newProductAvailabilityStatusController = TextEditingController();
  final newProductReturnPolicyController = TextEditingController();
  final newProductMinimumOrderQtyController = TextEditingController();
  final newProductBrandController = TextEditingController();
  final newProductWarrantyController = TextEditingController();
  final newProductPriceController = TextEditingController();
  final newProductDiscountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'New Product',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xffDB3022),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ElevatedButton(
              onPressed: () async {
                await postNewProductData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xffDB3022),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Add New Product',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Form Section
            Expanded(
              flex: 3,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'General Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: newProductTitleController,
                        label: 'Product Name',
                        hintText: 'Enter name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: newProductDescriptionController,
                        label: 'Product Description',
                        hintText: 'Enter description',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: newProductStockController,
                              label: 'Stock',
                              hintText: 'Enter stock',
                              isDigitsOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: newProductCategoryController,
                              label: 'Category',
                              hintText: 'Enter category',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Shipping Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                controller:
                                    newProductShippingInformationController,
                                label: 'Shipping Information',
                                hintText: 'Enter shipping information'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                                controller:
                                    newProductAvailabilityStatusController,
                                label: 'Availability Status',
                                hintText: 'Enter availability status'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                controller: newProductReturnPolicyController,
                                label: 'Return Policy',
                                hintText: 'Enter return policy'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: newProductMinimumOrderQtyController,
                              label: 'Minimum Order Quantity',
                              hintText: 'Enter minimum order quantity',
                              isDigitsOnly: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      const Text(
                        'Brand Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                                controller: newProductBrandController,
                                label: 'Brand',
                                hintText: 'Enter brand'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                                controller: newProductWarrantyController,
                                label: 'Warranty',
                                hintText: 'Enter warranty'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      const Text(
                        'Pricing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: newProductPriceController,
                              label: 'Price',
                              hintText: 'Enter price',
                              isFloatingPointOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: newProductDiscountController,
                              label: 'Discount (%)',
                              hintText: 'Enter discount',
                              isFloatingPointOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Right Image Section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Images',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Container(
                          child: listImages.isNotEmpty &&
                                  listImages[selectedImage] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.memory(
                                    listImages[selectedImage]!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    'No Image Selected',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: listImages.isNotEmpty &&
                                      listImages[selectedImage] != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            // Add button on the left
                            InkWell(
                              onTap: () {
                                _pickImage(); // Function to pick images
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                ),
                                child: Icon(Icons.add, size: 30),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    10), // Add some spacing between the button and the images
                            // ListView for the images
                            Expanded(
                              child: SizedBox(
                                height: 80, // Fixed height for the ListView
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: listImages.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedImage = index;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: index == selectedImage
                                                ? Colors.black
                                                : Colors.grey,
                                            width: 2,
                                          ),
                                        ),
                                        child: listImages[index] != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.memory(
                                                  listImages[index]!,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    Widget? suffix,
    bool isDigitsOnly = false,
    bool isFloatingPointOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isDigitsOnly
              ? TextInputType.number
              : isFloatingPointOnly
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
          inputFormatters: [
            if (isDigitsOnly) FilteringTextInputFormatter.digitsOnly,
            if (isFloatingPointOnly)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (isFloatingPointOnly && double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            if (isDigitsOnly && int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
// Check Database auto increament id

  Future<void> postNewProductData() async {
    final supabase = Supabase.instance.client;
    final url = Uri.parse('http://localhost:3000/productss');

    List<String> imagesList = []; // Store uploaded image URLs

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if images are uploaded
    if (listImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (var i = 0; i < listImages.length; i++) {
      Uint8List imageBytes = listImages[i]!;
      String base64Image = base64Encode(imageBytes);
      String hashedBase64 = sha256.convert(utf8.encode(base64Image)).toString();

      String imageName = 'product_$hashedBase64.jpg';

      try {
        // Upload image to Supabase Storage
        await supabase.storage.from('new_product_images').uploadBinary(
              imageName,
              imageBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Get public URL
        String imageUrl =
            supabase.storage.from('new_product_images').getPublicUrl(imageName);
        imagesList.add(imageUrl); // Store URL in the list

        debugPrint('imageUrl : $imageUrl');
      } catch (e) {
        debugPrint('Error uploading image $i: $e');
      }
    }

    debugPrint('Uploaded Images List: $imagesList');

    final addData = {
      'title': newProductTitleController.text,
      'description': newProductDescriptionController.text,
      'category': newProductCategoryController.text,
      'price': double.tryParse(newProductPriceController.text) ?? 0.0,
      'discountpercentage':
          double.tryParse(newProductDiscountController.text) ?? 0.0,
      'rating': 0.0,
      'stock': int.tryParse(newProductStockController.text) ?? 0,
      'brand': newProductBrandController.text,
      'warrantyinformation': newProductWarrantyController.text,
      'shippinginformation': newProductShippingInformationController.text,
      'availabilitystatus': newProductAvailabilityStatusController.text,
      'returnpolicy': newProductReturnPolicyController.text,
      'minimumorderquantity':
          int.tryParse(newProductMinimumOrderQtyController.text) ?? 1,
      'images': imagesList, // 🔹 Sending the list of image URLs
      'thumbnail': imagesList.isNotEmpty
          ? imagesList.first
          : '', // Set the first image as thumbnail
    };

    // Send Data to Backend
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(addData),
      );

      debugPrint('Response PRODUCT: ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('Product added successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.red,
          ),
        );
        clearTextFields();
      } else {
        debugPrint(
            'Failed to add product. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Error occurred: $error');
    }
  }

  void clearTextFields() {
    newProductTitleController.clear();
    newProductDescriptionController.clear();
    newProductCategoryController.clear();
    newProductPriceController.clear();
    newProductDiscountController.clear();
    newProductStockController.clear();
    newProductBrandController.clear();
    newProductWarrantyController.clear();
    newProductShippingInformationController.clear();
    newProductAvailabilityStatusController.clear();
    newProductReturnPolicyController.clear();
    newProductMinimumOrderQtyController.clear();
    listImages.clear();
    setState(() {});
  }

  // Future<void> postNewProductData() async {
  //   final supabase = Supabase.instance.client;
  //   final url = Uri.parse('http://localhost:3000/product');

  //   // Convert image to Base64 (optional for hashing)
  //   String base64Image = base64Encode(listImages.first!);
  //   String hashedBase64 = sha256.convert(utf8.encode(base64Image)).toString();
  //   debugPrint('Hashed Base64: $hashedBase64');

  //   // 🔹 Upload Image to Supabase Storage
  //   String imageName = 'product_$hashedBase64.jpg';
  //   Uint8List imageBytes = listImages.first!;

  //   await supabase.storage.from('new_product_images').uploadBinary(
  //         imageName,
  //         imageBytes,
  //         fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
  //       );

  //   // 🔹 Get the public URL
  //   final imageUrl =
  //       supabase.storage.from('new_product_images').getPublicUrl(imageName);
  //   debugPrint('Image URL: $imageUrl');

  //   // Prepare Data
  //   final addData = {
  //     'id': 197,
  //     'title': newProductTitleController.text,
  //     'description': newProductDescriptionController.text,
  //     'category': newProductCategoryController.text,
  //     'price': double.tryParse(newProductPriceController.text) ?? 0.0,
  //     'discountpercentage':
  //         double.tryParse(newProductDiscountController.text) ?? 0.0,
  //     'rating': 0.0,
  //     'stock': int.tryParse(newProductStockController.text) ?? 0,
  //     'brand': newProductBrandController.text,
  //     'warrantyinformation': newProductWarrantyController.text,
  //     'shippinginformation': newProductShippingInformationController.text,
  //     'availabilitystatus': newProductAvailabilityStatusController.text,
  //     'returnpolicy': newProductReturnPolicyController.text,
  //     'minimumorderquantity':
  //         int.tryParse(newProductMinimumOrderQtyController.text) ?? 1,
  //     'images' : ,
  //     'thumbnail': imageUrl, // 🔹 Sending Image URL instead of Base64

  //   };

  //   // 🔹 Send Data to Backend
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(addData),
  //     );

  //     debugPrint('Response PRODUCT: ${response.body}');

  //     if (response.statusCode == 201) {
  //       debugPrint('Product added successfully!');
  //     } else {
  //       debugPrint(
  //           'Failed to add product. Status code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     debugPrint('Error occurred: $error');
  //   }
  // }

  // Future<void> postNewProductData() async {
  //   final url = Uri.parse('http://localhost:3000/product');

  //   String base64Image = base64Encode(listImages.first!);
  //   String hashedBase64 = sha256.convert(utf8.encode(base64Image)).toString();
  //   debugPrint('Hashed Base64: $hashedBase64');

  //   final addData = {
  //     'id': 196,
  //     'title': newProductTitleController.text,
  //     'description': newProductDescriptionController.text,
  //     'category': newProductCategoryController.text,
  //     'price': double.tryParse(newProductPriceController.text) ?? 0.0,
  //     'discountpercentage':
  //         double.tryParse(newProductDiscountController.text) ?? 0.0,
  //     'rating': 0.0,
  //     'stock': int.tryParse(newProductStockController.text) ?? 0,
  //     'brand': newProductBrandController.text,
  //     'warrantyinformation': newProductWarrantyController.text,
  //     'shippinginformation': newProductShippingInformationController.text,
  //     'availabilitystatus': newProductAvailabilityStatusController.text,
  //     'returnpolicy': newProductReturnPolicyController.text,
  //     'minimumorderquantity':
  //         int.tryParse(newProductMinimumOrderQtyController.text) ?? 1,
  //     'thumbnail': 'previewBase64Image',
  //   };

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(addData),
  //     );

  //     debugPrint('Response PRODUCT: ${response.body}');

  //     if (response.statusCode == 201) {
  //       debugPrint('Product added successfully!');
  //     } else {
  //       debugPrint(
  //           'Failed to add product. Status code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     debugPrint('Error occurred: $error');
  //   }
  // }
}
