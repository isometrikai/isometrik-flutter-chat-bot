import 'package:equatable/equatable.dart';

class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => [];
}

class RestaurantFetchRequested extends RestaurantEvent {
  final String keyword;
  final String storeCategoryName;
  final String storeCategoryId; 

  const RestaurantFetchRequested({this.keyword = '', this.storeCategoryName = '', this.storeCategoryId = ''});

  @override
  List<Object?> get props => [keyword, storeCategoryName, storeCategoryId];
}

class RestaurantRefreshed extends RestaurantEvent {
  final String keyword;
  final String storeCategoryName;
  final String storeCategoryId;

  const RestaurantRefreshed({this.keyword = '', this.storeCategoryName = '', this.storeCategoryId = ''});

  @override
  List<Object?> get props => [keyword, storeCategoryName, storeCategoryId];
}


