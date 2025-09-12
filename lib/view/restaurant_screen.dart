import 'package:chat_bot/utils/enum.dart';
import 'package:chat_bot/view/customization_summary_screen.dart';
import 'package:chat_bot/view/product_customization_screen.dart';
import 'package:chat_bot/view/grocery_customization_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/chat_response.dart' as chat;
import '../data/model/universal_cart_response.dart';
import '../widgets/black_toast_view.dart';
import '../widgets/store_card.dart';
import '../widgets/screen_header.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_bloc.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_event.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_state.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';

class RestaurantScreen extends StatefulWidget {
  final chat.WidgetAction? actionData;
  final Function(bool)? onCheckout;
  // final CartBloc? cartBloc; // Optional CartBloc parameter

  const RestaurantScreen({
    super.key, 
    this.actionData,
    this.onCheckout,
    // this.cartBloc, // Optional parameter
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final RestaurantBloc _bloc;
  late final CartBloc cartBloc;
  // final CartManager cartManager = CartManager();
  String _currentKeyword = '';
  DateTime? _lastQueryAt;
  
  // Cart state
  int _cartItems = 0;
  List<UniversalCartData> _cartData = []; // Store cart data from getCart API

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _currentKeyword = value.trim();
    final now = DateTime.now();
    _lastQueryAt = now;
    
    // Skip API call for empty queries - show all results
    if (_currentKeyword.isEmpty) {
      _bloc.add(RestaurantFetchRequested(keyword: '', storeCategoryName: widget.actionData?.storeCategoryName ?? '', storeCategoryId: widget.actionData?.storeCategoryId ?? ''));
      return;
    }
    
    // Reduced debounce delay for faster response
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      // Debounce: only proceed if this is the latest input
      if (_lastQueryAt != now) return;
      _bloc.add(RestaurantFetchRequested(keyword: _currentKeyword, storeCategoryName: widget.actionData?.storeCategoryName ?? '', storeCategoryId: widget.actionData?.storeCategoryId ?? ''));
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc = RestaurantBloc();
    cartBloc = CartBloc();
    _cartData = globalCartData;
    _bootstrapData();
    isCartAPICalled = false;
    // Listen to cart state changes to update cart data
    cartBloc.stream.listen((state) {
      if (state is CartLoaded && state.rawCartData != null) {
        _updateCartData(state.rawCartData!.data);
      }else if (state is CartEmpty) {
        _updateCartData([]);
      }
    });
  }

  Future<void> _bootstrapData() async {
    cartBloc.add(CartFetchRequested(needToShowLoader: false));
    _bloc.add(RestaurantFetchRequested(keyword: _currentKeyword, storeCategoryName: widget.actionData?.storeCategoryName ?? '', storeCategoryId: widget.actionData?.storeCategoryId ?? ''));
    
  }

  /// Handle adding products with addons to cart
  void _onAddToCartWithAddOns(
    chat.Product product, 
    chat.Store store, 
    dynamic variant, 
    List<Map<String, dynamic>> addOns,
    String selectedProductId
  ) {
    try {
      //TODO:- Add Quantity
      cartBloc.add(CartAddItemRequested(
        storeId: store.storeId,
        cartType: 1, // Default cart type
        action: 1, // Add action
        storeCategoryId: store.storeCategoryId,
        newQuantity: 1,
        storeTypeId: store.type,
        productId: selectedProductId,
        centralProductId: product.parentProductId,
        unitId: variant.unitId,
        newAddOns: addOns,
      ));
      
      print("Added product with addons to cart: ${product.productName}");
    } catch (e) {
      print('RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e');
    }
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

void _openGroceryCustomization(String parentProductId, String productId, String unitId, String storeId, String storeCategoryId, int storeTypeId, String productName, String productImage) {
  showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => GroceryCustomizationScreen(
                            parentProductId: parentProductId,
                            productId: productId,
                            storeId: storeId,
                            productName: productName,
                            productImage: productImage,
                            onAddToCart: (parentProductId,productId,unitId) {
                              _onAddToCartForGrocery(parentProductId,productId,unitId,storeId,storeCategoryId,storeTypeId,null);
                            },
                          ),
                        );
  }

  void _openProductCustomization(chat.Product product, chat.Store store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductCustomizationScreen(
        product: product,
        store: store,
        onAddToCartWithAddOns: _onAddToCartWithAddOns,
      ),
    );
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


void _onQuantityChangedForGrocery(String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int variantsCount,
    int newQuantity,
    bool isIncrease,
    String productName,
    String productImage) {
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
                            _openGroceryCustomization(parentProductId,productId,unitId,storeId,storeCategoryId,storeTypeId,productName,productImage);
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
  
  void _onQuantityChanged(chat.Product product, chat.Store store, int newQuantity, bool isIncrease) {
    if (isIncrease == false && newQuantity == 1) {
      //TODO:- 0 Quantity
      int? addToCartOnId;
      if (product.variantsCount > 1) {
         addToCartOnId = _getAddToCartOnId(product.childProductId);
         print("addCartOnID: $addToCartOnId");
       }

      cartBloc.add(CartAddItemRequested(
        storeId: store.storeId,
        cartType: 2,
        action: 3, // Add/Update action
        storeCategoryId: store.storeCategoryId,
        newQuantity: 0,
        storeTypeId: store.type,
        productId: product.childProductId,
        centralProductId: product.parentProductId,
        unitId: product.unitId,
        addToCartOnId: addToCartOnId,
      ));
    }else if (newQuantity > 0 && isIncrease == true) {
      if (product.variantsCount > 1) {
         showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CustomizationSummaryScreen(
                          store: store,
                          product: product,
                          onChooseClicked: () {
                            _openProductCustomization(product, store);
                          },
                          onRepeatClicked: () {
                            //TODO:- Add Quantity
                            final addToCartOnId = _getAddToCartOnId(product.childProductId);
                            print("addCartOnID: $addToCartOnId");

                            cartBloc.add(CartAddItemRequested(
                              storeId: store.storeId,
                              cartType: 1,
                              action: 2, // Add action
                              storeCategoryId: store.storeCategoryId,
                              newQuantity: newQuantity + 1,
                              storeTypeId: store.type,
                              productId: product.childProductId,
                              centralProductId: product.parentProductId,
                              unitId: product.unitId,
                              addToCartOnId: addToCartOnId,
                            )); 
                          
                          },
                        ),
          );
      }else {
        //TODO:- Add Quantity
      cartBloc.add(CartAddItemRequested(
        storeId: store.storeId,
        cartType: 1,
        action: 2, // Add action
        storeCategoryId: store.storeCategoryId,
        newQuantity: newQuantity + 1,
        storeTypeId: store.type,
        productId: product.childProductId,
        centralProductId: product.parentProductId,
        unitId: product.unitId,
      ));        
      }

    } else {
      //TODO:- Remove Quantity
      int? addToCartOnId;
      if (product.variantsCount > 1) {
        addToCartOnId = _getAddToCartOnId(product.childProductId);
        print("addCartOnID: $addToCartOnId");
      }
      cartBloc.add(CartAddItemRequested(
        storeId: store.storeId,
        cartType: 2,
        action: 2, // Add/Update action
        storeCategoryId: store.storeCategoryId,
        newQuantity: newQuantity - 1,
        storeTypeId: store.type,
        productId: product.childProductId,
        centralProductId: product.parentProductId,
        unitId: product.unitId,
        addToCartOnId: addToCartOnId,
      ));
    }
  
  }

  // Update cart data from getCart API response
  void _updateCartData(List<UniversalCartData> cartData) {
    setState(() {
      _cartData = cartData;
      
    });
  }

  // Refresh cart data
  void _refreshCart() {
    cartBloc.add(CartFetchRequested(needToShowLoader: false));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
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
                          const SizedBox(height: 16),
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          Expanded(child: _buildRestaurantList()),
                        // Add bottom padding to account for the cart bar (only when items exist)
                        if (_cartItems > 0) const SizedBox(height: 105),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // // Bottom cart bar - positioned absolutely at the bottom (only show when items exist)
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


  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DEF3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF979797),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 17),
              ),
              onChanged: (value) {
                _onSearchChanged(value);
              },
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(54),
            ),
            child: const Icon(
              Icons.search,
              size: 17,
              color: Color(0xFF585C77),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRestaurantList() {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoadInProgress || state is RestaurantInitial) {
          return const Center();
        }

        if (state is RestaurantLoadFailure) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6E4185),
              ),
            ),
          );
        }

        final restaurants = (state as RestaurantLoadSuccess).restaurants;
        if (restaurants.isEmpty) {
          return const Center(
            child: Text(
              'No restaurants available',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6E4185),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _refreshCart();
            _bloc.add(RestaurantFetchRequested(keyword: _currentKeyword, storeCategoryName: widget.actionData?.storeCategoryName ?? ''));
          },
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: restaurants.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemBuilder: (context, index) {
              try {
                return StoreCard(
                  store: restaurants[index],
                  storesWidget: null,
                  index: index,
                  cartData: _cartData, // Pass cart data to StoreCard
                  onTap: () {
                    // Pass the entire store object as JSON, just like in Chat screen
                    final Map<String, dynamic> storeJson = restaurants[index].toJson();
                    OrderService().triggerStoreOrder(storeJson);
                    // Navigator.pop(context);
                  },
                  onAddToCartRequested: (product, store) {
                    if (store.storeIsOpen == false) {
                      print('STORE CLOSED');
                      BlackToastView.show(context, 'Store is closed. Please try again later');
                      return;
                    }else if (product.instock == false && store.type == FoodCategory.grocery.value) {
                      print('Product is not in stock');
                      BlackToastView.show(context, 'Product is not in stock. Please try again later');
                      return;
                    }
                    if (product.variantsCount > 1) {
                      if (store.type == FoodCategory.grocery.value) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => GroceryCustomizationScreen(
                            parentProductId: product.parentProductId,
                            productId: product.childProductId,
                            storeId: store.storeId,
                            productName: product.productName,
                            productImage: product.productImage,
                            onAddToCart: (parentProductId,productId,unitId) {
                              _onAddToCartForGrocery(parentProductId,productId,unitId,store.storeId,store.storeCategoryId,store.type,null);
                            },
                          ),
                        );
                      }else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ProductCustomizationScreen(
                            product: product,
                            store: store,
                            onAddToCartWithAddOns: _onAddToCartWithAddOns,
                          ),
                        );
                      }
                    }else {
                         try {
                           //TODO:- Add Quantity
                        cartBloc.add(CartAddItemRequested(
                          storeId: store.storeId,
                          cartType: 1, // Default cart type
                          action: 1, // Add action
                          storeCategoryId: store.storeCategoryId,
                          newQuantity: 1, // Add 1 item
                          storeTypeId: store.type,
                          productId: product.childProductId,
                          centralProductId: product.parentProductId,
                          unitId: product.unitId,
                        ));
                      } catch (e) {
                        print('RestaurantScreen: Error dispatching CartAddItemRequeste: $e');
                      }
                    }                  
                  },
                  onQuantityChanged: (product, store, newQuantity, isIncrease) {
                    if (store.type == FoodCategory.grocery.value) {
                      _onQuantityChangedForGrocery(product.parentProductId,product.childProductId,product.unitId,store.storeId,store.storeCategoryId,store.type,product.variantsCount,newQuantity,isIncrease,product.productName,product.productImage);
                    }else {
                      _onQuantityChanged(product, store, newQuantity, isIncrease);
                    }
                  }
                );
              } catch (e) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    border: Border.all(color: const Color(0xFFEEF4FF), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    restaurants[index].storename,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF242424),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

}
