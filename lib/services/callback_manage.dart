
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  Function(Map<String, dynamic>)? onOrderNow;
  Function()? onAddCardOpen;
  Function()? onAddressScreenOpen;
  Function(Map<String, dynamic>)? onStoreNow;
  Function(Map<String, dynamic>)? onSideMenuOption;
  Function(Map<String, dynamic>)? onOrderDetails;
  Function(Map<String, dynamic>)? onOrderTracking;
  Function(Map<String, dynamic>)? onScheduledLaterScreenOpen;
  Function(Map<String, dynamic>)? onSelectStaffScreenOpen;
  Function(Map<String, dynamic>)? onPrescriptionScreenOpen;
  Function(Map<String, dynamic>)? onStripePlaceOrderScreenOpen;
  Function(Map<String, dynamic>)? onClickManage;
  Function()? onChatDismiss; // Add dismiss callback
  Function()? onTutorialDismiss; // Add tutorial dismiss callback
  Function(bool)? onCartUpdate; // Add cart update callback
  Function(String)? onStripePayment; // Add stripe payment callback
  Function(String)? onAddressSummary; // Add order summary callback
  Function(String)? onSendMessage; // Add send message callback // CHANGE CALLBACK
  Function(Map<String, dynamic>)? onSelectSchedule; // Add select schedule callback
  Function(Map<String, dynamic>)? onSelectPrescription; // Add prescription screen callback
  Function(Map<String, dynamic>)? onSelectStaff; // Add select staff callback
  Function(Map<String, dynamic>)? onStripePlaceOrder; // Add stripe place order callback
  Function(Map<String, dynamic>)? onSelectClickManage; // Add manage callback

  void setProductCallback(Function(Map<String, dynamic>) callback) {
    onOrderNow = callback;
  }

  void setStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  void setSideMenuOptionCallback(Function(Map<String, dynamic>) callback) {
    onSideMenuOption = callback;
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

  void setPrescriptionScreenOpenCallback(Function(Map<String, dynamic>) prescriptionScreenOpen) {
    print('setPrescriptionScreenOpenCallback: $prescriptionScreenOpen');
    onPrescriptionScreenOpen = prescriptionScreenOpen;//1
  }

  void setClickManageCallback(Function(Map<String, dynamic>) onClickManage) {
    print('setClickManageCallback: $onClickManage');
    onClickManage = onClickManage;
  }

  void setStripePlaceOrderScreenOpenCallback(Function(Map<String, dynamic>) stripePlaceOrderScreenOpen) {
    print('setStripePlaceOrderScreenOpenCallback: $stripePlaceOrderScreenOpen');
    onStripePlaceOrderScreenOpen = stripePlaceOrderScreenOpen;
  }


  void setSelectStaffScreenOpenCallback(Function(Map<String, dynamic>) selectStaffScreenOpen) {
    onSelectStaffScreenOpen = selectStaffScreenOpen;//1
  }

  // Add dismiss callback setter
  void setDismissCallback(Function() callback) {
    onChatDismiss = callback;
  }

  void setTutorialDismissCallback(Function() callback) {
    onTutorialDismiss = callback;
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

  void setPrescriptionCallback(Function(Map<String, dynamic>) callback) {
    print('setPrescriptionScreenOpenCallback: $callback');
    onSelectPrescription = callback;//11
  }

  void setSelectClickManageCallback(Function(Map<String, dynamic>) callback) {
    print('setSelectClickManageCallback: $callback');
    onSelectClickManage = callback;
  }

  void setStripePlaceOrderCallback(Function(Map<String, dynamic>) callback) {
    print('setStripePlaceOrderCallback: $callback');
    onStripePlaceOrder = callback;
  }

  void setSelectStaffCallback(Function(Map<String, dynamic>) callback) {
    onSelectStaff = callback;//11
  }

   void setSendMessageCallback(Function(String) callback) { // CHANGE CALLBACK
    onSendMessage = callback;
  }

  void setonStoreCallback(Function(Map<String, dynamic>) callback) {
    onStoreNow = callback;
  }

  void setonSideMenuOptionCallback(Function(Map<String, dynamic>) callback) {
    onSideMenuOption = callback;
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

  void triggerPrescriptionScreenOpen(Map<String, dynamic> prescription) {
    print('triggerPrescriptionScreenOpen: $prescription');
    onPrescriptionScreenOpen?.call(prescription);//2
  }

  void triggerClickManageScreenOpen(Map<String, dynamic> clickManage) {
    print('triggerClickManage: $clickManage');
    onClickManage?.call(clickManage);
  }

  void triggerStripePlaceOrderScreenOpen(Map<String, dynamic> stripePlaceOrderScreenOpen) {
    print('triggerStripePlaceOrderScreenOpen: $stripePlaceOrderScreenOpen');
    onStripePlaceOrderScreenOpen?.call(stripePlaceOrderScreenOpen);
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

  void triggerSideMenuOption(Map<String, dynamic> sideMenuOption) {
    onSideMenuOption?.call(sideMenuOption);
  }

  void triggerOrderTracking(Map<String, dynamic> orderTracking) {
    onOrderTracking?.call(orderTracking);
  }

  // Add dismiss trigger
  void triggerChatDismiss() {
    onChatDismiss?.call();
  }

  void triggerTutorialDismiss() {
    onTutorialDismiss?.call();
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

  void triggerPrescriptionScreen(Map<String, dynamic> prescription) {
    print('triggerPrescriptionScreen: $prescription');
    onSelectPrescription?.call(prescription);
  }

  void triggerClickManageScreen(Map<String, dynamic> clickManage) {
    print('triggerClickManage: $clickManage');
    onSelectClickManage?.call(clickManage);
  }

  void triggerStripePlaceOrder(Map<String, dynamic> stripePlaceOrder) {
    print('triggerStripePlaceOrder: $stripePlaceOrder');
    onStripePlaceOrder?.call(stripePlaceOrder);
  }

  void triggerSelectStaff(Map<String, dynamic> staff) {
    onSelectStaff?.call(staff);
  }

  void clearCallback() {
    onOrderNow = null;
    onAddCardOpen = null;
    onStoreNow = null;
    onSideMenuOption = null;
    onOrderDetails = null;
    onChatDismiss = null; // Clear dismiss callback
    onTutorialDismiss = null; // Clear tutorial dismiss callback
    onCartUpdate = null; // Clear cart update callback
    onStripePayment = null; // Clear stripe payment callback
    onAddressSummary = null; // Clear address summary callback
    onAddressScreenOpen = null; // Clear address screen open callback
    onSendMessage = null; // Clear send message callback // CHANGE CALLBACK
    onScheduledLaterScreenOpen = null; // Clear scheduled later screen open callback
    onSelectStaffScreenOpen = null; // Clear select staff screen open callback
    onPrescriptionScreenOpen = null; // Clear prescription screen open callback
    onStripePlaceOrderScreenOpen = null; // Clear stripe place order screen open callback
    onStripePlaceOrder = null; // Clear stripe place order callback
    onSelectPrescription = null; // Clear prescription screen callback
    onSelectSchedule = null; // Clear select schedule callback
    onSelectStaff = null; // Clear select staff callback
    onSelectClickManage = null; // Clear select click manage callback
    onClickManage = null; // Clear click manage callback
  }
}
