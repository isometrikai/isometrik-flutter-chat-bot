import 'package:chat_bot/data/api_client.dart';
import 'package:chat_bot/data/model/cart_response.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class CartService {
  CartService._internal();
  static final CartService instance = CartService._internal();

  late final ApiClient _client = UniversalApiClient.instance.appClient;

  /// Fetch cart data from the API
  Future<ApiResult> fetchCart() async {
    try {
      final result = await _client.get('/v1/universalCart');
      
      if (result.isSuccess) {
        final universalCartResponse = UniversalCartResponse.fromJson(result.data);
        
        // Convert UniversalCartResponse to CartResponse for compatibility
        if (universalCartResponse.data.isNotEmpty) {
          final cartData = universalCartResponse.data.first;
          final seller = cartData.sellers.isNotEmpty ? cartData.sellers.first : null;
          
          // Get cart items from actual products
          List<CartItem> cartItems = [];
          if (seller != null && seller.products.isNotEmpty) {
            for (final product in seller.products) {
              int quantity = 1;
              double price = 0;
              
              if (product.accounting != null) {
                quantity = product.accounting!.totalQuantity;
                price = product.accounting!.unitPriceWithTax;
              }
              
              cartItems.add(CartItem(
                name: product.name ?? 'Unknown Product',
                quantity: quantity,
                price: price,
                currencySymbol: cartData.currencySymbol,
              ));
            }
          }
          
          // Get totals from cart accounting
          double subtotal = 0;
          double deliveryFee = 0;
          double total = 0;
          
          if (cartData.accounting != null) {
            subtotal = cartData.accounting!.unitPriceWithTax;
            deliveryFee = cartData.accounting!.deliveryFee;
            total = cartData.accounting!.finalTotal;
          }
          
          // Convert to CartResponse format
          final cartResponse = CartResponse(
            success: true,
            message: universalCartResponse.message,
            data: CartData(
              storeName: seller?.name ?? 'Store Name',
              storeId: cartData.id,
              rating: 4.5, // Default rating since not in API response
              reviewCount: '1.2k', // Default review count
              deliveryTime: '15-20 min', // Default delivery time
              address: 'Al Ghani Building - G Floor - Amm...', // Default address
              items: cartItems,
              subtotal: subtotal,
              deliveryFee: deliveryFee,
              total: total,
            ),
          );
          
          return ApiResult.success(cartResponse);
        } else {
          // Empty cart
          final cartResponse = CartResponse(
            success: true,
            message: universalCartResponse.message,
            data: CartData(
              items: [],
              subtotal: 0,
              deliveryFee: 0,
              total: 0,
            ),
          );
          
          return ApiResult.success(cartResponse);
        }
      } else {
        return ApiResult.error(result.message ?? 'Failed to fetch cart');
      }
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }
  
  /// Fetch universal cart and convert to WidgetAction format
  Future<ApiResult> fetchUniversalCartAsWidgetActions() async {
    try {
      final result = await _client.get('/v1/universalCart');

      if (result.isSuccess) {
        final universalCartResponse = UniversalCartResponse.fromJson(result.data);
        final widgetActions = universalCartResponse.toWidgetActions();
        return ApiResult.success(widgetActions);
      } else {
        return ApiResult.error(result.message ?? 'Failed to fetch cart');
      }
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }
  
  /// Fetch raw universal cart data
  Future<ApiResult> fetchRawUniversalCart() async {
    try {
      final result = await _client.get('/v1/universalCart');

      if (result.isSuccess) {
        final universalCartResponse = UniversalCartResponse.fromJson(result.data);
        return ApiResult.success(universalCartResponse);
      } else {
        return ApiResult.error(result.message ?? 'Failed to fetch cart');
      }
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }
}
