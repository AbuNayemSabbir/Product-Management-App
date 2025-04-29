import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo/modules/product/controllers/product_controller.dart';

import '../../core/utils/connectivity_utils.dart';

class SyncService extends GetxService {

  final ConnectivityUtils _connectivity = Get.find<ConnectivityUtils>();
  final RxBool isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSync();
  }

  void _initSync() {
    ever(_connectivity.isConnected, (isConnected) {
      if (isConnected) {
        syncData();
      }
    });

    GetStorage().listenKey('pending_operations', (value) {
      if (value != null && _connectivity.isConnected.value) {
        syncData();
      }
    });
  }

  Future<void> syncData() async {
    final productController = Get.find<ProductController>();
    await productController.syncPendingOperations();
    await productController.loadProducts();
  }
}
