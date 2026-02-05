import 'package:chat_bot/bloc/user_preference/user_preference_event.dart';
import 'package:chat_bot/bloc/user_preference/user_preference_state.dart';
import 'package:chat_bot/data/model/user_preference_request.dart';
import 'package:chat_bot/data/repositories/user_preference_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserPreferenceBloc extends Bloc<UserPreferenceEvent, UserPreferenceState> {
  UserPreferenceBloc({UserPreferenceRepository? repository})
      : _repository = repository ?? UserPreferenceRepository(),
        super(const UserPreferenceState()) {
    on<UserPreferenceLoadRequested>(_onLoadRequested);
    on<UserPreferenceSubmitRequested>(_onSubmitRequested);
    on<UserPreferenceServicesUpdated>(_onServicesUpdated);
    on<UserPreferencePersonalDetailsUpdated>(_onPersonalDetailsUpdated);
    on<UserPreferenceImportantPeopleUpdated>(_onImportantPeopleUpdated);
    on<UserPreferenceFoodUpdated>(_onFoodUpdated);
    on<UserPreferenceShoppingUpdated>(_onShoppingUpdated);
    on<UserPreferenceHealthUpdated>(_onHealthUpdated);
    on<UserPreferenceTravelUpdated>(_onTravelUpdated);
    on<UserPreferenceHomeServicesUpdated>(_onHomeServicesUpdated);
    on<UserPreferenceBudgetUpdated>(_onBudgetUpdated);
    on<UserPreferenceNotificationUpdated>(_onNotificationUpdated);
  }

  final UserPreferenceRepository _repository;

  Future<void> _onLoadRequested(
    UserPreferenceLoadRequested event,
    Emitter<UserPreferenceState> emit,
  ) async {
    emit(state.copyWith(loadStatus: UserPreferenceLoadStatus.loading));
    try {
      final result = await _repository.getUserPreference();
      if (result.isSuccess && result.data != null) {
        final body = result.data is Map<String, dynamic> ? result.data as Map<String, dynamic> : null;
        final data = body?['data'];
        final parsed = data is Map<String, dynamic> ? UserPreferenceRequest.fromJson(data) : null;
        if (parsed != null) {
          emit(state.copyWith(
            request: parsed,
            loadStatus: UserPreferenceLoadStatus.success,
          ));
          return;
        }
      }
      emit(state.copyWith(loadStatus: UserPreferenceLoadStatus.failure));
    } catch (_) {
      emit(state.copyWith(loadStatus: UserPreferenceLoadStatus.failure));
    }
  }

  Future<void> _onSubmitRequested(
    UserPreferenceSubmitRequested event,
    Emitter<UserPreferenceState> emit,
  ) async {
    emit(state.copyWith(
      submitStatus: UserPreferenceSubmitStatus.loading,
      submitMessage: null,
    ));
    try {
      // GET returned data → PATCH (edit). GET error or no data → POST (create).
      final result = state.isLoadSuccess
          ? await _repository.patchUserPreference(state.request)
          : await _repository.postUserPreference(state.request);
      if (result.isSuccess) {
        emit(state.copyWith(
          submitStatus: UserPreferenceSubmitStatus.success,
          submitMessage: null,
        ));
        // Utility.showErrorBlackToast(state.isLoadSuccess ? 'Preferences updated successfully' : 'Preferences saved successfully');
      } else {
        emit(state.copyWith(
          submitStatus: UserPreferenceSubmitStatus.failure,
          submitMessage: result.message ?? 'Failed to save preferences',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        submitStatus: UserPreferenceSubmitStatus.failure,
        submitMessage: e.toString(),
      ));
    }
  }

  void _onServicesUpdated(
    UserPreferenceServicesUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(services: event.services),
    ));
  }

  void _onPersonalDetailsUpdated(
    UserPreferencePersonalDetailsUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(personalDetails: event.details),
    ));
  }

  void _onImportantPeopleUpdated(
    UserPreferenceImportantPeopleUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(importantPeople: event.people),
    ));
  }

  void _onFoodUpdated(
    UserPreferenceFoodUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(foodPreferences: event.prefs),
    ));
  }

  void _onShoppingUpdated(
    UserPreferenceShoppingUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(shoppingHabits: event.habits),
    ));
  }

  void _onHealthUpdated(
    UserPreferenceHealthUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(healthPreferences: event.prefs),
    ));
  }

  void _onTravelUpdated(
    UserPreferenceTravelUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(travelPreferences: event.prefs),
    ));
  }

  void _onHomeServicesUpdated(
    UserPreferenceHomeServicesUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(homeServices: event.home),
    ));
  }

  void _onBudgetUpdated(
    UserPreferenceBudgetUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(budgetAndDeals: event.budget),
    ));
  }

  void _onNotificationUpdated(
    UserPreferenceNotificationUpdated event,
    Emitter<UserPreferenceState> emit,
  ) {
    emit(state.copyWith(
      request: state.request.copyWith(notificationSettings: event.settings),
    ));
  }
}
