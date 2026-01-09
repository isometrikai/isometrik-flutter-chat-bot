
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
  Function(Map<String, dynamic>)? onScheduledLaterScreenOpen;
  Function(Map<String, dynamic>)? onSelectStaffScreenOpen;
  Function(List<String>)? onPrescriptionScreenOpen;
  Function()? onChatDismiss; // Add dismiss callback
  Function(bool)? onCartUpdate; // Add cart update callback
  Function(String)? onStripePayment; // Add stripe payment callback
  Function(String)? onAddressSummary; // Add order summary callback
  Function(String)? onSendMessage; // Add send message callback // CHANGE CALLBACK
  Function(Map<String, dynamic>)? onSelectSchedule; // Add select schedule callback
  Function(List<String>)? onSelectPrescription; // Add prescription screen callback
  Function(Map<String, dynamic>)? onSelectStaff; // Add select staff callback

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

  void setScheduledLaterScreenOpenCallback(Function(Map<String, dynamic>) scheduledLaterScreenOpen) {
    print('setScheduledLaterScreenOpenCallback: $scheduledLaterScreenOpen');
    onScheduledLaterScreenOpen = scheduledLaterScreenOpen;
  }

  void setPrescriptionScreenOpenCallback(Function(List<String>) prescriptionScreenOpen) {
    print('setPrescriptionScreenOpenCallback: $prescriptionScreenOpen');
    onPrescriptionScreenOpen = prescriptionScreenOpen;//1
  }

  void setSelectStaffScreenOpenCallback(Function(Map<String, dynamic>) selectStaffScreenOpen) {
    onSelectStaffScreenOpen = selectStaffScreenOpen;//1
  }

  // Add dismiss callback setter
  void setDismissCallback(Function() callback) {
    onChatDismiss = callback;
  }

  // Add cart update callback setter
  void setCartUpdateCallback(Function(bool) callback) {
    onCartUpdate = callback;
  }

  void setStripePaymentCallback(Function(String) callback) {
    onStripePayment = callback;
  }

  void setAddressSummaryCallback(Function(String) callback) {
    onAddressSummary = callback;
  }

  void setSelectScheduleCallback(Function(Map<String, dynamic>) callback) {
    print('setSelectScheduleCallback: $callback');
    onSelectSchedule = callback;
  }

  void setPrescriptionCallback(Function(List<String>) callback) {
    print('setPrescriptionScreenOpenCallback: $callback');
    onSelectPrescription = callback;
  }

  void setSelectStaffCallback(Function(Map<String, dynamic>) callback) {
    onSelectStaff = callback;
  }

   void setSendMessageCallback(Function(String) callback) { // CHANGE CALLBACK
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

  void triggerScheduledLaterScreenOpen(Map<String, dynamic> obj) {
    print('triggerScheduledLaterScreenOpen: $obj');
    onScheduledLaterScreenOpen?.call(obj);
  }

  void triggerPrescriptionScreenOpen(List<String> prescription) {
    print('triggerPrescriptionScreenOpen: $prescription');
    onPrescriptionScreenOpen?.call(prescription);//2
  }

  void triggerSelectStaffScreenOpen(Map<String, dynamic> obj) {
    onSelectStaffScreenOpen?.call(obj);//2
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
    onCartUpdate?.call(isCartUpdate);
  }

  void triggerStripePayment(String cartNumber) {
    onStripePayment?.call(cartNumber);
  }
  
  void triggerAddressSummary(String addressSummary) {
    onAddressSummary?.call(addressSummary);
  }

  void triggerSendMessage(String message) { // CHANGE CALLBACK
    onSendMessage?.call(message);
  }

  void triggerSelectSchedule(Map<String, dynamic> schedule) {
    print('triggerSelectSchedule: $schedule');
    onSelectSchedule?.call(schedule);
  }

  void triggerPrescriptionScreen(List<String> prescription) {
    print('triggerPrescriptionScreen: $prescription');
    onSelectPrescription?.call(prescription);
  }

  void triggerSelectStaff(Map<String, dynamic> staff) {
    onSelectStaff?.call(staff);
  }

  void clearCallback() {
    onOrderNow = null;
    onAddCardOpen = null;
    onStoreNow = null;
    onOrderDetails = null;
    onChatDismiss = null; // Clear dismiss callback
    onCartUpdate = null; // Clear cart update callback
    onStripePayment = null; // Clear stripe payment callback
    onAddressSummary = null; // Clear address summary callback
    onAddressScreenOpen = null; // Clear address screen open callback
    onSendMessage = null; // Clear send message callback // CHANGE CALLBACK
    onScheduledLaterScreenOpen = null; // Clear scheduled later screen open callback
    onSelectStaffScreenOpen = null; // Clear select staff screen open callback
    onPrescriptionScreenOpen = null; // Clear prescription screen open callback
    onSelectPrescription = null; // Clear prescription screen callback
    onSelectSchedule = null; // Clear select schedule callback
    onSelectStaff = null; // Clear select staff callback
  }
}
