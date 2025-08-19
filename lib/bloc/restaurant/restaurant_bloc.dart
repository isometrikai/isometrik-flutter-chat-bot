import 'dart:async';

import 'package:chat_bot/bloc/restaurant/restaurant_event.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/repositories/restaurant_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository repository;

  RestaurantBloc({RestaurantRepository? repository})
      : repository = repository ?? const RestaurantRepository(),
        super(RestaurantInitial()) {
    on<RestaurantFetchRequested>(_onFetchRequested);
    on<RestaurantRefreshed>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(
    RestaurantEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    String keyword = '';
    if (event is RestaurantFetchRequested) {
      keyword = event.keyword;
    } else if (event is RestaurantRefreshed) {
      keyword = event.keyword;
    }

    emit(RestaurantLoadInProgress());
    try {
      final List<Store> stores = await repository.fetchStores(keyword: keyword);
      emit(RestaurantLoadSuccess(restaurants: stores, keyword: keyword));
    } catch (e) {
      emit(RestaurantLoadFailure(e.toString()));
    }
  }
}


