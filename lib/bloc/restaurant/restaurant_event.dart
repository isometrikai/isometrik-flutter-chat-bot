import 'package:equatable/equatable.dart';

class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class RestaurantFetchRequested extends RestaurantEvent {
  final String keyword;
  final String storeCategoryName;

  const RestaurantFetchRequested({this.keyword = '', this.storeCategoryName = ''});

  @override
  List<Object?> get props => [keyword, storeCategoryName];
}

class RestaurantRefreshed extends RestaurantEvent {
  final String keyword;
  final String storeCategoryName;

  const RestaurantRefreshed({this.keyword = '', this.storeCategoryName = ''});

  @override
  List<Object?> get props => [keyword, storeCategoryName];
}


