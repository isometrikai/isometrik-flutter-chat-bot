import 'package:chat_bot/bloc/store_details/store_details_event.dart';
import 'package:chat_bot/bloc/store_details/store_details_state.dart';
import 'package:chat_bot/data/repositories/availability_slots_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreDetailsBloc extends Bloc<StoreDetailsEvent, StoreDetailsState> {
  final AvailabilitySlotsRepository repository;

  StoreDetailsBloc({AvailabilitySlotsRepository? repository})
      : repository = repository ?? const AvailabilitySlotsRepository(),
        super(StoreDetailsInitial()) {
    on<AvailabilitySlotsRequested>(_onAvailabilitySlotsRequested);
  }

  Future<void> _onAvailabilitySlotsRequested(
    AvailabilitySlotsRequested event,
    Emitter<StoreDetailsState> emit,
  ) async {
    emit(StoreDetailsLoadInProgress(date: event.date));
    try {
      final slots = await repository.fetchAvailabilitySlots(
        date: event.date,
        userId: event.userId,
        storeCategoryId: event.storeCategoryId,
        eventType: event.eventType,
        timeZone: event.timeZone,
      );
      emit(StoreDetailsLoadSuccess(date: event.date, slots: slots));
    } catch (e) {
      emit(StoreDetailsLoadFailure(e.toString(), date: event.date));
    }
  }
}
