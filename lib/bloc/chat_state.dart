import 'package:chat_bot/data/model/chat_history_response.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final ChatResponse messages;

  const ChatLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatLoadedWithSessionId extends ChatState {
  final String sessionId;

  const ChatLoadedWithSessionId(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class ChatLoadedWithHistorySessionId extends ChatState {
  final List<ChatHistoryDetail> history;

  const ChatLoadedWithHistorySessionId(this.history);

  @override
  List<Object> get props => [history];
}

class ChatError extends ChatState {
  final String error;

  const ChatError([this.error = 'An error occurred']);

  @override
  List<Object> get props => [error];
}

class AddToCartState extends ChatState {
}
