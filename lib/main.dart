import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo/core/network/api_provider.dart';
import 'core/network/dio_client.dart';
import 'core/storage/local_storage.dart';
import 'core/utils/connectivity_utils.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/sync_service.dart';
import 'modules/product/controllers/product_controller.dart';
import 'modules/product/views/product_list_screen.dart';
import 'modules/product/views/product_form_screen.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
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
    // Core
    Get.lazyPut(() => DioClient());
    Get.lazyPut(() => LocalStorage());
    Get.put(ConnectivityUtils(), permanent: true);
    
    // Services
    Get.lazyPut(() => ApiProvider());
    
    // Repositories - initialize before services that depend on them
    Get.put(ProductRepository(), permanent: true);
    
    // Services that depend on repositories
    Get.put(SyncService(), permanent: true);
    
    // Controllers
    Get.lazyPut(() => ProductController());
    
    // Initialize connectivity
    Get.find<ConnectivityUtils>().initialize();
  }
}