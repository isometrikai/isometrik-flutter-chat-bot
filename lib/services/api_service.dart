import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/services/auth_service.dart';
import 'package:chat_bot/data/services/comprehensive_api_service.dart';
import 'package:chat_bot/utils/api_result.dart';

import '../data/model/greeting_response.dart';

class ApiService {
  static Future<void> initialize() async {
    await AuthService.instance.initialize();
    await ComprehensiveApiService.instance.initialize();
  }

  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    required String name,
    required String timestamp,
    String? location,
    double? longitude,
    double? latitude,
  }) {
    // Configure AuthService (legacy support)
    AuthService.instance.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
      isProduction: isProduction,
      userId: userId,
      name: name,
      timestamp: timestamp,
      location: location,
      longitude: longitude,
      latitude: latitude,
    );

    // Configure ComprehensiveApiService (new system)
    ComprehensiveApiService.instance.configure(
      chatBotId: chatBotId,
      userId: userId,
      name: name,
      timestamp: timestamp,
      location: location,
      longitude: longitude,
      latitude: latitude,
    );
  }

  // ==================== LEGACY METHODS (for backward compatibility) ====================

  static Future<MyGPTsResponse?> getChatbotData() =>
      ComprehensiveApiService.instance.getChatbotData();

  static Future<GreetingResponse?> getInitialOptionData() =>
      ComprehensiveApiService.instance.getInitialOptionData();

  static Future<ChatResponse?> sendChatMessage({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
  }) =>
      ComprehensiveApiService.instance.sendChatMessage(
        message: message,
        agentId: agentId,
        fingerPrintId: fingerPrintId,
        sessionId: sessionId,
        isLoggedIn: isLoggedIn,
        longitude: longitude,
        latitude: latitude,
      );

  static bool get isProduction => AuthService.instance.isProduction;

  // ==================== NEW COMPREHENSIVE API METHODS ====================

  /// Get comprehensive API service instance
  static ComprehensiveApiService get comprehensive => ComprehensiveApiService.instance;

  /// Force refresh token
  static Future<bool> forceRefreshToken() => ComprehensiveApiService.instance.forceRefreshToken();

  /// Clear stored data
  static Future<void> clearStoredData() => ComprehensiveApiService.instance.clearStoredData();

  /// Get current token
  static String? get currentToken => ComprehensiveApiService.instance.currentToken;

  /// Check if token is available
  static bool get hasToken => ComprehensiveApiService.instance.hasToken;

  // ==================== USER MANAGEMENT APIs ====================

  /// Verify phone number change OTP
  static Future<ApiResult> verifyChangePhoneOtp({
    required String currentPhoneNumber,
    required String newPhoneNumber,
    required String countryCode,
    required String otp,
  }) => ComprehensiveApiService.instance.verifyChangePhoneOtp(
    currentPhoneNumber: currentPhoneNumber,
    newPhoneNumber: newPhoneNumber,
    countryCode: countryCode,
    otp: otp,
  );

  /// Get user profile
  static Future<ApiResult> getUserProfile() => ComprehensiveApiService.instance.getUserProfile();

  /// Update user profile
  static Future<ApiResult> updateUserProfile(Map<String, dynamic> profileData) =>
      ComprehensiveApiService.instance.updateUserProfile(profileData);

  // ==================== STORE & PRODUCT APIs ====================

  /// Get stores list
  static Future<ApiResult> getStores({Map<String, String>? queryParameters}) =>
      ComprehensiveApiService.instance.getStores(queryParameters: queryParameters);

  /// Get store details
  static Future<ApiResult> getStoreDetails(String storeId) =>
      ComprehensiveApiService.instance.getStoreDetails(storeId);

  /// Get products list
  static Future<ApiResult> getProducts({Map<String, String>? queryParameters}) =>
      ComprehensiveApiService.instance.getProducts(queryParameters: queryParameters);

  /// Get product details
  static Future<ApiResult> getProductDetails(String productId) =>
      ComprehensiveApiService.instance.getProductDetails(productId);

  // ==================== ORDER APIs ====================

  /// Create order
  static Future<ApiResult> createOrder(Map<String, dynamic> orderData) =>
      ComprehensiveApiService.instance.createOrder(orderData);

  /// Get order details
  static Future<ApiResult> getOrderDetails(String orderId) =>
      ComprehensiveApiService.instance.getOrderDetails(orderId);

  /// Update order status
  static Future<ApiResult> updateOrderStatus(String orderId, String status) =>
      ComprehensiveApiService.instance.updateOrderStatus(orderId, status);

  /// Get user orders
  static Future<ApiResult> getUserOrders({Map<String, String>? queryParameters}) =>
      ComprehensiveApiService.instance.getUserOrders(queryParameters: queryParameters);

  // ==================== PAYMENT APIs ====================

  /// Process payment
  static Future<ApiResult> processPayment(Map<String, dynamic> paymentData) =>
      ComprehensiveApiService.instance.processPayment(paymentData);

  /// Get payment status
  static Future<ApiResult> getPaymentStatus(String paymentId) =>
      ComprehensiveApiService.instance.getPaymentStatus(paymentId);

  // ==================== NOTIFICATION APIs ====================

  /// Send push notification
  static Future<ApiResult> sendPushNotification(Map<String, dynamic> notificationData) =>
      ComprehensiveApiService.instance.sendPushNotification(notificationData);

  /// Get notifications
  static Future<ApiResult> getNotifications({Map<String, String>? queryParameters}) =>
      ComprehensiveApiService.instance.getNotifications(queryParameters: queryParameters);

  // ==================== ANALYTICS APIs ====================

  /// Track user event
  static Future<ApiResult> trackEvent(Map<String, dynamic> eventData) =>
      ComprehensiveApiService.instance.trackEvent(eventData);

  /// Get analytics data
  static Future<ApiResult> getAnalytics({Map<String, String>? queryParameters}) =>
      ComprehensiveApiService.instance.getAnalytics(queryParameters: queryParameters);
}


