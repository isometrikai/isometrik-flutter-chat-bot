import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/chat_response.dart';
import '../widgets/store_card.dart';
import '../widgets/screen_header.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_bloc.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_event.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_state.dart';
import 'package:chat_bot/services/cart_manager.dart';
import 'package:chat_bot/services/callback_manage.dart';

class RestaurantScreen extends StatefulWidget {
  final WidgetAction? actionData;
  final Function(List<String>)? onCheckout;

  const RestaurantScreen({
    super.key, 
    this.actionData,
    this.onCheckout,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final RestaurantBloc _bloc;
  final CartManager cartManager = CartManager();
  String _currentKeyword = '';
  DateTime? _lastQueryAt;
  
  // Cart state
  double _cartTotal = 0.00;
  int _cartItems = 0;
  Map<String, int> _productQuantities = {}; // Track product quantities
  Map<String, Product> _productDetails = {}; // Track product details
  Map<String, int> _initialQuantities = {}; // Track initial quantities when screen opened
  
  // Store restaurants data for product lookup
  List<Store> _restaurants = [];

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
    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      // Debounce: only proceed if this is the latest input
      if (_lastQueryAt != now) return;
      _bloc.add(RestaurantFetchRequested(keyword: _currentKeyword));
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc = RestaurantBloc();
    _bootstrapData();
  }

  Future<void> _bootstrapData() async {
    _bloc.add(RestaurantFetchRequested(keyword: _currentKeyword));
    _initializeInitialQuantities();
  }

  void _initializeInitialQuantities() {
    // Initialize initial quantities for products already in cart
    // This ensures we track the correct baseline when screen opens
    setState(() {
      // Get all products from CartManager and set their initial quantities
      final currentQuantities = cartManager.productQuantities;
      _initialQuantities.addAll(currentQuantities);
      
      print("Initialized quantities: $_initialQuantities");
    });
  }

  void _onAddToCart() {
    // Handle add to cart action - show added products
    final currentQuantities = cartManager.productQuantities;
    final currentCustomizations = cartManager.productCustomizations;
    
    // Create consolidated messages from quantities and customizations
    List<String> consolidatedMessages = [];
    currentQuantities.forEach((productId, quantity) {
      if (quantity > 0) {
        // Check if this is a customization ID (contains underscore and timestamp)
        final isCustomizationId = productId.contains('_') && 
                                 productId.split('_').length > 1 &&
                                 productId.split('_').last.length > 10; // Timestamp length
        
        if (isCustomizationId) {
          // This is a product with customizations
          final baseProductId = productId.split('_').first;
          
          // Find product details from restaurants data
          Product? product;
          for (final store in _restaurants) {
            for (final prod in store.products) {
              if (prod.childProductId == baseProductId) {
                product = prod;
                break;
              }
            }
            if (product != null) break;
          }
          
          if (product != null) {
            // Get customizations for this product
            final customizations = currentCustomizations[productId];
            String message = "Add ${quantity}X ${product.productName}";
            
            // Add customization details if available
            if (customizations != null && customizations.isNotEmpty) {
              List<String> customizationDetails = [];
              
              for (final entry in customizations.entries) {
                if (entry.value.isNotEmpty) {
                  if (entry.key == 'variant') {
                    // Handle variant specially
                    if (entry.value.length == 1) {
                      customizationDetails.add(entry.value.first);
                    } else {
                      customizationDetails.add("${entry.key}: ${entry.value.join(', ')}");
                    }
                  } else {
                    // Handle add-ons
                    customizationDetails.add("${entry.key}: ${entry.value.join(', ')}");
                  }
                }
              }
              
              if (customizationDetails.isNotEmpty) {
                message += " with ${customizationDetails.join(', ')}";
              }
            }
            
            message += " to cart";
            consolidatedMessages.add(message);
          }
        } else {
          // This is a regular product (single variant)
          // Find product details from restaurants data
          Product? product;
          for (final store in _restaurants) {
            for (final prod in store.products) {
              if (prod.childProductId == productId) {
                product = prod;
                break;
              }
            }
            if (product != null) break;
          }
          
          if (product != null) {
            // Calculate quantity added in this session
            final initialQuantity = _initialQuantities[productId] ?? 0;
            final quantityAdded = quantity - initialQuantity;
            
            if (quantityAdded > 0) {
              // Get customizations for this product
              final customizations = currentCustomizations[productId];
              String message = "Add ${quantityAdded}X ${product.productName}";
              
              // Add customization details if available
              if (customizations != null && customizations.isNotEmpty) {
                List<String> customizationDetails = [];
                
                for (final entry in customizations.entries) {
                  if (entry.value.isNotEmpty) {
                    if (entry.key == 'variant') {
                      // Handle variant specially
                      if (entry.value.length == 1) {
                        customizationDetails.add(entry.value.first);
                      } else {
                        customizationDetails.add("${entry.key}: ${entry.value.join(', ')}");
                      }
                    } else {
                      // Handle add-ons
                      customizationDetails.add("${entry.key}: ${entry.value.join(', ')}");
                    }
                  }
                }
                
                if (customizationDetails.isNotEmpty) {
                  message += " with ${customizationDetails.join(', ')}";
                }
              }
              
              message += " to cart";
              consolidatedMessages.add(message);
            }
          }
        }
      }
    });
    
    // Call the callback with consolidated messages and close the screen
    if (widget.onCheckout != null && consolidatedMessages.isNotEmpty) {
      widget.onCheckout!(consolidatedMessages);
    }
    
    // Close the screen
    Navigator.of(context).pop();
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

  void _syncLocalStateWithCartManager() {
    final currentQuantities = cartManager.productQuantities;
    
    setState(() {
      _productQuantities.clear();
      _productQuantities.addAll(currentQuantities);
      
      // Ensure product details are populated for all products in cart
      for (final store in _restaurants) {
        for (final product in store.products) {
          if (currentQuantities.containsKey(product.childProductId) && 
              currentQuantities[product.childProductId]! > 0) {
            _productDetails[product.childProductId] = product;
          }
        }
      }
      
      // Update cart totals
      _cartItems = _productQuantities.values.fold(0, (sum, qty) => sum + qty);
      _cartTotal = _productDetails.values.fold(0.0, (sum, prod) => 
        sum + (prod.finalPrice * (_productQuantities[prod.childProductId] ?? 0)));
      
      print('Synced local state - Items: $_cartItems, Total: $_cartTotal');
      print('Synced quantities: $_productQuantities');
      print('Product details: ${_productDetails.keys}');
    });
  }

  void _updateCartStateFromCartManager() {
    // Get current quantities from CartManager
    final currentQuantities = cartManager.productQuantities;
    
    print('Updating cart state from CartManager: $currentQuantities');
    
    // Update local cart state
    setState(() {
      _productQuantities.clear();
      _productQuantities.addAll(currentQuantities);
      
      // Populate product details from restaurants data
      _productDetails.clear();
      for (final store in _restaurants) {
        for (final product in store.products) {
          if (currentQuantities.containsKey(product.childProductId)) {
            _productDetails[product.childProductId] = product;
          }
        }
      }
      
      // Update cart totals
      _cartItems = _productQuantities.values.fold(0, (sum, qty) => sum + qty);
      _cartTotal = _productDetails.values.fold(0.0, (sum, prod) => 
        sum + (prod.finalPrice * (_productQuantities[prod.childProductId] ?? 0)));
      
      print('Cart state updated - Items: $_cartItems, Total: $_cartTotal');
      print('Product details: ${_productDetails.keys}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: StreamBuilder<Map<String, int>>(
        stream: cartManager.quantityStream,
        builder: (context, snapshot) {
          // Get current cart state from CartManager
          final currentQuantities = snapshot.data ?? {};
          
          // Calculate cart totals consistently
          int cartItems = 0;
          double cartTotal = 0.0;
          
          // Calculate totals from current quantities and product details
          for (final store in _restaurants) {
            for (final product in store.products) {
              if (currentQuantities.containsKey(product.childProductId)) {
                final quantity = currentQuantities[product.childProductId] ?? 0;
                if (quantity > 0) {
                  cartItems += quantity;
                  cartTotal += product.finalPrice * quantity;
                  
                  // Update product details
                  _productDetails[product.childProductId] = product;
                }
              }
            }
          }
          
          // Update local state variables for consistency
          _cartItems = cartItems;
          _cartTotal = cartTotal;
          
          // Debug logging
          print('StreamBuilder Cart Debug - Items: $cartItems, Total: $cartTotal');
          print('StreamBuilder Cart Debug - Quantities: $currentQuantities');
          print('StreamBuilder Cart Debug - Product Details: ${_productDetails.keys}');
          
          return Scaffold(
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
                                  Navigator.of(context).pop();
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildSearchBar(),
                              const SizedBox(height: 16),
                              Expanded(child: _buildRestaurantList()),
                              // Add bottom padding to account for the cart bar (only when items exist)
                              if (cartItems > 0) const SizedBox(height: 105),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom cart bar - positioned absolutely at the bottom (only show when items exist)
                  if (cartItems > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildBottomCartBarWithData(cartTotal, cartItems),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomCartBar() {
    return _buildBottomCartBarWithData(_cartTotal, _cartItems);
  }

  Widget _buildBottomCartBarWithData(double cartTotal, int cartItems) {
    return GestureDetector(
      onTap: _onAddToCart,
      child: Container(
        width: double.infinity,
        height: 105.56,
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FF),
        ),
        child: Center(
          child: Container(
            width: 343,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFD445EC),
                  Color(0xFFB02EFB),
                  Color(0xFF8E2FFD),
                  Color(0xFF5E3DFE),
                  Color(0xFF5186E0),
                ],
                stops: [0.0, 0.27, 0.48, 0.76, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Left side - Price and items
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د.إ${cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'aed',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cartItems.toString().padLeft(2, '0')} items',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Right side - Checkout button
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




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
          return const Center(child: CircularProgressIndicator());
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
        // Store restaurants data for product lookup
        _restaurants = restaurants;
        
        // Update cart state after restaurants are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateCartStateFromCartManager();
          }
        });
        
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

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: restaurants.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            try {
              return StoreCard(
                store: restaurants[index],
                storesWidget: null,
                index: index,
                onTap: () {
                  // Pass the entire store object as JSON, just like in Chat screen
                  final Map<String, dynamic> storeJson = restaurants[index].toJson();
                  OrderService().triggerStoreOrder(storeJson);
                  // Navigator.pop(context);
                },
                onAddToCart: (message, product, store, quantity) {
                  print('RestaurantScreen onAddToCart called - Product: ${product.productName}, Quantity: $quantity');
                  
                  // Ensure CartManager is updated with the total quantity, not delta
                  print('Setting quantity in CartManager: ${product.childProductId} = $quantity');
                  cartManager.setQuantity(product.childProductId, quantity);
                  
                  // Sync local state with CartManager after update
                  _syncLocalStateWithCartManager();
                },
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
        );
      },
    );
  }

}
