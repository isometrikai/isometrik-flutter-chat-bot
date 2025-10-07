import 'package:chat_bot/data/model/chat_history_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatHistoryRepository {
  static final ChatHistoryRepository _instance = ChatHistoryRepository._internal();
  static ChatHistoryRepository get instance => _instance;
  
  ChatHistoryRepository._internal();

  static const String baseUrl = 'https://easyagentapi.isometrik.ai';
  String userIds = '';

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
    
    final uri = Uri.parse('$baseUrl/v2/sessions/$userIds').replace(
      queryParameters: queryParams,
    );
    
    print(uri);
    
    try {
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => ChatHistoryResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }

  Future<void> deleteChat({
    required String sessionId,
  }) async {
    final url = Uri.parse('$baseUrl/v2/delete_chat/$userIds/$sessionId');
    print(url);
    try {
      final response = await http.delete(url);
      print(response.body);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting chat: $e');
    }
  }
}

