import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/restaurant_menu_response.dart';

abstract class RestaurantMenuState extends Equatable {
  const RestaurantMenuState();

  @override
  List<Object?> get props => [];
}

class RestaurantMenuInitial extends RestaurantMenuState {}

class RestaurantMenuLoadInProgress extends RestaurantMenuState {}

class RestaurantMenuLoadSuccess extends RestaurantMenuState {
  final List<ProductCategory> categories;

  const RestaurantMenuLoadSuccess({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class RestaurantMenuLoadFailure extends RestaurantMenuState {
  final String message;

  const RestaurantMenuLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}


