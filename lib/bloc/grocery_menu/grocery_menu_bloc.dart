import 'package:chat_bot/bloc/grocery_menu/grocery_menu_event.dart';
import 'package:chat_bot/bloc/grocery_menu/grocery_menu_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/repositories/restaurant_menu_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroceryMenuBloc extends Bloc<GroceryMenuEvent, GroceryMenuState> {
  final RestaurantMenuRepository repository;
  final WidgetAction? actionData;

  GroceryMenuBloc({
    RestaurantMenuRepository? repository,
    this.actionData,
  })  : repository = repository ?? const RestaurantMenuRepository(),
        super(GroceryMenuInitial()) {
    // on<GroceryMenuRequested>(_onRequested);
    // on<GroceryMenuRefreshed>(_onRequested);
    on<SubCategoryProductsRequested>(_onSubCategoryProductsRequested);
  }

  Future<void> _onSubCategoryProductsRequested(
    SubCategoryProductsRequested event,
    Emitter<GroceryMenuState> emit,
  ) async {
    Utility.showLoader();
    // emit(SubCategoryProductsLoadInProgress());
    try {
      print('🚀 GroceryMenuBloc: Starting SubCategoryProducts API call');
      print('  - All parameters now passed as headers');
      
      final response = await repository.fetchSubCategoryProducts(storeId: event.storeId, subCategoryId: event.subCategoryId);

      print('✅ GroceryMenuBloc: API call successful');
      print('  - Response categories: ${response.categoryData.length}');
      Utility.closeProgressDialog();
      emit(SubCategoryProductsLoadSuccess(subCategoryProducts: response));
    } catch (e) {
      print('❌ GroceryMenuBloc: API call failed');
      print('  - Error: $e');
      Utility.closeProgressDialog();
      emit(SubCategoryProductsLoadFailure('Failed to load subcategory products: $e'));
    }
  }
}
