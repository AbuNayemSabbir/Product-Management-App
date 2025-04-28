import 'package:get/get.dart';

import '../../core/network/api_provider.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/connectivity_utils.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorage _localStorage = Get.find<LocalStorage>();
  final ConnectivityUtils _connectivity = Get.find<ConnectivityUtils>();

  Future<List<Product>> getProducts() async {
    try {
      if (_connectivity.isConnected.value) {
        final response = await _apiProvider.getAllProducts();
        final products =
            (response).map((product) => Product.fromJson(product)).toList();

        // Save to local storage
        await _localStorage.saveProducts(
          products.map((p) => p.toJson()).toList(),
        );

        return products;
      } else {
        // Get from local storage
        final localProducts = _localStorage.getProducts();
        return localProducts.map((p) => Product.fromJson(p)).toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> saveProduct(Product product) async {
    try {
      final productJson = product.toJson();

      if (_connectivity.isConnected.value) {
        final response = await _apiProvider.createOrEditProduct(productJson);
        final savedProduct = Product.fromJson(response);

        // Update local storage
        await _updateLocalProduct(savedProduct);

        return savedProduct;
      } else {
        // Queue the operation for sync when online
        await _localStorage.addPendingOperation({
          'type': product.id == null ? 'create' : 'update',
          'data': productJson,
        });

        // Save to local storage immediately for offline use
        await _updateLocalProduct(product);

        return product;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateLocalProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      products[index] = product;
    } else {
      products.add(product);
    }

    await _localStorage.saveProducts(
      products.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> syncPendingOperations() async {
    if (!_connectivity.isConnected.value) return;

    final operations = _localStorage.getPendingOperations();
    for (final operation in operations) {
      try {
        await _apiProvider.createOrEditProduct(operation['data']);
      } catch (e) {
        continue;
      }
    }
    await _localStorage.clearPendingOperations();
  }
}
