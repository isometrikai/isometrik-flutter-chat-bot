import 'dart:async';

import 'package:chat_bot/bloc/chat_history/chat_history_event.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_state.dart';
import 'package:chat_bot/data/repositories/chat_history_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHistoryBloc extends Bloc<ChatHistoryEvent, ChatHistoryState> {
  final ChatHistoryRepository repository;
  int _currentSkip = 0;
  static const int _pageSize = 20;
  
  // Current category filter state
  bool? _isFoodChat;
  bool? _isGroceryChat;
  bool? _isPharmacyChat;
  bool? _isShoppingChat;
  bool? _isServicesChat;
  // Current search query
  String _currentQuery = '';

  ChatHistoryBloc({ChatHistoryRepository? repository})
      : repository = repository ?? ChatHistoryRepository.instance,
        super(ChatHistoryInitial()) {
    on<ChatHistoryFetchRequested>(_onFetchRequested);
    on<ChatHistoryRefreshed>(_onRefreshed);
    on<ChatHistoryLoadMoreRequested>(_onLoadMoreRequested);
    on<ChatHistoryDeleteRequested>(_onDeleteRequested);
    on<ChatHistoryCategoryFilterRequested>(_onCategoryFilterRequested);
    on<ChatHistorySearchRequested>(_onSearchRequested);
  }

  Future<void> _onFetchRequested(
    ChatHistoryFetchRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    Utility.showLoader();
    _currentSkip = 0;
    
    try {
      final sessions = await repository.fetchChatHistory(
        limit: _pageSize,
        skip: _currentSkip,
        isFoodChat: _isFoodChat,
        isGroceryChat: _isGroceryChat,
        isPharmacyChat: _isPharmacyChat,
        isServicesChat: _isServicesChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
      );
      Utility.closeProgressDialog();
      
      final hasMore = sessions.length == _pageSize;
      _currentSkip += sessions.length;
      
      emit(ChatHistoryLoadSuccess(
        sessions: sessions,
        hasMore: hasMore,
      ));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryLoadFailure(e.toString()));
    }
  }

  Future<void> _onRefreshed(
    ChatHistoryRefreshed event,
    Emitter<ChatHistoryState> emit,
  ) async {
    _currentSkip = 0;
    
    try {
      final sessions = await repository.fetchChatHistory(
        limit: _pageSize,
        skip: _currentSkip,
        isFoodChat: _isFoodChat,
        isGroceryChat: _isGroceryChat,
        isPharmacyChat: _isPharmacyChat,
        isShoppingChat: _isShoppingChat,
        isServicesChat: _isServicesChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
      );
      
      final hasMore = sessions.length == _pageSize;
      _currentSkip += sessions.length;
      
      emit(ChatHistoryLoadSuccess(
        sessions: sessions,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(ChatHistoryLoadFailure(e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    ChatHistoryLoadMoreRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatHistoryLoadSuccess || 
        !currentState.hasMore || 
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));
    
    try {
      final newSessions = await repository.fetchChatHistory(
        limit: _pageSize,
        skip: _currentSkip,
        isFoodChat: _isFoodChat,
        isGroceryChat: _isGroceryChat,
        isPharmacyChat: _isPharmacyChat,
        isShoppingChat: _isShoppingChat,
        isServicesChat: _isServicesChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
      );
      
      final hasMore = newSessions.length == _pageSize;
      _currentSkip += newSessions.length;
      
      final updatedSessions = [...currentState.sessions, ...newSessions];
      
      emit(currentState.copyWith(
        sessions: updatedSessions,
        hasMore: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // Optionally show error message for load more failure
    }
  }

  Future<void> _onDeleteRequested(
    ChatHistoryDeleteRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatHistoryLoadSuccess) {
      return;
    }
    Utility.showLoader();
    // emit(ChatHistoryDeleteInProgress(sessionId: event.sessionId));
    
    try {
      await repository.deleteChat(sessionId: event.sessionId);
      Utility.closeProgressDialog();
      
      // Remove the deleted session from the current list
      // final updatedSessions = currentState.sessions
      //     .where((session) => session.sessionId.toString() != event.sessionId)
      //     .toList();
      
      add(ChatHistoryFetchRequested());
      emit(ChatHistoryDeleteSuccess(sessionId: event.sessionId));
      // emit(ChatHistoryLoadSuccess(
      //   sessions: updatedSessions,
      //   hasMore: currentState.hasMore,
      //   isLoadingMore: currentState.isLoadingMore,
      // ));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryDeleteFailure(
        message: e.toString(),
        sessionId: event.sessionId,
      ));
      // Revert to the previous state after showing error
      emit(currentState);
    }
  }

  Future<void> _onCategoryFilterRequested(
    ChatHistoryCategoryFilterRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    // Update category filter state
    _isFoodChat = null;
    _isGroceryChat = null;
    _isPharmacyChat = null;
    _isShoppingChat = null;
    _isServicesChat = null;
    _currentQuery = '';
    
    // Set the appropriate filter based on category
    switch (event.category) {
      case '🍕 Restaurant':
        _isFoodChat = true;
        break;
      case '🥑 Grocery':
        _isGroceryChat = true;
        break;
      case '💊 Pharmacy':
        _isPharmacyChat = true;
        break;
      case '🛒 Shopping':
        _isShoppingChat = true;
        break;
      case '💄 Services':
        _isServicesChat = true;
        break;
      case 'ALL':
      default:
        // No filters applied
        break;
    }
    
    // Reset pagination and fetch new data
    _currentSkip = 0;
    Utility.showLoader();
    
    try {
      final sessions = await repository.fetchChatHistory(
        limit: _pageSize,
        skip: _currentSkip,
        isFoodChat: _isFoodChat,
        isGroceryChat: _isGroceryChat,
        isPharmacyChat: _isPharmacyChat,
        isShoppingChat: _isShoppingChat,
        isServicesChat: _isServicesChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
      );
      Utility.closeProgressDialog();
      
      final hasMore = sessions.length == _pageSize;
      _currentSkip += sessions.length;
      
      emit(ChatHistoryLoadSuccess(
        sessions: sessions,
        hasMore: hasMore,
      ));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryLoadFailure(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    ChatHistorySearchRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    // Update search query
    _currentQuery = event.query;
    
    // Reset pagination and fetch new data
    _currentSkip = 0;
    // Utility.showLoader();
    
    try {
      final sessions = await repository.fetchChatHistory(
        limit: _pageSize,
        skip: _currentSkip,
        isFoodChat: _isFoodChat,
        isGroceryChat: _isGroceryChat,
        isPharmacyChat: _isPharmacyChat,
        isShoppingChat: _isShoppingChat,
        isServicesChat: _isServicesChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
      );
      // Utility.closeProgressDialog();
      
      final hasMore = sessions.length == _pageSize;
      _currentSkip += sessions.length;
      
      emit(ChatHistoryLoadSuccess(
        sessions: sessions,
        hasMore: hasMore,
      ));
    } catch (e) {
      // Utility.closeProgressDialog();
      emit(ChatHistoryLoadFailure(e.toString()));
    }
  }
}



