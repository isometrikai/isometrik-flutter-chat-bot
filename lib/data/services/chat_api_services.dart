import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/chat_history_response.dart';
import 'package:chat_bot/data/model/customer_profile_response.dart';
import 'package:chat_bot/data/model/hawksearch_config_response.dart';
import 'package:chat_bot/data/model/session_id_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/log.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:unique_identifier/unique_identifier.dart';

/// Comprehensive API service that provides easy access to all APIs with automatic token refresh
class ChatApiServices {
  ChatApiServices._internal();
  static final ChatApiServices instance = ChatApiServices._internal();

  // Configuration
  String _chatBotId = '';
  String? _userId;
  String? _name;
  String? _timestamp;
  // String? _location;
  // double? _longitude;
  // double? _latitude;
  String? _clientGuid;
  String? _indexName;
  String? _visitId;
  String? _visitorId;
  String? _searchApiUrl;
  // String? _zoneId;
  String? _timezone;

  HawkSearchConfigData? _hawkSearchConfig;
  Future<HawkSearchConfigData?>? _hawkSearchConfigFuture;

  late final ApiClient _chatClient = UniversalApiClient.instance.chatClient;
  late final ApiClient _appClient = UniversalApiClient.instance.appClient;

  /// Configure the API service
  void configure({
    required String chatBotId,
    required String userId,
    required String name,
    required String timestamp,
    // required String userToken,
    // String? location,
    // double? longitude,
    // double? latitude,
    required String clientGuid,
    required String indexName,
    required String visitId,
    required String visitorId,
    required String searchApiUrl,
    // required String zoneId,
    required String timezone,
  }) {
    _chatBotId = chatBotId;
    _userId = userId;
    _name = name;
    _timestamp = timestamp;
    // _location = location;
    // _longitude = longitude;
    // _latitude = latitude;
    _clientGuid = clientGuid;
    _indexName = indexName;
    _visitId = visitId;
    _visitorId = visitorId;
    _searchApiUrl = searchApiUrl;
    // _zoneId = zoneId;
    _timezone = timezone;

    fetchHawkSearchConfigInBackground();
  }

  bool _isEmpty(String? value) => value == null || value.trim().isEmpty;

  bool get _needsHawkSearchConfig =>
      _isEmpty(_clientGuid) ||
      _isEmpty(_indexName) ||
      _isEmpty(_visitId) ||
      _isEmpty(_visitorId) ||
      _isEmpty(_searchApiUrl);

  String _effective(String? configured, String? fallback) {
    if (!_isEmpty(configured)) return configured!.trim();
    if (!_isEmpty(fallback)) return fallback!.trim();
    return '';
  }

  /// Fetches HawkSearch config without blocking configure.
  void fetchHawkSearchConfigInBackground() {
    if (!_needsHawkSearchConfig) return;
    _hawkSearchConfigFuture ??= _fetchHawkSearchConfig();
  }

  /// Ensures HawkSearch config is available when configured values are missing.
  Future<void> ensureHawkSearchConfigReady() async {
    if (!_needsHawkSearchConfig) return;
    await (_hawkSearchConfigFuture ??= _fetchHawkSearchConfig());
  }

  String get effectiveClientGuid =>
      _effective(_clientGuid, _hawkSearchConfig?.clientGuid);

  String get effectiveIndexName =>
      _effective(_indexName, _hawkSearchConfig?.indexName);

  String get effectiveVisitId =>
      _effective(_visitId, _hawkSearchConfig?.visitId);

  String get effectiveVisitorId =>
      _effective(_visitorId, _hawkSearchConfig?.visitorId);

  String get effectiveSearchApiUrl =>
      _effective(_searchApiUrl, _hawkSearchConfig?.searchApiUrl);

  Future<HawkSearchConfigData?> _fetchHawkSearchConfig() async {
    try {
      final res = await _appClient.get('/python/hawksearch/config');
      if (res.isSuccess && res.data is Map<String, dynamic>) {
        final response = HawkSearchConfigResponse.fromJson(
          res.data as Map<String, dynamic>,
        );
        _hawkSearchConfig = response.data;
        return _hawkSearchConfig;
      }
    } catch (e) {
      AppLog.error('Error fetching HawkSearch config: $e');
    }
    return null;
  }

  // /// Initialize the API service
  // Future<void> initialize() async {
  //   await TokenManager.instance.initialize();
  // }

  /// Get the configured userId
  String? get userId => _userId;
  
  /// Get the configured latitude
  // double? get latitude => _latitude;
  
  /// Get the configured longitude
  // double? get longitude => _longitude;

  String? get timezone => _timezone;

