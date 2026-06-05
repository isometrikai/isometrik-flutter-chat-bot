import 'package:chat_bot/data/model/chat_response.dart';
import 'package:equatable/equatable.dart';

abstract class HotelSearchEvent extends Equatable {
  const HotelSearchEvent();

  @override
  List<Object?> get props => [];
}

class HotelSearchFetchRequested extends HotelSearchEvent {
  const HotelSearchFetchRequested({
    required this.action,
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.needToShowLoader = false,
  });

  final WidgetAction action;
  final String searchQuery;
  final String selectedFilter;
  final bool needToShowLoader;

  @override
  List<Object?> get props =>
      [action, searchQuery, selectedFilter, needToShowLoader];
}

class HotelSearchFilterChanged extends HotelSearchEvent {
  const HotelSearchFilterChanged(this.filter);

  final String filter;

  @override
  List<Object?> get props => [filter];
}
