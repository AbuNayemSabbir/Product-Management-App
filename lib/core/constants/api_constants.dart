class ApiConstants {
  static const String baseUrl = 'https://stg-zero.propertyproplus.com.au/api';
  static const String authenticate = '$baseUrl/TokenAuth/Authenticate';
  static const String getAllProducts = '$baseUrl/services/app/ProductSync/GetAllproduct';
  static const String createOrEditProduct = '$baseUrl/services/app/ProductSync/CreateOrEdit';
  
  static const String tenantId = '10';
  static const String abpTenantIdHeader = 'Abp.TenantId';
  static const String authorizationHeader = 'Authorization';
}