import 'package:chat_bot/data/model/chat_response.dart';
import 'package:equatable/equatable.dart';

abstract class HotelSearchState extends Equatable {
  const HotelSearchState();

  @override
  List<Object?> get props => [];
}

class HotelSearchInitial extends HotelSearchState {}

class HotelSearchLoadInProgress extends HotelSearchState {
  const HotelSearchLoadInProgress({
    this.searchQuery = '',
    this.selectedFilter = 'All',
  });

  final String searchQuery;
  final String selectedFilter;

  @override
  List<Object?> get props => [searchQuery, selectedFilter];
}

class HotelSearchLoadSuccess extends HotelSearchState {
  const HotelSearchLoadSuccess({
    required this.hotels,
    required this.filteredHotels,
    required this.total,
    required this.searchQuery,
    required this.selectedFilter,
  });

  final List<HotelProperty> hotels;
  final List<HotelProperty> filteredHotels;
  final int total;
  final String searchQuery;
  final String selectedFilter;

  HotelSearchLoadSuccess copyWith({
    List<HotelProperty>? hotels,
    List<HotelProperty>? filteredHotels,
    int? total,
    String? searchQuery,
    String? selectedFilter,
  }) {
    return HotelSearchLoadSuccess(
      hotels: hotels ?? this.hotels,
      filteredHotels: filteredHotels ?? this.filteredHotels,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props =>
      [hotels, filteredHotels, total, searchQuery, selectedFilter];
}

class HotelSearchLoadFailure extends HotelSearchState {
  const HotelSearchLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
