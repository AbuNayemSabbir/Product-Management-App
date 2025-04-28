import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../repositories/product_repository.dart';
import '../../core/utils/connectivity_utils.dart';

class SyncService extends GetxService {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final ConnectivityUtils _connectivity = Get.find<ConnectivityUtils>();

  @override
  void onInit() {
    super.onInit();
    _initSync();
  }

  void _initSync() {
    // Sync when connectivity changes to online
    ever(_connectivity.isConnected, (isConnected) {
      if (isConnected) {
        syncData();
      }
    });

    // Also sync periodically (every 5 minutes)
    GetStorage().listenKey('last_sync', (value) {
      syncData();
    });
  }

  Future<void> syncData() async {
    if (_connectivity.isConnected.value) {
      try {
        await _productRepository.syncPendingOperations();
        await _productRepository.getProducts(); // Refresh data from server
      } catch (e) {
        Get.snackbar('Sync Error', 'Failed to sync data with server');
      }
    }
  }
}