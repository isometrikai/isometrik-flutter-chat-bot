import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/product_portion_response.dart';

abstract class ProductCustomizationEvent extends Equatable {
  const ProductCustomizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductPortions extends ProductCustomizationEvent {
  final String centralProductId;
  final String childProductId;
  final String storeId;

  const LoadProductPortions({
    required this.centralProductId,
    required this.childProductId,
    required this.storeId,
  });

  @override
  List<Object?> get props => [centralProductId, childProductId, storeId];
}

class SelectProductVariant extends ProductCustomizationEvent {
  final ProductPortion variant;

  const SelectProductVariant({required this.variant});

  @override
  List<Object?> get props => [variant];
}

class ToggleAddOnItem extends ProductCustomizationEvent {
  final String addOnCategoryName;
  final String addOnItemId;
  final bool isSelected;

  const ToggleAddOnItem({
    required this.addOnCategoryName,
    required this.addOnItemId,
    required this.isSelected,
  });

  @override
  List<Object?> get props => [addOnCategoryName, addOnItemId, isSelected];
}

class ResetCustomization extends ProductCustomizationEvent {}

class AddToCart extends ProductCustomizationEvent {
  final int quantity;
  final Map<String, List<String>> selectedCustomizations;

  const AddToCart({
    required this.quantity,
    required this.selectedCustomizations,
  });

  @override
  List<Object?> get props => [quantity, selectedCustomizations];
}
