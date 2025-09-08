import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/grocery_customization/grocery_customization_event.dart';
import 'package:chat_bot/bloc/grocery_customization/grocery_customization_state.dart';
import 'package:chat_bot/data/repositories/grocery_product_repository.dart';
import 'package:chat_bot/data/model/grocery_product_details_response.dart';

class GroceryCustomizationBloc extends Bloc<GroceryCustomizationEvent, GroceryCustomizationState> {
  final GroceryProductRepository _repository;

  GroceryCustomizationBloc({required GroceryProductRepository repository})
      : _repository = repository,
        super(GroceryCustomizationInitial()) {
    on<LoadGroceryProductDetails>(_onLoadGroceryProductDetails);
    on<SelectGroceryProductVariant>(_onSelectGroceryProductVariant);
    on<UpdateGroceryQuantity>(_onUpdateGroceryQuantity);
    on<AddGroceryToCart>(_onAddGroceryToCart);
  }

  Future<void> _onLoadGroceryProductDetails(
    LoadGroceryProductDetails event,
    Emitter<GroceryCustomizationState> emit,
  ) async {
    emit(GroceryCustomizationLoading());

    try {
      final result = await _repository.getGroceryProductDetails(
        parentProductId: event.parentProductId,
        productId: event.productId,
        storeId: event.storeId,
      );

      if (result.isSuccess) {
        final response = result.data as GroceryProductDetailsResponse;
        final product = response.data.productData.data.first;
        
        // Select the primary variant by default
        GroceryProductVariant? primaryVariant;
        GroceryProductSizeData? primarySizeData;
        
        for (final variant in product.variants) {
          if (variant.isPrimary) {
            primaryVariant = variant;
            primarySizeData = variant.sizeData.firstWhere(
              (sizeData) => sizeData.isPrimary,
              orElse: () => variant.sizeData.first,
            );
            break;
          }
        }
        
        // If no primary variant found, use the first one
        if (primaryVariant == null && product.variants.isNotEmpty) {
          primaryVariant = product.variants.first;
          primarySizeData = primaryVariant.sizeData.first;
        }

        final totalPrice = primarySizeData != null 
            ? primarySizeData.finalPriceList.finalPrice 
            : product.finalPriceList.finalPrice;

        emit(GroceryCustomizationLoaded(
          product: product,
          selectedVariant: primaryVariant,
          selectedSizeData: primarySizeData,
          quantity: 1,
          totalPrice: totalPrice,
        ));
      } else {
        emit(GroceryCustomizationError(message: result.message ?? 'Failed to load grocery product details'));
      }
    } catch (e) {
      emit(GroceryCustomizationError(message: 'Error loading grocery product details: $e'));
    }
  }

  void _onSelectGroceryProductVariant(
    SelectGroceryProductVariant event,
    Emitter<GroceryCustomizationState> emit,
  ) {
    if (state is GroceryCustomizationLoaded) {
      final currentState = state as GroceryCustomizationLoaded;
      
      // Find the variant that contains this size data
      GroceryProductVariant? selectedVariant;
      for (final variant in currentState.product.variants) {
        if (variant.sizeData.any((sizeData) => sizeData.childProductId == event.variant.childProductId)) {
          selectedVariant = variant;
          break;
        }
      }

      final totalPrice = event.variant.finalPriceList.finalPrice * currentState.quantity;

      emit(GroceryCustomizationLoaded(
        product: currentState.product,
        selectedVariant: selectedVariant,
        selectedSizeData: event.variant,
        quantity: currentState.quantity,
        totalPrice: totalPrice,
      ));
    }
  }

  void _onUpdateGroceryQuantity(
    UpdateGroceryQuantity event,
    Emitter<GroceryCustomizationState> emit,
  ) {
    if (state is GroceryCustomizationLoaded) {
      final currentState = state as GroceryCustomizationLoaded;
      
      if (currentState.selectedSizeData != null) {
        final totalPrice = currentState.selectedSizeData!.finalPriceList.finalPrice * event.quantity;

        emit(GroceryCustomizationLoaded(
          product: currentState.product,
          selectedVariant: currentState.selectedVariant,
          selectedSizeData: currentState.selectedSizeData,
          quantity: event.quantity,
          totalPrice: totalPrice,
        ));
      }
    }
  }

  void _onAddGroceryToCart(
    AddGroceryToCart event,
    Emitter<GroceryCustomizationState> emit,
  ) {
    if (state is GroceryCustomizationLoaded) {
      final currentState = state as GroceryCustomizationLoaded;
      
      if (currentState.selectedSizeData == null) {
        emit(GroceryCustomizationError(message: 'Please select a variant'));
        return;
      }

      if (event.quantity <= 0) {
        emit(GroceryCustomizationError(message: 'Please select a valid quantity'));
        return;
      }

      if (currentState.selectedSizeData!.outOfStock) {
        emit(GroceryCustomizationError(message: 'This item is out of stock'));
        return;
      }

      if (event.quantity > currentState.selectedSizeData!.availableStock) {
        emit(GroceryCustomizationError(message: 'Not enough stock available'));
        return;
      }

      // Success - item can be added to cart
      emit(GroceryCustomizationSuccess(
        message: 'Item added to cart successfully',
        product: currentState.product,
        selectedSizeData: currentState.selectedSizeData!,
        quantity: event.quantity,
      ));
    }
  }
}
