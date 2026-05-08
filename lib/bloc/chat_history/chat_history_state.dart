import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/model/shared_session.dart';

abstract class ChatHistoryState extends Equatable {
  const ChatHistoryState();

  @override
  List<Object?> get props => [];
}

class ChatHistoryInitial extends ChatHistoryState {}

class ChatHistoryLoadInProgress extends ChatHistoryState {}

class ChatHistoryLoadSuccess extends ChatHistoryState {
  final List<ChatHistoryResponse> sessions;
  final bool hasMore;
  final bool isLoadingMore;

  const ChatHistoryLoadSuccess({
    required this.sessions,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ChatHistoryLoadSuccess copyWith({
    List<ChatHistoryResponse>? sessions,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatHistoryLoadSuccess(
      sessions: sessions ?? this.sessions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [sessions, hasMore, isLoadingMore];
}

class ChatHistoryLoadFailure extends ChatHistoryState {
  final String message;

  const ChatHistoryLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatHistoryDeleteInProgress extends ChatHistoryState {
  final String sessionId;
  
  const ChatHistoryDeleteInProgress({required this.sessionId});
  
  @override
  List<Object?> get props => [sessionId];
}

class ChatHistoryDeleteSuccess extends ChatHistoryState {
  final String sessionId;
  
  const ChatHistoryDeleteSuccess({required this.sessionId});
  
  @override
  List<Object?> get props => [sessionId];
}

class ChatHistoryDeleteFailure extends ChatHistoryState {
  final String message;
  final String sessionId;
  
  const ChatHistoryDeleteFailure({required this.message, required this.sessionId});
  
  @override
  List<Object?> get props => [message, sessionId];
}

class ChatHistoryDeleteAllSuccess extends ChatHistoryState {
  const ChatHistoryDeleteAllSuccess();
}

class ChatHistoryDeleteAllFailure extends ChatHistoryState {
  final String message;

  const ChatHistoryDeleteAllFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatHistoryArchiveSuccess extends ChatHistoryState {
  final String sessionId;

  const ChatHistoryArchiveSuccess({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class ChatHistoryArchiveFailure extends ChatHistoryState {
  final String message;
  final String sessionId;

  const ChatHistoryArchiveFailure({required this.message, required this.sessionId});

  @override
  List<Object?> get props => [message, sessionId];
}

class ChatHistoryArchiveAllSuccess extends ChatHistoryState {
  const ChatHistoryArchiveAllSuccess();
}

class ChatHistoryArchiveAllFailure extends ChatHistoryState {
  final String message;

  const ChatHistoryArchiveAllFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatHistoryUnarchiveSuccess extends ChatHistoryState {
  final String sessionId;

  const ChatHistoryUnarchiveSuccess({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class ChatHistoryUnarchiveFailure extends ChatHistoryState {
  final String message;
  final String sessionId;

  const ChatHistoryUnarchiveFailure({required this.message, required this.sessionId});

  @override
  List<Object?> get props => [message, sessionId];
}

class ChatHistoryShareSuccess extends ChatHistoryState {
  final String sessionId;
  final String shareUrl;

  const ChatHistoryShareSuccess({required this.sessionId, required this.shareUrl});

  @override
  List<Object?> get props => [sessionId, shareUrl];
}

class ChatHistoryShareFailure extends ChatHistoryState {
  final String sessionId;
  final String message;

  const ChatHistoryShareFailure({required this.sessionId, required this.message});

  @override
  List<Object?> get props => [sessionId, message];
}

class ChatHistorySharedSessionsLoadSuccess extends ChatHistoryState {
  final List<SharedSession> shares;

  const ChatHistorySharedSessionsLoadSuccess({required this.shares});

  @override
  List<Object?> get props => [shares];
}

/// Dedicated loading state so Shared links sheet does not confuse this with chat-history load states.
class ChatHistorySharedSessionsLoadInProgress extends ChatHistoryState {
  const ChatHistorySharedSessionsLoadInProgress();
}

class ChatHistorySharedSessionsLoadFailure extends ChatHistoryState {
  final String message;

  const ChatHistorySharedSessionsLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatHistorySharedSessionRevokeSuccess extends ChatHistoryState {
  final String shareId;

  const ChatHistorySharedSessionRevokeSuccess({required this.shareId});

  @override
  List<Object?> get props => [shareId];
}

class ChatHistorySharedSessionRevokeFailure extends ChatHistoryState {
  final String shareId;
  final String message;

  const ChatHistorySharedSessionRevokeFailure({required this.shareId, required this.message});

  @override
  List<Object?> get props => [shareId, message];
}



