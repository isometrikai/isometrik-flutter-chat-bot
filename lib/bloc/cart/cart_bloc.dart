import 'dart:async';

import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';

import 'package:chat_bot/data/repositories/cart_repository.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<UniversalCartData> globalCartData = [];

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;
  // final CartManager cartManager = CartManager();
  List<UniversalCartData> cartData = [];

  

  // Getter for total product count
  int get getTotalProductCount {
    // print('CartBloc getTotalProductCount called: $totalProductCount');
    return totalProductCount;
  }

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
    print('CALLBACK MANAGER cart bloc  2: $event');
    // if (event.needToShowLoader) { 
    //   Utility.showLoader();
    // }
    print('CALLBACK MANAGER cart bloc  3');
    try {
      // Fetch raw cart data once and use it for both purposes
      final rawResult = await repository.fetchRawUniversalCart();
      print('CALLBACK MANAGER cart bloc  4');
      //  if (event.needToShowLoader) {
      //   Utility.closeProgressDialog();
      // }
      print('CALLBACK MANAGER cart bloc  5');
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
          globalCartData = rawCartData.data;
          final cart = rawCartData.data.first;
          final seller = cart.sellers.isNotEmpty ? cart.sellers.first : null;

          storeName = seller?.name;
          storeType = seller?.storeType;
          
          // Calculate total product count
          totalProductCount = 0;
          for (final cartItem in rawCartData.data) {
            for (final sellerItem in cartItem.sellers) {
              // for (final product in sellerItem.products) {
                totalProductCount += sellerItem.products.length;
              // }
            }
          }
          print('CartBloc: Calculated totalProductCount: $totalProductCount');
        }else {
          cartData.clear();
          globalCartData.clear();
          totalProductCount = 0;
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
        cartData.clear();
        globalCartData.clear();
        totalProductCount = 0;
        emit(CartEmpty());
        // emit(CartError(message: rawResult.message ?? 'Failed to fetch cart'));
      }
    } catch (e) {
      print('CALLBACK MANAGER cart bloc error 1: $e');
      cartData.clear();
      globalCartData.clear();
      totalProductCount = 0;
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

  /// Validate cart compatibility before adding new items
  CartValidationResult _validateCartCompatibility(CartAddItemRequested event) {
    // If cart is empty, allow adding any item
    if (cartData.isEmpty && globalCartData.isEmpty) {
      return CartValidationResult(isValid: true);
    }
    // if (globalCartData.isNotEmpty && cartData.isEmpty) {
      cartData = globalCartData;
    // }
    if (cartData.isEmpty) {
      return CartValidationResult(isValid: true);
    }

    // Check all cart items for compatibility
    for (final existingCart in cartData) {
      // If store type ID is the same, check if store ID matches
      if (existingCart.storeTypeId == event.storeTypeId) {
        if (existingCart.sellers.isNotEmpty) {
          // Check if any product in the cart has a different store ID
          for (final seller in existingCart.sellers) {
            for (final product in seller.products) {
              if (product.storeId != null && product.storeId != event.storeId) {
                cartId = existingCart.id;
                return CartValidationResult(
                  isValid: false,
                  errorMessage: 'Cannot add items from different stores. Please clear your cart first.',
                );
              }
            }
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
                globalCartData.clear();
                totalProductCount = 0;
                // Call the same event again to add the pending item
                add(event);
                return;
              } else {
                add(event);//i Added
                // emit(CartError(message: clearResult.message ?? 'Failed to clear cart'));
                return;
              }
            } else {
              // No cart ID available, just clear local data and continue
              cartData.clear();
              globalCartData.clear();
              totalProductCount = 0;
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
        add(CartFetchRequested(needToShowLoader: event.needToShowLoaderForCartFetch));
      } else {
        add(CartFetchRequested(needToShowLoader: event.needToShowLoaderForCartFetch));
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
int totalProductCount = 0;

/// Result class for cart validation
class CartValidationResult {
  final bool isValid;
  final String errorMessage;

  CartValidationResult({
    required this.isValid,
    this.errorMessage = '',
  });
}
