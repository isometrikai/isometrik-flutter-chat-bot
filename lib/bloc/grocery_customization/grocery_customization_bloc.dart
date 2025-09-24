import 'dart:async';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/grocery_customization/grocery_customization_event.dart';
import 'package:chat_bot/bloc/grocery_customization/grocery_customization_state.dart';
import 'package:chat_bot/data/repositories/grocery_product_repository.dart';
import 'package:chat_bot/data/model/grocery_product_details_response.dart';

class GroceryCustomizationBloc extends Bloc<GroceryCustomizationEvent, GroceryCustomizationState> {
  final GroceryProductRepository _repository;
  String? _currentStoreId;

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
    _currentStoreId = event.storeId; // Store the storeId for later use

    try {
      final result = await _repository.getGroceryProductDetails(
        parentProductId: event.parentProductId,
        productId: event.productId,
        storeId: event.storeId,
      );

      if (result.isSuccess) {
        final response = result.data as GroceryProductDetailsResponse;
        final product = response.data.productData.data.first;
        
        // Auto-select variants with single options and primary variants
        GroceryProductVariant? selectedVariant;
        GroceryProductSizeData? selectedSizeData;
        
        // First, try to find a primary variant
        for (final variant in product.variants) {
          if (variant.isPrimary) {
            selectedVariant = variant;
            selectedSizeData = variant.sizeData.firstWhere(
              (sizeData) => sizeData.isPrimary,
              orElse: () => variant.sizeData.first,
            );
            break;
          }
        }
        
        // If no primary variant found, auto-select single-option variants
        if (selectedVariant == null && product.variants.isNotEmpty) {
          // Find the first variant with only one option (auto-select)
          for (final variant in product.variants) {
            if (variant.sizeData.length == 1) {
              selectedVariant = variant;
              selectedSizeData = variant.sizeData.first;
              break;
            }
          }
          
          // If no single-option variant found, use the first variant's first option
          if (selectedVariant == null) {
            selectedVariant = product.variants.first;
            selectedSizeData = selectedVariant.sizeData.first;
          }
        }

        final totalPrice = selectedSizeData != null 
            ? selectedSizeData.finalPriceList.finalPrice 
            : product.finalPriceList.finalPrice;

        emit(GroceryCustomizationLoaded(
          product: product,
          selectedVariant: selectedVariant,
          selectedSizeData: selectedSizeData,
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

  Future<void> _onSelectGroceryProductVariant(
    SelectGroceryProductVariant event,
    Emitter<GroceryCustomizationState> emit,
  ) async {
    if (state is GroceryCustomizationLoaded) {
      final currentState = state as GroceryCustomizationLoaded;

      // Check if this variant has multiple options
      final hasMultipleOptions = currentState.product.variants.length > 1;
      
      if (hasMultipleOptions) {
        Utility.showLoader();
        
        try {
          final result = await _repository.getGroceryProductDetails(
            parentProductId: currentState.product.parentProductId,
            productId: event.variant.childProductId,
            storeId: _currentStoreId ?? currentState.product.supplier.id,
          );

          if (result.isSuccess) {
            final response = result.data as GroceryProductDetailsResponse;
            final product = response.data.productData.data.first;
            
            // Auto-select primary variant or first available
            GroceryProductVariant? newSelectedVariant;
            GroceryProductSizeData? newSelectedSizeData;
            
            // Find primary variant
            for (final variant in product.variants) {
              if (variant.isPrimary) {
                newSelectedVariant = variant;
                newSelectedSizeData = variant.sizeData.firstWhere(
                  (sizeData) => sizeData.isPrimary,
                  orElse: () => variant.sizeData.first,
                );
                break;
              }
            }
            
            // If no primary found, use first variant's first option
            if (newSelectedVariant == null && product.variants.isNotEmpty) {
              newSelectedVariant = product.variants.first;
              newSelectedSizeData = newSelectedVariant.sizeData.first;
            }

            final totalPrice = newSelectedSizeData != null 
                ? newSelectedSizeData.finalPriceList.finalPrice 
                : product.finalPriceList.finalPrice;

            Utility.closeProgressDialog();
            emit(GroceryCustomizationLoaded(
              product: product,
              selectedVariant: newSelectedVariant,
              selectedSizeData: newSelectedSizeData,
              quantity: currentState.quantity,
              totalPrice: totalPrice,
            ));
          } else {
            Utility.closeProgressDialog();
            emit(GroceryCustomizationError(message: result.message ?? 'Failed to load product details'));
          }
        } catch (e) {
          Utility.closeProgressDialog();
          emit(GroceryCustomizationError(message: 'Error loading product details: $e'));
        }
      } else {
         // Find the variant that contains this size data
        GroceryProductVariant? selectedVariant;
        for (final variant in currentState.product.variants) {
          if (variant.sizeData.any((sizeData) => sizeData.childProductId == event.variant.childProductId)) {
            selectedVariant = variant;
            break;
          }
        }
        // For single option, just update the selection
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
