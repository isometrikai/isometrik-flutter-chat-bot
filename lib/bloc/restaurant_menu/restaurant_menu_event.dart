import 'package:equatable/equatable.dart';

abstract class RestaurantMenuEvent extends Equatable {
  const RestaurantMenuEvent();

  @override
  List<Object?> get props => [];
}

class RestaurantMenuRequested extends RestaurantMenuEvent {
  const RestaurantMenuRequested();
}

class RestaurantMenuRefreshed extends RestaurantMenuEvent {
  const RestaurantMenuRefreshed();
}


