import 'package:chat_bot/data/model/cart_response.dart';
import 'package:chat_bot/data/services/cart_service.dart';
import 'package:chat_bot/utils/api_result.dart';

class CartRepository {
  const CartRepository();

  Future<ApiResult> fetchCart() {
    return CartService.instance.fetchCart();
  }
}
