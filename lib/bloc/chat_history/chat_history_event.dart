import 'package:equatable/equatable.dart';

abstract class ChatHistoryEvent extends Equatable {
  const ChatHistoryEvent();

  @override
  List<Object?> get props => [];
}

class ChatHistoryFetchRequested extends ChatHistoryEvent {
  // const ChatHistoryFetchRequested();
  final bool isFromArchive;
  const ChatHistoryFetchRequested({this.isFromArchive = false});

  @override
  List<Object?> get props => [isFromArchive];
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

class ChatHistoryArchiveRequested extends ChatHistoryEvent {
  final String sessionId;

  const ChatHistoryArchiveRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class ChatHistoryUnarchiveRequested extends ChatHistoryEvent {
  final String sessionId;

  const ChatHistoryUnarchiveRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class ChatHistoryShareRequested extends ChatHistoryEvent {
  final String sessionId;

  const ChatHistoryShareRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class ChatHistorySharedSessionsFetchRequested extends ChatHistoryEvent {
  final bool isActive;

  const ChatHistorySharedSessionsFetchRequested({this.isActive = true});

  @override
  List<Object?> get props => [isActive];
}

class ChatHistorySharedSessionRevokeRequested extends ChatHistoryEvent {
  final String shareId;

  const ChatHistorySharedSessionRevokeRequested({required this.shareId});

  @override
  List<Object?> get props => [shareId];
}

class ChatHistoryArchiveAllRequested extends ChatHistoryEvent {
  const ChatHistoryArchiveAllRequested();
}

class ChatHistoryDeleteAllRequested extends ChatHistoryEvent {
  const ChatHistoryDeleteAllRequested();
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



