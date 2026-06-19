import 'package:chat_bot/data/model/chat_history_response.dart';
import 'package:chat_bot/data/model/shared_session.dart';
import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';

class ChatHistoryRepository {
  static final ChatHistoryRepository _instance = ChatHistoryRepository._internal();
  static ChatHistoryRepository get instance => _instance;
  
  ChatHistoryRepository._internal();

  String userIds = '';

  // Use the same chat client that handles token management automatically
  late final ApiClient _chatClient = UniversalApiClient.instance.chatClient;

  void configure({
    required String userId,
  }) {
    userIds = userId;
  }

  Future<List<ChatHistoryResponse>> fetchChatHistory({
    int limit = 15,
    int skip = 0,
    bool? isFoodChat,
    bool? isGroceryChat,
    bool? isPharmacyChat,
    bool? isShoppingChat,
    bool? isServicesChat,
    bool? isHealthCareChat,
    bool? isDonationChat,
    String? query,
    bool? isFromArchive = false,
  }) async {
    
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };

    if (isFromArchive == true) {
      queryParams['archived_only'] = 'true';
    }else {
      queryParams['include_archived'] = 'false';
    }
    
    // Add search query if specified
    if (query != null && query.isNotEmpty) {
      queryParams['query'] = query;
    }
    
    // Add category filters if specified
    if (isFoodChat == true) {
      queryParams['is_food_chat'] = 'true';
    }
    if (isGroceryChat == true) {
      queryParams['is_grocery_chat'] = 'true';
    }
    if (isPharmacyChat == true) {
      queryParams['is_pharmacy_chat'] = 'true';
    }
    if (isShoppingChat == true) {
      queryParams['is_shopping_chat'] = 'true';
    }
    if (isServicesChat == true) {
      queryParams['is_services_chat'] = 'true';
    }
    if (isHealthCareChat == true) {
      queryParams['is_health_care_chat'] = 'true';
    }
    if (isDonationChat == true) {
      queryParams['is_donation_chat'] = 'true';
    }
    
    try {
      // Use ApiClient which automatically handles token management
      final res = await _chatClient.get(
        '/v2/sessions/$userIds',
        queryParameters: queryParams,
      );
      
      if (res.isSuccess && res.data != null) {
        try {
          // The API returns a list of chat history items
          if (res.data is List) {
            return (res.data as List)
                .map((json) => ChatHistoryResponse.fromJson(json as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception('Invalid response format: expected List');
          }
        } catch (e) {
          throw Exception('Error parsing chat history: $e');
        }
      } else {
        throw Exception('Failed to load chat history: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }

  Future<void> deleteChat({
    required String sessionId,
  }) async {
    try {
      // Use ApiClient which automatically handles token management
      final res = await _chatClient.delete('/v2/delete_chat/$userIds/$sessionId');
      
      if (!res.isSuccess) {
        throw Exception('Failed to delete chat: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error deleting chat: $e');
    }
  }

  Future<void> deleteAllChats() async {
    try {
      final res = await _chatClient.delete('/v2/delete_all_chats/$userIds');

      if (!res.isSuccess) {
        throw Exception('Failed to delete all chats: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error deleting all chats: $e');
    }
  }

  Future<void> archiveChat({
    required String sessionId,
  }) async {
    try {
      // Use ApiClient which automatically handles token management
      final res = await _chatClient.patch(
        '/v2/archive_chat/$userIds/$sessionId',
        const {},
      );

      if (!res.isSuccess) {
        throw Exception('Failed to archive chat: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error archiving chat: $e');
    }
  }

  Future<void> archiveAllChats() async {
    try {
      final res = await _chatClient.patch(
        '/v2/archive_all_chats/$userIds',
        const {},
      );

      if (!res.isSuccess) {
        throw Exception('Failed to archive all chats: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error archiving all chats: $e');
    }
  }

  Future<void> unarchiveChat({
    required String sessionId,
  }) async {
    try {
      final res = await _chatClient.patch(
        '/v2/unarchive_chat/$userIds/$sessionId',
        const {},
      );

      if (!res.isSuccess) {
        throw Exception('Failed to unarchive chat: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error unarchiving chat: $e');
    }
  }

  Future<String> shareSession({
    required String sessionId,
  }) async {
    try {
      final res = await _chatClient.post(
        '/v2/share_session/$sessionId',
        <String, dynamic>{
          'user_id': userIds,
        },
      );

      if (!res.isSuccess || res.data == null) {
        throw Exception('Failed to share chat: ${res.message ?? 'Unknown error'}');
      }

      if (res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final shareUrl = data['share_url'];
        if (shareUrl is String && shareUrl.isNotEmpty) {
          return shareUrl;
        }
        throw Exception('Invalid share response: missing share_url');
      }

      throw Exception('Invalid share response format');
    } catch (e) {
      throw Exception('Error sharing chat: $e');
    }
  }

  Future<List<SharedSession>> fetchSharedSessions({
    bool isActive = true,
  }) async {
    try {
      final res = await _chatClient.get(
        '/v2/shared_sessions/$userIds',
        queryParameters: <String, String>{
          'is_active': isActive ? 'true' : 'false',
        },
      );

      if (!res.isSuccess || res.data == null) {
        throw Exception('Failed to load shared sessions: ${res.message ?? 'Unknown error'}');
      }

      if (res.data is Map<String, dynamic>) {
        final map = res.data as Map<String, dynamic>;
        final shares = map['shares'];
        if (shares is List) {
          return shares
              .whereType<Map<String, dynamic>>()
              .map(SharedSession.fromJson)
              .toList();
        }
        return const <SharedSession>[];
      }

      throw Exception('Invalid shared sessions response format');
    } catch (e) {
      throw Exception('Error fetching shared sessions: $e');
    }
  }

  Future<void> revokeSharedSession({
    required String shareId,
  }) async {
    try {
      final res = await _chatClient.delete('/v2/share_session/$shareId/$userIds');

      if (!res.isSuccess) {
        throw Exception('Failed to revoke shared session: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error revoking shared session: $e');
    }
  }

  Future<void> exportData({
    required String toEmail,
  }) async {
    try {
      final res = await _chatClient.post(
        '/v2/export/jobs',
        <String, dynamic>{
          'user_id': userIds,
          'to_email': toEmail,
        },
      );

      if (!res.isSuccess) {
        throw Exception('Failed to request data export: ${res.message ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error requesting data export: $e');
    }
  }
}

