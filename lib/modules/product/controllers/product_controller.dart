import 'package:get/get.dart';
import 'package:todo/core/constants/api_constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _repository = Get.find<ProductRepository>();
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add a small delay to ensure dependencies are ready
    Future.delayed(Duration(milliseconds: 100), () {
      loadProducts();
    });
  }

  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final fetchedProducts = await _repository.getProducts();
      products.assignAll(fetchedProducts);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProduct(Product product) async {
    try {
      isLoading.value = true;
      final savedProduct = await _repository.saveProduct(product);
      
      // Update the local list
      final index = products.indexWhere((p) => p.id == savedProduct.id);
      if (index >= 0) {
        products[index] = savedProduct;
      } else {
        products.add(savedProduct);
      }
      
      Get.back();
      Get.snackbar('Success', 'Product saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void editProduct(Product product) {
    Get.toNamed('/product/form', arguments: product);
  }

  void addProduct() {
    Get.toNamed('/product/form', arguments: Product(
      tenantId: int.parse(ApiConstants.tenantId),
      name: '',
      description: '',
      isAvailable: false,
    ));
  }
}