import 'package:chat_bot/data/model/chat_response.dart';
import 'package:equatable/equatable.dart';

abstract class CarSearchState extends Equatable {
  const CarSearchState();

  @override
  List<Object?> get props => [];
}

class CarSearchInitial extends CarSearchState {}

class CarSearchLoadInProgress extends CarSearchState {
  const CarSearchLoadInProgress({this.searchQuery = ''});

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

class CarSearchLoadSuccess extends CarSearchState {
  const CarSearchLoadSuccess({
    required this.rentals,
    required this.filteredRentals,
    required this.total,
    required this.searchQuery,
  });

  final List<CarRentalSearch> rentals;
  final List<CarRentalSearch> filteredRentals;
  final int total;
  final String searchQuery;

  CarSearchLoadSuccess copyWith({
    List<CarRentalSearch>? rentals,
    List<CarRentalSearch>? filteredRentals,
    int? total,
    String? searchQuery,
  }) {
    return CarSearchLoadSuccess(
      rentals: rentals ?? this.rentals,
      filteredRentals: filteredRentals ?? this.filteredRentals,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [rentals, filteredRentals, total, searchQuery];
}

class CarSearchLoadFailure extends CarSearchState {
  const CarSearchLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
