import 'package:chat_bot/bloc/grocery_menu/grocery_menu_event.dart';
import 'package:chat_bot/bloc/grocery_menu/grocery_menu_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/enum.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroceryMenuBloc extends Bloc<GroceryMenuEvent, GroceryMenuState> {
  final RestaurantMenuRepository repository;
  final WidgetAction? actionData;

  GroceryMenuBloc({RestaurantMenuRepository? repository, this.actionData})
    : repository = repository ?? const RestaurantMenuRepository(),
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

      final int storeTypeId =
          actionData?.storeTypeId ?? event.storeTypeId ?? -111;
      final response =
          storeTypeId == FoodCategory.services.value
              ? await repository.fetchServiceGenieProducts(
                storeId: event.storeId,
                storeCategoryId: event.subCategoryId,
                storeCategoryName:
                    actionData?.storeCategoryName ?? event.storeCategoryName,
              )
              : await repository.fetchSubCategoryProducts(
                storeId: event.storeId,
                subCategoryId: event.subCategoryId,
              );

      print('✅ GroceryMenuBloc: API call successful');
      print('  - Response categories: ${response.categoryData.length}');
      Utility.closeProgressDialog();
      emit(SubCategoryProductsLoadSuccess(subCategoryProducts: response));
    } catch (e) {
      print('❌ GroceryMenuBloc: API call failed');
      print('  - Error: $e');
      Utility.closeProgressDialog();
      emit(
        SubCategoryProductsLoadFailure(
          'Failed to load subcategory products: $e',
        ),
      );
    }
  }
}
