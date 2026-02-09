import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/services/api_service.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/utility.dart';

/// Universal API client that automatically handles token refresh for all APIs
class UniversalApiClient {
  UniversalApiClient._internal();
  static final UniversalApiClient instance = UniversalApiClient._internal();

  late final ApiClient _serviceClient = ApiClient(
    baseUrl: 'https://service-apis.isometrik.io',
    buildHeaders: _buildHeaders,
    onUnauthorizedRefresh: _handleTokenRefresh,
  );

  /// Chat client - uses dynamic base URL based on isProduction flag
  ApiClient get _chatClient => ApiClient(
    baseUrl: AppConstants.chatBaseUrl,
    buildHeaders: _buildAppHeaders,//_buildHeaders,
    // onUnauthorizedRefresh: _handleTokenRefresh,
  );

  ApiClient get _appClient => ApiClient(
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildAppHeaders,
  );

  ApiClient get _groceryClient => ApiClient(
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildGroceryHeaders,
  );

  /// User preference API (eazylife): accept, authorization Bearer, language, platform 3
  ApiClient get _userPreferenceClient => ApiClient(
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildUserPreferenceHeaders,
  );

  Future<Map<String, String>> _buildUserPreferenceHeaders() async {
    final raw = TokenManager.instance.userToken ?? '';
    final token = raw.isEmpty ? '' : (raw.startsWith('Bearer ') ? raw : 'Bearer $raw');
    return {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'language': 'en',
      'platform': Utility.getPlatform().toString(),
      if (token.isNotEmpty) 'authorization': token,
    };
  }

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
      // 'Content-Length':'391',
      'Content-Type': 'application/json',
      'language': 'en',
      'lan': 'en',
      'currencysymbol': Utility.getCurrencySymbol(),//2K8u2KU=
      'currencycode': Utility.getCurrencyCode(),
      'platform': Utility.getPlatform().toString(),
      'ipAddress': '192.168.1.3',
      'Authorization': token ?? '',
    };
  }

  /// Build headers specifically for grocery API calls
  Future<Map<String, String>> _buildGroceryHeaders() async {
    final token = TokenManager.instance.userToken;
    return {
      'currencysymbol': Utility.getCurrencySymbol(),//2K8u2KU=
      'storeId': '', // Default storeId, will be overridden
      'Authorization': token ?? '',
      'storeType': '8',
      'ipAddress': '192.168.5.105',
      'platform': Utility.getPlatform().toString(),
      'language': 'en',
      'currencycode': Utility.getCurrencyCode(),//AED
      'skip': '0',
      'cityId': '5df7b7218798dc2c1114e6bf',
      'size': '5',
      'storeCategoryId': '',
    };
  }

  /// Build grocery headers with dynamic storeId
  Future<Map<String, String>> buildGroceryHeadersWithStoreId(
    String storeId,
    String storeCategoryId,
  ) async {
    final token = TokenManager.instance.userToken;
    return {
      'currencysymbol': Utility.getCurrencySymbol(),//2K8u2KU=
      'storeId': storeId,
      'Authorization': '$token',
      'storeType': '8',
      'ipAddress': '192.168.5.105',
      'platform': Utility.getPlatform().toString(),
      'language': 'en',
      'currencycode': Utility.getCurrencyCode(),//AED
      'skip': '0',
      'cityId': '5df7b7218798dc2c1114e6bf',
      'size': '5',
      'storeCategoryId': storeCategoryId,
    };
  }

  Future<Map<String, String>> buildServiceGenieHeaders({
    required String storeCategoryId,
  }) async {
    final token = TokenManager.instance.userToken;
    final headers = <String, String>{
      'User-Agent':
          'Eazy Life/2.0.1 (com.eazy.customerapp; build:64; iOS 26.0.1)',
      'Accept-Encoding': 'gzip',
      'Accept-Language': 'en-IN;q=1.0',
      'platform': Utility.getPlatform().toString(),
      'language': 'en',
      'filterType': '1',
      'logintype': '1',
      'searchType': '1',
      'storeCategoryId': storeCategoryId,
      'Accept': 'application/json',
      'currencycode': Utility.getCurrencyCode(),//AED
      'currencysymbol': Utility.getCurrencySymbol(),//2K8u2KU=
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = token;
    }

    return headers;
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

  /// Get user preference API client (POST/GET/PATCH userPreference)
  ApiClient get userPreferenceClient => _userPreferenceClient;

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
      baseUrl: ApiService.baseApiUrl,
      buildHeaders: () async => customHeaders ?? {},
    );
    
    return await client.get(endpoint, queryParameters: queryParameters);
  }
}
