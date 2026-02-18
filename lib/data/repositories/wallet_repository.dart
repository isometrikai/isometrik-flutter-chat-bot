import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/member_points_response.dart';
import 'package:chat_bot/data/model/wallet_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

/// Repository for GET /v1/wallet and GET /v1/zinrelo/member/points (eazylife APIs).
/// Uses same base URL and headers as other app APIs (appClient).
class WalletRepository {
  WalletRepository({ApiClient? apiClient})
      : _client = apiClient ?? UniversalApiClient.instance.appClient;

  final ApiClient _client;

  static const String _walletEndpoint = '/v1/wallet';
  static const String _memberPointsEndpoint = '/v1/zinrelo/member/points';

  /// GET wallet for user. [userId] and [userType] (e.g. customer) required by API.
  Future<ApiResult> fetchWallet({
    required String userId,
    String userType = 'customer',
  }) async {
    final result = await _client.get(
      _walletEndpoint,
      queryParameters: {
        'userId': userId,
        'userType': userType,
      },
    );

    if (!result.isSuccess) {
      return ApiResult.error(result.message ?? 'Failed to load wallet');
    }

    final data = result.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.error('Invalid wallet response');
    }

    try {
      final parsed = WalletResponse.fromJson(data);
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.error('Parse error: $e');
    }
  }

  /// GET Zinrelo member points. No loader; same headers as wallet.
  Future<ApiResult> fetchMemberPoints() async {
    final result = await _client.get(_memberPointsEndpoint);
    if (!result.isSuccess) {
      return ApiResult.error(result.message ?? 'Failed to load points');
    }
    final data = result.data;
    if (data is! Map<String, dynamic>) {
      return ApiResult.error('Invalid points response');
    }
    try {
      final parsed = MemberPointsResponse.fromJson(data);
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.error('Parse error: $e');
    }
  }
}
