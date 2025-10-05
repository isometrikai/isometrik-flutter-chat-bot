import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/chat_history_response.dart';

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



