import '../model/chat_response.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Function(String)? onOrderNow;
  Function(String)? onStoreNow;
  Function()? onChatDismiss; // Add dismiss callback

  void setProductCallback(Function(String) callback) {
    onOrderNow = callback;
  }

  void setStoreCallback(Function(String) callback) {
    onStoreNow = callback;
  }

  // Add dismiss callback setter
  void setDismissCallback(Function() callback) {
    onChatDismiss = callback;
  }

  void triggerProductOrder(String product) {
    onOrderNow?.call(product);
  }


  void setonStoreCallback(Function(String) callback) {
    onStoreNow = callback;
  }

  void triggerStoreOrder(String store) {
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
