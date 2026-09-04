import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/data/services/user_token_refresh_manager.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/services/api_service.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/utility.dart';

/// Universal API client that automatically handles token refresh for all APIs
class UniversalApiClient {
  UniversalApiClient._internal();
  static final UniversalApiClient instance = UniversalApiClient._internal();

  late final ApiClient _serviceClient = ApiClient(
    baseUrl: 'https://service-apis.isometrik.io',
    buildHeaders: _buildHeaders,
    onUnauthorizedRefresh: _handleIsometrikTokenRefresh,
  );

  /// Chat client - uses dynamic base URL based on isProduction flag
  ApiClient get _chatClient => ApiClient(
    baseUrl: AppConstants.chatBaseUrl,
    buildHeaders: _buildAppHeaders,//_buildHeaders,
    onUnauthorizedRefresh: _handleUserTokenRefresh,
    onTokenExpiredLogout: _handleTokenExpiredLogout,
  );

  ApiClient get _appClient => ApiClient(
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildAppHeaders,
    onUnauthorizedRefresh: _handleUserTokenRefresh,
    onTokenExpiredLogout: _handleTokenExpiredLogout,
  );

  ApiClient get _groceryClient => ApiClient(
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildGroceryHeaders,
    onUnauthorizedRefresh: _handleUserTokenRefresh,
    onTokenExpiredLogout: _handleTokenExpiredLogout,
  );

  /// User preference API (eazylife): accept, authorization Bearer, language, platform 3
  ApiClient get _userPreferenceClient => ApiClient(
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildUserPreferenceHeaders,
    onUnauthorizedRefresh: _handleUserTokenRefresh,
    onTokenExpiredLogout: _handleTokenExpiredLogout,
  );

  /// Customer preference API: PATCH /v1/customer/* with JSON `authorization` header
  ApiClient get _customerPreferenceClient => ApiClient(
    // Uses same baseApiUrl configured via ApiService.configure (e.g. https://api-stage.eazylife-online.com)
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildCustomerPreferenceHeaders,
    onUnauthorizedRefresh: _handleUserTokenRefresh,
    onTokenExpiredLogout: _handleTokenExpiredLogout,
  );

  /// Xeni hotel APIs (availability, etc.)
  ApiClient get _hotelAvailabilityClient => ApiClient(
    baseUrl: ApiService.baseApiUrl,
    buildHeaders: _buildHotelAvailabilityHeaders,
    onUnauthorizedRefresh: _handleUserTokenRefresh,
    onTokenExpiredLogout: _handleTokenExpiredLogout,
  );

  Future<Map<String, String>> _buildUserPreferenceHeaders() async {
    final raw = Utility.getUserToken();
    final token = raw.isEmpty ? '' : (raw.startsWith('Bearer ') ? raw : 'Bearer $raw');
    return {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'language': Utility.getLanguage(),
      'platform': Utility.getPlatform(),
      if (token.isNotEmpty) 'authorization': token,
    };
  }

  /// Some easyagentapi endpoints expect a JSON string in `authorization` header
  /// (not an `Authorization: Bearer ...` header). We pass through `userToken` verbatim.
  Future<Map<String, String>> _buildCustomerPreferenceHeaders() async {
    final raw = Utility.getUserToken();
    final platform = Utility.getPlatform();
    return {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'language': Utility.getLanguage(),
      'platform': platform.isNotEmpty ? platform : '3',
      if (raw.isNotEmpty) 'authorization': raw,
    };
  }

