import 'dart:async';

import 'package:chat_bot/bloc/chat_history/chat_history_event.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_state.dart';
import 'package:chat_bot/data/repositories/chat_history_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHistoryBloc extends Bloc<ChatHistoryEvent, ChatHistoryState> {
  final ChatHistoryRepository repository;

  ChatHistoryBloc({ChatHistoryRepository? repository})
      : repository = repository ?? const ChatHistoryRepository(),
        super(ChatHistoryInitial()) {
    on<ChatHistoryFetchRequested>(_onFetchRequested);
    on<ChatHistoryRefreshed>(_onRefreshed);
  }

  Future<void> _onFetchRequested(
    ChatHistoryFetchRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    Utility.showLoader();
    
    try {
      final sessions = await repository.fetchChatHistory();
      Utility.closeProgressDialog();
      emit(ChatHistoryLoadSuccess(sessions: sessions));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryLoadFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    ChatHistoryRefreshed event,
    Emitter<ChatHistoryState> emit,
  ) async {
    emit(ChatHistoryLoadInProgress());
    
    try {
      final sessions = await repository.fetchChatHistory();
      emit(ChatHistoryLoadSuccess(sessions: sessions));
    } catch (e) {
      emit(ChatHistoryLoadFailure(e.toString()));
    }
  }
}



