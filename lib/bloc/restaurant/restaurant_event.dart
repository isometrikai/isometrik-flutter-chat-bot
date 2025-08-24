import 'package:equatable/equatable.dart';

class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class RestaurantFetchRequested extends RestaurantEvent {
  final String keyword;

  const RestaurantFetchRequested({this.keyword = ''});

  @override
  List<Object?> get props => [keyword];
}

class RestaurantRefreshed extends RestaurantEvent {
  final String keyword;

  const RestaurantRefreshed({this.keyword = ''});

  @override
  List<Object?> get props => [keyword];
}


