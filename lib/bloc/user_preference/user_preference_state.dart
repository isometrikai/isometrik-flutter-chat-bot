import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/user_preference_request.dart';

enum UserPreferenceSubmitStatus { idle, loading, success, failure }

enum UserPreferenceLoadStatus { idle, loading, success, failure }

class UserPreferenceState extends Equatable {
  const UserPreferenceState({
    UserPreferenceRequest? request,
    this.submitStatus = UserPreferenceSubmitStatus.idle,
    this.submitMessage,
    this.loadStatus = UserPreferenceLoadStatus.idle,
  }) : request = request ?? const UserPreferenceRequest();

  final UserPreferenceRequest request;
  final UserPreferenceSubmitStatus submitStatus;
  final String? submitMessage;
  final UserPreferenceLoadStatus loadStatus;

  UserPreferenceState copyWith({
    UserPreferenceRequest? request,
    UserPreferenceSubmitStatus? submitStatus,
    String? submitMessage,
    UserPreferenceLoadStatus? loadStatus,
  }) {
    return UserPreferenceState(
      request: request ?? this.request,
      submitStatus: submitStatus ?? this.submitStatus,
      submitMessage: submitMessage ?? this.submitMessage,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }

  @override
  List<Object?> get props => [request, submitStatus, submitMessage, loadStatus];

  bool get isSubmitting => submitStatus == UserPreferenceSubmitStatus.loading;
  bool get isSubmitSuccess => submitStatus == UserPreferenceSubmitStatus.success;
  bool get isSubmitFailure => submitStatus == UserPreferenceSubmitStatus.failure;
  bool get isLoading => loadStatus == UserPreferenceLoadStatus.loading;
  bool get isLoadSuccess => loadStatus == UserPreferenceLoadStatus.success;
  bool get isLoadFailure => loadStatus == UserPreferenceLoadStatus.failure;
}
