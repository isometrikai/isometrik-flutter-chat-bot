import 'dart:async';

import 'package:chat_bot/bloc/chat_history/chat_history_event.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_state.dart';
import 'package:chat_bot/data/data.dart';
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
  bool? _isHealthCareChat;
  // Current search query
  String _currentQuery = '';
  bool _isFromArchive = false;

  ChatHistoryBloc({ChatHistoryRepository? repository})
      : repository = repository ?? ChatHistoryRepository.instance,
        super(ChatHistoryInitial()) {
    on<ChatHistoryFetchRequested>(_onFetchRequested);
    on<ChatHistoryRefreshed>(_onRefreshed);
    on<ChatHistoryLoadMoreRequested>(_onLoadMoreRequested);
    on<ChatHistoryDeleteRequested>(_onDeleteRequested);
    on<ChatHistoryArchiveRequested>(_onArchiveRequested);
    on<ChatHistoryUnarchiveRequested>(_onUnarchiveRequested);
    on<ChatHistoryShareRequested>(_onShareRequested);
    on<ChatHistorySharedSessionsFetchRequested>(_onSharedSessionsFetchRequested);
    on<ChatHistorySharedSessionRevokeRequested>(_onSharedSessionRevokeRequested);
    on<ChatHistoryArchiveAllRequested>(_onArchiveAllRequested);
    on<ChatHistoryDeleteAllRequested>(_onDeleteAllRequested);
    on<ChatHistoryCategoryFilterRequested>(_onCategoryFilterRequested);
    on<ChatHistorySearchRequested>(_onSearchRequested);
  }

  Future<void> _onFetchRequested(
    ChatHistoryFetchRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    Utility.showLoader();
    _currentSkip = 0;
    _isFromArchive = event.isFromArchive;
    
    try {
      final sessions = await repository.fetchChatHistory(
        limit: _pageSize,
        skip: _currentSkip,
        isFoodChat: _isFoodChat,
        isGroceryChat: _isGroceryChat,
        isPharmacyChat: _isPharmacyChat,
        isServicesChat: _isServicesChat,
        isHealthCareChat: _isHealthCareChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        isFromArchive: _isFromArchive,
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
        isHealthCareChat: _isHealthCareChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        isFromArchive: _isFromArchive,
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
        isHealthCareChat: _isHealthCareChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        isFromArchive: _isFromArchive,
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
      
      add(ChatHistoryFetchRequested(isFromArchive: _isFromArchive));
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

  Future<void> _onArchiveRequested(
    ChatHistoryArchiveRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatHistoryLoadSuccess) {
      return;
    }

    Utility.showLoader();

    try {
      await repository.archiveChat(sessionId: event.sessionId);
      Utility.closeProgressDialog();

      add(ChatHistoryFetchRequested());
      emit(ChatHistoryArchiveSuccess(sessionId: event.sessionId));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryArchiveFailure(
        message: e.toString(),
        sessionId: event.sessionId,
      ));
      emit(currentState);
    }
  }

  Future<void> _onUnarchiveRequested(
    ChatHistoryUnarchiveRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatHistoryLoadSuccess) {
      return;
    }

    Utility.showLoader();

    try {
      await repository.unarchiveChat(sessionId: event.sessionId);
      Utility.closeProgressDialog();

      add(ChatHistoryFetchRequested(isFromArchive: _isFromArchive));
      emit(ChatHistoryUnarchiveSuccess(sessionId: event.sessionId));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryUnarchiveFailure(
        message: e.toString(),
        sessionId: event.sessionId,
      ));
      emit(currentState);
    }
  }

  Future<void> _onShareRequested(
    ChatHistoryShareRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    final currentState = state;
    Utility.showLoader();

    try {
      final shareUrl = await repository.shareSession(sessionId: event.sessionId);
      Utility.closeProgressDialog();
      emit(ChatHistoryShareSuccess(sessionId: event.sessionId, shareUrl: shareUrl));
      emit(currentState);
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryShareFailure(sessionId: event.sessionId, message: e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onSharedSessionsFetchRequested(
    ChatHistorySharedSessionsFetchRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    emit(const ChatHistorySharedSessionsLoadInProgress());
    Utility.showLoader();
    try {
      final shares = await repository.fetchSharedSessions(isActive: event.isActive);
      Utility.closeProgressDialog();
      emit(ChatHistorySharedSessionsLoadSuccess(shares: shares));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistorySharedSessionsLoadFailure(message: e.toString()));
    }
  }

  Future<void> _onSharedSessionRevokeRequested(
    ChatHistorySharedSessionRevokeRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    Utility.showLoader();
    try {
      await repository.revokeSharedSession(shareId: event.shareId);
      Utility.closeProgressDialog();
      emit(ChatHistorySharedSessionRevokeSuccess(shareId: event.shareId));

      final shares = await repository.fetchSharedSessions(isActive: true);
      emit(ChatHistorySharedSessionsLoadSuccess(shares: shares));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistorySharedSessionRevokeFailure(shareId: event.shareId, message: e.toString()));
    }
  }

  Future<void> _onArchiveAllRequested(
    ChatHistoryArchiveAllRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    final currentState = state;
    Utility.showLoader();

    try {
      await repository.archiveAllChats();
      Utility.closeProgressDialog();

      add(ChatHistoryFetchRequested());
      emit(const ChatHistoryArchiveAllSuccess());
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryArchiveAllFailure(message: e.toString()));
      emit(currentState);
    }
  }

  Future<void> _onDeleteAllRequested(
    ChatHistoryDeleteAllRequested event,
    Emitter<ChatHistoryState> emit,
  ) async {
    final currentState = state;
    Utility.showLoader();

    try {
      await repository.deleteAllChats();
      Utility.closeProgressDialog();

      add(ChatHistoryFetchRequested(isFromArchive: _isFromArchive));
      emit(const ChatHistoryDeleteAllSuccess());
      emit(currentState);
    } catch (e) {
      Utility.closeProgressDialog();
      emit(ChatHistoryDeleteAllFailure(message: e.toString()));
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
    _isHealthCareChat = null;
    _currentQuery = '';
    _isFromArchive = false;
    
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
      case '🏥 Health Care':
        _isHealthCareChat = true;
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
        isHealthCareChat: _isHealthCareChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        isFromArchive: _isFromArchive,
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
    _isFromArchive = false;
    
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
        isHealthCareChat: _isHealthCareChat,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        isFromArchive: _isFromArchive,
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



