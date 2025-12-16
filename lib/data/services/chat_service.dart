import 'package:chat_bot/data/data.dart';

class ChatService {
  ChatService._internal();
  static final ChatService instance = ChatService._internal();

  Future<ChatResponse?> sendChatMessage({
    required String message,
    required String agentId,
    required String fingerPrintId,
    required String sessionId,
    bool isLoggedIn = false,
    double longitude = 0.0,
    double latitude = 0.0,
    String staffId = "",
    String serviceRequestedTime = "",
  }) {
    return ChatApiServices.instance.sendChatMessage(
      message: message,
      agentId: agentId,
      fingerPrintId: fingerPrintId,
      sessionId: sessionId,
      isLoggedIn: isLoggedIn,
      longitude: longitude,
      latitude: latitude,
      staffId: staffId,
      serviceRequestedTime: serviceRequestedTime,
    );
  }

  Future<SessionIdResponse?> getSessionId() {
    return ChatApiServices.instance.getSessionId();
  }

  Future<List<ChatHistoryDetail>> fetchChatHistory(String sessionId) {
    return ChatApiServices.instance.fetchChatHistory(sessionId);
  }

}


