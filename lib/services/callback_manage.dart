import '../model/chat_response.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Function(Product)? onOrderNow;

  Function(Store)? onStoreNow;

  void setProductCallback(Function(Product) callback) {
    onOrderNow = callback;
  }

  void setStoreCallback(Function(Store) callback) {
    onStoreNow = callback;
  }

  void triggerProductOrder(Product product) {
    onOrderNow?.call(product);
  }


  void setonStoreCallback(Function(Store) callback) {
    onStoreNow = callback;
  }

  void triggerStoreOrder(Store store) {
    onStoreNow?.call(store);
  }

  void clearCallback() {
    onOrderNow = null;
    onStoreNow = null;
  }
}