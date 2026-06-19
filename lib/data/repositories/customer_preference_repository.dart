import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

/// Repository for easyagentapi customer preference endpoints.
class CustomerPreferenceRepository {
  CustomerPreferenceRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.customerPreferenceClient;

  final ApiClient _client;

  static const String _zainEndpoint = '/v1/customer/zainPersonalization';

  Future<ApiResult> patchZainPersonalization({required bool enabled}) async {
    return _client.patch(_zainEndpoint, {
      'zain_personalization': enabled,
    });
  }
}

