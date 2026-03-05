import 'package:chat_bot/data/model/chat_history_response.dart';
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
    String? query,
  }) async {
    
    final Map<String, String> queryParams = {
      'limit': limit.toString(),
      'skip': skip.toString(),
    };
    
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
}

