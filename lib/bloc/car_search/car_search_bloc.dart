import 'package:chat_bot/bloc/car_search/car_search_event.dart';
import 'package:chat_bot/bloc/car_search/car_search_state.dart';
import 'package:chat_bot/data/model/car_search_response.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/repositories/car_search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarSearchBloc extends Bloc<CarSearchEvent, CarSearchState> {
  CarSearchBloc({CarSearchRepository? repository})
      : _repository = repository ?? CarSearchRepository(),
        super(CarSearchInitial()) {
    on<CarSearchFetchRequested>(_onFetchRequested);
    on<CarSearchQueryChanged>(_onQueryChanged);
  }

  final CarSearchRepository _repository;

  Future<void> _onFetchRequested(
    CarSearchFetchRequested event,
    Emitter<CarSearchState> emit,
  ) async {
    emit(const CarSearchLoadInProgress());

    try {
      final result = await _repository.searchCars(action: event.action);

      if (result.isSuccess && result.data is CarSearchResponse) {
        final response = result.data as CarSearchResponse;
        emit(
          CarSearchLoadSuccess(
            rentals: response.rentals,
            filteredRentals: response.rentals,
            total: response.total,
            searchQuery: '',
          ),
        );
      } else {
        emit(
          CarSearchLoadFailure(
            result.message ?? 'Failed to search cars',
          ),
        );
      }
    } catch (e) {
      emit(CarSearchLoadFailure(e.toString()));
    }
  }

  void _onQueryChanged(
    CarSearchQueryChanged event,
    Emitter<CarSearchState> emit,
  ) {
    final current = state;
    if (current is! CarSearchLoadSuccess) return;

    emit(
      current.copyWith(
        searchQuery: event.searchQuery,
        filteredRentals: _applyClientFilter(
          current.rentals,
          event.searchQuery,
        ),
      ),
    );
  }

  static List<CarRentalSearch> _applyClientFilter(
    List<CarRentalSearch> rentals,
    String searchQuery,
  ) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return rentals;

    return rentals.where((rental) {
      final name = rental.name.toLowerCase();
      final vendor = rental.vendor.toLowerCase();
      final brand = rental.raw.rentalCarBrand.toLowerCase();
      final vehicleName = rental.raw.vehicle.name.toLowerCase();
      return name.contains(query) ||
          vendor.contains(query) ||
          brand.contains(query) ||
          vehicleName.contains(query);
    }).toList();
  }
}
