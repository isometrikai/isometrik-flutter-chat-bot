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
  }) async {
    
    final url = Uri.parse('$baseUrl/v2/sessions/$userIds?limit=$limit&skip=$skip');
    
    try {
      final response = await http.get(url);
      
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
    
    try {
      final response = await http.delete(url);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting chat: $e');
    }
  }
}

