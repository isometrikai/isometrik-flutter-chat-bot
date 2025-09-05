import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/product_portion_response.dart';

abstract class ProductCustomizationState extends Equatable {
  const ProductCustomizationState();

  @override
  List<Object?> get props => [];
}

class ProductCustomizationInitial extends ProductCustomizationState {}

class ProductCustomizationLoading extends ProductCustomizationState {}

class ProductCustomizationLoaded extends ProductCustomizationState {
  final List<ProductPortion> variants;
  final ProductPortion? selectedVariant;
  final Map<String, Set<String>> selectedAddOns;
  final double totalPrice;

  const ProductCustomizationLoaded({
    required this.variants,
    this.selectedVariant,
    required this.selectedAddOns,
    required this.totalPrice,
  });

  ProductCustomizationLoaded copyWith({
    List<ProductPortion>? variants,
    ProductPortion? selectedVariant,
    Map<String, Set<String>>? selectedAddOns,
    double? totalPrice,
  }) {
    return ProductCustomizationLoaded(
      variants: variants ?? this.variants,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [variants, selectedVariant, selectedAddOns, totalPrice];
}

class ProductCustomizationError extends ProductCustomizationState {
  final String message;

  const ProductCustomizationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProductCustomizationSuccess extends ProductCustomizationState {
  final String message;
  final Map<String, List<String>> selectedCustomizations;

  const ProductCustomizationSuccess({
    required this.message,
    required this.selectedCustomizations,
  });

  @override
  List<Object?> get props => [message, selectedCustomizations];
}
