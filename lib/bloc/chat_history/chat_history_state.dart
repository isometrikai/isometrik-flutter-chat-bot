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

  const ChatHistoryLoadSuccess({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class ChatHistoryLoadFailure extends ChatHistoryState {
  final String message;

  const ChatHistoryLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}



