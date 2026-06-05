import 'package:chat_bot/bloc/hotel_search/hotel_search_event.dart';
import 'package:chat_bot/bloc/hotel_search/hotel_search_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/hotel_search_response.dart';
import 'package:chat_bot/data/repositories/hotel_search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelSearchBloc extends Bloc<HotelSearchEvent, HotelSearchState> {
  HotelSearchBloc({HotelSearchRepository? repository})
      : _repository = repository ?? HotelSearchRepository(),
        super(HotelSearchInitial()) {
    on<HotelSearchFetchRequested>(_onFetchRequested);
    on<HotelSearchFilterChanged>(_onFilterChanged);
  }

  final HotelSearchRepository _repository;

  static const List<String> filterOptions = [
    'All',
    'Beach view',
    'Infinity pool',
    'Luxury',
  ];

  Future<void> _onFetchRequested(
    HotelSearchFetchRequested event,
    Emitter<HotelSearchState> emit,
  ) async {
    emit(
      HotelSearchLoadInProgress(
        searchQuery: event.searchQuery,
        selectedFilter: event.selectedFilter,
      ),
    );

    try {
      final result = await _repository.searchHotels(
        action: event.action,
        searchName: event.searchQuery,
      );

      if (result.isSuccess && result.data is HotelSearchResponse) {
        final response = result.data as HotelSearchResponse;
        final filtered = _applyClientFilter(
          response.hotels,
          event.selectedFilter,
        );
        emit(
          HotelSearchLoadSuccess(
            hotels: response.hotels,
            filteredHotels: filtered,
            total: response.total,
            searchQuery: event.searchQuery,
            selectedFilter: event.selectedFilter,
          ),
        );
      } else {
        emit(
          HotelSearchLoadFailure(
            result.message ?? 'Failed to search hotels',
          ),
        );
      }
    } catch (e) {
      emit(HotelSearchLoadFailure(e.toString()));
    }
  }

  void _onFilterChanged(
    HotelSearchFilterChanged event,
    Emitter<HotelSearchState> emit,
  ) {
    final current = state;
    if (current is! HotelSearchLoadSuccess) return;

    emit(
      current.copyWith(
        selectedFilter: event.filter,
        filteredHotels: _applyClientFilter(current.hotels, event.filter),
      ),
    );
  }

  static List<HotelProperty> _applyClientFilter(
    List<HotelProperty> hotels,
    String filter,
  ) {
    if (filter == 'All' || filter.isEmpty) return hotels;

    final query = filter.toLowerCase();
    return hotels.where((hotel) {
      final name = hotel.name.toLowerCase();
      final chain = hotel.chain.toLowerCase();
      final city = hotel.contact.address.city.toLowerCase();
      return name.contains(query) || chain.contains(query) || city.contains(query);
    }).toList();
  }
}
