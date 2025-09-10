import 'package:equatable/equatable.dart';

abstract class GroceryMenuEvent extends Equatable {
  const GroceryMenuEvent();

  @override
  List<Object?> get props => [];
}

class GroceryMenuRequested extends GroceryMenuEvent {
  const GroceryMenuRequested();
}

class GroceryMenuRefreshed extends GroceryMenuEvent {
  const GroceryMenuRefreshed();
}

class SubCategoryProductsRequested extends GroceryMenuEvent {
  final String storeId;
  final String subCategoryId;

  const SubCategoryProductsRequested({
    required this.storeId,
    required this.subCategoryId,
  });

  @override
  List<Object?> get props => [storeId, subCategoryId];
}
