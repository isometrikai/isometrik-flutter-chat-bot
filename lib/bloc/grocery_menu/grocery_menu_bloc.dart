import 'package:chat_bot/bloc/grocery_menu/grocery_menu_event.dart';
import 'package:chat_bot/bloc/grocery_menu/grocery_menu_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:chat_bot/data/repositories/restaurant_menu_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroceryMenuBloc extends Bloc<GroceryMenuEvent, GroceryMenuState> {
  final RestaurantMenuRepository repository;
  final WidgetAction? actionData;

  GroceryMenuBloc({
    RestaurantMenuRepository? repository,
    this.actionData,
  })  : repository = repository ?? const RestaurantMenuRepository(),
        super(GroceryMenuInitial()) {
    on<GroceryMenuRequested>(_onRequested);
    on<GroceryMenuRefreshed>(_onRequested);
  }

  Future<void> _onRequested(
    GroceryMenuEvent event,
    Emitter<GroceryMenuState> emit,
  ) async {
    emit(GroceryMenuLoadInProgress());
    try {
      final String storeId = actionData?.storeId?.isNotEmpty == true
          ? actionData?.storeId ?? ''
          : '63627cf6b35f2f000c9ecc23';

      final obj = await repository.fetchMenu(
        storeId: storeId,
      );

      emit(GroceryMenuLoadSuccess(categories: obj.productData, storeData: obj.storeData));
    } catch (e) {
      emit(GroceryMenuLoadFailure(e.toString()));
    }
  }
}
