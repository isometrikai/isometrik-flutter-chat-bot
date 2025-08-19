import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/model/greeting_response.dart';

abstract class LaunchState extends Equatable {
  const LaunchState();

  @override
  List<Object?> get props => [];
}

class LaunchInitial extends LaunchState {}

class LaunchInProgress extends LaunchState {}

class LaunchSuccess extends LaunchState {
  final MyGPTsResponse chatbotData;
  final GreetingResponse? greetingData;

  const LaunchSuccess({required this.chatbotData, this.greetingData});

  @override
  List<Object?> get props => [chatbotData, greetingData];
}

class LaunchFailure extends LaunchState {
  final String message;

  const LaunchFailure(this.message);

  @override
  List<Object?> get props => [message];
}


