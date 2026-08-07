import 'package:chat_bot/services/api_service.dart';
import 'package:chat_bot/utils/store_category_registry.dart';

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
  restaurant_sections,
  hotel_destination,customer_profile_details,hotel_order_summary,hotel_booking_confirmed,car_pickup_places,car_dropoff_places,car_rentals_search,car_order_summary,car_booking_confirmed,flight_origin_places,flight_destination_places,flights_search,flight_order_summary,flight_booking_confirmed,package_types,
  hotel_booking_dates,
  hotel_guests_rooms,
  hotels,
  see_available_rooms,hotel_booking_for_me,hotel_booking_for_other,see_more_hotels,hotel_confirm_booking,car_booking_date_time,car_driver_details,see_more_cars,trip_type_selection,flight_booking_date_time,flight_add_member,flight_cabin_type,flight_traveller_details,see_more_flights,add_dropoff_address,package_instructions,
  subscription;

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
  services(25),//healthCare and services are same
  donation(26);

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
  food('restaurants', '634e50c3fd5d83948e00e745', '63d0ca1f4c14e776bb0be105'),
  grocery('groceries', '634e537076e179f58008c0e5', '63d0dd8c4c14e776bb0be106'),
  pharmacy('pharmacies', '634e525ae671ac4ee4016be7', '63d0d22069d51ed75c0b0014'),
  shopping('shopping', '636df238c8dcc5100f056ed8', '63d0e034784d8a8bf40f9134'),
  services('services', '63ac1c7322ec7895aa000935', '63dca9ad8231302e910696dc'),
  healthCare('healthcare', '6507f939c2630000b000458d', '65797ea23b2084c0630fd274'),
  donation('donation', '65c0bfa3a348d2a13a088506', '65c0bfa3a348d2a13a088506');

  const FoodStoreCategoryId(this.apiKey, this.stagingId, this.productionId);

  /// Key in session API `store_categories` (e.g. `restaurants`, `groceries`).
  final String apiKey;
  final String productionId;
  final String stagingId;

  String get value {
    final fromApi = StoreCategoryRegistry.idFor(apiKey);
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    return ApiService.isProduction ? productionId : stagingId;
  }

  static FoodStoreCategoryId fromValue(String value) {
    if (value.isEmpty) return FoodStoreCategoryId.food;
    for (final category in FoodStoreCategoryId.values) {
      if (category.value == value) return category;
    }
    for (final category in FoodStoreCategoryId.values) {
      if (category.stagingId == value || category.productionId == value) {
        return category;
      }
    }
    return FoodStoreCategoryId.food;
  }
}