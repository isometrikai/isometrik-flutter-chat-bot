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
}
