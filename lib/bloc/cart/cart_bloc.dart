import 'dart:async';

import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';

import 'package:chat_bot/data/repositories/cart_repository.dart';
import 'package:chat_bot/services/cart_manager.dart';
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

  /// Handle adding items to cart
  Future<void> _onCartAddItemRequested(
    CartAddItemRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
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

var isCartAPICalled = false;
