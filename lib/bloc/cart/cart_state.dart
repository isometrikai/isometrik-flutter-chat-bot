import 'package:chat_bot/data/data.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<WidgetAction> cartItems;
  final UniversalCartResponse? rawCartData;
  final String? storeName;
  final String? storeType;

  CartLoaded({
    required this.cartItems,
    this.rawCartData,
    this.storeName,
    this.storeType,
  });
}

class CartEmpty extends CartState {}

class CartProductAdded extends CartState {
  final String storeCategoryId;

  CartProductAdded({required this.storeCategoryId});

}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}


