import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/data/model/chat_response.dart' as chat;
import 'package:chat_bot/utils/enum.dart';
import 'package:chat_bot/view/customization_summary_screen.dart';
import 'package:chat_bot/view/grocery_customization_screen.dart';
import 'package:chat_bot/view/product_customization_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/subcategory_products_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/widgets/menu_item_card.dart';
import 'package:chat_bot/widgets/screen_header.dart';
import 'package:chat_bot/services/callback_manage.dart';
import '../bloc/grocery_menu/grocery_menu_bloc.dart';
import '../bloc/grocery_menu/grocery_menu_event.dart';
import '../bloc/grocery_menu/grocery_menu_state.dart';
import '../utils/asset_helper.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';

import '../widgets/black_toast_view.dart';

class GroceriesMenuScreen extends StatefulWidget {
  final chat.WidgetAction? actionData;
  final Function(bool)? onCheckout;

  const GroceriesMenuScreen({super.key, this.actionData, this.onCheckout});

  @override
  State<GroceriesMenuScreen> createState() => _GroceriesMenuScreenState();
}

class _GroceriesMenuScreenState extends State<GroceriesMenuScreen> {
  static const Color _purple = Color(0xFF8E2FFD);
  static const Color _border = Color(0xFFD8DEF3);
  static const Color _veg = Color(0xFF66BB6A);
  static const Color _nonVeg = Color(0xFFF44336);

  final TextEditingController _searchController = TextEditingController();
  late final GroceryMenuBloc _bloc;
  late final CartBloc cartBloc;

  // Dynamic data from API
  int _selectedMainCategoryIndex = 0;

  // Cart state
  List<UniversalCartData> _cartData = []; // Store cart data from getCart API

  @override
  void initState() {
    super.initState();
    _bloc = GroceryMenuBloc(actionData: widget.actionData);
    cartBloc = CartBloc();
    
    _fetchSubCategoryProducts();
    cartBloc.add(CartFetchRequested(needToShowLoader: false));
  }

