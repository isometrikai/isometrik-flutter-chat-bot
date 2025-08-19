import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_event.dart';
import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:chat_bot/data/repositories/restaurant_menu_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RestaurantMenuBloc extends Bloc<RestaurantMenuEvent, RestaurantMenuState> {
  final RestaurantMenuRepository repository;
  final SeeMoreAction? actionData;

  RestaurantMenuBloc({
    RestaurantMenuRepository? repository,
    this.actionData,
  })  : repository = repository ?? const RestaurantMenuRepository(),
        super(RestaurantMenuInitial()) {
    on<RestaurantMenuRequested>(_onRequested);
    on<RestaurantMenuRefreshed>(_onRequested);
  }

  Future<void> _onRequested(
    RestaurantMenuEvent event,
    Emitter<RestaurantMenuState> emit,
  ) async {
    emit(RestaurantMenuLoadInProgress());
    try {
      final String storeId = actionData?.storeCategoryId.isNotEmpty == true
          ? actionData!.storeCategoryId
          : '63627cf6b35f2f000c9ecc23';

      final List<ProductCategory> categories = await repository.fetchMenu(
        storeId: storeId,
      );

      emit(RestaurantMenuLoadSuccess(categories: categories));
    } catch (e) {
      emit(RestaurantMenuLoadFailure(e.toString()));
    }
  }
}


