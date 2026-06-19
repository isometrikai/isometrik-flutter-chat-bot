import 'package:chat_bot/data/model/chat_response.dart';
import 'package:equatable/equatable.dart';

abstract class FlightSearchEvent extends Equatable {
  const FlightSearchEvent();

  @override
  List<Object?> get props => [];
}

class FlightSearchFetchRequested extends FlightSearchEvent {
  const FlightSearchFetchRequested({
    required this.action,
    this.flightBooking,
    this.needToShowLoader = false,
  });

  final WidgetAction action;
  final Map<String, dynamic>? flightBooking;
  final bool needToShowLoader;

  @override
  List<Object?> get props => [action, flightBooking, needToShowLoader];
}

class FlightSearchLoadMoreRequested extends FlightSearchEvent {
  const FlightSearchLoadMoreRequested({
    required this.action,
    this.flightBooking,
  });

  final WidgetAction action;
  final Map<String, dynamic>? flightBooking;

  @override
  List<Object?> get props => [action, flightBooking];
}
