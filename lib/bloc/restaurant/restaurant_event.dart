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
  final bool needToShowLoader;

  const RestaurantFetchRequested({this.keyword = '', this.storeCategoryName = '', this.storeCategoryId = '', this.needToShowLoader = false});

  @override
  List<Object?> get props => [keyword, storeCategoryName, storeCategoryId, needToShowLoader];
}

class RestaurantRefreshed extends RestaurantEvent {
  final String keyword;
  final String storeCategoryName;
  final String storeCategoryId;
  final bool needToShowLoader;

  const RestaurantRefreshed({this.keyword = '', this.storeCategoryName = '', this.storeCategoryId = '', this.needToShowLoader = false});

  @override
  List<Object?> get props => [keyword, storeCategoryName, storeCategoryId, needToShowLoader];
}


