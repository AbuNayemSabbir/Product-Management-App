import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../repositories/product_repository.dart';
import '../../core/utils/connectivity_utils.dart';

class SyncService extends GetxService {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final ConnectivityUtils _connectivity = Get.find<ConnectivityUtils>();
  final RxBool isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSync();
  }

  void _initSync() {
    // Listen for connectivity changes
    ever(_connectivity.isConnected, (isConnected) {
      if (isConnected) {
        // When connection is restored, sync data
        syncData();
      }
    });

    // Also listen for manual sync triggers
    GetStorage().listenKey('pending_operations', (value) {
      if (value != null && _connectivity.isConnected.value) {
        syncData();
      }
    });
  }

  Future<void> syncData() async {
    if (_connectivity.isConnected.value && !isSyncing.value) {
      try {
        isSyncing.value = true;
        
        // First sync pending operations
        await _productRepository.syncPendingOperations();
        
        // Then refresh products from server
        await _productRepository.getProducts();
        
        // Update last sync time
        GetStorage().write('last_sync_time', DateTime.now().toIso8601String());
        
      } catch (e) {
        Get.snackbar('Sync Error', 'Failed to sync data with server: ${e.toString()}');
      } finally {
        isSyncing.value = false;
      }
    }
  }
}