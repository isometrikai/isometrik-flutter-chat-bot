import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_bloc.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_event.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_state.dart';
import 'package:chat_bot/data/model/product_portion_response.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/repositories/product_portion_repository.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:chat_bot/utils/text_styles.dart';



class ProductCustomizationScreen extends StatefulWidget {
  final Product? product;
  final Store? store;
  final bool? isFromMenuScreen;
  final String? storeId;
  final String? productId;
  final String? centralProductId;
  final String? productName;
  final String? productImage;
  
  final Function(String)? onAddToCart;
  final Function(Product, Store, ProductPortion, List<Map<String, dynamic>>,String)? onAddToCartWithAddOns;

  const ProductCustomizationScreen({
    super.key,
    this.product,
    this.store,
    this.onAddToCart,
    this.onAddToCartWithAddOns,
    this.isFromMenuScreen,
    this.storeId,
    this.productId,
    this.centralProductId,
    this.productName,
    this.productImage,
  });

  @override
  State<ProductCustomizationScreen> createState() => _ProductCustomizationScreenState();
}

class _ProductCustomizationScreenState extends State<ProductCustomizationScreen> {
  late ProductCustomizationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ProductCustomizationBloc(
      repository: ProductPortionRepository(
        apiClient: UniversalApiClient.instance.appClient,
      ),
    );
    
