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
  select_staff,
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
  points;

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
  grocery(2),
  pharmacy(6),
  services(25);

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
  food('634e50c3fd5d83948e00e745'),
  grocery('634e537076e179f58008c0e5'),
  pharmacy('634e525ae671ac4ee4016be7'),
  healthCare('6507f939c2630000b000458d'),
  shopping('636df238c8dcc5100f056ed8'),
  services('63ac1c7322ec7895aa000935');

  const FoodStoreCategoryId(this.value);
  
  final String value;
  
  // Create from integer value
  static FoodStoreCategoryId fromValue(String value) {
    return FoodStoreCategoryId.values.firstWhere(
      (category) => category.value == value,
      orElse: () => FoodStoreCategoryId.food, // default fallback
    );
  }
}