  void _fetchSubCategoryProducts() {
    _bloc.add(SubCategoryProductsRequested(storeId: widget.actionData?.storeId ?? ''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: <Widget>[
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: ScreenHeader(
                        title: widget.actionData?.title ?? '',
                        subtitle: widget.actionData?.subtitle ?? '',
                        onClose: () {
                          if (widget.onCheckout != null ) {
                            widget.onCheckout!(true);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Content Area
                    Expanded(
                      child: BlocListener<CartBloc, CartState>(
                        listener: (context, state) {
                          if (state is CartLoaded && state.rawCartData != null) {
                            _updateCartData(state.rawCartData!.data);
                          }else if (state is CartEmpty) {
                            _updateCartData([]);
                          }
                        },
                        child: BlocListener<GroceryMenuBloc, GroceryMenuState>(
                          listener: (context, state) {
                            if (state is SubCategoryProductsLoadFailure) {
                              // Optionally show error message
                              print('SubCategoryProducts API Error: ${state.message}');
                            }
                          },
                        child: BlocBuilder<GroceryMenuBloc, GroceryMenuState>(
                          builder: (context, state) {
                            if (state is SubCategoryProductsLoadInProgress) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 32),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (state is SubCategoryProductsLoadFailure) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Text(
                                  state.message,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }
                            if (state is SubCategoryProductsLoadSuccess) {
                              return _buildNewGroceryUI(state.subCategoryProducts);
                            }
                            
                            // Default loading state
                            return const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildNewGroceryUI(SubCategoryProductsResponse subCategoryProducts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          // _buildSearchBar(),
          // const SizedBox(height: 16),
          
          // Category Filter Chips
          _buildCategoryFilterChips(subCategoryProducts),
          const SizedBox(height: 16),
          
          // Products Grid
          _buildProductsGrid(subCategoryProducts),
        ],
      ),
    );
  }


  Widget _buildCategoryFilterChips(SubCategoryProductsResponse subCategoryProducts) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subCategoryProducts.categoryData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final categoryData = subCategoryProducts.categoryData[index];
          final bool isSelected = index == _selectedMainCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedMainCategoryIndex = index;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF9FF) : Colors.white,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: isSelected ? _purple : _border),
              ),
              alignment: Alignment.center,
              child: Text(
                categoryData.subCategoryName,
                style: TextStyle(
                  fontSize: 14,
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

  // Calculate dynamic dimensions based on screen size
  Map<String, double> _calculateDynamicDimensions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate available width (screen width - horizontal padding - spacing)
    final horizontalPadding = 40.0; // 20px on each side
    final availableWidth = screenWidth - horizontalPadding;
    
    // Calculate item width based on screen size
    double itemWidth;
    double itemHeight;
    double spacing;
    
    if (screenWidth < 360) {
      // Small devices (like iPhone SE)
      itemWidth = (availableWidth - 12) / 2; // 12px spacing between items
      // Calculate height based on content: image (90% of width) + fixed content (112px)
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight + 112; // Fixed content height
      spacing = 8.0;
    } else if (screenWidth < 400) {
      // Medium devices
      itemWidth = (availableWidth - 16) / 2; // 16px spacing
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight + 112; // Fixed content height
      spacing = 10.0;
    } else {
      // Large devices (like iPhone Pro Max, tablets)
      itemWidth = (availableWidth - 20) / 2; // 20px spacing
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight + 112; // Fixed content height
      spacing = 12.0;
    }
    
    return {
      'itemWidth': itemWidth,
      'itemHeight': itemHeight,
      'spacing': spacing,
      'aspectRatio': itemWidth / itemHeight,
    };
  }

  Widget _buildProductsGrid(SubCategoryProductsResponse subCategoryProducts) {
    if (subCategoryProducts.categoryData.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Color(0xFF979797),
              ),
              SizedBox(height: 16),
              Text(
                'No products available',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF979797),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search or check back later',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF979797),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get products from selected category or all categories
    List<SubCategoryProduct> allProducts = [];
    if (_selectedMainCategoryIndex < subCategoryProducts.categoryData.length) {
      allProducts = subCategoryProducts.categoryData[_selectedMainCategoryIndex].subCategory;
    } else {
      // Show all products from all categories
      for (final categoryData in subCategoryProducts.categoryData) {
        allProducts.addAll(categoryData.subCategory);
      }
    }

    return Expanded(
      child: Builder(
        builder: (context) {
          final dimensions = _calculateDynamicDimensions(context);
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: dimensions['aspectRatio']!,
              crossAxisSpacing: dimensions['spacing']!,
              mainAxisSpacing: dimensions['spacing']!,
            ),
            itemCount: allProducts.length,
            itemBuilder: (BuildContext context, int index) {
              final subCategoryProduct = allProducts[index];
              final product = subCategoryProduct.toProduct();
              final menuItem = _mapProduct(product);
              
              return MenuItemCard(
                title: menuItem.title,
                price: menuItem.price,
                originalPrice: menuItem.originalPrice,
                isVeg: menuItem.isVeg,
                imageUrl: menuItem.imageUrl,
                productId: menuItem.productId,
                centralProductId: menuItem.centralProductId,
                isCustomizable: menuItem.isCustomizable,
                purple: _purple,
                vegColor: _veg,
                nonVegColor: _nonVeg,
                imageWidth: dimensions['itemWidth']!,
                imageHeight: dimensions['itemWidth']! * 0.9, // Better proportion for taller cards
                cardWidth: dimensions['itemWidth']!,
                cartData: _cartData,
                onQuantityChanged: (productId, centralProductId, quantity, isIncrease, isCustomizable) {
                  _onQuantityChangedForGrocery(product.parentProductId,product.childProductId,product.unitId,product.storeId ?? '',product.storeCategoryId ?? '',product.storeTypeId ?? -111,product.variantsCount,quantity,isIncrease);
                },
                onClick: () {
                  // Handle product click
                  final Map<String, dynamic> productJson = product.toJson();
                  OrderService().triggerProductOrder(productJson);
                },
                onAddToCart: (productId, centralProductId, quantity, isCustomizable) {
                  if (widget.actionData?.storeIsOpen == false) {
                    print('STORE CLOSED');
                    BlackToastView.show(context, 'Store is closed. Please try again later');
                    return;
                  }
                  else if (subCategoryProduct.outOfStock && widget.actionData?.storeTypeId == FoodCategory.grocery.value) {
                    print('Product is not in stock');
                    BlackToastView.show(context, 'Product is not in stock. Please try again later');
                    return;
                  }
                  if (isCustomizable) {
                     showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => GroceryCustomizationScreen(
                            parentProductId: product.parentProductId,
                            productId: product.childProductId,
                            storeId: widget.actionData?.storeId ?? '',
                            productName: product.productName,
                            productImage: product.productImage,
                            onAddToCart: (parentProductId,productId,unitId) {
                              _onAddToCartForGrocery(parentProductId,productId,unitId,widget.actionData?.storeId ?? '',widget.actionData?.storeCategoryId ?? '',FoodCategory.grocery.value,null);
                            },
                          ),
                        );
                  } else {
                    cartBloc.add(CartAddItemRequested(
                      storeId: widget.actionData?.storeId ?? '',
                      cartType: 1,
                      action: 1,
                      storeCategoryId: widget.actionData?.storeCategoryId ?? '',
                      newQuantity: quantity,
                      storeTypeId: widget.actionData?.storeTypeId ?? -111,
                      productId: productId,
                      centralProductId: centralProductId,
                      unitId: '',
                    ));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }


  void _onAddToCartForGrocery(
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int? addToCartOnId,
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
        productId: productId,
        centralProductId: parentProductId,
        unitId: unitId,
        addToCartOnId: addToCartOnId,
      ));
      
      print("Added product to cart: ${productId}");
    } catch (e) {
      print('RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e');
    }
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
      assetPath: imageUrl ?? AssetHelper.getAssetPath('images/ic_placeHolder.svg'),
      imageUrl: imageUrl,
      productId: p.childProductId,
      centralProductId: p.parentProductId,
      isCustomizable: p.variantCount ?? false,
    );
  }

  String _formatCurrency(String symbol, double value) {
    // Format currency with proper symbol
    if (symbol.isNotEmpty) {
      return '$symbol${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return '₹${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
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

  
void _onQuantityChangedForGrocery(
  String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int variantsCount,
    int newQuantity,
    bool isIncrease) {
    if (isIncrease == false && newQuantity == 1) {
      //TODO:- 0 Quantity
      int? addToCartOnId;
      if (variantsCount > 1) {
         addToCartOnId = _getAddToCartOnId(productId);
         print("addCartOnID: $addToCartOnId");
       }

      cartBloc.add(CartAddItemRequested(
        storeId: storeId,
        cartType: 2,
        action: 3, // Add/Update action
        storeCategoryId: storeCategoryId,
        newQuantity: 0,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: parentProductId,
        unitId: unitId,
        addToCartOnId: addToCartOnId,
      ));
    }else if (newQuantity > 0 && isIncrease == true) {
      if (variantsCount > 1) {
         showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CustomizationSummaryScreen(
                          // store: store,
                          // product: product,
                          onChooseClicked: () {
                            _openGroceryCustomization(parentProductId,productId,unitId,storeId,storeCategoryId,storeTypeId);
                          },
                          onRepeatClicked: () {
                            //TODO:- Add Quantity
                            final addToCartOnId = _getAddToCartOnId(productId);
                            print("addCartOnID: $addToCartOnId");

                            cartBloc.add(CartAddItemRequested(
                              storeId: storeId,
                              cartType: 1,
                              action: 2, // Add action
                              storeCategoryId: storeCategoryId,
                              newQuantity: newQuantity + 1,
                              storeTypeId: storeTypeId,
                              productId: productId,
                              centralProductId: parentProductId,
                              unitId: unitId,
                              addToCartOnId: addToCartOnId,
                            )); 
                          
                          },
                        ),
          );
      }else {
        //TODO:- Add Quantity
         final addToCartOnId = _getAddToCartOnId(productId);
          print("addCartOnID: $addToCartOnId");
      cartBloc.add(CartAddItemRequested(
        storeId: storeId,
        cartType: 1,
        action: 2, // Add action
        storeCategoryId: storeCategoryId,
        newQuantity: newQuantity + 1,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: parentProductId,
        unitId: unitId,
        addToCartOnId: addToCartOnId,
      ));        
      }

    } else {
      //TODO:- Remove Quantity
      int? addToCartOnId;
      if (variantsCount > 1) {
        addToCartOnId = _getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
      }
      cartBloc.add(CartAddItemRequested(
        storeId: storeId,
        cartType: 2,
        action: 2, // Add/Update action
        storeCategoryId: storeCategoryId,
        newQuantity: newQuantity - 1,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: parentProductId,
        unitId: unitId,
        addToCartOnId: addToCartOnId,
      ));
    }
  
  }

  void _openProductCustomization(String productId, String centralProductId, String storeId,String storeCategoryId,int storeTypeId, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductCustomizationScreen(
        productId: productId,
        centralProductId: centralProductId,
        storeId: storeId,
        productName: 'Product Name',
        productImage: 'Product Image',
        isFromMenuScreen: true,
        onAddToCartWithAddOns: (product, store, variant, addOns) => _onAddToCartWithAddOns(productId, centralProductId, storeId, storeCategoryId, storeTypeId, context, variant, addOns),
      ),
    );
  }


void _openGroceryCustomization(String parentProductId, String productId, String unitId, String storeId, String storeCategoryId, int storeTypeId) {
  showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => GroceryCustomizationScreen(
                            parentProductId: parentProductId,
                            productId: productId,
                            storeId: storeId,
                            productName: 'productName',
                            productImage: 'productImage',
                            onAddToCart: (parentProductId,productId,unitId) {
                              _onAddToCartForGrocery(parentProductId,productId,unitId,storeId,storeCategoryId,storeTypeId,null);
                            },
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
    List<Map<String, dynamic>> addOns
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
        productId: productId,
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
  });
}