    if (widget.isFromMenuScreen == true) {
        _bloc.add(LoadProductPortions(
        centralProductId: widget.centralProductId ?? '',
        childProductId: widget.productId ?? '',
        storeId: widget.storeId ?? '',
      ));
    }else {
      _bloc.add(LoadProductPortions(
        centralProductId: widget.product?.parentProductId ?? '',
        childProductId: widget.product?.childProductId ?? '',
        storeId: widget.store?.storeId ?? '',
      ));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ProductCustomizationBloc, ProductCustomizationState>(
        listener: (context, state) {
          if (state is ProductCustomizationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // Main content with light purple background
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F7FF),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: BlocBuilder<ProductCustomizationBloc, ProductCustomizationState>(
                          builder: (context, state) {
                            if (state is ProductCustomizationLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF8E2FFD),
                                ),
                              );
                            }
                            
                            if (state is ProductCustomizationError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: const Color(0xFF6E4185).withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.message,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF6E4185),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (widget.isFromMenuScreen == true) {
                                          _bloc.add(LoadProductPortions(
                                          centralProductId: widget.centralProductId ?? '',
                                          childProductId: widget.productId ?? '',
                                          storeId: widget.storeId ?? '',
                                        ));
                                        }else {
                                        _bloc.add(LoadProductPortions(
                                          centralProductId: widget.product?.parentProductId ?? '',
                                          childProductId: widget.product?.childProductId ?? '',
                                          storeId: widget.store?.storeId ?? '',
                                        ));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF8E2FFD),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            if (state is ProductCustomizationLoaded) {
                              return _buildCustomizationContent(state);
                            }
                            
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      _buildBottomBar(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 28,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD8DEF3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 15),
          // Header content
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DFFB),
                  borderRadius: BorderRadius.circular(6.22),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.22),
                  child: widget.product?.productImage.isNotEmpty ?? false
                      ? Image.network(
                          widget.isFromMenuScreen == true ? widget.productImage ?? '' : widget.product?.productImage ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.restaurant,
                            color: Color(0xFF8E2FFD),
                            size: 20,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: Color(0xFF8E2FFD),
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                 widget.isFromMenuScreen == true ? widget.productName ?? '' : widget.product?.productName ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF242424),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(38.18),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF585C77),
                    size: 9.6,
                  ),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 0),
          // Container(
          //   height: 1,
          //   color: const Color(0xFFE9DFFB),
          // ),
        ],
      ),
    );
  }

  Widget _buildCustomizationContent(ProductCustomizationLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSizeSection(state),
          const SizedBox(height: 16),
          // Dynamically show add-on sections based on API data
          ...state.selectedVariant!.addOns.map((addOnCategory) => 
            Column(
              children: [
                _buildAddOnSection(addOnCategory, state),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSizeSection(ProductCustomizationLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your size*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF242424),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Required | Select any 1',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6E4185),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEEF4FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              ...state.variants.map((variant) => _buildSizeOption(variant, state)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSizeOption(ProductPortion variant, ProductCustomizationLoaded state) {
    final isSelected = state.selectedVariant?.id == variant.id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${variant.name} (${variant.currencySymbol}${variant.price.toStringAsFixed(0)})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF242424),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _bloc.add(SelectProductVariant(variant: variant));
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF8E2FFD) : const Color(0xFFE9DFFB),
                  width: 0.83,
                ),
                color: isSelected ? const Color(0xFF8E2FFD) : Colors.white,
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnSection(AddOnCategory addOnCategory, ProductCustomizationLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              addOnCategory.name,
              style: AppTextStyles.addonTitle.copyWith(
                color: const Color(0xFF242424),
              ),
            ),
            if (addOnCategory.mandatory) 
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          addOnCategory.mandatory 
              ? 'Required | Select any ${addOnCategory.maximumLimit}'
              : 'Optional | You can select up to ${addOnCategory.maximumLimit} items',
          style: AppTextStyles.addonDescription.copyWith(
            color: const Color(0xFF6E4185),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEEF4FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: addOnCategory.addOns.isNotEmpty
              ? Column(
                  children: [
                    ...addOnCategory.addOns.map((addOn) => _buildAddOnOption(addOn, addOnCategory, state)),
                  ],
                )
              : const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No options available',
                    style: TextStyle(
                      color: Color(0xFF979797),
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAddOnOption(AddOnItem addOn, AddOnCategory addOnCategory, ProductCustomizationLoaded state) {
    final isSelected = state.selectedAddOns[addOnCategory.name]?.contains(addOn.id) ?? false;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${addOn.name} (${addOn.currencySymbol}${addOn.price.toStringAsFixed(0)})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF242424),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _bloc.add(ToggleAddOnItem(
                addOnCategoryName: addOnCategory.name,
                addOnItemId: addOn.id,
                isSelected: !isSelected,
              ));
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                // Use radio button for single selection, checkbox for multiple selection
                shape: addOnCategory.multiple ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: addOnCategory.multiple 
                    ? BorderRadius.circular(3.33) 
                    : null,
                border: Border.all(
                  color: isSelected ? const Color(0xFF8E2FFD) : const Color(0xFFB0C4FF),
                  width: 0.83,
                ),
                color: isSelected ? const Color(0xFF8E2FFD) : Colors.white,
              ),
              child: isSelected
                  ? addOnCategory.multiple
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 13.33,
                        )
                      : Container(
                          margin: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to format addons data for CartAddItemRequested API
  List<Map<String, dynamic>> _formatAddOnsForAPI(ProductCustomizationLoaded state) {
    final List<Map<String, dynamic>> formattedAddOns = [];
    
    for (final entry in state.selectedAddOns.entries) {
      if (entry.value.isNotEmpty) {
        final addOnCategory = state.selectedVariant!.addOns.firstWhere(
          (category) => category.name == entry.key,
        );
        
        if (addOnCategory.unitAddOnId.isNotEmpty) {
          formattedAddOns.add({
            "addOnGroup": entry.value.toList(),
            "id": addOnCategory.unitAddOnId,
          });
        }
      }
    }
    
    return formattedAddOns;
  }

  /// Validates if all required options are selected
  bool _validateRequiredOptions(ProductCustomizationLoaded state) {
    // Check if size is selected (always required)
    if (state.selectedVariant == null) {
      BlackToastView.show(context, 'Please select a size');
      return false;
    }

    // Check mandatory add-on categories
    for (final addOnCategory in state.selectedVariant!.addOns) {
      if (addOnCategory.mandatory) {
        final selectedItems = state.selectedAddOns[addOnCategory.name] ?? <String>{};
        
        if (selectedItems.isEmpty) {
          BlackToastView.show(context, 'Please Select Option');
          return false;
        }
        
        // Check if minimum required items are selected
        if (selectedItems.length < addOnCategory.minimumLimit) {
          BlackToastView.show(context, 'Please select at least ${addOnCategory.minimumLimit} items from ${addOnCategory.name}');
          return false;
        }
        
        // Check if maximum limit is not exceeded
        if (selectedItems.length > addOnCategory.maximumLimit) {
          BlackToastView.show(context, 'You can select maximum ${addOnCategory.maximumLimit} items from ${addOnCategory.name}');
          return false;
        }
      }
    }

    return true;
  }

  Widget _buildBottomBar() {
    return BlocBuilder<ProductCustomizationBloc, ProductCustomizationState>(
      builder: (context, state) {
        if (state is! ProductCustomizationLoaded) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FF),
          ),
          child: Column(
            children: [
              Container(
                width: 343,
                height: 62,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD445EC),
                      Color(0xFFB02EFB),
                      Color(0xFF8E2FFD),
                      Color(0xFF5E3DFE),
                      Color(0xFF5186E0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate required options first
                    if (!_validateRequiredOptions(state)) {
                      return; // Stop execution if validation fails
                    }
                    
                    if (state.selectedVariant != null) {
                      // Format addons data for API
                      final formattedAddOns = _formatAddOnsForAPI(state);
                      
                      if (formattedAddOns.isNotEmpty) {
                        // Addons selected, use the new callback
                        if (widget.onAddToCartWithAddOns != null) {
                          if (widget.isFromMenuScreen == true) {
                          // widget.onAddToCartWithAddOns!(
                          //   widget.product!,
                          //     widget.store!,
                          //     state.selectedVariant!,
                          //     formattedAddOns,
                          //   );
                          }else {
                            widget.onAddToCartWithAddOns!(
                              widget.product!,
                              widget.store!,
                              state.selectedVariant!,
                              formattedAddOns,
                              state.selectedVariant!.childProductId,
                          );
                          }
                          Navigator.of(context).pop();
                        }
                      } else {
                        widget.onAddToCartWithAddOns!(
                              widget.product!,
                              widget.store!,
                              state.selectedVariant!,
                              formattedAddOns,
                              state.selectedVariant!.childProductId,
                        );
                        Navigator.of(context).pop();
                        // No addons selected, proceed with original logic
                        // final customizations = <String, List<String>>{};
                        
                        // customizations['variant'] = [state.selectedVariant!.name];
                        
                        // for (final entry in state.selectedAddOns.entries) {
                        //   if (entry.value.isNotEmpty) {
                        //     final addOnCategory = state.selectedVariant!.addOns.firstWhere(
                        //       (category) => category.name == entry.key,
                        //     );
                            
                        //     final selectedItems = <String>[];
                        //     for (final addOnId in entry.value) {
                        //       final addOnItem = addOnCategory.addOns.firstWhere(
                        //         (item) => item.id == addOnId,
                        //       );
                        //       selectedItems.add(addOnItem.name);
                        //     }
                            
                        //     if (selectedItems.isNotEmpty) {
                        //       customizations[entry.key] = selectedItems;
                        //     }
                        //   }
                        // }
                        
                        // if (widget.onAddToCart != null) {
                        //   final variantName = state.selectedVariant!.name;
                          
                        //   List<String> customizationDetails = [];
                          
                        //   for (final entry in state.selectedAddOns.entries) {
                        //     if (entry.value.isNotEmpty) {
                        //       final addOnCategory = state.selectedVariant!.addOns.firstWhere(
                        //         (category) => category.name == entry.key,
                        //       );
                              
                        //       final selectedItems = <String>[];
                        //       for (final addOnId in entry.value) {
                        //         final addOnItem = addOnCategory.addOns.firstWhere(
                        //           (item) => item.id == addOnId,
                        //         );
                        //         selectedItems.add(addOnItem.name);
                        //       }
                              
                        //       if (selectedItems.isNotEmpty) {
                        //         customizationDetails.add("${entry.key}: ${selectedItems.join(', ')}");
                        //       }
                        //     }
                        //   }
                          
                        //   String message = "[VARIANT_SELECTION] Added 1X ${widget.isFromMenuScreen == true ? widget.productName ?? '' : widget.product?.productName ?? ''} - $variantName";
                        //   if (customizationDetails.isNotEmpty) {
                        //     message += " with ${customizationDetails.join(', ')}";
                        //   }
                        //   message += " to cart";
                          
                        //   widget.onAddToCart!(message);
                        // }
                        
                        // Navigator.of(context).pop();
                        
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Home indicator
              Container(
                width: 132.26,
                height: 4.93,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(98.7),
                ),
              ),
              const SizedBox(height: 7.45),
            ],
          ),
        );
      },
    );
  }
}

