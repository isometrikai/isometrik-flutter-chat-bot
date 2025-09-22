import 'package:chat_bot/utils/asset_path.dart';
import 'package:chat_bot/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/cart_details_price_widget';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../data/model/universal_cart_response.dart';
import '../data/model/chat_response.dart';
import '../utils/text_styles.dart';

/// Data class to hold category-specific cart information
class CategoryData {
  final List<WidgetAction> cartItems;
  final String storeName;
  final String? storeType;
  final String currencySymbol;

  CategoryData({
    required this.cartItems,
    required this.storeName,
    this.storeType,
    required this.currencySymbol,
  });
}

class CartScreen extends StatefulWidget {
  final Function(String)? onCheckout;

  const CartScreen({
    super.key,
    this.onCheckout,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int selectedCategoryIndex = 0; // 0 for Restaurant, 1 for Grocery, 2 for Pharmacy

  @override
  void initState() {
    super.initState();
    
    // Fetch cart data using BLoC
    context.read<CartBloc>().add(CartFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Filter chips
            _buildFilterChips(),
            
            // Cart content
            Expanded(
              child: _buildCartContent(),
            ),
            
            // Bottom action buttons
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your cart',
            style: AppTextStyles.launchTitle.copyWith(
              color: const Color(0xFF171212),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(63.64),
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFF585C77),
                weight: 100,
                // height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        // Calculate category counts from cart data
        final categoryCounts = _calculateCategoryCounts(state);
        
        final categories = [
          {'name': '🍕 Restaurant', 'count': categoryCounts['restaurant']},
          {'name': '🥑 Grocery', 'count': categoryCounts['grocery']},
          {'name': '💊 Pharmacy', 'count': categoryCounts['pharmacy']},
        ];

        return Container(
          height: 40,
          margin: const EdgeInsets.only(top: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategoryIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    name: category['name'] as String,
                    count: category['count'] as int,
                    isSelected: isSelected,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String name,
    required int count,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFDFAFF) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF8E2FFD) : const Color(0xFFD8DEF3),
        ),
        borderRadius: BorderRadius.circular(80),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: AppTextStyles.button.copyWith(
              color: const Color(0xFF242424),
            ),
          ),
          // Only show count badge if count > 0
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF8E2FFD),
                borderRadius: BorderRadius.circular(39.59),
              ),
              child: Text(
                count.toString().padLeft(2, '0'),
                style: AppTextStyles.restaurantDescription.copyWith(
                  fontSize: 7.71,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Calculate category counts from cart data
  Map<String, int> _calculateCategoryCounts(CartState state) {
    int foodCount = 0;
    int groceryCount = 0;
    int pharmacyCount = 0;

    if (state is CartLoaded && state.rawCartData != null) {
      for (final cartData in state.rawCartData!.data) {
        for (final seller in cartData.sellers) {
          // storeTypeId 1 = Food, storeTypeId 2 = Grocery
          if (seller.storeTypeId == FoodCategory.food.value) {
            foodCount += seller.products.length;
          } else if (seller.storeTypeId == FoodCategory.grocery.value) {
            groceryCount += seller.products.length;
          } else if (seller.storeTypeId == FoodCategory.pharmacy.value) {
            pharmacyCount += seller.products.length;
          }
        }
      }
    }

    return {
      'restaurant': foodCount,
      'grocery': groceryCount,
      'pharmacy': pharmacyCount,
    };
  }

  Widget _buildCartContent() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF8E2FFD),
            ),
          );
        }

        if (state is CartError) {
          return _buildEmptyCart();
        }

        if (state is CartEmpty) {
          return _buildEmptyCart();
        }

        if (state is CartLoaded) {
          // Get data for the selected category
          final categoryData = _getCategoryData(state, selectedCategoryIndex);
          
          if (categoryData == null) {
            return _buildEmptyCart();
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Store info card (if we have store info)
                _buildStoreInfoCard(categoryData),
                
                const SizedBox(height: 24),
                
                // Use the CartDetailsPriceWidget
                CartDetailsPriceWidget(cartItems: categoryData.cartItems),
              ],
            ),
          );
        }

        return const Center(
          // child: Text('Unknown cart state'),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty cart SVG icon
          SvgPicture.asset(
            AssetPath.get('images/ic_emptyCart.svg'),
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          // "Your cart is empty" text
          Text(
            'Your cart is empty',
            style: AppTextStyles.restaurantTitle.copyWith(
              color: const Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 8),
          // Description text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add items like food, groceries, medicines, services or other products to get started.',
              textAlign: TextAlign.center,
              style: AppTextStyles.restaurantDescription.copyWith(
                color: const Color(0xFF6E4185),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get category data based on selected category (Food=1, Grocery=2)
  CategoryData? _getCategoryData(CartLoaded state, int categoryIndex) {
    if (state.rawCartData == null || state.rawCartData!.data.isEmpty) {
      return null;
    }

    // Map category index to storeId: 0=Food(storeId=1), 1=Grocery(storeId=2)
    int targetStoreId = categoryIndex == 0 ? FoodCategory.food.value : categoryIndex == 1 ? FoodCategory.grocery.value : FoodCategory.pharmacy.value;

    // Find cart data with matching storeId
    UniversalCartData? matchingCartData;
    Seller? matchingSeller;
    
    for (final cartData in state.rawCartData!.data) {
      // Check if any seller in this cart has the target storeId
      for (final seller in cartData.sellers) {
        if (seller.storeTypeId == targetStoreId) {
          matchingCartData = cartData;
          matchingSeller = seller;
          break;
        }
      }
      if (matchingCartData != null) break;
    }

    if (matchingCartData == null || matchingSeller == null) {
      return null;
    }
    
    // Convert to widget actions for this specific category
    final cartItems = _convertToWidgetActions(matchingCartData, matchingSeller);
    
    return CategoryData(
      cartItems: cartItems,
      storeName: matchingSeller.name,
      storeType: matchingSeller.storeType,
      currencySymbol: matchingCartData.currencySymbol,
    );
  }

  /// Format selectedAddOns by grouping them by addOnName
  String _formatSelectedAddOns(List<SelectedAddOn> selectedAddOns) {
    // Group add-ons by addOnName
    Map<String, List<String>> groupedAddOns = {};
    
    for (final addOn in selectedAddOns) {
      if (!groupedAddOns.containsKey(addOn.addOnName)) {
        groupedAddOns[addOn.addOnName] = [];
      }
      groupedAddOns[addOn.addOnName]!.add(addOn.name);
    }
    
    // Format the grouped add-ons
    List<String> formattedGroups = [];
    groupedAddOns.forEach((addOnName, addOnNames) {
      formattedGroups.add('$addOnName:- ${addOnNames.join(',')}');
    });
    
    return formattedGroups.join('\n');
  }

  /// Convert UniversalCartData to WidgetAction list for specific seller
  List<WidgetAction> _convertToWidgetActions(UniversalCartData cartData, Seller seller) {
    List<WidgetAction> widgetActions = [];
    
    // Extract actual cart items from seller products
    if (seller.products.isNotEmpty) {
      for (final product in seller.products) {
        // Get quantity from product.quantity or fallback
        int totalQuantity = 1;
        if (product.quantity != null) {
          totalQuantity = product.quantity?.value ?? 1;
        }
        
        // Get unit price with tax from accounting
        double unitPrice = 0;
        if (product.accounting != null) {
          unitPrice = product.accounting!.taxableAmount;
        }
        
        // Get product name
        String productName = product.name;
        
        // Format selectedAddOns if they exist
        String formattedAddOns = '';
        if (product.selectedAddOns != null && product.selectedAddOns!.isNotEmpty) {
          formattedAddOns = _formatSelectedAddOns(product.selectedAddOns!);
        }
        
        widgetActions.add(WidgetAction(
          buttonText: '',
          title: '',
          subtitle: '',
          storeCategoryId: cartData.storeCategoryId,
          keyword: '',
          quantity: '${totalQuantity}x',
          productName: productName,
          currencySymbol: cartData.currencySymbol,
          productPrice: unitPrice,
          addOns: formattedAddOns,
        ));
      }
    }
    
    // Add delivery fee from cart accounting
    double deliveryFee = 0;
    if (cartData.accounting != null) {
      deliveryFee = cartData.accounting!.deliveryFee;
    }
    
    if (deliveryFee > 0) {
      widgetActions.add(WidgetAction(
        buttonText: '',
        title: '',
        subtitle: '',
        storeCategoryId: cartData.storeCategoryId,
        keyword: '',
        productName: 'Delivery fee',
        currencySymbol: cartData.currencySymbol,
        productPrice: deliveryFee,
      ));
    }
    
    // Add service fee from cart accounting
    double serviceFee = 0;
    if (cartData.accounting != null) {
      serviceFee = cartData.accounting?.serviceFeeTotal ?? 0;
    }
    
    if (serviceFee > 0) {
      widgetActions.add(WidgetAction(
        buttonText: '',
        title: '',
        subtitle: '',
        storeCategoryId: cartData.storeCategoryId,
        keyword: '',
        productName: 'Service Fee',
        currencySymbol: cartData.currencySymbol,
        productPrice: serviceFee,
      ));
    }
    
    // Add tax information from cart accounting
    if (cartData.accounting != null && cartData.accounting!.tax.isNotEmpty) {
      for (final tax in cartData.accounting!.tax) {
        if (tax.totalValue > 0) {
          widgetActions.add(WidgetAction(
            buttonText: '',
            title: '',
            subtitle: '',
            storeCategoryId: cartData.storeCategoryId,
            keyword: '',
            productName: tax.taxName,
            currencySymbol: cartData.currencySymbol,
            productPrice: tax.totalValue,
          ));
        }
      }
    }
    
    // Add total from cart accounting
    double finalTotal = 0;
    if (cartData.accounting != null) {
      finalTotal = cartData.accounting!.finalTotal;
    }
    
    widgetActions.add(WidgetAction(
      buttonText: '',
      title: '',
      subtitle: '',
      storeCategoryId: cartData.storeCategoryId,
      keyword: '',
      productName: 'Total To Pay',
      currencySymbol: cartData.currencySymbol,
      productPrice: finalTotal,
    ));
    
    return widgetActions;
  }

  Widget _buildStoreInfoCard(CategoryData categoryData) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        border: Border.all(color: const Color(0xFFEEF4FF), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Store info row
          Row(
            children: [
              // Store icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DFFB),
                  borderRadius: BorderRadius.circular(42.67),
                ),
                child: SvgPicture.asset(
                  AssetPath.get('images/ic_storeCart.svg'),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              
              // Store details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryData.storeName,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: const Color(0xFF242424),
                      ),
                    ),
                    // const SizedBox(height: 10),
                    // Row(
                    //   children: [
                    //     // Rating
                    //     Row(
                    //       children: [
                    //         const Icon(
                    //           Icons.star,
                    //           size: 12,
                    //           color: Color(0xFFA674BF),
                    //         ),
                    //         const SizedBox(width: 4),
                    //         Text(
                    //           '4.5 (1.2k reviews)',
                    //           style: const TextStyle(
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.w400,
                    //             color: Color(0xFF242424),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     const SizedBox(width: 7),
                    //     const Text(
                    //       '|',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.w400,
                    //         color: Color(0xFFD7CDE9),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 7),
                    //     // Delivery time
                    //     Row(
                    //       children: [
                    //         const Icon(
                    //           Icons.access_time,
                    //           size: 12,
                    //           color: Color(0xFFA674BF),
                    //         ),
                    //         const SizedBox(width: 4),
                    //         Text(
                    //           '15-20 min',
                    //           style: const TextStyle(
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.w400,
                    //             color: Color(0xFF242424),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        // Only show checkout button if cart has data for the selected category
        if (state is CartLoaded) {
          final categoryData = _getCategoryData(state, selectedCategoryIndex);
          if (categoryData != null && categoryData.cartItems.isNotEmpty) {
            return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Proceed to checkout button
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      widget.onCheckout?.call("Proceed to checkout");
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 62,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF5186E0),
                            Color(0xFF5E3DFE),
                            Color(0xFF8E2FFD),
                            Color(0xFFB02EFB),
                            Color(0xFFD445EC),
                          ],
                          stops: [0.0, 0.24, 0.52, 0.73, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Proceed to checkout',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          }
        }
        
        // Return empty container when cart is empty or in other states
        return const SizedBox.shrink();
      },
    );
  }
}
