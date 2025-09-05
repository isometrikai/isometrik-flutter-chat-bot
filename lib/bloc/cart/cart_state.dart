import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';

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

class CartProductAdded extends CartState {}

class CartError extends CartState {
  final String message;

  CartError({required this.message});
}


