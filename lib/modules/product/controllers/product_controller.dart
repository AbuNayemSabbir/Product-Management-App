import 'package:get/get.dart';
import 'package:todo/core/constants/api_constants.dart';

import '../../../core/utils/connectivity_utils.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/sync_service.dart';

class ProductController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final LocalStorage _localStorage = Get.find<LocalStorage>();
  final ConnectivityUtils _connectivity = Get.find<ConnectivityUtils>();
  final SyncService _syncService = Get.find<SyncService>();
  
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isProductLoading = true.obs;

  RxBool get isOnline => _connectivity.isConnected;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void syncWithServer() {
    _syncService.syncData();
  }

  Future<List<Product>> getProducts() async {
    try {
      if (_connectivity.isConnected.value) {
        final response = await _apiProvider.getAllProducts();
        final fetchedProducts = (response).map((product) => Product.fromJson(product)).toList();

        await _localStorage.saveProducts(
          fetchedProducts.map((p) => p.toJson()).toList(),
        );

        return fetchedProducts;
      } else {
        final localProducts = _localStorage.getProducts();
        return localProducts.map((p) => Product.fromJson(p)).toList();
      }
    } catch (e) {
      rethrow;
    } finally {
      isProductLoading.value = false;
    }
  }

  Future<void> loadProducts() async {
    try {
      isProductLoading.value = true;
      final fetchedProducts = await getProducts();
      products.assignAll(fetchedProducts);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isProductLoading.value = false;
    }
  }

  Future<Product> saveProduct(Product product) async {
    try {
      isLoading.value = true;
      final productJson = product.toJson();

      if (_connectivity.isConnected.value) {
        final response = await _apiProvider.createOrEditProduct(productJson);
        final savedProduct = Product.fromJson(response);

        await _updateLocalProduct(savedProduct);

        Get.back();
        Get.snackbar('Success', 'Product saved successfully');
        return savedProduct;
      } else {
        await _localStorage.addPendingOperation({
          'type': product.id == null ? 'create' : 'update',
          'data': productJson,
        });

        await _updateLocalProduct(product);

        Get.back();
        Get.snackbar('Success', 'Product saved offline');
        return product;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: ${e.toString()}');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateLocalProduct(Product product) async {
    final fetchedProducts = await getProducts();
    final index = fetchedProducts.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      fetchedProducts[index] = product;
    } else {
      fetchedProducts.add(product);
    }

    await _localStorage.saveProducts(
      fetchedProducts.map((p) => p.toJson()).toList(),
    );
    
    final productIndex = products.indexWhere((p) => p.id == product.id);
    if (productIndex >= 0) {
      products[productIndex] = product;
    } else {
      products.add(product);
    }
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

  void editProduct(Product product) {
    Get.toNamed('/product/form', arguments: product);
  }

  void addProduct() {
    Get.toNamed('/product/form',
        arguments: Product(
          tenantId: int.parse(ApiConstants.tenantId),
          name: '',
          description: '',
          isAvailable: false,
        ));
  }
}
