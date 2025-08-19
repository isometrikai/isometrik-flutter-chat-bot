import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

/// Comprehensive API service that provides easy access to all APIs with automatic token refresh
class ComprehensiveApiService {
  ComprehensiveApiService._internal();
  static final ComprehensiveApiService instance = ComprehensiveApiService._internal();

  // Configuration
  String _chatBotId = '';
  String? _userId;
  String? _name;
  String? _timestamp;
  String? _userToken;
  String? _location;
  double? _longitude;
  double? _latitude;

  // API Clients
  late final ApiClient _serviceClient = UniversalApiClient.instance.serviceClient;
  late final ApiClient _chatClient = UniversalApiClient.instance.chatClient;
  late final ApiClient _appClient = UniversalApiClient.instance.appClient;

  /// Configure the API service
  void configure({
    required String chatBotId,
    required String userId,
    required String name,
    required String timestamp,
    required String userToken,
    String? location,
    double? longitude,
    double? latitude,
  }) {
    _chatBotId = chatBotId;
    _userId = userId;
    _name = name;
    _timestamp = timestamp;
    _location = location;
    _longitude = longitude;
    _latitude = latitude;
  }

  /// Initialize the API service
  Future<void> initialize() async {
    await TokenManager.instance.initialize();
  }

  // ==================== CHATBOT APIs ====================

