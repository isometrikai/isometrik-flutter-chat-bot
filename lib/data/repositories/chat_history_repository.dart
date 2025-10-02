import 'package:chat_bot/data/model/chat_history_response.dart';
import 'package:chat_bot/utils/user_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatHistoryRepository {
  const ChatHistoryRepository();

  static const String baseUrl = 'https://easyagentapi.isometrik.ai';

  Future<List<ChatHistoryResponse>> fetchChatHistory() async {
    // Get user ID from preferences, fallback to default if not available
    final userId = await UserPreferences.getUserId() ?? '68c129ebbdaeb6000f7ed53c';
    
    final url = Uri.parse('$baseUrl/v2/sessions/$userId');
    
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
}

