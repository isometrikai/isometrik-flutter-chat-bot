import 'package:chat_bot/data/model/chat_response.dart';
import 'package:equatable/equatable.dart';

abstract class FlightSearchState extends Equatable {
  const FlightSearchState();

  @override
  List<Object?> get props => [];
}

class FlightSearchInitial extends FlightSearchState {}

class FlightSearchLoadInProgress extends FlightSearchState {
  const FlightSearchLoadInProgress();
}

class FlightSearchLoadSuccess extends FlightSearchState {
  const FlightSearchLoadSuccess({
    required this.flights,
    required this.total,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<FlightSearch> flights;
  final int total;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  FlightSearchLoadSuccess copyWith({
    List<FlightSearch>? flights,
    int? total,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return FlightSearchLoadSuccess(
      flights: flights ?? this.flights,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [flights, total, currentPage, hasMore, isLoadingMore];
}

class FlightSearchLoadFailure extends FlightSearchState {
  const FlightSearchLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
