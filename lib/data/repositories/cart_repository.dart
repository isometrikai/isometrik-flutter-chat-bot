import 'package:chat_bot/data/services/cart_service.dart';
import 'package:chat_bot/utils/api_result.dart';

class CartRepository {
  const CartRepository();

  Future<ApiResult> fetchCart() {
    return CartService.instance.fetchCart();
  }

  Future<ApiResult> fetchUniversalCartAsWidgetActions() {
    return CartService.instance.fetchUniversalCartAsWidgetActions();
  }

  Future<ApiResult> fetchRawUniversalCart() {
    return CartService.instance.fetchRawUniversalCart();
  }

  Future<ApiResult> addToCart({
    required String storeId,
    required int cartType,
    required int action,
    required String storeCategoryId,
    required int newQuantity,
    required int storeTypeId,
    required String productId,
    required String centralProductId,
    required String unitId,
    List<Map<String, dynamic>>? newAddOns,
    dynamic addToCartOnId,
  }) {
    return CartService.instance.addToCart(
      storeId: storeId,
      cartType: cartType,
      action: action,
      storeCategoryId: storeCategoryId,
      newQuantity: newQuantity,
      storeTypeId: storeTypeId,
      productId: productId,
      centralProductId: centralProductId,
      unitId: unitId,
      newAddOns: newAddOns,
      addToCartOnId: addToCartOnId,
    );
  }
}
