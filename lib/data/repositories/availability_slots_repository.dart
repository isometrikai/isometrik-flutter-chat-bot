import 'package:chat_bot/data/model/availability_slots_response.dart';
import 'package:chat_bot/data/services/token_manager.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/utility.dart';

class AvailabilitySlotsRepository {
  const AvailabilitySlotsRepository();

  Future<List<AvailabilitySlot>> fetchAvailabilitySlots({
    required String date, // Format: MM/dd/yyyy
    required String userId,
    required String storeCategoryId,
    String eventType = 'teleCallAvgMin',
    String timeZone = 'Asia/Kolkata',
  }) async {
    // Build headers with storeCategoryId
    final token = Utility.getUserToken();
    final headers = <String, String>{
      'User-Agent': 'Eazy Life/2.0.1 (com.eazy.customerapp; build:77; iOS 26.1.0) Alamofire/5.6.1',
      'Authorization': token,
      'language': Utility.getLanguage(),
      'storeCategoryId': storeCategoryId,
      'Accept-Encoding': 'br;q=1.0, gzip;q=0.9, deflate;q=0.8',
      'Accept-Language': 'en-IN;q=1.0, it-IN;q=0.9',
      'Content-Type': 'application/json',
    };

    final Map<String, String> queryParams = {
      'date': date,
      'eventType': eventType,
      'timeZone': timeZone,
      'userId': userId,
    };

    // Use UniversalApiClient's getWithCustomHeaders method
    final res = await UniversalApiClient.instance.getWithCustomHeaders(
      '/v1/availability/slots',
      queryParameters: queryParams,
      customHeaders: headers,
    );

    if (!res.isSuccess || res.data == null) {
      throw Exception(res.message ?? '');
    }

    final AvailabilitySlotsResponse parsed = AvailabilitySlotsResponse.fromJson(
      res.data as Map<String, dynamic>,
    );
    
    // Filter to only return available slots
    return parsed.data.where((slot) => slot.isAvailable).toList();
  }
}

