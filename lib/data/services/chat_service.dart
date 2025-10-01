import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/session_id_response.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';

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
  }) {
    return ChatApiServices.instance.sendChatMessage(
      message: message,
      agentId: agentId,
      fingerPrintId: fingerPrintId,
      sessionId: sessionId,
      isLoggedIn: isLoggedIn,
      longitude: longitude,
      latitude: latitude,
    );
  }

  Future<SessionIdResponse?> getSessionId() {
    return ChatApiServices.instance.getSessionId();
  }

  // Future<ChatResponse?> addToCart({
  //   required String storeId,
  //   required int cartType,
  //   required int action,
  //   required String storeCategoryId,
  //   required int newQuantity,
  //   required int storeTypeId,
  //   required String productId,
  //   required String centralProductId,
  //   required String unitId,
  // }) {
  //   return ChatApiServices.instance.addToCart(
  //     storeId: storeId,
  //     cartType: cartType,
  //     action: action,
  //     storeCategoryId: storeCategoryId,
  //     newQuantity: newQuantity,
  //     storeTypeId: storeTypeId,
  //     productId: productId,
  //     centralProductId: centralProductId,
  //     unitId: unitId,
  //   );
  // }
}


