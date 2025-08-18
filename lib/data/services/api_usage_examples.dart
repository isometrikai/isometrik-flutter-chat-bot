import 'package:chat_bot/services/api_service.dart';
import 'package:chat_bot/utils/api_result.dart';

/// Examples of how to use the comprehensive API service with automatic token refresh
class ApiUsageExamples {
  
  /// Example 1: Basic chatbot functionality (existing methods work as before)
  static Future<void> basicChatbotExample() async {
    // These methods automatically handle token refresh
    final chatbotData = await ApiService.getChatbotData();
    final greetingData = await ApiService.getInitialOptionData();
    
    final chatResponse = await ApiService.sendChatMessage(
      message: "Hello, how can you help me?",
      agentId: "67a9df239dbfc422720f19b5",
      fingerPrintId: "device-123",
      sessionId: "session-456",
    );
  }

  /// Example 2: User management APIs
  static Future<void> userManagementExample() async {
    // Get user profile
    final profileResult = await ApiService.getUserProfile();
    if (profileResult.isSuccess) {
      print('User profile: ${profileResult.data}');
    }

    // Update user profile
    final updateResult = await ApiService.updateUserProfile({
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
    });
    
    if (updateResult.isSuccess) {
      print('Profile updated successfully');
    }

    // Verify phone number change
    final otpResult = await ApiService.verifyChangePhoneOtp(
      currentPhoneNumber: '+1234567890',
      newPhoneNumber: '+0987654321',
      countryCode: '+1',
      otp: '123456',
    );
  }

  /// Example 3: Store and product APIs
  static Future<void> storeAndProductExample() async {
    // Get stores list
    final storesResult = await ApiService.getStores(
      queryParameters: {
        'category': 'restaurant',
        'location': 'dubai',
        'limit': '10',
      },
    );
    
    if (storesResult.isSuccess) {
      print('Stores: ${storesResult.data}');
    }

    // Get store details
    final storeDetailsResult = await ApiService.getStoreDetails('store-123');
    if (storeDetailsResult.isSuccess) {
      print('Store details: ${storeDetailsResult.data}');
    }

    // Get products
    final productsResult = await ApiService.getProducts(
      queryParameters: {
        'store_id': 'store-123',
        'category': 'food',
        'limit': '20',
      },
    );
    
    if (productsResult.isSuccess) {
      print('Products: ${productsResult.data}');
    }
  }

  /// Example 4: Order management APIs
  static Future<void> orderManagementExample() async {
    // Create order
    final createOrderResult = await ApiService.createOrder({
      'store_id': 'store-123',
      'items': [
        {
          'product_id': 'product-456',
          'quantity': 2,
          'price': 25.99,
        }
      ],
      'delivery_address': {
        'street': '123 Main St',
        'city': 'Dubai',
        'postal_code': '12345',
      },
      'payment_method': 'card',
    });
    
    if (createOrderResult.isSuccess) {
      final orderId = createOrderResult.data['order_id'];
      
      // Get order details
      final orderDetailsResult = await ApiService.getOrderDetails(orderId);
      if (orderDetailsResult.isSuccess) {
        print('Order details: ${orderDetailsResult.data}');
      }
      
      // Update order status
      final updateStatusResult = await ApiService.updateOrderStatus(orderId, 'confirmed');
      if (updateStatusResult.isSuccess) {
        print('Order status updated');
      }
    }

    // Get user orders
    final userOrdersResult = await ApiService.getUserOrders(
      queryParameters: {
        'status': 'active',
        'limit': '10',
      },
    );
    
    if (userOrdersResult.isSuccess) {
      print('User orders: ${userOrdersResult.data}');
    }
  }

  /// Example 5: Payment APIs
  static Future<void> paymentExample() async {
    // Process payment
    final paymentResult = await ApiService.processPayment({
      'order_id': 'order-123',
      'amount': 25.99,
      'currency': 'USD',
      'payment_method': 'card',
      'card_token': 'tok_123456789',
    });
    
    if (paymentResult.isSuccess) {
      final paymentId = paymentResult.data['payment_id'];
      
      // Check payment status
      final statusResult = await ApiService.getPaymentStatus(paymentId);
      if (statusResult.isSuccess) {
        print('Payment status: ${statusResult.data}');
      }
    }
  }

  /// Example 6: Notification APIs
  static Future<void> notificationExample() async {
    // Send push notification
    final notificationResult = await ApiService.sendPushNotification({
      'user_id': 'user-123',
      'title': 'Order Update',
      'body': 'Your order has been confirmed!',
      'data': {
        'order_id': 'order-123',
        'type': 'order_update',
      },
    });
    
    if (notificationResult.isSuccess) {
      print('Notification sent successfully');
    }

    // Get notifications
    final notificationsResult = await ApiService.getNotifications(
      queryParameters: {
        'user_id': 'user-123',
        'limit': '20',
      },
    );
    
    if (notificationsResult.isSuccess) {
      print('Notifications: ${notificationsResult.data}');
    }
  }

  /// Example 7: Analytics APIs
  static Future<void> analyticsExample() async {
    // Track user event
    final eventResult = await ApiService.trackEvent({
      'user_id': 'user-123',
      'event_type': 'product_view',
      'event_data': {
        'product_id': 'product-456',
        'category': 'food',
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
    
    if (eventResult.isSuccess) {
      print('Event tracked successfully');
    }

    // Get analytics data
    final analyticsResult = await ApiService.getAnalytics(
      queryParameters: {
        'user_id': 'user-123',
        'date_from': '2024-01-01',
        'date_to': '2024-12-31',
        'metrics': 'orders,revenue,products_viewed',
      },
    );
    
    if (analyticsResult.isSuccess) {
      print('Analytics data: ${analyticsResult.data}');
    }
  }

  /// Example 8: Token management
  static Future<void> tokenManagementExample() async {
    // Check if token is available
    if (ApiService.hasToken) {
      print('Token is available');
    } else {
      print('No token available');
    }

    // Force refresh token
    final refreshResult = await ApiService.forceRefreshToken();
    if (refreshResult) {
      print('Token refreshed successfully');
    } else {
      print('Token refresh failed');
    }

    // Get current token (for debugging)
    final currentToken = ApiService.currentToken;
    print('Current token: ${currentToken?.substring(0, 20)}...');

    // Clear stored data (logout)
    await ApiService.clearStoredData();
    print('Stored data cleared');
  }

  /// Example 9: Error handling
  static Future<void> errorHandlingExample() async {
    try {
      final result = await ApiService.getUserProfile();
      
      if (result.isSuccess) {
        print('Success: ${result.data}');
      } else if (result.isUnauthorized) {
        print('Unauthorized - token refresh should have been attempted automatically');
      } else {
        print('Error: ${result.message}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  /// Example 10: Using comprehensive API service directly
  static Future<void> comprehensiveServiceExample() async {
    final comprehensive = ApiService.comprehensive;
    
    // All methods automatically handle token refresh
    final chatbotData = await comprehensive.getChatbotData();
    final stores = await comprehensive.getStores();
    final orders = await comprehensive.getUserOrders();
    
    // Create custom client for different base URL
    final customClient = comprehensive.createCustomClient('https://api.example.com');
    // Use customClient for API calls to different domain
  }
}
