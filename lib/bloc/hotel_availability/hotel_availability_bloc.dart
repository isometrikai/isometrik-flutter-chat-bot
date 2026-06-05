import 'package:chat_bot/bloc/hotel_availability/hotel_availability_event.dart';
import 'package:chat_bot/bloc/hotel_availability/hotel_availability_state.dart';
import 'package:chat_bot/data/model/hotel_availability_response.dart';
import 'package:chat_bot/data/repositories/hotel_availability_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelAvailabilityBloc
    extends Bloc<HotelAvailabilityEvent, HotelAvailabilityState> {
  HotelAvailabilityBloc({HotelAvailabilityRepository? repository})
      : _repository = repository ?? HotelAvailabilityRepository(),
        super(HotelAvailabilityInitial()) {
    on<HotelAvailabilityFetchRequested>(_onFetchRequested);
    on<HotelRoomSelected>(_onRoomSelected);
  }

  final HotelAvailabilityRepository _repository;

  Future<void> _onFetchRequested(
    HotelAvailabilityFetchRequested event,
    Emitter<HotelAvailabilityState> emit,
  ) async {
    final summary = Utility.formatHotelBookingSummary(event.hotelBooking);

    emit(
      HotelAvailabilityLoadInProgress(
        hotelName: event.hotelName,
        hotelImageUrl: event.hotelImageUrl,
        bookingSummary: summary,
      ),
    );

    try {
      final result =
          await _repository.fetchAvailability(event.hotelBooking);
      if (result.isSuccess && result.data is HotelAvailabilityResponse) {
        final response = result.data as HotelAvailabilityResponse;
        if (response.rooms.isEmpty) {
          emit(const HotelAvailabilityLoadFailure('No rooms available'));
          return;
        }
        emit(
          HotelAvailabilityLoadSuccess(
            rooms: response.rooms,
            selectedRoomId: response.rooms.first.id,
            hotelName: event.hotelName,
            hotelImageUrl: event.hotelImageUrl,
            bookingSummary: summary,
          ),
        );
      } else {
        emit(
          HotelAvailabilityLoadFailure(
            result.message ?? 'Failed to load rooms',
          ),
        );
      }
    } catch (e) {
      emit(HotelAvailabilityLoadFailure(e.toString()));
    }
  }

  void _onRoomSelected(
    HotelRoomSelected event,
    Emitter<HotelAvailabilityState> emit,
  ) {
    final current = state;
    if (current is! HotelAvailabilityLoadSuccess) return;
    emit(current.copyWith(selectedRoomId: event.roomId));
  }
}
