import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/grocery_product_details_response.dart';

abstract class GroceryCustomizationEvent extends Equatable {
  const GroceryCustomizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroceryProductDetails extends GroceryCustomizationEvent {
  final String parentProductId;
  final String productId;
  final String storeId;

  const LoadGroceryProductDetails({
    required this.parentProductId,
    required this.productId,
    required this.storeId,
  });

  @override
  List<Object?> get props => [parentProductId, productId, storeId];
}

class SelectGroceryProductVariant extends GroceryCustomizationEvent {
  final GroceryProductSizeData variant;

  const SelectGroceryProductVariant({required this.variant});

  @override
  List<Object?> get props => [variant];
}

class UpdateGroceryQuantity extends GroceryCustomizationEvent {
  final int quantity;

  const UpdateGroceryQuantity({required this.quantity});

  @override
  List<Object?> get props => [quantity];
}

class AddGroceryToCart extends GroceryCustomizationEvent {
  final int quantity;
  final String selectedVariantId;

  const AddGroceryToCart({
    required this.quantity,
    required this.selectedVariantId,
  });

  @override
  List<Object?> get props => [quantity, selectedVariantId];
}
