import 'package:chat_bot/data/model/chat_response.dart';
import 'package:equatable/equatable.dart';

abstract class CarSearchEvent extends Equatable {
  const CarSearchEvent();

  @override
  List<Object?> get props => [];
}

class CarSearchFetchRequested extends CarSearchEvent {
  const CarSearchFetchRequested({
    required this.action,
    this.needToShowLoader = false,
  });

  final WidgetAction action;
  final bool needToShowLoader;

  @override
  List<Object?> get props => [action, needToShowLoader];
}

class CarSearchQueryChanged extends CarSearchEvent {
  const CarSearchQueryChanged(this.searchQuery);

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}
