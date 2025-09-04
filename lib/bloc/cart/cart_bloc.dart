import 'dart:async';

import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';

import 'package:chat_bot/data/repositories/cart_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;
  // final CartManager cartManager = CartManager();
  List<UniversalCartData> cartData = [];

  int totalProductCount = 0;

  // Getter for total product count
  int get getTotalProductCount => totalProductCount;

  CartBloc({CartRepository? repository})
      : repository = repository ?? const CartRepository(),
        super(CartInitial()) {
    
    on<CartFetchRequested>(_onCartFetchRequested);
    on<CartAddItemRequested>(_onCartAddItemRequested);
  }

  Future<void> _onCartFetchRequested(
    CartFetchRequested event,
    Emitter<CartState> emit,
  ) async {
    if (event.needToShowLoader) { 
      Utility.showLoader();
    }

    try {
      // Fetch raw cart data once and use it for both purposes
      final rawResult = await repository.fetchRawUniversalCart();

       if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }
      
      if (rawResult.isSuccess) {
        final rawCartData = rawResult.data as UniversalCartResponse;
          cartId = rawCartData.data.first.id;
          print('cartId: $cartId');
        
        // Convert to widget actions
        final widgetActions = rawCartData.toWidgetActions();
        
        String? storeName;
        String? storeType;
        
        if (rawCartData.data.isNotEmpty) {
          cartData = rawCartData.data;
          final cart = rawCartData.data.first;
          final seller = cart.sellers.isNotEmpty ? cart.sellers.first : null;

        //   // Store the store info
          storeName = seller?.name;
          storeType = seller?.storeType;
        }
        
        if (widgetActions.isEmpty) {
          emit(CartEmpty());
        } else {
          emit(CartLoaded(
            cartItems: widgetActions,
            rawCartData: rawCartData,
            storeName: storeName,
            storeType: storeType,
          ));
        }
        
      } else {
        emit(CartError(message: rawResult.message ?? 'Failed to fetch cart'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
       if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }
    }
  }

  // Method to manually update cart count (useful for testing or manual updates)
  void updateCartCount(int count) {
    totalProductCount = count;
  }

  // Get CartManager instance
  // CartManager get getCartManager => cartManager;

  /// Validate cart compatibility before adding new items
  CartValidationResult _validateCartCompatibility(CartAddItemRequested event) {
    // If cart is empty, allow adding any item
    if (cartData.isEmpty) {
      return CartValidationResult(isValid: true);
    }

    // Get the first cart data to check existing store info
    final existingCart = cartData.first;
    
    // Check if store type ID matches
    if (existingCart.storeTypeId != event.storeTypeId) {
      return CartValidationResult(
        isValid: false,
        errorMessage: 'Cannot add items from different store types. Please clear your cart first.',
      );
    }

    // Check if store ID matches (from seller info)
    if (existingCart.sellers.isNotEmpty) {
      // Check if any product in the cart has a different store ID
      for (final seller in existingCart.sellers) {
        for (final product in seller.products) {
          if (product.storeId != null && product.storeId != event.storeId) {
            return CartValidationResult(
              isValid: false,
              errorMessage: 'Cannot add items from different stores. Please clear your cart first.',
            );
          }
        }
      }
    }

    return CartValidationResult(isValid: true);
  }

  /// Handle adding items to cart
  Future<void> _onCartAddItemRequested(
    CartAddItemRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      
              // Validate cart compatibility before making API call
        final validationResult = _validateCartCompatibility(event);
        if (!validationResult.isValid) {
          // Show confirmation dialog for cart validation error
          final userChoice = await Utility.showConfirmationDialog(
            title: 'Remove Cart?',
            message: 'You already have items from a different store in your cart. Would you like to replace them?',
            primaryButtonText: 'Yes',
            secondaryButtonText: 'Cancel',
            barrierDismissible: false,
          );
          
          if (userChoice == true) {
            // User chose to clear cart - call clear cart API
            if (cartId.isNotEmpty) {
              final clearResult = await repository.clearCart(cartId: cartId);
              if (clearResult.isSuccess) {
                // Cart cleared successfully, now add the new item
                // Clear local cart data
                cartData.clear();
                // Call the same event again to add the pending item
                add(event);
                return;
              } else {
                emit(CartError(message: clearResult.message ?? 'Failed to clear cart'));
                return;
              }
            } else {
              // No cart ID available, just clear local data and continue
              cartData.clear();
              // Call the same event again to add the pending item
              add(event);
              return;
            }
          } else {
            // User cancelled, don't add the item
            return;
          }
        }

       // emit(CartLoading());
      if (event.needToShowLoader) {
        Utility.showLoader();
      }
      
      final result = await repository.addToCart(
        storeId: event.storeId,
        cartType: event.cartType,
        action: event.action,
        storeCategoryId: event.storeCategoryId,
        newQuantity: event.newQuantity,
        storeTypeId: event.storeTypeId,
        productId: event.productId,
        centralProductId: event.centralProductId,
        unitId: '', //event.unitId,
        newAddOns: event.newAddOns,
        addToCartOnId: event.addToCartOnId,
      );

      if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }

      if (result.isSuccess) {
        isCartAPICalled = true;
        emit(CartProductAdded());
        add(CartFetchRequested(needToShowLoader: false));
      } else {
        emit(CartError(message: result.message ?? 'Failed to add item to cart'));
      }
    } catch (e) {
       if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }
      emit(CartError(message: e.toString()));
    }
  }
}
var cartId = '';
var isCartAPICalled = false;

/// Result class for cart validation
class CartValidationResult {
  final bool isValid;
  final String errorMessage;

  CartValidationResult({
    required this.isValid,
    this.errorMessage = '',
  });
}
