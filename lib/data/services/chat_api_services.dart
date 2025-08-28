import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

/// Comprehensive API service that provides easy access to all APIs with automatic token refresh
class ChatApiServices {
  ChatApiServices._internal();
  static final ChatApiServices instance = ChatApiServices._internal();

  // Configuration
  String _chatBotId = '';
  String? _userId;
  String? _name;
  String? _timestamp;
  String? _location;
  double? _longitude;
  double? _latitude;

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

    // Match existing endpoint used elsewhere
    final res = await _chatClient.post('/v2/chatbot', body);
    // final res = await _appClient.post('/v2/chatbot', body);
    // final res = await _chatClient.post('/v2/test-response', body);
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
      "centralProductId": centralProductId,
      "isMultiCart": 2
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

  ApiClient createCustomClient(String baseUrl) {
    return UniversalApiClient.instance.createClient(baseUrl);
  }

}