  Future<Map<String, String>> _buildHotelAvailabilityHeaders() async {
    final raw = Utility.getUserToken();
    final token = raw.isEmpty
        ? ''
        : (raw.startsWith('Bearer ') ? raw : 'Bearer $raw');
    final platform = Utility.getPlatform();
    return {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'language': Utility.getLanguage(),
      'platform': platform.isNotEmpty ? platform : '3',
      'currencysymbol': Utility.getCurrencySymbol(),
      'currencycode': Utility.getCurrencyCode(),
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
    final token = Utility.getUserToken();
    return {
      // 'Content-Length':'391',
      'Content-Type': 'application/json',
      'language': Utility.getLanguage(),
      'lan': Utility.getLanguage(),
      'currencysymbol': Utility.getCurrencySymbol(),//2K8u2KU=
      'currencycode': Utility.getCurrencyCode(),
      'platform': Utility.getPlatform(),
      'ipAddress': '192.168.1.3',
      'Authorization': token,
    };
  }

  /// Build headers specifically for grocery API calls
  Future<Map<String, String>> _buildGroceryHeaders() async {
    final token = Utility.getUserToken();
    return {
      'currencysymbol': Utility.getCurrencySymbol(),//2K8u2KU=
      'storeId': '', // Default storeId, will be overridden
      'Authorization': token,
      'storeType': '8',
      'ipAddress': '192.168.5.105',
      'platform': Utility.getPlatform(),
      'language': Utility.getLanguage(),
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
    final token = Utility.getUserToken();
    return {
      'currencysymbol': Utility.getCurrencySymbol(),//2K8u2KU=
      'storeId': storeId,
      'Authorization': token,
      'storeType': '8',
      'ipAddress': '192.168.5.105',
      'platform': Utility.getPlatform(),
      'language': Utility.getLanguage(),
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
    final token = Utility.getUserToken();
    final headers = <String, String>{
      'User-Agent':
          'Eazy Life/2.0.1 (com.eazy.customerapp; build:64; iOS 26.0.1)',
      'Accept-Encoding': 'gzip',
      'Accept-Language': 'en-IN;q=1.0',
      'platform': Utility.getPlatform(),
      'language': Utility.getLanguage(),
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

  /// Isometrik guestAuth refresh (service-apis only).
  Future<bool> _handleIsometrikTokenRefresh() async {
    return await TokenManager.instance.refreshToken();
  }

  /// Eazylife user token refresh via `/v1/generateToken` (not used by HawkSearch).
  Future<bool> _handleUserTokenRefresh() async {
    return await UserTokenRefreshManager.instance.refreshToken();
  }

  /// 401 from eazylife APIs → host app logout.
  void _handleTokenExpiredLogout() {
    OrderService().triggerSideMenuOption({'action': 'token_expired_logout'});
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

  /// Get easyagentapi customer preference client (PATCH /v1/customer/*)
  ApiClient get customerPreferenceClient => _customerPreferenceClient;

  /// Xeni hotel availability client
  ApiClient get hotelAvailabilityClient => _hotelAvailabilityClient;

  /// Create a custom API client for any base URL.
  /// [enableTokenRefresh] defaults to true for Isometrik-style clients.
  /// Pass false for HawkSearch (and any other non-eazylife/non-isometrik APIs).
  ApiClient createClient(
    String baseUrl, {
    bool enableTokenRefresh = true,
  }) {
    return ApiClient(
      baseUrl: baseUrl,
      buildHeaders: _buildHeaders,
      onUnauthorizedRefresh:
          enableTokenRefresh ? _handleIsometrikTokenRefresh : null,
    );
  }

  /// Make a GET request with custom headers
  Future<ApiResult> getWithCustomHeaders(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? customHeaders,
  }) async {
    // Create a custom client with the specific headers + eazylife refresh
    final client = ApiClient(
      baseUrl: ApiService.baseApiUrl,
      buildHeaders: () async {
        final headers = Map<String, String>.from(customHeaders ?? {});
        // Ensure Authorization uses the latest token after a refresh retry.
        final token = Utility.getUserToken();
        if (token.isNotEmpty) {
          if (headers.containsKey('Authorization')) {
            headers['Authorization'] = token;
          } else if (headers.containsKey('authorization')) {
            headers['authorization'] = token;
          }
        }
        return headers;
      },
      onUnauthorizedRefresh: _handleUserTokenRefresh,
      onTokenExpiredLogout: _handleTokenExpiredLogout,
    );
    
    return await client.get(endpoint, queryParameters: queryParameters);
  }
}
