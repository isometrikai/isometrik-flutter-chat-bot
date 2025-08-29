import 'dart:async';

import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/repositories/cart_repository.dart';
import 'package:chat_bot/services/cart_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;
  final CartManager cartManager = CartManager();

  int totalProductCount = 0;

  // Getter for total product count
  int get getTotalProductCount => totalProductCount;

  CartBloc({CartRepository? repository})
      : repository = repository ?? const CartRepository(),
        super(CartInitial()) {
    
    on<CartFetchRequested>(_onCartFetchRequested);
  }

  Future<void> _onCartFetchRequested(
    CartFetchRequested event,
    Emitter<CartState> emit,
  ) async {
    if (event.needToShowLoader) { 
      emit(CartLoading());
    }

    try {
      // Fetch raw cart data once and use it for both purposes
      final rawResult = await repository.fetchRawUniversalCart();
      
      if (rawResult.isSuccess) {
        final rawCartData = rawResult.data as UniversalCartResponse;
        
        // Convert to widget actions
        final widgetActions = rawCartData.toWidgetActions();
        
        String? storeName;
        String? storeType;
        
        if (rawCartData.data.isNotEmpty) {
          final cartData = rawCartData.data.first;
          final seller = cartData.sellers.isNotEmpty ? cartData.sellers.first : null;
          
          totalProductCount = 0;
          Map<String, int> productQuantities = {};
          
          for (var obj in rawCartData.data) {
            for (var sellerData in obj.sellers) {
              totalProductCount += sellerData.products.length;
              
              // Extract product quantities for CartManager
              for (var product in sellerData.products) {
                if (product.quantity != null) {
                  productQuantities[product.id] = product.quantity?.value ?? 1;
                }
              }
            }
          }
          
          // Load quantities into CartManager
          cartManager.loadFromData(productQuantities);
          
          print('Total product count across all sellers: $totalProductCount');
          print('Loaded ${productQuantities.length} products into CartManager');
          
          // Store the store info
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
    }
  }

  // Method to manually update cart count (useful for testing or manual updates)
  void updateCartCount(int count) {
    totalProductCount = count;
  }

  // Get CartManager instance
  CartManager get getCartManager => cartManager;
}
