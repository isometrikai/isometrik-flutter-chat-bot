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



