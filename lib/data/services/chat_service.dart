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
    // double longitude = 0.0,
    // double latitude = 0.0,
    String staffId = "",
    String serviceRequestedTime = "",
    String storeCategoryId = "",
    List<String> prescriptionImageUrls = const [],
    Map<String, dynamic> tableBookingData = const {},
    Map<String, dynamic> hotelDestinationData = const {},
    Map<String, dynamic> carPickupData = const {},
    Map<String, dynamic> flightBookingData = const {},
    Map<String, dynamic> packageDeliveryData = const {},
  }) {
    return ChatApiServices.instance.sendChatMessage(
      message: message,
      agentId: agentId,
      fingerPrintId: fingerPrintId,
      sessionId: sessionId,
      isLoggedIn: isLoggedIn,
      // longitude: longitude,
      // latitude: latitude,
      staffId: staffId,
      serviceRequestedTime: serviceRequestedTime,
      storeCategoryId: storeCategoryId,
      prescriptionImageUrls: prescriptionImageUrls,
      tableBookingData: tableBookingData,
      hotelDestinationData: hotelDestinationData,
      carPickupData: carPickupData,
      flightBookingData: flightBookingData,
      packageDeliveryData: packageDeliveryData,
    );
  }

  Future<SessionIdResponse?> getSessionId() {
    return ChatApiServices.instance.getSessionId();
  }

  Future<bool?> fetchCustomerProfilePersonalization() async {
    final profile = await ChatApiServices.instance.fetchCustomerProfile();
    return profile?.zainPersonalization;
  }

  Future<List<ChatHistoryDetail>> fetchChatHistory(String sessionId) {
    return ChatApiServices.instance.fetchChatHistory(sessionId);
  }

}


