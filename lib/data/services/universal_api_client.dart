import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/token_manager.dart';

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
    buildHeaders: _buildHeaders,
    onUnauthorizedRefresh: _handleTokenRefresh,
  );

  /// Build headers with current token
  Future<Map<String, String>> _buildHeaders() async {
    final token = TokenManager.instance.authorizationHeader;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
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

  /// Create a custom API client for any base URL
  ApiClient createClient(String baseUrl) {
    return ApiClient(
      baseUrl: baseUrl,
      buildHeaders: _buildHeaders,
      onUnauthorizedRefresh: _handleTokenRefresh,
    );
  }
}
