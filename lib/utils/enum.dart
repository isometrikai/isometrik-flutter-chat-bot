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
  track_order,
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
  pharmacy(6);

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