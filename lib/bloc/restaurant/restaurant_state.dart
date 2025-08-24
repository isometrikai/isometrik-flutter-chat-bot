import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/chat_response.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoadInProgress extends RestaurantState {}

class RestaurantLoadSuccess extends RestaurantState {
  final List<Store> restaurants;
  final String keyword;

  const RestaurantLoadSuccess({required this.restaurants, this.keyword = ''});

  @override
  List<Object?> get props => [restaurants, keyword];
}

class RestaurantLoadFailure extends RestaurantState {
  final String message;

  const RestaurantLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}


