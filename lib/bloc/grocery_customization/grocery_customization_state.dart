import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/grocery_product_details_response.dart';

abstract class GroceryCustomizationState extends Equatable {
  const GroceryCustomizationState();

  @override
  List<Object?> get props => [];
}

class GroceryCustomizationInitial extends GroceryCustomizationState {}

class GroceryCustomizationLoading extends GroceryCustomizationState {}

class GroceryCustomizationLoaded extends GroceryCustomizationState {
  final GroceryProduct product;
  final GroceryProductVariant? selectedVariant;
  final GroceryProductSizeData? selectedSizeData;
  final int quantity;
  final double totalPrice;

  const GroceryCustomizationLoaded({
    required this.product,
    this.selectedVariant,
    this.selectedSizeData,
    required this.quantity,
    required this.totalPrice,
  });

  GroceryCustomizationLoaded copyWith({
    GroceryProduct? product,
    GroceryProductVariant? selectedVariant,
    GroceryProductSizeData? selectedSizeData,
    int? quantity,
    double? totalPrice,
  }) {
    return GroceryCustomizationLoaded(
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedSizeData: selectedSizeData ?? this.selectedSizeData,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [product, selectedVariant, selectedSizeData, quantity, totalPrice];
}

class GroceryCustomizationError extends GroceryCustomizationState {
  final String message;

  const GroceryCustomizationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class GroceryCustomizationSuccess extends GroceryCustomizationState {
  final String message;
  final GroceryProduct product;
  final GroceryProductSizeData selectedSizeData;
  final int quantity;

  const GroceryCustomizationSuccess({
    required this.message,
    required this.product,
    required this.selectedSizeData,
    required this.quantity,
  });

  @override
  List<Object?> get props => [message, product, selectedSizeData, quantity];
}
