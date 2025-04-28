import 'package:get_storage/get_storage.dart';

class LocalStorage {
  final GetStorage _box = GetStorage();

  static const String _productsKey = 'products';
  static const String _pendingOperationsKey = 'pending_operations';

  Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    await _box.write(_productsKey, products);
  }

  List<Map<String, dynamic>> getProducts() {
    final products = _box.read<List<dynamic>>(_productsKey);
    if (products != null) {
      return products.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> addPendingOperation(Map<String, dynamic> operation) async {
    final operations = getPendingOperations();
    operations.add(operation);
    await _box.write(_pendingOperationsKey, operations);
  }

  List<Map<String, dynamic>> getPendingOperations() {
    final operations = _box.read<List<dynamic>>(_pendingOperationsKey);
    if (operations != null) {
      return operations.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> clearPendingOperations() async {
    await _box.remove(_pendingOperationsKey);
  }
}
