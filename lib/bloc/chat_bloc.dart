import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/data/services/chat_service.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  ChatBloc() : super(ChatInitial()) {
    on<ChatLoadEvent>(_onFetchChat);
    // on<AddToCartEvent>(_addToCart);
    on<ChatSessionIdEvent>(_onFetchChatWithSessionId);
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

  Future<void> _onFetchChatWithSessionId(ChatSessionIdEvent event, Emitter<ChatState> emit) async {
    try {
      if (event.needToShowLoader) {
        Utility.showLoader();
      }
      // No loading state - background API call only
      final response = await ChatService.instance.getSessionId();
      if (response != null) {
        sessionId = response.sessionId.toString();
        // emit(ChatLoadedWithSessionId(response.sessionId.toString()));
      }
      if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }
      // Silently fail - no error emission
    } catch (e) {
      // Silently handle error - background call should not show errors
      if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }
    }
  }


}
