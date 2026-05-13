import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/user_preference_request.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

/// Repository for user preference API: POST, GET, PATCH /v1/userPreference
class UserPreferenceRepository {
  UserPreferenceRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.userPreferenceClient;

  final ApiClient _client;

  static const String _endpoint = '/v1/userPreference';

  /// POST user preference (create or full replace) - pass body as per API; only send what user selected.
  Future<ApiResult> postUserPreference(UserPreferenceRequest request) async {
    return _client.post(_endpoint, request.toJson());
  }

  /// POST with raw map (e.g. when building from form)
  Future<ApiResult> postUserPreferenceMap(Map<String, dynamic> body) async {
    return _client.post(_endpoint, body);
  }

  /// GET user preference (for pre-filling form or PATCH later)
  Future<ApiResult> getUserPreference() async {
    return _client.get(_endpoint);
  }

  /// PATCH user preference (partial update)
  Future<ApiResult> patchUserPreference(UserPreferenceRequest request) async {
    return _client.patch(_endpoint, request.toJson());
  }

  /// PATCH with raw map
  Future<ApiResult> patchUserPreferenceMap(Map<String, dynamic> body) async {
    return _client.patch(_endpoint, body);
  }
}
