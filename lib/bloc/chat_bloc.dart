import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/data/services/chat_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  ChatBloc() : super(ChatInitial()) {
    on<ChatLoadEvent>(_onFetchChat);
    // on<AddToCartEvent>(_addToCart);
  }

  Future<void> _onFetchChat(ChatLoadEvent event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      final chat = await ChatService.instance.sendChatMessage(
        message: event.message,
        agentId: event.agentId,
        fingerPrintId: event.fingerPrintId,
        sessionId: event.sessionId,
        isLoggedIn: event.isLoggedIn,
        longitude: double.parse(event.longitude),
        latitude: double.parse(event.latitude),
      );
      if (chat != null) {
        emit(ChatLoaded(chat));
      } else {
        emit(ChatError('Failed to send message'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  // Future<void> _addToCart(AddToCartEvent event, Emitter<ChatState> emit) async {
  //   try {
  //     emit(ChatLoading());
  //     final chat = await ChatService.instance.addToCart(
  //       storeId: event.storeId,
  //       cartType: event.cartType,
  //       action: event.action,
  //       storeCategoryId: event.storeCategoryId,
  //       newQuantity: event.newQuantity,
  //       storeTypeId: event.storeTypeId,
  //       productId: event.productId,
  //       centralProductId: event.centralProductId,
  //       unitId: event.unitId,
  //     );
  //     if (chat != null) {
  //       emit(ChatLoaded(chat));
  //     } else {
  //       emit(ChatError('Failed to send message'));
  //     }
  //   } catch (e) {
  //     emit(ChatError(e.toString()));
  //   }
  // }


}
