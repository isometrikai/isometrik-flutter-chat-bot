
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Function(Map<String, dynamic>)? onOrderNow;
  Function()? onAddCardOpen;
  Function()? onAddressScreenOpen;
  Function(Map<String, dynamic>)? onStoreNow;
  Function(Map<String, dynamic>)? onOrderDetails;
  Function(Map<String, dynamic>)? onOrderTracking;
  Function()? onChatDismiss; // Add dismiss callback
  Function(bool)? onCartUpdate; // Add cart update callback
  Function(String)? onStripePayment; // Add stripe payment callback
  Function(String)? onAddressSummary; // Add order summary callback
  Function(String)? onSendMessage; // Add send message callback

  void setProductCallback(Function(Map<String, dynamic>) callback) {
    onOrderNow = callback;
  }

  void setStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  void setAddCardOpenCallback(Function() callback) {
    onAddCardOpen = callback;
  }
  
  void setAddressScreenOpenCallback(Function() callback) {
    onAddressScreenOpen = callback;
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
    print('setCartUpdateCallback called with callback: $callback');
    onCartUpdate = callback;
    print('onCartUpdate set to: $onCartUpdate');
  }

  void setStripePaymentCallback(Function(String) callback) {
    onStripePayment = callback;
  }

  void setAddressSummaryCallback(Function(String) callback) {
    onAddressSummary = callback;
  }

  void setSendMessageCallback(Function(String) callback) {
    onSendMessage = callback;
  }

  void setonStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  void triggerProductOrder(Map<String, dynamic> product) {
    onOrderNow?.call(product);
  }

  void triggerAddCardOpen() {
    onAddCardOpen?.call();
  }

  void triggerAddressScreenOpen() {
    onAddressScreenOpen?.call();
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
    print('triggerCartUpdate called with: $isCartUpdate');
    print('onCartUpdate callback is: $onCartUpdate');
    if (onCartUpdate != null) {
      print('Calling onCartUpdate callback...');
      onCartUpdate?.call(isCartUpdate);
      print('onCartUpdate callback completed');
    } else {
      print('ERROR: onCartUpdate callback is null!');
    }
  }

  void triggerStripePayment(String cartNumber) {
    onStripePayment?.call(cartNumber);
  }
  
  void triggerAddressSummary(String addressSummary) {
    onAddressSummary?.call(addressSummary);
  }

  void triggerSendMessage(String message) {
    onSendMessage?.call(message);
  }


  void clearCallback() {
    print('clearCallback');
    onOrderNow = null;
    onAddCardOpen = null;
    onStoreNow = null;
    onOrderDetails = null;
    onChatDismiss = null; // Clear dismiss callback
    onCartUpdate = null; // Clear cart update callback
    onStripePayment = null; // Clear stripe payment callback
    onAddressSummary = null; // Clear address summary callback
    onAddressScreenOpen = null; // Clear address screen open callback
    onSendMessage = null; // Clear send message callback
  }

  // Debug method to check callback status
  void debugCallbackStatus() {
    print('=== OrderService Callback Status ===');
    print('onOrderNow: ${onOrderNow != null ? "SET" : "NULL"}');
    print('onAddCardOpen: ${onAddCardOpen != null ? "SET" : "NULL"}');
    print('onAddressScreenOpen: ${onAddressScreenOpen != null ? "SET" : "NULL"}');
    print('onStoreNow: ${onStoreNow != null ? "SET" : "NULL"}');
    print('onOrderDetails: ${onOrderDetails != null ? "SET" : "NULL"}');
    print('onOrderTracking: ${onOrderTracking != null ? "SET" : "NULL"}');
    print('onChatDismiss: ${onChatDismiss != null ? "SET" : "NULL"}');
    print('onCartUpdate: ${onCartUpdate != null ? "SET" : "NULL"}');
    print('onStripePayment: ${onStripePayment != null ? "SET" : "NULL"}');
    print('onAddressSummary: ${onAddressSummary != null ? "SET" : "NULL"}');
    print('onSendMessage: ${onSendMessage != null ? "SET" : "NULL"}');
    print('=====================================');
  }
}