  Future<ChatResponse?> sendChatMessage({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    // double longitude = 0.0,
    // double latitude = 0.0,
    String staffId = "",
    String serviceRequestedTime = "",
    String storeCategoryId = "",
    List<String> prescriptionImageUrls = const [],
    Map<String, dynamic> tableBookingData = const {},
    Map<String, dynamic> hotelDestinationData = const {},
    Map<String, dynamic> carPickupData = const {},
    Map<String, dynamic> flightBookingData = const {},
    Map<String, dynamic> packageDeliveryData = const {},
  }) async {
    await ensureHawkSearchConfigReady();

    final body = {
      'user_id': _userId,
      'device_id': fingerPrintId,
      'query': message,
      'session_id': sessionId,
      'client_guid': effectiveClientGuid,
      'index_name': effectiveIndexName,
      'visit_id': effectiveVisitId,
      'visitor_id': effectiveVisitorId,
      'search_api_url': effectiveSearchApiUrl,
      'zone_id': Utility.getZoneId(),
      'location': {
        'latitude': Utility.getLatitude().toString(),
        'longitude': Utility.getLongitude().toString(),
      },
      'user_data': {
        'name': _name ?? '',
        'timestamp': _timestamp ?? '',
        'location': Utility.getLocation(),
      },
      'staff_id': staffId,
      'service_requested_time': serviceRequestedTime,
      'store_category_id': storeCategoryId,
      'prescription_image_urls': prescriptionImageUrls,
      'table_booking': tableBookingData,
      'hotel_booking': hotelDestinationData,
      'car_booking': carPickupData,
      'flight_booking': flightBookingData,
      'package_delivery': packageDeliveryData,
      'enable_personalisation': Utility.getPersonalization(),
    };

    // Match existing endpoint used elsewhere
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

  Future<SessionIdResponse?> getSessionId() async {
    final body = {
      'user_id': _userId,
      'device_id': await _getDeviceId(),
      'user_name': _name
    };

    final res = await _chatClient.post('/v2/create_session', body);
    if (res.isSuccess && res.data != null) {
      return SessionIdResponse.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }

  Future<CustomerProfileResponse?> fetchCustomerProfile() async {
    try {
      final res = await _appClient.get('/v1/customer/profile');
      if (res.isSuccess && res.data is Map<String, dynamic>) {
        return CustomerProfileResponse.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (e) {
      AppLog.error('Error fetching customer profile: $e');
    }
    return null;
  }

  Future<List<ChatHistoryDetail>> fetchChatHistory(String sessionId) async {
    final res = await _chatClient.get('/v2/history/$sessionId');
    if (res.isSuccess && res.data != null) {
      try {
        // The API returns a list of chat history items
        if (res.data is List) {
          return (res.data as List)
              .map((item) => ChatHistoryDetail.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        AppLog.error('Error parsing chat history: $e');
        return [];
      }
    }
    return [];
  }

  static Future<String> _getDeviceId() async {
    try {
      return await UniqueIdentifier.serial ?? "default-device-id";
    } catch (e) {
      return "default-device-id";
    }
  }


  /// [enableTokenRefresh] — set false for HawkSearch (no eazylife/isometrik refresh).
  ApiClient createCustomClient(
    String baseUrl, {
    bool enableTokenRefresh = true,
  }) {
    return UniversalApiClient.instance.createClient(
      baseUrl,
      enableTokenRefresh: enableTokenRefresh,
    );
  }

  /// Get order details and extract only the required fields
  Future<Map<String, dynamic>?> getOrderDetails({
    required String orderId,
    required String type,
  }) async {
    try {
      Utility.showLoader();
      final queryParams = {
        'orderId': orderId,
        'type': type,
      };

      final res = await _appClient.get('/v1/orders/details', queryParameters: queryParams);
      Utility.closeProgressDialog();
      if (res.isSuccess && res.data != null) {
        final responseData = res.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>?;
        
        if (data != null && data['storeOrders'] != null) {
          final orderType = data['orderType'] ?? -1;
          final storeOrders = data['storeOrders'] as List<dynamic>;
          if (storeOrders.isNotEmpty) {
            final storeOrder = storeOrders.first as Map<String, dynamic>;
            
            // Extract only the required 5 fields
            return {
              'storeOrderId': storeOrder['storeOrderId'] ?? '',
              'storeType': storeOrder['storeType'] ?? 0,
              'storeCategoryId': storeOrder['storeCategoryId'] ?? '',
              'orderType': orderType,
              // 'storeSubCategoryId': storeOrder['storeSubCategoryId'] ?? '',
              // 'subStoreTypeId': storeOrder['subStoreTypeId'] ?? '',
            };
          }
        }
      }
      return null;
    } catch (e) {
      AppLog.error('Error fetching order details: $e');
      Utility.closeProgressDialog();
      return null;
    }
  }

}
