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
    String storeCategoryId = "",
    List<String> prescriptionImageUrls = const [],
    Map<String, dynamic> tableBookingData = const {},
    Map<String, dynamic> hotelDestinationData = const {},
    Map<String, dynamic> carPickupData = const {},
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
      storeCategoryId: storeCategoryId,
      prescriptionImageUrls: prescriptionImageUrls,
      tableBookingData: tableBookingData,
      hotelDestinationData: hotelDestinationData,
      carPickupData: carPickupData,
    );
  }

  Future<SessionIdResponse?> getSessionId() {
    return ChatApiServices.instance.getSessionId();
  }

  Future<List<ChatHistoryDetail>> fetchChatHistory(String sessionId) {
    return ChatApiServices.instance.fetchChatHistory(sessionId);
  }

}


