import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/core/constants/api_constants.dart';
import 'package:todo/core/constants/theme_constants.dart';
import 'package:todo/data/models/product_model.dart';
import '../controllers/product_controller.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final ProductController _controller = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _isAvailable = false.obs;

  @override
  void initState() {
    super.initState();
    final product = Get.arguments as Product?;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _isAvailable.value = product.isAvailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(Get.arguments?.id == null ? 'Add Product' : 'Edit Product'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Product Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: const Icon(Icons.inventory),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: AppColors.primary.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: AppColors.primary.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product description';
                    }
                    return null;
                  },
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Obx(() => CheckboxListTile(
                      title: const Text('Product Available'),
                      subtitle: const Text('Check if product is in stock'),
                      value: _isAvailable.value,
                      onChanged: (value) => _isAvailable.value = value ?? false,
                      activeColor: Colors.teal,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    )),
                  ),
                ),
                const SizedBox(height: 40),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: _controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SAVE PRODUCT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: (Get.arguments as Product?)?.id,
        tenantId: int.parse(ApiConstants.tenantId),
        name: _nameController.text,
        description: _descriptionController.text,
        isAvailable: _isAvailable.value,
      );
      _controller.saveProduct(product);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}