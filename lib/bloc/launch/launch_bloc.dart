import 'dart:async';

import 'package:chat_bot/bloc/launch/launch_event.dart';
import 'package:chat_bot/bloc/launch/launch_state.dart';
import 'package:chat_bot/data/repositories/launch_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final LaunchRepository repository;

  LaunchBloc({LaunchRepository? repository})
      : repository = repository ?? const LaunchRepository(),
        super(LaunchInitial()) {
    on<LaunchRequested>(_onRequested);
    on<LaunchRetried>(_onRequested);
  }

  Future<void> _onRequested(
    LaunchEvent event,
    Emitter<LaunchState> emit,
  ) async {
    // emit(LaunchInProgress());
    // Utility.showLoader();
    try {
      await repository.initialize();
      final chatbotData = await repository.getChatbotData();
      final greetingData = await repository.getInitialOptionData();
      // if (chatbotData == null) {
      if (greetingData == null || chatbotData == null) {
        emit(const LaunchFailure('Failed to load chatbot data'));
        // Utility.closeProgressDialog();
        return;
      }
      // Utility.closeProgressDialog();
      emit(LaunchSuccess(chatbotData: chatbotData, greetingData: greetingData));
    } catch (e) {
      emit(LaunchFailure(e.toString()));
    }
  }
}


