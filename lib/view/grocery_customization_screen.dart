import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/grocery_customization/grocery_customization_bloc.dart';
import 'package:chat_bot/bloc/grocery_customization/grocery_customization_event.dart';
import 'package:chat_bot/bloc/grocery_customization/grocery_customization_state.dart';
import 'package:chat_bot/data/model/grocery_product_details_response.dart';
import 'package:chat_bot/data/repositories/grocery_product_repository.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import '../utils/text_styles.dart';

class GroceryCustomizationScreen extends StatefulWidget {
  final String parentProductId;
  final String productId;
  final String storeId;
  final String productName;
  final String productImage;
  // final int storeTypeId;
  final Function(String,String,String)? onAddToCart;

  const GroceryCustomizationScreen({
    super.key,
    required this.parentProductId,
    required this.productId,
    required this.storeId,
    required this.productName,
    required this.productImage,
    // required this.storeTypeId,
    this.onAddToCart,
  });

  @override
  State<GroceryCustomizationScreen> createState() => _GroceryCustomizationScreenState();
}

class _GroceryCustomizationScreenState extends State<GroceryCustomizationScreen> {
  late GroceryCustomizationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GroceryCustomizationBloc(
      repository: GroceryProductRepository(
        apiClient: UniversalApiClient.instance.appClient,
      ),
    );
    
    _bloc.add(LoadGroceryProductDetails(
      parentProductId: widget.parentProductId,
      productId: widget.productId,
      storeId: widget.storeId,
    ));
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
      child: BlocListener<GroceryCustomizationBloc, GroceryCustomizationState>(
        listener: (context, state) {
          if (state is GroceryCustomizationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is GroceryCustomizationSuccess) {
            if (widget.onAddToCart != null) {
              final parentProductId = widget.parentProductId;
              final productId = state.selectedSizeData.childProductId;
              final unitId = state.selectedSizeData.unitId;
              widget.onAddToCart!(parentProductId,productId,unitId);
            }
            Navigator.of(context).pop();
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
                        child: BlocBuilder<GroceryCustomizationBloc, GroceryCustomizationState>(
                          builder: (context, state) {
                            if (state is GroceryCustomizationLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF8E2FFD),
                                ),
                              );
                            }
                            
                            if (state is GroceryCustomizationError) {
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
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontSize: 16,
                                        color: const Color(0xFF6E4185),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        _bloc.add(LoadGroceryProductDetails(
                                          parentProductId: widget.parentProductId,
                                          productId: widget.productId,
                                          storeId: widget.storeId,
                                        ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF8E2FFD),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: Text(
                                        'Retry',
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            if (state is GroceryCustomizationLoaded) {
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
                  child: widget.productImage.isNotEmpty
                      ? Image.network(
                          widget.productImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.shopping_cart,
                            color: Color(0xFF8E2FFD),
                            size: 20,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_cart,
                          color: Color(0xFF8E2FFD),
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.productName,
                  style: AppTextStyles.launchTitle.copyWith(
                    color: const Color(0xFF242424),
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
        ],
      ),
    );
  }

  Widget _buildCustomizationContent(GroceryCustomizationLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVariantSection(state),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildVariantSection(GroceryCustomizationLoaded state) {
    if (state.product.variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your variant*',
          style: AppTextStyles.productTitle.copyWith(
            color: const Color(0xFF242424),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Required | Select any 1',
          style: AppTextStyles.restaurantDescription.copyWith(
            color: const Color(0xFF6E4185),
          ),
        ),
        const SizedBox(height: 8),
        ...state.product.variants.map((variant) => _buildVariantTypeSection(variant, state)),
      ],
    );
  }

  Widget _buildVariantTypeSection(GroceryProductVariant variant, GroceryCustomizationLoaded state) {
    final hasMultipleOptions = variant.sizeData.length > 1;
    final isAutoSelected = !hasMultipleOptions;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEF4FF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Variant type header
          Row(
            children: [
              if (state.product.variants.length > 1) ...[
              Text(
                variant.name,
                style: AppTextStyles.productTitle.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF242424),
                  fontWeight: FontWeight.w600,
                ),
              ),
              ]
              // if (isAutoSelected) ...[
              //   const SizedBox(width: 8),
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFE9DFFB),
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     child: const Text(
              //       'Auto-selected',
              //       style: TextStyle(
              //         fontSize: 10,
              //         fontWeight: FontWeight.w500,
              //         color: Color(0xFF8E2FFD),
              //       ),
              //     ),
              //   ),
              // ],
            ],
          ),
          if (state.product.variants.length > 1) ...[
          const SizedBox(height: 12),
          ],
          // Variant options
          ...variant.sizeData.map((sizeData) => _buildVariantOption(sizeData, state, isAutoSelected, variant.sizeData.length == 1)),
        ],
      ),
    );
  }

  Widget _buildVariantOption(GroceryProductSizeData sizeData, GroceryCustomizationLoaded state, bool isAutoSelected, bool isSelectedAlways) {
    final isOutOfStock = sizeData.outOfStock || sizeData.availableStock == 0;
    final isClickable = !isOutOfStock;
    // Check if this option is selected
    final isSelected = state.selectedSizeData?.childProductId == sizeData.childProductId;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSelectedAlways == false ? '${sizeData.name} (${state.product.currency}${sizeData.finalPriceList.finalPrice.toStringAsFixed(0)})' : sizeData.name,
                  style: AppTextStyles.productTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isOutOfStock ? const Color(0xFF979797) : const Color(0xFF242424),
                  ),
                ),
                if (isOutOfStock)
                  Text(
                    'Out of Stock',
                    style: AppTextStyles.restaurantDescription.copyWith(
                      color: Colors.red,
                    ),
                  )
                else if (sizeData.availableStock < 10)
                  Text(
                    'Only ${sizeData.availableStock} left',
                    style: AppTextStyles.restaurantDescription.copyWith(
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isClickable ? () {
              _bloc.add(SelectGroceryProductVariant(variant: sizeData));
            } : null,
            child: 
            isSelectedAlways ? Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:  const Color(0xFF8E2FFD),
                  width: 0.83,
                ),
                color: 
                    const Color(0xFF8E2FFD) 
              ),
              child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
            ) : Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOutOfStock 
                      ? const Color(0xFFE9DFFB)
                      : isSelected 
                          ? const Color(0xFF8E2FFD) 
                          : const Color(0xFFE9DFFB),
                  width: 0.83,
                ),
                color: isOutOfStock 
                    ? Colors.white
                    : isSelected 
                        ? const Color(0xFF8E2FFD) 
                        : Colors.white,
              ),
              child: isSelected && !isOutOfStock
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

  Widget _buildBottomBar() {
    return BlocBuilder<GroceryCustomizationBloc, GroceryCustomizationState>(
      builder: (context, state) {
        if (state is! GroceryCustomizationLoaded) {
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
                  onPressed: () {
                    if (state.selectedSizeData == null) {
                      BlackToastView.show(context, 'Please select a variant');
                      return;
                    }
                    
                    // if (state.selectedSizeData!.outOfStock) {
                    //   BlackToastView.show(context, 'This item is out of stock');
                    //   return;
                    // }
                    
                    // if (state.quantity > state.selectedSizeData!.availableStock) {
                    //   BlackToastView.show(context, 'Not enough stock available');
                    //   return;
                    // }
                    
                    _bloc.add(AddGroceryToCart(
                      quantity: state.quantity,
                      selectedVariantId: state.selectedSizeData!.childProductId,
                    ));
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
                  child: Text(
                    'Add',
                    style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.2,
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
