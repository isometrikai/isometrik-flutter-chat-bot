import 'package:chat_bot/bloc/flight_search/flight_search_event.dart';
import 'package:chat_bot/bloc/flight_search/flight_search_state.dart';
import 'package:chat_bot/data/model/flight_search_response.dart';
import 'package:chat_bot/data/repositories/flight_search_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlightSearchBloc extends Bloc<FlightSearchEvent, FlightSearchState> {
  FlightSearchBloc({FlightSearchRepository? repository})
      : _repository = repository ?? FlightSearchRepository(),
        super(FlightSearchInitial()) {
    on<FlightSearchFetchRequested>(_onFetchRequested);
    on<FlightSearchLoadMoreRequested>(_onLoadMoreRequested);
  }

  final FlightSearchRepository _repository;

  Future<void> _onFetchRequested(
    FlightSearchFetchRequested event,
    Emitter<FlightSearchState> emit,
  ) async {
    emit(const FlightSearchLoadInProgress());

    try {
      final result = await _repository.searchFlights(
        action: event.action,
        flightBooking: event.flightBooking,
        page: 1,
        limit: FlightSearchRepository.defaultPageLimit,
      );

      if (result.isSuccess && result.data is FlightSearchResponse) {
        final response = result.data as FlightSearchResponse;
        emit(
          FlightSearchLoadSuccess(
            flights: response.flights,
            total: response.total,
            currentPage: 1,
            hasMore: _hasMore(
              loadedCount: response.flights.length,
              pageCount: response.flights.length,
              total: response.total,
            ),
          ),
        );
      } else {
        emit(
          FlightSearchLoadFailure(
            result.message ?? 'Failed to search flights',
          ),
        );
      }
    } catch (e) {
      emit(FlightSearchLoadFailure(e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    FlightSearchLoadMoreRequested event,
    Emitter<FlightSearchState> emit,
  ) async {
    final current = state;
    if (current is! FlightSearchLoadSuccess) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final result = await _repository.searchFlights(
        action: event.action,
        flightBooking: event.flightBooking,
        page: nextPage,
        limit: FlightSearchRepository.defaultPageLimit,
      );

      if (result.isSuccess && result.data is FlightSearchResponse) {
        final response = result.data as FlightSearchResponse;
        final allFlights = [...current.flights, ...response.flights];

        emit(
          current.copyWith(
            flights: allFlights,
            total: response.total > 0 ? response.total : current.total,
            currentPage: nextPage,
            isLoadingMore: false,
            hasMore: _hasMore(
              loadedCount: allFlights.length,
              pageCount: response.flights.length,
              total: response.total > 0 ? response.total : current.total,
            ),
          ),
        );
      } else {
        emit(current.copyWith(isLoadingMore: false));
      }
    } catch (_) {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  static bool _hasMore({
    required int loadedCount,
    required int pageCount,
    required int total,
  }) {
    if (pageCount < FlightSearchRepository.defaultPageLimit) {
      return false;
    }
    if (total > 0) {
      return loadedCount < total;
    }
    return pageCount >= FlightSearchRepository.defaultPageLimit;
  }
}
