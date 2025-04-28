import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class ProductListScreen extends StatelessWidget {
  final ProductController _controller = Get.find<ProductController>();

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.loadProducts,
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          itemCount: _controller.products.length,
          itemBuilder: (context, index) {
            final product = _controller.products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Switch(
                value: product.isAvailable,
                onChanged: (value) {
                  _controller.saveProduct(
                    product.copyWith(isAvailable: value),
                  );
                },
              ),
              onTap: () => _controller.editProduct(product),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}