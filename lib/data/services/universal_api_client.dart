import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/utils/api_result.dart';

/// Universal API client that automatically handles token refresh for all APIs
class UniversalApiClient {
  UniversalApiClient._internal();
  static final UniversalApiClient instance = UniversalApiClient._internal();

  late final ApiClient _serviceClient = ApiClient(
    baseUrl: 'https://service-apis.isometrik.io',
    buildHeaders: _buildHeaders,
    onUnauthorizedRefresh: _handleTokenRefresh,
  );

  late final ApiClient _chatClient = ApiClient(
    baseUrl: 'https://easyagentapi.isometrik.ai',
    buildHeaders: _buildAppHeaders,//_buildHeaders,
    // onUnauthorizedRefresh: _handleTokenRefresh,
  );

  late final ApiClient _appClient = ApiClient(
    baseUrl: 'https://apisuperapp-staging.eazy-online.com',
    buildHeaders: _buildAppHeaders,
  );

  late final ApiClient _groceryClient = ApiClient(
    baseUrl: 'https://apisuperapp-staging.eazy-online.com',
    buildHeaders: _buildGroceryHeaders,
  );

  /// Build headers with current token
  Future<Map<String, String>> _buildHeaders() async {
    final token = TokenManager.instance.authorizationHeader;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
    };
  }

  Future<Map<String, String>> _buildAppHeaders() async {
    final token = TokenManager.instance.userToken;
    return {
    'currencycode':'AED',
    // 'Content-Length':'391',
    'Content-Type':'application/json',
    'language':'en',
    'lan':'en',
    'currencysymbol': '2K8u2KU=',
    'platform':'1',
    'ipAddress':'192.168.1.3',
      'Authorization': token ?? '',
    };
  }

  /// Build headers specifically for grocery API calls
  Future<Map<String, String>> _buildGroceryHeaders() async {
    final token = TokenManager.instance.userToken;
    return {
      'currencysymbol': '2K8u2KU=',
      'storeId': '', // Default storeId, will be overridden
      'Authorization': token ?? '',
      'storeType': '8',
      'ipAddress': '192.168.5.105',
      'platform': '1',
      'language': 'en',
      'currencycode': 'AED',
      'skip': '0',
      'cityId': '5df7b7218798dc2c1114e6bf',
      'size': '5',
      'storeCategoryId': '',
    };
  }

  /// Build grocery headers with dynamic storeId
  Future<Map<String, String>> buildGroceryHeadersWithStoreId(String storeId, String storeCategoryId) async {
    final token = TokenManager.instance.userToken;
    return {
      'currencysymbol': '2K8u2KU=',
      'storeId': storeId,
      'Authorization': '$token',
      'storeType': '8',
      'ipAddress': '192.168.5.105',
      'platform': '1',
      'language': 'en',
      'currencycode': 'AED',
      'skip': '0',
      'cityId': '5df7b7218798dc2c1114e6bf',
      'size': '5',
      'storeCategoryId': storeCategoryId,
    };
  }

  /// Handle token refresh when unauthorized
  Future<bool> _handleTokenRefresh() async {
    return await TokenManager.instance.refreshToken();
  }

  /// Get service API client (for isometrik.io APIs)
  ApiClient get serviceClient => _serviceClient;

  /// Get chat API client (for easyagentapi.isometrik.ai APIs)
  ApiClient get chatClient => _chatClient;

  ApiClient get appClient => _appClient;

  /// Get grocery API client (for grocery-specific APIs)
  ApiClient get groceryClient => _groceryClient;

  /// Create a custom API client for any base URL
  ApiClient createClient(String baseUrl) {
    return ApiClient(
      baseUrl: baseUrl,
      buildHeaders: _buildHeaders,
      onUnauthorizedRefresh: _handleTokenRefresh,
    );
  }

  /// Make a GET request with custom headers
  Future<ApiResult> getWithCustomHeaders(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? customHeaders,
  }) async {
    // Create a custom client with the specific headers
    final client = ApiClient(
      baseUrl: 'https://apisuperapp-staging.eazy-online.com',
      buildHeaders: () async => customHeaders ?? {},
    );
    
    return await client.get(endpoint, queryParameters: queryParameters);
  }
}