  /// Get chatbot data from MyGPTs API
  Future<MyGPTsResponse?> getChatbotData() async {
    final res = await _serviceClient.get(
      '/v1/guest/mygpts',
      queryParameters: {'id': _chatBotId},
    );
    if (res.isSuccess && res.data != null) {
      try {
        return MyGPTsResponse.fromJson(res.data as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get initial greeting/options data
  Future<GreetingResponse?> getInitialOptionData() async {
    final res = await _chatClient.get(
      '/v2/home-screen',
      queryParameters: {
        'username': _name ?? '',
        'timestamp': _timestamp ?? '',
        'location': _location ?? '',
      },
    );
    if (res.isSuccess && res.data != null) {
      try {
        return GreetingResponse.fromJson(res.data as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Send chat message
  Future<ChatResponse?> sendChatMessage({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
  }) async {
    final body = {
      'user_id': _userId,
      'device_id': fingerPrintId,
      'query': message,
      'session_id': sessionId,
      'location': {
        'latitude': (latitude == 0.0 ? (_latitude ?? 0.0) : latitude).toString(),
        'longitude': (longitude == 0.0 ? (_longitude ?? 0.0) : longitude).toString(),
      },
      'user_data': {
        'name': _name ?? '',
        'timestamp': _timestamp ?? '',
        'location': _location ?? '',
      }
    };
    
    final res = await _chatClient.post('/v2/chatbot', body);
    if (res.isSuccess && res.data != null) {
      try {
        return ChatResponse.fromJson(res.data as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<ChatResponse?> addToCart({
    required String storeId,
    required int cartType,
    required int action,
    required String storeCategoryId,
    required int newQuantity,
    required int storeTypeId,
    required String productId,
    required String centralProductId,

  }) async {
    final body = {
      "offers": {},
      "storeId": storeId,
      "cartType": cartType,
      "action": action,
      "deliveryAddressId": "",
      "storeCategoryId": storeCategoryId,
      "newQuantity": newQuantity,
      "unitId": "",
      "userType": 1,
      "storeTypeId": storeTypeId,
      "productId": productId,
      "centralProductId": centralProductId
    };

    final res = await _appClient.post('/v1/cart', body);
    if (res.isSuccess && res.data != null) {
      try {
        return ChatResponse.fromJson(res.data as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // ==================== USER MANAGEMENT APIs ====================

  /// Verify phone number change OTP
  Future<ApiResult> verifyChangePhoneOtp({
    required String currentPhoneNumber,
    required String newPhoneNumber,
    required String countryCode,
    required String otp,
  }) {
    return _serviceClient.post(
      '/api/v1/users/change-phone-verify',
      {
        'current_phone_number': currentPhoneNumber,
        'new_phone_number': newPhoneNumber,
        'country_code': countryCode,
        'otp': otp,
      },
    );
  }

  /// Get user profile
  Future<ApiResult> getUserProfile() {
    return _serviceClient.get('/api/v1/users/profile');
  }

  /// Update user profile
  Future<ApiResult> updateUserProfile(Map<String, dynamic> profileData) {
    return _serviceClient.put('/api/v1/users/profile', body: profileData);
  }

  // ==================== STORE & PRODUCT APIs ====================

  /// Get stores list
  Future<ApiResult> getStores({
    Map<String, String>? queryParameters,
  }) {
    return _serviceClient.get(
      '/api/v1/stores',
      queryParameters: queryParameters,
    );
  }

  /// Get store details
  Future<ApiResult> getStoreDetails(String storeId) {
    return _serviceClient.get('/api/v1/stores/$storeId');
  }

  /// Get products list
  Future<ApiResult> getProducts({
    Map<String, String>? queryParameters,
  }) {
    return _serviceClient.get(
      '/api/v1/products',
      queryParameters: queryParameters,
    );
  }

  /// Get product details
  Future<ApiResult> getProductDetails(String productId) {
    return _serviceClient.get('/api/v1/products/$productId');
  }

  // ==================== ORDER APIs ====================

  /// Create order
  Future<ApiResult> createOrder(Map<String, dynamic> orderData) {
    return _serviceClient.post('/api/v1/orders', orderData);
  }

  /// Get order details
  Future<ApiResult> getOrderDetails(String orderId) {
    return _serviceClient.get('/api/v1/orders/$orderId');
  }

  /// Update order status
  Future<ApiResult> updateOrderStatus(String orderId, String status) {
    return _serviceClient.patch('/api/v1/orders/$orderId', {
      'status': status,
    });
  }

  /// Get user orders
  Future<ApiResult> getUserOrders({
    Map<String, String>? queryParameters,
  }) {
    return _serviceClient.get(
      '/api/v1/orders',
      queryParameters: queryParameters,
    );
  }

  // ==================== PAYMENT APIs ====================

  /// Process payment
  Future<ApiResult> processPayment(Map<String, dynamic> paymentData) {
    return _serviceClient.post('/api/v1/payments', paymentData);
  }

  /// Get payment status
  Future<ApiResult> getPaymentStatus(String paymentId) {
    return _serviceClient.get('/api/v1/payments/$paymentId');
  }

  // ==================== NOTIFICATION APIs ====================

  /// Send push notification
  Future<ApiResult> sendPushNotification(Map<String, dynamic> notificationData) {
    return _serviceClient.post('/api/v1/notifications/push', notificationData);
  }

  /// Get notifications
  Future<ApiResult> getNotifications({
    Map<String, String>? queryParameters,
  }) {
    return _serviceClient.get(
      '/api/v1/notifications',
      queryParameters: queryParameters,
    );
  }

  // ==================== ANALYTICS APIs ====================

  /// Track user event
  Future<ApiResult> trackEvent(Map<String, dynamic> eventData) {
    return _serviceClient.post('/api/v1/analytics/events', eventData);
  }

  /// Get analytics data
  Future<ApiResult> getAnalytics({
    Map<String, String>? queryParameters,
  }) {
    return _serviceClient.get(
      '/api/v1/analytics',
      queryParameters: queryParameters,
    );
  }

  // ==================== UTILITY METHODS ====================

  /// Create custom API client for any base URL
  ApiClient createCustomClient(String baseUrl) {
    return UniversalApiClient.instance.createClient(baseUrl);
  }

  /// Force refresh token
  Future<bool> forceRefreshToken() async {
    return await TokenManager.instance.forceRefreshToken();
  }

  /// Clear stored data
  Future<void> clearStoredData() async {
    await TokenManager.instance.clearToken();
  }

  /// Get current token
  String? get currentToken => TokenManager.instance.currentToken;

  /// Check if token is available
  bool get hasToken => TokenManager.instance.hasToken;
}
