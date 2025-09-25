import 'dart:async';

import 'package:chat_bot/bloc/restaurant/restaurant_event.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/repositories/restaurant_repository.dart';
import 'package:chat_bot/utils/utility.dart';
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
    String storeCategoryName = '';
    String storeCategoryId = '';
    bool needToShowLoader = false;
    if (event is RestaurantFetchRequested) {
      keyword = event.keyword;
      storeCategoryName = event.storeCategoryName;
      storeCategoryId = event.storeCategoryId;
      needToShowLoader = event.needToShowLoader;
    } else if (event is RestaurantRefreshed) {
      keyword = event.keyword;
      storeCategoryName = event.storeCategoryName;
      storeCategoryId = event.storeCategoryId;
      needToShowLoader = event.needToShowLoader;
    }
    
    // Only show global loader for initial load, not for search
    if (keyword.isEmpty) {
      Utility.showLoader();
    }else if (needToShowLoader == true) {
      Utility.showLoader();
    }else{
      emit(RestaurantLoadInProgress());
    }
    
    try {
      final List<Store> stores = await repository.fetchStores(keyword: keyword, storeCategoryName: storeCategoryName, storeCategoryId: storeCategoryId);
      Utility.closeProgressDialog();
      emit(RestaurantLoadSuccess(restaurants: stores, keyword: keyword));
    } catch (e) {
      Utility.closeProgressDialog();
      emit(RestaurantLoadFailure(e.toString()));
    }
  }
}


