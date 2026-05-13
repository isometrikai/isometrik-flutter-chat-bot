import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/user_preference_request.dart';

abstract class UserPreferenceEvent extends Equatable {
  const UserPreferenceEvent();

  @override
  List<Object?> get props => [];
}

/// Load user preference (GET) when flow screen opens. Binds response into state.request.
class UserPreferenceLoadRequested extends UserPreferenceEvent {
  const UserPreferenceLoadRequested();
}

/// Submit current preference (POST). Emits loading then success/failure.
class UserPreferenceSubmitRequested extends UserPreferenceEvent {
  const UserPreferenceSubmitRequested();
}

/// Update services selection (step 0) - pass selected keys as true
class UserPreferenceServicesUpdated extends UserPreferenceEvent {
  const UserPreferenceServicesUpdated(this.services);
  final UserPreferenceServices services;

  @override
  List<Object?> get props => [services];
}

/// Update personal details (step 1)
class UserPreferencePersonalDetailsUpdated extends UserPreferenceEvent {
  const UserPreferencePersonalDetailsUpdated(this.details);
  final UserPreferencePersonalDetails details;

  @override
  List<Object?> get props => [details];
}

/// Update important people list (step 2)
class UserPreferenceImportantPeopleUpdated extends UserPreferenceEvent {
  const UserPreferenceImportantPeopleUpdated(this.people);
  final List<UserPreferenceImportantPerson> people;

  @override
  List<Object?> get props => [people];
}

/// Update food preferences (step 3)
class UserPreferenceFoodUpdated extends UserPreferenceEvent {
  const UserPreferenceFoodUpdated(this.prefs);
  final UserPreferenceFoodPreferences prefs;

  @override
  List<Object?> get props => [prefs];
}

/// Update shopping habits (step 4)
class UserPreferenceShoppingUpdated extends UserPreferenceEvent {
  const UserPreferenceShoppingUpdated(this.habits);
  final UserPreferenceShoppingHabits habits;

  @override
  List<Object?> get props => [habits];
}

/// Update health preferences (step 5)
class UserPreferenceHealthUpdated extends UserPreferenceEvent {
  const UserPreferenceHealthUpdated(this.prefs);
  final UserPreferenceHealthPreferences prefs;

  @override
  List<Object?> get props => [prefs];
}

/// Update travel preferences (step 6)
class UserPreferenceTravelUpdated extends UserPreferenceEvent {
  const UserPreferenceTravelUpdated(this.prefs);
  final UserPreferenceTravelPreferences prefs;

  @override
  List<Object?> get props => [prefs];
}

/// Update home services (step 7)
class UserPreferenceHomeServicesUpdated extends UserPreferenceEvent {
  const UserPreferenceHomeServicesUpdated(this.home);
  final UserPreferenceHomeServices home;

  @override
  List<Object?> get props => [home];
}

/// Update budget & deals (step 8)
class UserPreferenceBudgetUpdated extends UserPreferenceEvent {
  const UserPreferenceBudgetUpdated(this.budget);
  final UserPreferenceBudgetAndDeals budget;

  @override
  List<Object?> get props => [budget];
}

/// Update notification settings (step 9)
class UserPreferenceNotificationUpdated extends UserPreferenceEvent {
  const UserPreferenceNotificationUpdated(this.settings);
  final UserPreferenceNotificationSettings settings;

  @override
  List<Object?> get props => [settings];
}
