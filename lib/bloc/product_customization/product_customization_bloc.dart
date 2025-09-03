import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_event.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_state.dart';
import 'package:chat_bot/data/repositories/product_portion_repository.dart';
import 'package:chat_bot/data/model/product_portion_response.dart';

class ProductCustomizationBloc extends Bloc<ProductCustomizationEvent, ProductCustomizationState> {
  final ProductPortionRepository _repository;

  ProductCustomizationBloc({required ProductPortionRepository repository})
      : _repository = repository,
        super(ProductCustomizationInitial()) {
    on<LoadProductPortions>(_onLoadProductPortions);
    on<SelectProductVariant>(_onSelectProductVariant);
    on<ToggleAddOnItem>(_onToggleAddOnItem);
    on<ResetCustomization>(_onResetCustomization);
    on<AddToCart>(_onAddToCart);
  }

  Future<void> _onLoadProductPortions(
    LoadProductPortions event,
    Emitter<ProductCustomizationState> emit,
  ) async {
    emit(ProductCustomizationLoading());

    try {
      final result = await _repository.getProductPortions(
        centralProductId: event.centralProductId,
        childProductId: event.childProductId,
        storeId: event.storeId,
      );

      if (result.isSuccess) {
        final response = result.data as ProductPortionResponse;
        final variants = response.data;
        
        // Select the primary variant by default
        final primaryVariant = variants.firstWhere(
          (variant) => variant.isPrimary,
          orElse: () => variants.first,
        );

        final selectedAddOns = <String, Set<String>>{};
        
        // Initialize add-ons from API data
        for (final variant in variants) {
          for (final addOnCategory in variant.addOns) {
            selectedAddOns[addOnCategory.name] = <String>{};
          }
        }

        final totalPrice = _calculateTotalPrice(primaryVariant, selectedAddOns);

        emit(ProductCustomizationLoaded(
          variants: variants,
          selectedVariant: primaryVariant,
          selectedAddOns: selectedAddOns,
          totalPrice: totalPrice,
        ));
      } else {
        emit(ProductCustomizationError(message: result.message ?? 'Failed to load product portions'));
      }
    } catch (e) {
      emit(ProductCustomizationError(message: 'Error loading product portions: $e'));
    }
  }

  void _onSelectProductVariant(
    SelectProductVariant event,
    Emitter<ProductCustomizationState> emit,
  ) {
    if (state is ProductCustomizationLoaded) {
      final currentState = state as ProductCustomizationLoaded;
      final selectedAddOns = Map<String, Set<String>>.from(currentState.selectedAddOns);
      
      // Reset add-ons for the new variant
      for (final addOnCategory in event.variant.addOns) {
        selectedAddOns[addOnCategory.name] = <String>{};
      }

      final totalPrice = _calculateTotalPrice(event.variant, selectedAddOns);

      emit(ProductCustomizationLoaded(
        variants: currentState.variants,
        selectedVariant: event.variant,
        selectedAddOns: selectedAddOns,
        totalPrice: totalPrice,
      ));
    }
  }

  void _onToggleAddOnItem(
    ToggleAddOnItem event,
    Emitter<ProductCustomizationState> emit,
  ) {
    if (state is ProductCustomizationLoaded) {
      final currentState = state as ProductCustomizationLoaded;
      final selectedVariant = currentState.selectedVariant;
      
      if (selectedVariant == null) return;

      final selectedAddOns = Map<String, Set<String>>.from(currentState.selectedAddOns);
      final addOnCategory = selectedVariant.addOns.firstWhere(
        (category) => category.name == event.addOnCategoryName,
      );

      if (event.isSelected) {
        // Check maximum limit
        if (selectedAddOns[event.addOnCategoryName]!.length < addOnCategory.maximumLimit) {
          selectedAddOns[event.addOnCategoryName]!.add(event.addOnItemId);
        }
      } else {
        // Check minimum limit for mandatory add-ons
        if (addOnCategory.mandatory && 
            selectedAddOns[event.addOnCategoryName]!.length <= addOnCategory.minimumLimit) {
          return; // Don't allow removing if it would violate minimum limit
        }
        selectedAddOns[event.addOnCategoryName]!.remove(event.addOnItemId);
      }

      final totalPrice = _calculateTotalPrice(selectedVariant, selectedAddOns);

      emit(ProductCustomizationLoaded(
        variants: currentState.variants,
        selectedVariant: selectedVariant,
        selectedAddOns: selectedAddOns,
        totalPrice: totalPrice,
      ));
    }
  }

  void _onResetCustomization(
    ResetCustomization event,
    Emitter<ProductCustomizationState> emit,
  ) {
    if (state is ProductCustomizationLoaded) {
      final currentState = state as ProductCustomizationLoaded;
      final selectedAddOns = <String, Set<String>>{};
      
      for (final addOnCategory in currentState.selectedVariant!.addOns) {
        selectedAddOns[addOnCategory.name] = <String>{};
      }

      final totalPrice = _calculateTotalPrice(currentState.selectedVariant!, selectedAddOns);

      emit(ProductCustomizationLoaded(
        variants: currentState.variants,
        selectedVariant: currentState.selectedVariant,
        selectedAddOns: selectedAddOns,
        totalPrice: totalPrice,
      ));
    }
  }

  void _onAddToCart(
    AddToCart event,
    Emitter<ProductCustomizationState> emit,
  ) {
    if (state is ProductCustomizationLoaded) {
      final currentState = state as ProductCustomizationLoaded;
      
      // Validate mandatory add-ons
      bool isValid = true;
      String errorMessage = '';
      
      for (final addOnCategory in currentState.selectedVariant!.addOns) {
        if (addOnCategory.mandatory) {
          final selectedCount = currentState.selectedAddOns[addOnCategory.name]?.length ?? 0;
          if (selectedCount < addOnCategory.minimumLimit) {
            isValid = false;
            errorMessage = 'Please select at least ${addOnCategory.minimumLimit} option(s) for ${addOnCategory.name}';
            break;
          }
        }
      }

      if (!isValid) {
        emit(ProductCustomizationError(message: errorMessage));
        return;
      }

      // Success - item can be added to cart
      final customizationData = <String, List<String>>{};
      
      // Add selected variant
      if (currentState.selectedVariant != null) {
        customizationData['variant'] = [currentState.selectedVariant!.name];
      }
      
      // Add selected add-ons
      for (final entry in currentState.selectedAddOns.entries) {
        if (entry.value.isNotEmpty) {
          final addOnNames = <String>[];
          for (final addOnId in entry.value) {
            final addOnCategory = currentState.selectedVariant!.addOns.firstWhere(
              (category) => category.name == entry.key,
            );
            final addOnItem = addOnCategory.addOns.firstWhere(
              (item) => item.id == addOnId,
            );
            addOnNames.add(addOnItem.name);
          }
          if (addOnNames.isNotEmpty) {
            customizationData[entry.key] = addOnNames;
          }
        }
      }
      
      emit(ProductCustomizationSuccess(
        message: 'Item added to cart successfully',
        selectedCustomizations: customizationData,
      ));
    }
  }

  double _calculateTotalPrice(ProductPortion variant, Map<String, Set<String>> selectedAddOns) {
    double total = variant.price;
    
    for (final addOnCategory in variant.addOns) {
      final selectedItems = selectedAddOns[addOnCategory.name] ?? <String>{};
      for (final addOnItem in addOnCategory.addOns) {
        if (selectedItems.contains(addOnItem.id)) {
          total += addOnItem.price;
        }
      }
    }
    
    return total;
  }
}
