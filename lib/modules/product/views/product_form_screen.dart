import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/core/constants/api_constants.dart';
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
        title: Text(Get.arguments?.id == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              Obx(() => SwitchListTile(
                title: const Text('Available'),
                value: _isAvailable.value,
                onChanged: (value) => _isAvailable.value = value,
              )),
              const SizedBox(height: 20),
              Obx(() => _controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveProduct,
                      child: const Text('Save Product'),
                    )),
            ],
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