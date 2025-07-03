import '../model/chat_response.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Function(Map<String, dynamic>)? onOrderNow;
  Function(Map<String, dynamic>)? onStoreNow;
  Function()? onChatDismiss; // Add dismiss callback

  void setProductCallback(Function(Map<String, dynamic>) callback) {
    onOrderNow = callback;
  }

  void setStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  // Add dismiss callback setter
  void setDismissCallback(Function() callback) {
    onChatDismiss = callback;
  }

  void triggerProductOrder(Map<String, dynamic> product) {
    onOrderNow?.call(product);
  }


  void setonStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  void triggerStoreOrder(Map<String, dynamic> store) {
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
