import 'package:equatable/equatable.dart';

abstract class ChatHistoryEvent extends Equatable {
  const ChatHistoryEvent();

  @override
  List<Object?> get props => [];
}

class ChatHistoryFetchRequested extends ChatHistoryEvent {
  const ChatHistoryFetchRequested();
}

class ChatHistoryRefreshed extends ChatHistoryEvent {
  const ChatHistoryRefreshed();
}

class ChatHistoryLoadMoreRequested extends ChatHistoryEvent {
  const ChatHistoryLoadMoreRequested();
}

class ChatHistoryDeleteRequested extends ChatHistoryEvent {
  final String sessionId;
  
  const ChatHistoryDeleteRequested({required this.sessionId});
  
  @override
  List<Object?> get props => [sessionId];
}

class ChatHistoryCategoryFilterRequested extends ChatHistoryEvent {
  final String category;
  
  const ChatHistoryCategoryFilterRequested({required this.category});
  
  @override
  List<Object?> get props => [category];
}

class ChatHistorySearchRequested extends ChatHistoryEvent {
  final String query;
  
  const ChatHistorySearchRequested({required this.query});
  
  @override
  List<Object?> get props => [query];
}



