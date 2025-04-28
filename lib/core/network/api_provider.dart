import 'package:get/get.dart';
import 'dio_client.dart';
import '../constants/api_constants.dart';

class ApiProvider {
  final DioClient _dioClient = Get.find<DioClient>();
  String? _accessToken;

  Future<void> authenticate() async {
    try {
      final response = await _dioClient.post(
        ApiConstants.authenticate,
        data: {
          "userNameOrEmailAddress": "samad",
          "password": "1234",
        },
      );
      _accessToken = response.data['result']['accessToken'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAllProducts() async {
    if (_accessToken == null) {
      await authenticate();
    }
    final response = await _dioClient.get(
      ApiConstants.getAllProducts,
      accessToken: _accessToken,
    );
    return response.data;
  }

  Future<dynamic> createOrEditProduct(Map<String, dynamic> product) async {
    if (_accessToken == null) {
      await authenticate();
    }
    final response = await _dioClient.post(
      ApiConstants.createOrEditProduct,
      data: product,
      accessToken: _accessToken,
    );
    return response.data;
  }
}