import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/data/model/chat_response.dart' as chat;
import 'package:chat_bot/utils/enum.dart';
import 'package:chat_bot/view/customization_summary_screen.dart';
import 'package:chat_bot/view/product_customization_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_bloc.dart';
import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_event.dart';
import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_state.dart';
import 'package:chat_bot/widgets/menu_item_card.dart';
import 'package:chat_bot/widgets/screen_header.dart';
import 'package:chat_bot/services/cart_manager.dart';
import 'package:chat_bot/services/callback_manage.dart';
import '../utils/asset_helper.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';
import '../utils/text_styles.dart';

import '../widgets/black_toast_view.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final chat.WidgetAction? actionData;
  final Function(bool)? onCheckout;

  const RestaurantMenuScreen({super.key, this.actionData, this.onCheckout});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  static const Color _purple = Color(0xFF8E2FFD);
  static const Color _border = Color(0xFFD8DEF3);
  static const Color _labelGrey = Color(0xFF979797);
  static const Color _veg = Color(0xFF66BB6A);
  static const Color _nonVeg = Color(0xFFF44336);

  final TextEditingController _searchController = TextEditingController();
  late final RestaurantMenuBloc _bloc;
  late final CartBloc cartBloc;

  // Dynamic data from API
  List<ProductCategory> _categories = <ProductCategory>[];
  int _selectedMainCategoryIndex = 0;
  int _selectedBiriyaniSubIndex = 0;
  bool _filterVeg = false;
  bool _filterNonVeg = false;

  // Cart state
  double _cartTotal = 0.00;
  int _cartItems = 0;
  Map<String, int> _productQuantities = {}; // Track product quantities
  Map<String, chat.Product> _productDetails = {}; // Track product details
  Map<String, int> _initialQuantities = {}; // Track initial quantities when screen opened
  List<UniversalCartData> _cartData = []; // Store cart data from getCart API

  

  // Maintain subcategory selection per category for ALL view
  final Map<String, int> _subIndexByCategory = <String, int>{};

  @override
  void initState() {
    super.initState();
    isCartAPICalled = false;
    _cartData = globalCartData;
    _bloc = RestaurantMenuBloc(actionData: widget.actionData);
    cartBloc = CartBloc();
    cartBloc.add(CartFetchRequested(needToShowLoader: false));
    _bloc.add(const RestaurantMenuRequested());
    
      OrderService().setCartUpdateCallback((bool isCartUpdate) {
      if (mounted && isCartUpdate) {
        print('RestaurantMenuScreen: Cart update received - $isCartUpdate');
        // Refresh cart data when cart update is triggered
        print('RestaurantMenuScreen: Refreshing cart data');
        cartBloc.add(CartFetchRequested(needToShowLoader: true));
      }
    });

  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _clearCart() {
    setState(() {
      _cartItems = 0;
      _cartTotal = 0.00;
      _productQuantities.clear();
      _productDetails.clear();
      _initialQuantities.clear();
    });
  }

  double _extractPriceFromString(String priceString) {
    // Remove all non-numeric characters except decimal point
    String cleanString = priceString.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Remove trailing decimal points
    cleanString = cleanString.replaceAll(RegExp(r'\.+$'), '');
    
    // Handle cases where there might be multiple decimal points (keep only the first one)
    final parts = cleanString.split('.');
    if (parts.length > 2) {
      cleanString = '${parts[0]}.${parts[1]}';
    }
    
    // Parse the cleaned string
    final price = double.tryParse(cleanString);
    
    
    return price ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bloc),
        BlocProvider.value(value: cartBloc),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              // Main content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, _cartItems > 0 ? 129 : 24), // Add bottom padding when cart is visible
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ScreenHeader(
                        title: widget.actionData?.title ?? '',
                        subtitle: widget.actionData?.subtitle ?? '',
                        onClose: () {
                          // _onAddToCart();
                          if (widget.onCheckout != null ) {
                            widget.onCheckout!(true);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                      // const SizedBox(height: 16),
                      // _buildSearchBar(theme),
                      const SizedBox(height: 16),
                      _buildDietToggles(),
                      const SizedBox(height: 16),
                      BlocListener<CartBloc, CartState>(
                        listener: (context, state) {
                          if (state is CartLoaded && state.rawCartData != null) {
                            _updateCartData(state.rawCartData!.data);
                          }else if (state is CartEmpty) {
                            _updateCartData([]);
                          }
                        },
                        child: BlocBuilder<RestaurantMenuBloc, RestaurantMenuState>(
                          builder: (context, state) {
                            if (state is RestaurantMenuInitial || state is RestaurantMenuLoadInProgress) {
                              return Container();
                              // const Padding(
                              //   padding: EdgeInsets.only(top: 32),
                              //   child: Center(child: CircularProgressIndicator()),
                              // );
                            }
                            if (state is RestaurantMenuLoadFailure) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Text(
                                  state.message,
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            }
                            final categories = (state as RestaurantMenuLoadSuccess).categories;
                            _categories = categories;
                            
                            if (categories.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Text(
                                  'No menu available',
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: const Color(0xFF6E4185),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _buildMainCategories(),
                                const SizedBox(height: 24),
                                _buildCurrentCategorySection(),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom cart bar - positioned absolutely at the bottom (only show when items exist)
              // if (_cartItems > 0)
              //   Positioned(
              //     left: 0,
              //     right: 0,
              //     bottom: 0,
              //     child: _buildBottomCartBar(),
              //   ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTextStyles.bodyText.copyWith(
                      color: _labelGrey,
                    ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(54),
            ),
            child: const Icon(Icons.search, size: 18, color: Color(0xFF585C77)),
          ),
        ],
      ),
    );
  }

  Widget _buildDietToggles() {
    return Row(
      children: <Widget>[
        // Non-veg switch
        Row(
          children: <Widget>[
            Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: _nonVeg ,
                        width: 1.05,
                      ),
                      borderRadius: BorderRadius.circular(3.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 8.4,
                        height: 8.4,
                        decoration: BoxDecoration(
                          color: _nonVeg ,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _filterNonVeg = !_filterNonVeg;
                });
              },
              child: Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: _filterNonVeg ? _nonVeg : const Color(0xFFD8DEF3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: _filterNonVeg ? 22 : 2,
                      top: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        // Veg switch
        Row(
          children: <Widget>[
            Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color:  _veg ,
                        width: 1.05,
                      ),
                      borderRadius: BorderRadius.circular(3.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 8.4,
                        height: 8.4,
                        decoration: BoxDecoration(
                          color: _veg ,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _filterVeg = !_filterVeg;
                });
              },
              child: Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: _filterVeg ? _veg : const Color(0xFFD8DEF3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: _filterVeg ? 22 : 2,
                      top: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainCategories() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1, // +1 for ALL
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == _selectedMainCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedMainCategoryIndex = index;
              _selectedBiriyaniSubIndex = 0;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF9FF) : Colors.white,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: isSelected ? _purple : _border),
              ),
              alignment: Alignment.center,
              child: Text(
                index == 0 ? 'ALL' : _categories[index - 1].catName,
                style: AppTextStyles.button.copyWith(
                  color: const Color(0xFF242424),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoryChips({
    required ProductCategory category,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return SizedBox(
      height: 31,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: category.subCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => onSelected(index)),
            child: Container(
              height: 31,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF9FF) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? _purple : _border),
              ),
              alignment: Alignment.center,
              child: Text(
                category.subCategories[index].name,
                style: AppTextStyles.restaurantDescription.copyWith(
                  color: const Color(0xFF242424),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ProductCategory? get _currentCategory =>
      (_categories.isNotEmpty && _selectedMainCategoryIndex > 0)
          ? _categories[_selectedMainCategoryIndex - 1]
          : null; // null means ALL

  Widget _buildCurrentCategorySection() {
    final ProductCategory? category = _currentCategory;
    if (category == null) {
      // ALL view: display each category as its own section
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final ProductCategory c in _categories) ...<Widget>[
            _buildOneCategorySection(
              category: c,
              selectedSubIndex:
                  _subIndexByCategory[c.catName] ?? 0,
              onSubSelected: (int idx) => _subIndexByCategory[c.catName] = idx,
            ),
            const SizedBox(height: 24),
          ]
        ],
      );
    }

    // Single category view
    return _buildOneCategorySection(
      category: category,
      selectedSubIndex: _selectedBiriyaniSubIndex,
      onSubSelected: (int idx) => _selectedBiriyaniSubIndex = idx,
    );
  }

  Widget _buildOneCategorySection({
    required ProductCategory category,
    required int selectedSubIndex,
    required ValueChanged<int> onSubSelected,
  }) {
    final List<_MenuItem> items = <_MenuItem>[];
    if (category.isSubCategories && category.subCategories.isNotEmpty) {
      final int subIndex = (selectedSubIndex >= 0 &&
              selectedSubIndex < category.subCategories.length)
          ? selectedSubIndex
          : 0;
      final List<chat.Product> products =
          category.subCategories[subIndex].products;
      items.addAll(products.map(_mapProduct));
    } else {
      items.addAll(category.products.map(_mapProduct));
    }

    final List<_MenuItem> filtered = items.where((menuItem) {
      // If both filters are off, show all items
      if (!_filterVeg && !_filterNonVeg) {
        // Only apply search filter
        if (_searchController.text.trim().isNotEmpty &&
            !menuItem.title
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase())) {
          return false;
        }
        return true;
      }
      
      // If only veg filter is on, show only veg items
      if (_filterVeg && !_filterNonVeg && !menuItem.isVeg) return false;
      
      // If only non-veg filter is on, show only non-veg items
      if (_filterNonVeg && !_filterVeg && menuItem.isVeg) return false;
      
      // If both filters are on, show all items (both veg and non-veg)
      // Apply search filter
      if (_searchController.text.trim().isNotEmpty &&
          !menuItem.title
              .toLowerCase()
              .contains(_searchController.text.trim().toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          category.catName,
          style: AppTextStyles.restaurantTitle.copyWith(
            color: const Color(0xFF242424),
          ),
        ),
        const SizedBox(height: 8),
        if (category.isSubCategories && category.subCategories.isNotEmpty) ...<Widget>[
          _buildSubcategoryChips(
            category: category,
            selectedIndex: selectedSubIndex,
            onSelected: onSubSelected,
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 222,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final _MenuItem item = filtered[index];
              return MenuItemCard(
                title: item.title,
                price: item.price,
                originalPrice: item.originalPrice,
                isVeg: item.isVeg,
                imageUrl: item.imageUrl,
                productId: item.productId,
                centralProductId: item.centralProductId,
                isCustomizable: item.isCustomizable,
                purple: _purple,
                vegColor: _veg,
                nonVegColor: _nonVeg,
                cartData: _cartData, // Pass cart data to MenuItemCard
                onQuantityChanged: (productId, centralProductId, quantity, isIncrease, isCustomizable) {
                  _onQuantityChanged(productId, centralProductId, quantity, isIncrease, isCustomizable, item.title, item.imageUrl ?? '');
                }, // Pass quantity change callback
                onClick: () {
                  // Find the product data and trigger order
                  chat.Product? foundProduct;
                  for (final category in _categories) {
                    if (category.isSubCategories && category.subCategories.isNotEmpty) {
                      for (final subCategory in category.subCategories) {
                        foundProduct = subCategory.products.firstWhere(
                          (p) => p.childProductId == item.productId,
                          orElse: () => subCategory.products.first,
                        );
                        if (foundProduct != null) break;
                      }
                    } else {
                      foundProduct = category.products.firstWhere(
                        (p) => p.childProductId == item.productId,
                        orElse: () => category.products.first,
                      );
                    }
                    if (foundProduct != null) break;
                  }
                  
                  if (foundProduct != null) {
                    // Pass the entire product object as JSON, just like in Chat screen
                    final Map<String, dynamic> productJson = foundProduct.toJson();
                    OrderService().triggerProductOrder(productJson);
                  }
                },
                onAddToCart: (productId, centralProductId, quantity, isCustomizable) {
                    if (widget.actionData?.storeIsOpen == false) {
                      print('STORE CLOSED');
                      BlackToastView.show(context, 'Store is closed. Please try again later');
                      return;
                    }
                    else if (item.instock == false && widget.actionData?.storeTypeId == FoodCategory.grocery.value) {
                      print('Product is not in stock');
                      BlackToastView.show(context, 'Product is not in stock. Please try again later');
                      return;
                    }
                  if (isCustomizable) {
                     showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ProductCustomizationScreen(
                      productId: productId,
                      centralProductId: centralProductId,
                      storeId: widget.actionData?.storeId ?? '',
                      productName: item.title,
                      productImage: item.imageUrl?.isNotEmpty ?? false ? item.imageUrl : null,
                      isFromMenuScreen: true,
                      onAddToCartWithAddOns: (product, store, variant, addOns, selectedProductId) {
                        //TODO:- Add Quantity
                        cartBloc.add(CartAddItemRequested(
                       storeId: widget.actionData?.storeId ?? '',
                       cartType: 1, // Default cart type
                       action: 1, // Add action
                       storeCategoryId: widget.actionData?.storeCategoryId ?? '',
                       newQuantity: quantity , // Add 1 item
                       storeTypeId: widget.actionData?.storeTypeId ?? -111,
                        productId: selectedProductId,
                        centralProductId: centralProductId,
                        unitId: variant.unitId,
                        newAddOns: addOns,
                    ));
                      },
                    ),
                  );
                  }else {
                    //TODO:- Add Quantity
                  cartBloc.add(CartAddItemRequested(
                       storeId: widget.actionData?.storeId ?? '',
                       cartType: 1, // Default cart type
                       action: 1, // Add action
                       storeCategoryId: widget.actionData?.storeCategoryId ?? '',
                       newQuantity: quantity , // Add 1 item
                       storeTypeId: widget.actionData?.storeTypeId ?? -111,
                        productId: productId,
                        centralProductId: centralProductId,
                        unitId: '',
                    ));
                  }                 
                },
              );
            },
          ),
        ),
      ],
    );
  }

  _MenuItem _mapProduct(chat.Product p) {
    final String priceText = _formatCurrency(
      p.currencySymbol,
      p.finalPriceList.finalPrice,
    );
    final String basePriceText = _formatCurrency(
      p.currencySymbol,
      p.finalPriceList.basePrice,
    );
    final String? imageUrl = _extractImageUrl(p.images);
    return _MenuItem(
      title: p.productName,
      price: priceText,
      originalPrice: basePriceText,
      isVeg: !p.containsMeat,
      assetPath: imageUrl ?? '',
      imageUrl: imageUrl,
      productId: p.childProductId,
      centralProductId: p.parentProductId,
      isCustomizable: p.variantsCount > 1,
    );
  }

  String _formatCurrency(String symbol, double value) {
    // Keep simple formatting matching the mock (e.g., AED25)
    if (symbol.isNotEmpty && symbol != 'AED') {
      return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return 'AED${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  String? _extractImageUrl(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      return images.isNotEmpty ? images : null;
    }
    if (images is List && images.isNotEmpty) {
      final dynamic first = images.first;
      if (first is String && first.isNotEmpty) return first;
    }
    return null;
  }

  // Widget _buildBottomCartBar() {
  //   return GestureDetector(
  //     onTap: _onAddToCart,
  //     child: Container(
  //       width: double.infinity,
  //       height: 105.56,
  //       padding: const EdgeInsets.only(top: 10),
  //       decoration: const BoxDecoration(
  //         color: Color(0xFFF5F7FF),
  //       ),
  //       child: Center(
  //         child: Container(
  //           width: 343,
  //           height: 62,
  //           decoration: BoxDecoration(
  //             gradient: const LinearGradient(
  //               begin: Alignment.centerLeft,
  //               end: Alignment.centerRight,
  //               colors: [
  //                 Color(0xFFD445EC),
  //                 Color(0xFFB02EFB),
  //                 Color(0xFF8E2FFD),
  //                 Color(0xFF5E3DFE),
  //                 Color(0xFF5186E0),
  //               ],
  //               stops: [0.0, 0.27, 0.48, 0.76, 1.0],
  //             ),
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           child: Row(
  //             children: [
  //               // Left side - Price and items
  //               Padding(
  //                 padding: const EdgeInsets.only(left: 25, top: 13),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'د.إ${_cartTotal.toStringAsFixed(2)}',
  //                       style: const TextStyle(
  //                         fontFamily: 'aed',
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w400,
  //                         height: 1.2,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 2),
  //                     Text(
  //                       '${_cartItems.toString().padLeft(2, '0')} items',
  //                       style: const TextStyle(
  //                         fontFamily: 'Plus Jakarta Sans',
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.w400,
  //                         height: 1.4,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               const Spacer(),
  //               // Right side - Checkout button
  //               Padding(
  //                 padding: const EdgeInsets.only(right: 25),
  //                 child: const Text(
  //                   'Checkout',
  //                   style: TextStyle(
  //                     fontFamily: 'Plus Jakarta Sans',
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w700,
  //                     height: 1.2,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Update cart data from getCart API response
  void _updateCartData(List<UniversalCartData> cartData) {
    // Use post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _cartData = cartData;
          
        });
      }
    });
  }

   /// Get addToCartOnId from cart data for a specific product
  dynamic _getAddToCartOnId(String productId) {
    try {
      // Use filter to find the product with matching ID
      final cartData = cartBloc.cartData
          .expand((cart) => cart.sellers)
          .expand((seller) => seller.products)
          .where((product) => product.id == productId)
          .firstOrNull;
      
      return cartData?.addToCartOnId;
    } catch (e) {
      print('Error getting addToCartOnId: $e');
      return null;
    }
  }

  // Handle quantity changes for products
  void _onQuantityChanged(String productId, String centralProductId, int currentQuantity, bool isIncrease, bool isCustomizable, String productName, String productImage) {
    try {
      if (isIncrease == false && currentQuantity == 1) {
          //TODO:- 0 Quantity
        int? addToCartOnId;
        if (isCustomizable == true) {
          addToCartOnId = _getAddToCartOnId(productId);
          print("addCartOnID: $addToCartOnId");
        }

         cartBloc.add(CartAddItemRequested(
          storeId: widget.actionData?.storeId ?? '',
          cartType: 2,
          action: 3, // Add action
          storeCategoryId: widget.actionData?.storeCategoryId ?? '',
          newQuantity: 0,
          storeTypeId: widget.actionData?.storeTypeId ?? -111,
          productId: productId,
          centralProductId: centralProductId,
          unitId: '',
          addToCartOnId: addToCartOnId,
        ));
      }else if (currentQuantity > 0 && isIncrease == true) {

          if (isCustomizable) {

            showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CustomizationSummaryScreen(
                          
                          onChooseClicked: () {
                            // When "I'll choose" is clicked, open ProductCustomizationScreen
                            _openProductCustomization(productId, centralProductId,widget.actionData?.storeId ?? '', widget.actionData?.storeCategoryId ?? '', widget.actionData?.storeTypeId ?? -111, context, productName, productImage);
                          },
                          onRepeatClicked: () {
                            //TODO:- Add Quantity
                            final addToCartOnId = _getAddToCartOnId(productId);
                            print("addCartOnID: $addToCartOnId");

                            cartBloc.add(CartAddItemRequested(
                              storeId: widget.actionData?.storeId ?? '',
                              cartType: 1,
                              action: 2, // Add action
                              storeCategoryId: widget.actionData?.storeCategoryId ?? '',
                              newQuantity: currentQuantity + 1,
                              storeTypeId: widget.actionData?.storeTypeId ?? -111,
                              productId: productId,
                              centralProductId: centralProductId,
                              unitId: '',
                              addToCartOnId: addToCartOnId,
                            )); 
                          
                          },
                        ),
          );
             
          }else {
            //TODO:- Add Quantity
             cartBloc.add(CartAddItemRequested(
          storeId: widget.actionData?.storeId ?? '',
          cartType: 1,
          action: 2, // Remove action
          storeCategoryId: widget.actionData?.storeCategoryId ?? '',
          newQuantity: currentQuantity + 1,
          storeTypeId: widget.actionData?.storeTypeId ?? -111,
          productId: productId,
          centralProductId: centralProductId,
          unitId: '',
        ));
          }
    
      } else {
        //TODO:- Remove Quantity
        int? addToCartOnId;
        if (isCustomizable == true) {
          addToCartOnId = _getAddToCartOnId(productId);
          print("addCartOnID: $addToCartOnId");
        }
        cartBloc.add(CartAddItemRequested(
          storeId: widget.actionData?.storeId ?? '',
          cartType: 2,
          action: 2, // Add action
          storeCategoryId: widget.actionData?.storeCategoryId ?? '',
          newQuantity: currentQuantity - 1,
          storeTypeId: widget.actionData?.storeTypeId ?? -111,
          productId: productId,
          centralProductId: centralProductId,
          unitId: '',
          addToCartOnId: addToCartOnId,
        ));
      }
    } catch (e) {
      print('Error changing quantity: $e');
    }
  }

  void _openProductCustomization(String productId, String centralProductId, String storeId,String storeCategoryId,int storeTypeId, BuildContext context, String productName, String productImage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductCustomizationScreen(
        productId: productId,
        centralProductId: centralProductId,
        storeId: storeId,
        productName: productName,
        productImage: productImage,
        isFromMenuScreen: true,
        onAddToCartWithAddOns: (product, store, variant, addOns, selectedProductId) => _onAddToCartWithAddOns(productId, centralProductId, storeId, storeCategoryId, storeTypeId, context, variant, addOns,selectedProductId),
      ),
    );
  }

   /// Handle adding products with addons to cart
  void _onAddToCartWithAddOns(
    String productId, 
    String centralProductId, 
    String storeId, 
    String storeCategoryId,
    int storeTypeId,
    BuildContext context,
    dynamic variant, 
    List<Map<String, dynamic>> addOns,
    String selectedProductId
  ) {
    try {
      //TODO:- Add Quantity
      cartBloc.add(CartAddItemRequested(
        storeId: storeId,
        cartType: 1, // Default cart type
        action: 1, // Add action
        storeCategoryId: storeCategoryId,
        newQuantity: 1,
        storeTypeId: storeTypeId,
        productId: selectedProductId,
        centralProductId: centralProductId,
        unitId: variant.unitId,
        newAddOns: addOns,
      ));
      
      // print("Added product with addons to cart: ${product.productName}");
    } catch (e) {
      print('RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e');
    }
  }
}


// Replaced inline card with shared MenuItemCard

class _MenuItem {
  final String title;
  final String price;
  final String originalPrice;
  final bool isVeg;
  final String assetPath;
  final String? imageUrl;
  final String? productId;
  final String? centralProductId;
  final bool isCustomizable;
  final bool instock;

  const _MenuItem({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isVeg,
    required this.assetPath,
    this.imageUrl,
    this.productId,
    this.centralProductId,
    this.isCustomizable = false,
    this.instock = true,
  });
}


