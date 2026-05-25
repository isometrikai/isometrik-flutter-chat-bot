import 'package:chat_bot/services/api_service.dart';

enum WidgetEnum {
  stores,
  see_more,
  products,
  menu,
  related_products,
  add_more,
  cart,
  proceed_to_checkout,
  add_address,
  add_payment,
  schedule_later,
  staff_selection,
  prescription_screen,
  payment,
  order_summary,
  order_confirmed,
  order_details,
  call_restaurant,
  call_driver,
  order_completed,
  rating,
  options,
  cash_on_delivery,
  choose_address,
  choose_card,
  order_tracking,
  online_payment_confirm_order,
  service_types,
  choose_date,
  add_dependent,
  restaurant_sections;

  // Add string values for API communication
  String get value {
    return toString().split('.').last;
  }
  
  // Create from string (useful for API responses)
  static WidgetEnum fromString(String value) {
    return WidgetEnum.values.firstWhere(
      (widget) => widget.value == value,
      orElse: () => WidgetEnum.stores, // default fallback
    );
  }
  
}

enum FoodCategory {
  food(1),
  grocery(2),// grocey and shopping are same
  pharmacy(6),
  services(25);//healthCare and services are same

  const FoodCategory(this.value);
  
  final int value;
  
  // Create from integer value
  static FoodCategory fromValue(int value) {
    return FoodCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => FoodCategory.food, // default fallback
    );
  }
}

enum FoodStoreCategoryId {
  food('634e50c3fd5d83948e00e745', '63d0ca1f4c14e776bb0be105'),
  grocery('634e537076e179f58008c0e5', '63d0dd8c4c14e776bb0be106'),
  pharmacy('634e525ae671ac4ee4016be7', '63d0d22069d51ed75c0b0014'),
  healthCare('6507f939c2630000b000458d', '65797ea23b2084c0630fd274'),
  shopping('636df238c8dcc5100f056ed8', '63d0e034784d8a8bf40f9134'),
  services('63ac1c7322ec7895aa000935', '63dca9ad8231302e910696dc');

  const FoodStoreCategoryId(this.stagingId, this.productionId);

  final String productionId;
  final String stagingId;

  String get value => ApiService.isProduction ? productionId : stagingId;

  static FoodStoreCategoryId fromValue(String value) {
    return FoodStoreCategoryId.values.firstWhere(
      (category) => category.value == value,
      orElse: () => FoodStoreCategoryId.food,
    );
  }
}