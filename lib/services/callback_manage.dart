
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Function(Map<String, dynamic>)? onOrderNow;
  Function(Map<String, dynamic>)? onStoreNow;
  Function(Map<String, dynamic>)? onOrderDetails;
  Function(Map<String, dynamic>)? onOrderTracking;
  Function()? onChatDismiss; // Add dismiss callback
  Function(bool)? onCartUpdate; // Add cart update callback

  void setProductCallback(Function(Map<String, dynamic>) callback) {
    onOrderNow = callback;
  }

  void setStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  void setOrderDetailsCallback(Function(Map<String, dynamic>) orderDetails) {
    onOrderDetails = orderDetails;
  }

  void setOrderTrackingCallback(Function(Map<String, dynamic>) orderTracking) {
    onOrderTracking = orderTracking;
  }

  // Add dismiss callback setter
  void setDismissCallback(Function() callback) {
    onChatDismiss = callback;
  }

  // Add cart update callback setter
  void setCartUpdateCallback(Function(bool) callback) {
    onCartUpdate = callback;
  }

  void setonStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  void triggerProductOrder(Map<String, dynamic> product) {
    onOrderNow?.call(product);
  }

  void triggerOrderDetails(Map<String, dynamic> orderDetails) {
    onOrderDetails?.call(orderDetails);
  }

  void triggerStoreOrder(Map<String, dynamic> store) {
    onStoreNow?.call(store);
  }

  void triggerOrderTracking(Map<String, dynamic> orderTracking) {
    onOrderTracking?.call(orderTracking);
  }

  // Add dismiss trigger
  void triggerChatDismiss() {
    onChatDismiss?.call();
  }

  // Add cart update trigger
  void triggerCartUpdate(bool isCartUpdate) {
    print('CALLBACK MANAGER 1');
    onCartUpdate?.call(isCartUpdate);
    print('CALLBACK MANAGER 2');
  }

  void clearCallback() {
    onOrderNow = null;
    onStoreNow = null;
    onOrderDetails = null;
    onChatDismiss = null; // Clear dismiss callback
    onCartUpdate = null; // Clear cart update callback
  }
}
