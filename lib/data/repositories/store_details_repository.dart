import 'package:chat_bot/data/model/store_details_response.dart';
import 'package:chat_bot/utils/api_result.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/services/api_service.dart';
import 'package:chat_bot/utils/log.dart';
import 'package:chat_bot/utils/utility.dart';

class StoreDetailsRepository {
  const StoreDetailsRepository();

  Future<StoreDetailsData> fetchStoreDetails({
    required String storeId,
    required double latitude,
    required double longitude,
    String timezone = 'Asia/Kolkata',
  }) async {
    AppLog.info('🏪 StoreDetailsRepository: Starting fetchStoreDetails');
    AppLog.info('🏪 Parameters: storeId=$storeId, lat=$latitude, long=$longitude, timezone=$timezone');
    
    // Use custom headers as per the API requirements
    final token = TokenManager.instance.userToken ?? '';
    AppLog.info('🏪 Token available: ${token.isNotEmpty ? 'Yes (${token.substring(0, token.length > 20 ? 20 : token.length)}...)' : 'No'}');
    
    final authHeader = token.isNotEmpty 
        ? (token.startsWith('Bearer ') ? token : 'Bearer $token')
        : '';
    
    final headers = {
      'Accept-Language': 'en-IN;q=1.0, it-IN;q=0.9',
      'language': 'en',
      'User-Agent': 'Eazy Life/2.0.1 (com.eazy.customerapp; build:77; iOS 26.1.0) Alamofire/5.6.1',
      'Accept-Encoding': 'br;q=1.0, gzip;q=0.9, deflate;q=0.8',
      'currencycode': Utility.getCurrencyCode(),
      'currencysymbol': Utility.getCurrencySymbol(),
      if (authHeader.isNotEmpty) 'Authorization': authHeader,
    };

    final baseUrl = ApiService.baseApiUrl;
    AppLog.info('🏪 Base URL: $baseUrl');
    
    final client = ApiClient(
      baseUrl: baseUrl,
      buildHeaders: () async => headers,
    );

    final Map<String, String> queryParams = {
      'lat': latitude.toString(),
      'long': longitude.toString(),
      's_id': storeId,
      'timezone': timezone,
    };

    AppLog.info('🏪 Making GET request to /python/store/details with params: $queryParams');
    
    final ApiResult res = await client.get(
      '/python/store/details',
      queryParameters: queryParams,
    );

    AppLog.info('🏪 API Response - Success: ${res.isSuccess}, Message: ${res.message}');

    if (!res.isSuccess || res.data == null) {
      AppLog.error('🏪 API call failed: ${res.message}');
      throw Exception(res.message ?? 'Failed to load store details');
    }

    try {
      final StoreDetailsResponse parsed = StoreDetailsResponse.fromJson(
        res.data as Map<String, dynamic>,
      );
      AppLog.info('🏪 Successfully parsed response. Timing slots: ${parsed.data.timing.length}');
      return parsed.data;
    } catch (e, stackTrace) {
      AppLog.error('🏪 Error parsing response: $e');
      AppLog.error('🏪 Stack trace: $stackTrace');
      throw Exception('Failed to parse store details: $e');
    }
  }
}

