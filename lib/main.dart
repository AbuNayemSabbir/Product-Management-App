import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo/core/network/api_provider.dart';

import 'core/constants/theme_constants.dart';
import 'core/network/dio_client.dart';
import 'core/storage/local_storage.dart';
import 'core/utils/connectivity_utils.dart';
import 'data/services/sync_service.dart';
import 'modules/product/controllers/product_controller.dart';
import 'modules/product/views/product_form_screen.dart';
import 'modules/product/views/product_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Management',
      theme: AppTheme.lightTheme,
      initialBinding: AppBindings(),
      getPages: [
        GetPage(name: '/', page: () => ProductListScreen()),
        GetPage(name: '/product/form', page: () => ProductFormScreen()),
      ],
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DioClient());
    Get.lazyPut(() => LocalStorage());
    Get.put(ConnectivityUtils(), permanent: true);
    
    Get.lazyPut(() => ApiProvider());
    Get.lazyPut(() => SyncService(), fenix: true);
    Get.lazyPut(() => ProductController(), fenix: true);
    
    Get.find<ConnectivityUtils>().initialize();
  }
}
