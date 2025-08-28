import 'dart:async';

import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/repositories/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repository;

  CartBloc({CartRepository? repository})
      : repository = repository ?? const CartRepository(),
        super(CartInitial()) {
    
    on<CartFetchRequested>(_onCartFetchRequested);
  }

  Future<void> _onCartFetchRequested(
    CartFetchRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      // Fetch cart items as widget actions
      final result = await repository.fetchUniversalCartAsWidgetActions();
      
      if (result.isSuccess) {
        final widgetActions = result.data as List<WidgetAction>;
        
        // Also fetch the raw cart data for store information
        final rawResult = await repository.fetchRawUniversalCart();
        UniversalCartResponse? rawCartData;
        String? storeName;
        String? storeType;
        
        if (rawResult.isSuccess) {
          rawCartData = rawResult.data as UniversalCartResponse;
          if (rawCartData.data.isNotEmpty) {
            final cartData = rawCartData.data.first;
            final seller = cartData.sellers.isNotEmpty ? cartData.sellers.first : null;
            
            // Store the store info
            storeName = seller?.name;
            storeType = seller?.storeType;
          }
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
        
        print('Cart fetched successfully: ${widgetActions.length} items');
      } else {
        emit(CartError(message: result.message ?? 'Failed to fetch cart'));
      }
    } catch (e) {
      emit(CartError(message: e.toString()));
    }
  }
}
