import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:chat_bot/data/model/subcategory_products_response.dart';

abstract class GroceryMenuState extends Equatable {
  const GroceryMenuState();

  @override
  List<Object?> get props => [];
}

class GroceryMenuInitial extends GroceryMenuState {}

class GroceryMenuLoadInProgress extends GroceryMenuState {}

class GroceryMenuLoadSuccess extends GroceryMenuState {
  final List<ProductCategory> categories;
  final StoreData storeData;

  const GroceryMenuLoadSuccess({required this.categories, required this.storeData});

  @override
  List<Object?> get props => [categories, storeData];
}

class GroceryMenuLoadFailure extends GroceryMenuState {
  final String message;

  const GroceryMenuLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SubCategoryProductsLoadInProgress extends GroceryMenuState {}

class SubCategoryProductsLoadSuccess extends GroceryMenuState {
  final SubCategoryProductsResponse subCategoryProducts;

  const SubCategoryProductsLoadSuccess({required this.subCategoryProducts});

  @override
  List<Object?> get props => [subCategoryProducts];
}

class SubCategoryProductsLoadFailure extends GroceryMenuState {
  final String message;

  const SubCategoryProductsLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
