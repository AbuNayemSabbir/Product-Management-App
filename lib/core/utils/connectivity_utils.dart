import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityUtils extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = false.obs;

  Future<void> initialize() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = results.any((result) => result != ConnectivityResult.none);
    
    if (isConnected.value != connected) {
      isConnected.value = connected;
      if (connected) {
        Get.snackbar('Network', 'You are online');
      } else {
        Get.snackbar('Network', 'You are offline');
      }
    }
  }
}