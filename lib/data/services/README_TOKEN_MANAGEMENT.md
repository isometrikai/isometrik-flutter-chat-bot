# 🔐 Comprehensive Token Management System

This document describes the new centralized token management system that automatically handles token refresh for all APIs in your Flutter chatbot application.

## 🎯 Overview

The new system provides:
- ✅ **Automatic token refresh** for all API calls
- ✅ **Centralized token management** across all services
- ✅ **Backward compatibility** with existing code
- ✅ **Comprehensive API coverage** for all endpoints
- ✅ **Deduplication** of refresh requests
- ✅ **Persistent storage** of tokens
- ✅ **Error handling** and retry logic

## 🏗️ Architecture

### Core Components

1. **`TokenManager`** - Centralized token management
2. **`UniversalApiClient`** - Universal API client with token refresh
3. **`ComprehensiveApiService`** - Complete API service with all endpoints
4. **`ApiService`** - Updated service with backward compatibility

### Flow Diagram

```
API Call → ApiClient → Check Token → Unauthorized? → TokenManager.refreshToken() → Retry API Call
                ↓              ↓              ↓                    ↓                    ↓
            Success         Valid Token   401/400/406         New Token           Success
```

## 🚀 Quick Start

### 1. Configuration

```dart
// Configure the API service (same as before)
ApiService.configure(
  chatBotId: '1476',
  appSecret: 'your-app-secret',
  licenseKey: 'your-license-key',
  isProduction: false,
  userId: 'user-123',
  name: 'John Doe',
  timestamp: '2024-01-01T00:00:00Z',
  location: 'Dubai',
  longitude: 55.2708,
  latitude: 25.2048,
);

// Initialize (now handles both legacy and new systems)
await ApiService.initialize();
```

### 2. Using Existing Methods (No Changes Required)

```dart
// These methods automatically handle token refresh
final chatbotData = await ApiService.getChatbotData();
final greetingData = await ApiService.getInitialOptionData();

final chatResponse = await ApiService.sendChatMessage(
  message: "Hello!",
  agentId: "67a9df239dbfc422720f19b5",
  fingerPrintId: "device-123",
  sessionId: "session-456",
);
```

### 3. Using New Comprehensive APIs

```dart
// User management
final profile = await ApiService.getUserProfile();
final updateResult = await ApiService.updateUserProfile({'name': 'New Name'});

// Store and products
final stores = await ApiService.getStores(queryParameters: {'category': 'restaurant'});
final products = await ApiService.getProducts(queryParameters: {'store_id': 'store-123'});

// Orders
final order = await ApiService.createOrder(orderData);
final orderDetails = await ApiService.getOrderDetails('order-123');

// Payments
final payment = await ApiService.processPayment(paymentData);
final paymentStatus = await ApiService.getPaymentStatus('payment-123');

// Notifications
final notification = await ApiService.sendPushNotification(notificationData);
final notifications = await ApiService.getNotifications();

// Analytics
final event = await ApiService.trackEvent(eventData);
final analytics = await ApiService.getAnalytics();
```

## 🔧 Token Management

### Automatic Refresh

Tokens are automatically refreshed when:
- Status code `401` (Unauthorized)
- Status code `400` with "Token Not found" message
- Status code `406` with "Token Expired" message

### Manual Token Management

```dart
// Check if token is available
if (ApiService.hasToken) {
  print('Token available');
}

// Force refresh token
final success = await ApiService.forceRefreshToken();

// Get current token (for debugging)
final token = ApiService.currentToken;

// Clear stored data (logout)
await ApiService.clearStoredData();
```

## 📋 Available APIs

### Chatbot APIs
- `getChatbotData()` - Get MyGPTs chatbot data
- `getInitialOptionData()` - Get greeting/options data
- `sendChatMessage()` - Send chat message

### User Management APIs
- `getUserProfile()` - Get user profile
- `updateUserProfile()` - Update user profile
- `verifyChangePhoneOtp()` - Verify phone number change OTP

### Store & Product APIs
- `getStores()` - Get stores list
- `getStoreDetails()` - Get store details
- `getProducts()` - Get products list
- `getProductDetails()` - Get product details

### Order APIs
- `createOrder()` - Create new order
- `getOrderDetails()` - Get order details
- `updateOrderStatus()` - Update order status
- `getUserOrders()` - Get user orders

### Payment APIs
- `processPayment()` - Process payment
- `getPaymentStatus()` - Get payment status

