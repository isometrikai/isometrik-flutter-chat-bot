import 'package:flutter/material.dart';
import '../data/model/chat_response.dart';
import '../widgets/cart_details_price_widget';
import '../data/services/cart_service.dart';
import '../data/model/universal_cart_response.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<WidgetAction>? _cartItems;
  bool _isLoading = false;
  String? _error;
  String? _storeName;
  String? _storeType;

  @override
  void initState() {
    super.initState();
    
    // Always fetch from API
    _fetchCartFromApi();
  }

  Future<void> _fetchCartFromApi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await CartService.instance.fetchUniversalCartAsWidgetActions();
      
      if (result.isSuccess) {
        final widgetActions = result.data as List<WidgetAction>;
        
        // Also fetch the raw cart data for store information
        final rawResult = await CartService.instance.fetchRawUniversalCart();
        if (rawResult.isSuccess) {
          final universalCartResponse = rawResult.data as UniversalCartResponse;
          if (universalCartResponse.data.isNotEmpty) {
            final cartData = universalCartResponse.data.first;
            final seller = cartData.sellers.isNotEmpty ? cartData.sellers.first : null;
            
            // Store the store info
            _storeName = seller?.name;
            _storeType = seller?.storeType;
          }
        }
        
        setState(() {
          _cartItems = widgetActions;
          _isLoading = false;
        });
        
        print('Cart fetched successfully: ${_cartItems?.length} items');
      } else {
        setState(() {
          _error = result.message ?? 'Failed to fetch cart';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
          const Text(
            'Your cart',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171212),
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
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = [
      {'name': '🍕 Food', 'count': '', 'isSelected': true},
      {'name': '🥑 Grocery', 'count': '', 'isSelected': false},
      {'name': '💊 Pharmacy', 'count': '', 'isSelected': false},
      // {'name': '🔨 Services', 'count': '', 'isSelected': false},
      // {'name': '🛍️ Shopping', 'count': '', 'isSelected': false},
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
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildFilterChip(
              name: category['name'] as String,
              count: category['count'] as String,
              isSelected: category['isSelected'] as bool,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String name,
    required String count,
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
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF242424),
            ),
          ),
          // const SizedBox(width: 4),
          // Container(
          //   padding: const EdgeInsets.all(2.64),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFF8E2FFD),
          //     borderRadius: BorderRadius.circular(39.59),
          //   ),
          //   child: Text(
          //     count,
          //     style: const TextStyle(
          //       fontSize: 7.71,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    // Show loading state
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8E2FFD),
        ),
      );
    }

    // Show error state
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFF8E2FFD),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading cart',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF242424),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCartFromApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E2FFD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Use the cartItems (either from widget or fetched from API)
    if (_cartItems == null || _cartItems!.isEmpty) {
      return _buildEmptyCart();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Store info card (if we have store info)
          _buildStoreInfoCard(),
          
          const SizedBox(height: 24),
          
          // Use the CartDetailsPriceWidget
          CartDetailsPriceWidget(cartItems: _cartItems!),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Color(0xFF8E2FFD),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    // Use fetched store data from API
    String? storeName = _storeName ?? 'Store Name';
    String? storeType = _storeType;
    double? rating;
    String? deliveryTime;
    String? address;

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
                child: const Icon(
                  Icons.store,
                  size: 16,
                  color: Color(0xFF777777),
                ),
              ),
              const SizedBox(width: 12),
              
              // Store details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF242424),
                      ),
                    ),
                    if (storeType != null && storeType.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        storeType,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Color(0xFFA674BF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${rating?.toStringAsFixed(1) ?? '4.5'} (1.2k reviews)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF242424),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          '|',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFD7CDE9),
                          ),
                        ),
                        const SizedBox(width: 7),
                        // Delivery time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: Color(0xFFA674BF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deliveryTime ?? '15-20 min',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF242424),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // More items button
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to restaurant/menu screen to add more items
              },
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF8E2FFD), width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '+ More items',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8E2FFD),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Proceed to checkout button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to checkout screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Proceeding to checkout...'),
                    backgroundColor: Color(0xFF8E2FFD),
                  ),
                );
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
                child: const Center(
                  child: Text(
                    'Proceed to checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
