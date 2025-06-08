import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  ChatBloc() : super(ChatInitial()) {
    on<ChatLoadEvent>(_onFetchChat);
  }

  Future<void> _onFetchChat(ChatLoadEvent event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      final chat = await ApiService.sendChatMessage(
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
        emit(ChatError());
      }
    } catch (e) {
      emit(ChatError());
    }
  }


}
