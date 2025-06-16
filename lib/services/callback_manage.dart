import '../model/chat_response.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Function(Product)? onOrderNow;
  Function(Store)? onStoreNow;
  Function()? onChatDismiss; // Add dismiss callback

  void setProductCallback(Function(Product) callback) {
    onOrderNow = callback;
  }

  void setStoreCallback(Function(Store) callback) {
    onStoreNow = callback;
  }

  // Add dismiss callback setter
  void setDismissCallback(Function() callback) {
    onChatDismiss = callback;
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

  // Add dismiss trigger
  void triggerChatDismiss() {
    onChatDismiss?.call();
  }

  void clearCallback() {
    onOrderNow = null;
    onStoreNow = null;
    onChatDismiss = null; // Clear dismiss callback
  }
}