### Notification APIs
- `sendPushNotification()` - Send push notification
- `getNotifications()` - Get notifications

### Analytics APIs
- `trackEvent()` - Track user event
- `getAnalytics()` - Get analytics data

## 🔄 Error Handling

### Automatic Retry Logic

```dart
try {
  final result = await ApiService.getUserProfile();
  
  if (result.isSuccess) {
    print('Success: ${result.data}');
  } else if (result.isUnauthorized) {
    print('Unauthorized - token refresh attempted automatically');
  } else {
    print('Error: ${result.message}');
  }
} catch (e) {
  print('Exception: $e');
}
```

### Response Types

All API methods return `ApiResult` with:
- `isSuccess` - Whether the request succeeded
- `isUnauthorized` - Whether the request failed due to token issues
- `message` - Error message if failed
- `data` - Response data if successful

## 🛠️ Advanced Usage

### Using Comprehensive Service Directly

```dart
final comprehensive = ApiService.comprehensive;

// All methods automatically handle token refresh
final chatbotData = await comprehensive.getChatbotData();
final stores = await comprehensive.getStores();
final orders = await comprehensive.getUserOrders();

// Create custom client for different base URL
final customClient = comprehensive.createCustomClient('https://api.example.com');
```

### Custom API Client

```dart
// Create custom API client for any base URL
final customClient = UniversalApiClient.instance.createClient('https://api.example.com');

// Use custom client for API calls
final result = await customClient.get('/custom/endpoint');
```

## 🔍 Debugging

### Token Refresh Logs

The system logs token refresh activities:
```
🔄 Refreshing authentication token...
✅ Token refresh successful
🔄 Token expired, attempting refresh...
🔄 Token refreshed, retrying request...
```

### API Request Logs

All API requests are logged with curl commands for debugging:
```
API Request -> GET https://service-apis.isometrik.io/v1/guest/mygpts?id=1476
Headers: {"Content-Type":"application/json","Authorization":"Bearer <token>"}
cURL: curl -X GET 'https://service-apis.isometrik.io/v1/guest/mygpts?id=1476' -H 'Content-Type: application/json' -H 'Authorization: Bearer <token>'
```

## 🔒 Security Features

### Token Storage
- Tokens are stored securely in SharedPreferences
- Automatic cleanup on logout
- No hardcoded tokens in code

### Deduplication
- Multiple simultaneous requests don't trigger multiple token refreshes
- Single refresh request serves all waiting requests

### Error Handling
- Graceful handling of network errors
- Timeout protection (120 seconds)
- Fallback mechanisms

## 📱 Migration Guide

### From Old System

**No changes required!** All existing code continues to work:

```dart
// This still works exactly the same
final chatbotData = await ApiService.getChatbotData();
final chatResponse = await ApiService.sendChatMessage(...);
```

### To New System

Optionally use the new comprehensive APIs:

```dart
// Instead of custom API calls, use built-in methods
final stores = await ApiService.getStores();
final orders = await ApiService.getUserOrders();
final profile = await ApiService.getUserProfile();
```

## 🧪 Testing

### Test Token Refresh

```dart
// Force token refresh to test the system
final success = await ApiService.forceRefreshToken();
print('Token refresh: ${success ? 'Success' : 'Failed'}');
```

### Test API Calls

```dart
// Test various API endpoints
final results = await Future.wait([
  ApiService.getChatbotData(),
  ApiService.getUserProfile(),
  ApiService.getStores(),
]);

// Check if all succeeded
final allSuccess = results.every((result) => result != null);
print('All APIs working: $allSuccess');
```

## 🚨 Troubleshooting

### Common Issues

1. **Token Not Found (400)**
   - System automatically refreshes token
   - Check if app secret and license key are correct

2. **Token Expired (406)**
   - System automatically refreshes token
   - Check token refresh endpoint configuration

3. **Network Errors**
   - Check internet connectivity
   - Verify API endpoints are accessible

4. **Configuration Errors**
   - Ensure all required parameters are provided
   - Check app secret and license key format

### Debug Steps

1. Check logs for token refresh messages
2. Verify API configuration
3. Test token refresh manually
4. Check network connectivity
5. Verify API endpoints are correct

## 📞 Support

For issues or questions:
1. Check the logs for error messages
2. Verify configuration parameters
3. Test with the provided examples
4. Review the troubleshooting section

---

**Note**: This system provides automatic token refresh for all APIs. You don't need to handle token expiration manually in your application code.
