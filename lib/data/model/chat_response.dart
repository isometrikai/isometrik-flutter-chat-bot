import 'dart:convert';

import 'package:chat_bot/widgets/widgets.dart';

import '../../utils/enum.dart';

// Main Chat Response Model
class ChatResponse {
  final String text;
  final String requestId;
  final List<ChatWidget> widgets;
  final int? cartCount;
  final bool needToEndThisChat;
  final bool isOnlinePayment;

  ChatResponse({
    required this.text,
    required this.requestId,
    required this.widgets,
    this.cartCount,
    this.needToEndThisChat = false,
    this.isOnlinePayment = false,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    List<ChatWidget> widgetsList = [];
    
    // Handle widgets field - it can be either a List or a String
    final widgetsData = json['widgets'];
    if (widgetsData != null) {
      if (widgetsData is List) {
        // Normal case: widgets is a list
        widgetsList = widgetsData
            .map((item) => ChatWidget.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (widgetsData is String) {
        // Edge case: widgets is a string (like error messages)
        // In this case, we don't parse it as widgets and leave the list empty
        // This prevents parsing errors and the string won't be displayed anywhere
        widgetsList = [];
      }
    }
    
    return ChatResponse(
      text: json['text'] ?? '',
      requestId: json['request_id'] ?? '',
      widgets: widgetsList,
      cartCount: json['cartCount'] ?? -1,
      needToEndThisChat: json['needToEndThisChat'] ?? false,
      isOnlinePayment: json['isOnlinePayment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'request_id': requestId,
      'widgets': widgets.map((widget) => widget.toJson()).toList(),
      'cartCount': cartCount,
      'needToEndThisChat': needToEndThisChat,
      'isOnlinePayment': isOnlinePayment,
    };
  }

  // Helper method to check if response has widgets
  bool get hasWidgets => widgets.isNotEmpty;

  // Helper method to get widgets by type
  List<ChatWidget> getWidgetsByType(String type) {
    return widgets.where((widget) => widget.type == type).toList();
  }

  // Helper method to get options widgets specifically
  List<ChatWidget> get optionsWidgets => getWidgetsByType('options');
  // Helper method to get see_more widgets specifically
  List<ChatWidget> get seeMoreWidgets => getWidgetsByType('see_more');
  List<ChatWidget> get cartWidgets => getWidgetsByType('cart');
  List<ChatWidget> get chooseAddressWidgets => getWidgetsByType('choose_address');
  List<ChatWidget> get chooseCardWidgets => getWidgetsByType('choose_card');
  List<ChatWidget> get orderSummaryWidgets => getWidgetsByType('order_summary');
  List<ChatWidget> get orderConfirmedWidgets => getWidgetsByType('order_confirmed');
  List<ChatWidget> get orderTrackingWidgets => getWidgetsByType('order_tracking');
  List<ChatWidget> get orderDetailsWidgets => getWidgetsByType('order_details');
  List<ChatWidget> get scheduledLaterWidgets => getWidgetsByType('schedule_later');
  List<ChatWidget> get selectStaffWidgets => getWidgetsByType('select_staff');
  @override
  String toString() {
    return 'ChatResponse(text: $text, requestId: $requestId, widgets: ${widgets.length})';
  }
}


// Chat Widget Model
class ChatWidget {
  final int widgetId;
  final int widgetsType;
  final String type;
  final bool isTableBookingFlow;
  final bool isTableBookingTimeSlot;
  final bool isHotelBookingFlow;
  final bool isCarBookingFlow;
  final bool isFlightBookingFlow;
  final bool isPackageTypesFlow;
  final bool isForReturn;
  final bool? isForPickup;
  final bool? isDeparture;
  final List<dynamic> widget; // Raw JSON data

  ChatWidget({
    required this.widgetId,
    required this.widgetsType,
    required this.type,
    required this.isTableBookingFlow,
    required this.isTableBookingTimeSlot,
    required this.isFlightBookingFlow,
    required this.isHotelBookingFlow,
    required this.isCarBookingFlow,
    required this.isPackageTypesFlow,
    required this.isForReturn,
    required this.isForPickup,
    required this.isDeparture,
    required this.widget,
  });

  factory ChatWidget.fromJson(Map<String, dynamic> json) {
    return ChatWidget(
      widgetId: json['widgetId'] ?? 0,
      widgetsType: json['widgets_type'] ?? 0,
      type: json['type'] ?? '',
      isTableBookingFlow: json['is_table_booking_flow'] ?? false,
      isTableBookingTimeSlot: json['is_table_booking_time_slot_selection'] ?? false,
      isHotelBookingFlow: json['is_hotel_booking_flow'] ?? false,
      isCarBookingFlow: json['is_car_booking_flow'] ?? false,
      widget: (json['widget'] as List<dynamic>?) ?? [],
      isForReturn: json['isForReturn'] ?? false,
      isForPickup: json['isForPickup'] ?? false,
      isFlightBookingFlow: json['is_flight_booking'] ?? false,
      isPackageTypesFlow: json['is_package_flow'] ?? false,
      isDeparture: json['isDeparture'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'widgetId': widgetId,
      'widgets_type': widgetsType,
      'type': type,
      'is_table_booking_flow': isTableBookingFlow,
      'is_hotel_booking_flow': isHotelBookingFlow,
      'is_table_booking_time_slot_selection': isTableBookingTimeSlot,
      'is_car_booking_flow': isCarBookingFlow,
      'widget': widget,
      'isForReturn': isForReturn,
      'isForPickup': isForPickup,
      'is_flight_booking_flow': isFlightBookingFlow,
      'is_package_flow': isPackageTypesFlow,
      'isDeparture': isDeparture,
    };
  }

  // Helper methods for different widget types
  bool get isOptionsWidget => type == WidgetEnum.options.value;
  bool get isStoresWidget => type == WidgetEnum.stores.value;
  bool get isProductsWidget => type == WidgetEnum.products.value;
  bool get isSeeMoreWidget => type == WidgetEnum.see_more.value;
  bool get isMenuWidget => type == WidgetEnum.menu.value;
  bool get isCartWidget => type == WidgetEnum.cart.value;
  bool get isRestaurantSectionsWidget => type == WidgetEnum.restaurant_sections.value;
  bool get isServicesDeliveryOptionsWidget => type == WidgetEnum.service_types.value;
  bool get isChooseAddressWidget => type == WidgetEnum.choose_address.value;
  bool get isChooseCardWidget => type == WidgetEnum.choose_card.value;
  bool get isAddAddressWidget => type == WidgetEnum.add_address.value;
  bool get isAddPaymentWidget => type == WidgetEnum.add_payment.value;
  bool get isChooseDateWidget => type == WidgetEnum.choose_date.value;
  bool get isScheduledLaterWidget => type == WidgetEnum.schedule_later.value;
  bool get isSelectStaffWidget => type == WidgetEnum.staff_selection.value;
  bool get isSeeAvailableRoomsWidget => type == WidgetEnum.see_available_rooms.value;
  bool get isCarBookingDateTimeWidget => type == WidgetEnum.car_booking_date_time.value;
  bool get isHotelBookingForMeWidget =>
      type == WidgetEnum.hotel_booking_for_me.value;
  bool get isHotelBookingForOtherWidget =>
      type == WidgetEnum.hotel_booking_for_other.value;
  bool get isCarDriverDetailsWidget => type == WidgetEnum.car_driver_details.value;
  bool get isSeeMoreHotelsWidget => type == WidgetEnum.see_more_hotels.value;
  bool get isSeeMoreCarsWidget => type == WidgetEnum.see_more_cars.value;
  bool get isSeeMoreFlightsWidget => type == WidgetEnum.see_more_flights.value;
  bool get isAddDropoffAddressWidget => type == WidgetEnum.add_dropoff_address.value;
  bool get isTripTypeSelectionWidget => type == WidgetEnum.trip_type_selection.value;
  bool get isFlightBookingDateTimeWidget => type == WidgetEnum.flight_booking_date_time.value;
  bool get isFlightAddMemberWidget => type == WidgetEnum.flight_add_member.value;
  bool get isFlightCabinTypeWidget => type == WidgetEnum.flight_cabin_type.value;
  bool get isFlightTravellerDetailsWidget => type == WidgetEnum.flight_traveller_details.value;
  bool get isHotelConfirmBookingWidget => type == WidgetEnum.hotel_confirm_booking.value;
  bool get isPrescriptionScreenWidget => type == WidgetEnum.prescription_screen.value;
  bool get isOnlinePaymentConfirmOrderWidget => type == WidgetEnum.online_payment_confirm_order.value;
  bool get isOrderSummaryWidget => type == WidgetEnum.order_summary.value;
  bool get isOrderConfirmedWidget => type == WidgetEnum.order_confirmed.value;
  bool get isOrderTrackingWidget => type == WidgetEnum.order_tracking.value;
  bool get isOrderDetailsWidget => type == WidgetEnum.order_details.value;
  bool get isAddDependentWidget => type == WidgetEnum.add_dependent.value;
  bool get isHotelDestinationWidget => type == WidgetEnum.hotel_destination.value;
  bool get isCarPickupPlacesWidget => type == WidgetEnum.car_pickup_places.value;
  bool get isCarDropoffPlacesWidget => type == WidgetEnum.car_dropoff_places.value;
  bool get isFlightOriginPlacesWidget => type == WidgetEnum.flight_origin_places.value;
  bool get isFlightDestinationPlacesWidget => type == WidgetEnum.flight_destination_places.value;
  bool get isCarRentalsSearchWidget => type == WidgetEnum.car_rentals_search.value;
  bool get isFlightsSearchWidget => type == WidgetEnum.flights_search.value;
  bool get isCustomerProfileDetailsWidget => type == WidgetEnum.customer_profile_details.value;
  bool get isHotelOrderSummaryWidget => type == WidgetEnum.hotel_order_summary.value;
  bool get isCarOrderSummaryWidget => type == WidgetEnum.car_order_summary.value;
  bool get isFlightOrderSummaryWidget => type == WidgetEnum.flight_order_summary.value;
  bool get isHotelBookingConfirmedWidget => type == WidgetEnum.hotel_booking_confirmed.value;
  bool get isCarBookingConfirmedWidget => type == WidgetEnum.car_booking_confirmed.value;
  bool get isFlightBookingConfirmedWidget => type == WidgetEnum.flight_booking_confirmed.value;
  bool get isPackageTypesWidget => type == WidgetEnum.package_types.value;
  bool get isHotelsWidget => type == WidgetEnum.hotels.value;
  bool get isButtonWidget => type == 'button';
  bool get isInputWidget => type == 'input';
  bool get isImageWidget => type == 'image';
  bool get isTextWidget => type == 'text';

  // Get raw JSON for each item in widget
  List<Map<String, dynamic>> get rawItems {
    return widget.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      } else if (item is String) {
        try {
          return json.decode(item) as Map<String, dynamic>;
        } catch (e) {
          return {'value': item.toString()};
        }
      } else {
        return {'value': item.toString()};
      }
    }).toList();
  }

  // Get raw JSON for a specific item by index
  Map<String, dynamic>? getRawItem(int index) {
    if (index >= 0 && index < widget.length) {
      final item = widget[index];
      if (item is Map<String, dynamic>) {
        return item;
      } else if (item is String) {
        try {
          return json.decode(item) as Map<String, dynamic>;
        } catch (e) {
          return {'value': item.toString()};
        }
      } else {
        return {'value': item.toString()};
      }
    }
    return null;
  }

  // Get JSON string for a specific item by index
  String? getRawItemAsJsonString(int index) {
    final rawItem = getRawItem(index);
    return rawItem != null ? json.encode(rawItem) : null;
  }

  // Get all raw items as JSON strings
  List<String> get rawItemsAsJsonStrings {
    return rawItems.map((item) => json.encode(item)).toList();
  }

  // Get options for options widget
  List<String> get options => isOptionsWidget
      ? widget.map((e) => e.toString()).toList()
      : [];

  // Get stores for stores widget (converted to models)
  List<Store> get stores => isStoresWidget
      ? widget.map((e) => Store.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get products for products widget (converted to models)
  List<Product> get products => isProductsWidget
      ? widget.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get see_more actions (converted to models)
  List<WidgetAction> get seeMore => isSeeMoreWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get menu actions (converted to models)
  List<WidgetAction> get menu => isMenuWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get orderTracking => isOrderTrackingWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get orderDetails => isOrderDetailsWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get add_address actions (converted to models)
  List<WidgetAction> get addAddress => isAddAddressWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get add_payment actions (converted to models)
  List<WidgetAction> get addPayment => isAddPaymentWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get choose_date actions (converted to models)
  List<WidgetAction> get chooseDate => isChooseDateWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get scheduled_later actions (converted to models)
  List<WidgetAction> get scheduledLater => isScheduledLaterWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get see_available_rooms actions (converted to models)
  List<WidgetAction> get seeAvailableRooms => isSeeAvailableRoomsWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get seeMoreHotels => isSeeMoreHotelsWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get seeMoreCars => isSeeMoreCarsWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get seeMoreFlights => isSeeMoreFlightsWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get addDropoffAddress => isAddDropoffAddressWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get tripTypeSelection => isTripTypeSelectionWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get hotelConfirmBooking => isHotelConfirmBookingWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get flightBookingDateTime => isFlightBookingDateTimeWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get flightAddMember => isFlightAddMemberWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get flightTravellerDetails => isFlightTravellerDetailsWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get hotelBookingForMe => isHotelBookingForMeWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get hotelBookingForOther => isHotelBookingForOtherWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get carDriverDetails => isCarDriverDetailsWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  List<WidgetAction> get carBookingDateTime => isCarBookingDateTimeWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get select_staff actions (converted to models)
  List<WidgetAction> get selectStaff => isSelectStaffWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get prescription_screen actions (converted to models)
  List<WidgetAction> get prescriptionScreen => isPrescriptionScreenWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get online_payment_confirm_order actions (converted to models)
  List<WidgetAction> get onlinePaymentConfirmOrder => isOnlinePaymentConfirmOrderWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get add_dependent actions (converted to models)
  List<WidgetAction> get addDependent => isAddDependentWidget
      ? widget.map((e) => WidgetAction.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get raw stores data (without converting to models)
  List<Map<String, dynamic>> get rawStores => isStoresWidget
      ? widget.map((e) => e as Map<String, dynamic>).toList()
      : [];

  // Get raw products data (without converting to models)
  List<Map<String, dynamic>> get rawProducts => isProductsWidget
      ? widget.map((e) => e as Map<String, dynamic>).toList()
      : [];

  // Get raw store by index
  Map<String, dynamic>? getRawStore(int index) {
    if (isStoresWidget && index >= 0 && index < widget.length) {
      return widget[index] as Map<String, dynamic>;
    }
    return null;
  }

  // Get raw product by index
  Map<String, dynamic>? getRawProduct(int index) {
    if (isProductsWidget && index >= 0 && index < widget.length) {
      return widget[index] as Map<String, dynamic>;
    }
    return null;
  }

  // Helper method to get cart items
  List<WidgetAction> getCartItems() {
    if (isCartWidget) {
      return widget.map((item) => WidgetAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get restaurant sections items
  List<WidgetAction> getRestaurantSectionsItems() {
    if (isRestaurantSectionsWidget) {
      return widget.map((item) => WidgetAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

   // Helper method to get cart items
  List<WidgetAction> getServicesDeliveryOptions() {
    if (isServicesDeliveryOptionsWidget) {
      return widget.map((item) => WidgetAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get address options
  List<AddressOption> getAddressOptions() {
    if (isChooseAddressWidget) {
      return widget.map((item) => AddressOption.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get card options
  List<CardOption> getCardOptions() {
    if (isChooseCardWidget) {
      return widget.map((item) => CardOption.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get order summary items
  List<WidgetAction> getOrderSummaryItems() {
    if (isOrderSummaryWidget) {
      return widget.map((item) => WidgetAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get order confirmed data
  Map<String, dynamic>? getOrderConfirmedData() {
    if (isOrderConfirmedWidget && widget.isNotEmpty) {
      final firstItem = widget.first;
      if (firstItem is Map<String, dynamic>) {
        return firstItem;
      }
    }
    return null;
  }

  // Helper method to get hotel destination items
  List<HotelDestination> getHotelDestinationItems() {
    if (isHotelDestinationWidget) {
      return widget.map((item) => HotelDestination.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get car pickup places items
  List<CarPickupPlace> getCarPickupPlacesItems() {
    if (isCarPickupPlacesWidget) {
      return widget.map((item) => CarPickupPlace.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get car dropoff places items
  List<CarPickupPlace> getCarDropoffPlacesItems() {
    if (isCarDropoffPlacesWidget) {
      return widget.map((item) => CarPickupPlace.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get flight origin places items
  List<CarPickupPlace> getFlightOriginPlacesItems() {
    if (isFlightOriginPlacesWidget) {
      return widget.map((item) => CarPickupPlace.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get flight destination places items
  List<CarPickupPlace> getFlightDestinationPlacesItems() {
    if (isFlightDestinationPlacesWidget) {
      return widget.map((item) => CarPickupPlace.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get car rentals search items
  List<CarRentalSearch> getCarRentalsSearchItems() {
    if (isCarRentalsSearchWidget) {
      return widget
          .map(
            (item) => CarRentalSearch.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    return [];
  }

  // Helper method to get flights search items
  List<FlightSearch> getFlightsSearchItems() {
    if (isFlightsSearchWidget) {
      return widget.map((item) => FlightSearch.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get customer profile details items
  List<HotelDestination> getCustomerProfileDetailsItems() {
    if (isCustomerProfileDetailsWidget) {
      return widget
          .map(
            (item) => HotelDestination.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    return [];
  }

  // Helper method to get hotels items
  List<HotelProperty> getHotelsItems() {
    if (isHotelsWidget) {
      return widget.map((item) => HotelProperty.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get hotel order summary items
  List<HotelOrderSummary> getHotelOrderSummaryItems() {
    if (isHotelOrderSummaryWidget) {
      return widget
          .map(
            (item) => HotelOrderSummary.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    return [];
  }

  // Helper method to get car order summary items
  List<CarOrderSummary> getCarOrderSummaryItems() {
    if (isCarOrderSummaryWidget) {
      return widget
          .map(
            (item) => CarOrderSummary.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }
    return [];
  }

  // Helper method to get flight order summary items
  List<FlightOrderSummary> getFlightOrderSummaryItems() {
    if (isFlightOrderSummaryWidget) {
      return widget.map((item) => FlightOrderSummary.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get hotel booking confirmed items
  List<WidgetAction> getHotelBookingConfirmedItems() {
    if (isHotelBookingConfirmedWidget) {
      return widget.map((item) => WidgetAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get car booking confirmed items
  List<WidgetAction> getCarBookingConfirmedItems() {
    if (isCarBookingConfirmedWidget) {
      return widget.map((item) => WidgetAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get flight booking confirmed items
  List<WidgetAction> getFlightBookingConfirmedItems() {
    if (isFlightBookingConfirmedWidget) {
      return widget.map((item) => WidgetAction.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // Helper method to get package types items
  List<SendPackageType> getPackageTypesItems() {
    if (isPackageTypesWidget) {
      return widget
          .map((item) => SendPackageType.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
  // Get raw store as JSON string by index
  String? getRawStoreAsJsonString(int index) {
    final rawStore = getRawStore(index);
    return rawStore != null ? json.encode(rawStore) : null;
  }

  // Get raw product as JSON string by index
  String? getRawProductAsJsonString(int index) {
    final rawProduct = getRawProduct(index);
    return rawProduct != null ? json.encode(rawProduct) : null;
  }

  // Get first option (useful for single selection)
  String? get firstOption => widget.isNotEmpty ? widget.first.toString() : null;

  @override
  String toString() {
    return 'ChatWidget(id: $widgetId, type: $type, items: ${widget.length})';
  }
}

// Keep all your existing model classes (Product, Store, etc.) unchanged
// ... (all your existing model classes remain the same)

// Product Model for products widget
class Product {
  // final String id;
  final String parentProductId;
  final String childProductId;
  // final Map<String, dynamic> offers;
  final int variantsCount;
  final String productName;
  final FinalPriceList finalPriceList;
  final List<String> images;
  final bool containsMeat;
  final String currencySymbol;
  final String currency;
  final String unitId;
  final bool? customizable;
  final String? storeCategoryId;
  final int? storeTypeId;
  final String? storeId;
  final bool? storeIsOpen;
  final bool? instock;
  final bool? variantCount;// For Grocery, Services Only
  final bool? isPrimary;
  final String? serviceRequireTime;

  const Product({
    // required this.id,
    required this.parentProductId,
    required this.childProductId,
    // required this.offers,
    required this.variantsCount,
    required this.productName,
    required this.finalPriceList,
    required this.images,
    required this.containsMeat,
    required this.currencySymbol,
    required this.currency,
    required this.unitId,
     this.customizable,
     this.storeCategoryId,
     this.storeTypeId,
     this.storeId,
     this.storeIsOpen,
     this.instock,
     this.variantCount,
     this.isPrimary,
     this.serviceRequireTime,
  });

  double get finalPrice => finalPriceList.finalPrice;

  // Backward compatibility getter for productImage
  String get productImage => images.isNotEmpty ? images.first : '';

  factory Product.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> finalPriceListJson =
        (json['finalPriceList'] ?? {}) as Map<String, dynamic>;

    // Handle images as either List<String> or single string
    List<String> imagesList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imagesList = (json['images'] as List).map((e) => e.toString()).toList();
      } else if (json['images'] is String) {
        imagesList = [json['images'].toString()];
      }
    }

    return Product(
      // id: json['id']?.toString() ?? '',
      parentProductId: json['parentProductId']?.toString() ?? '',
      childProductId: json['childProductId']?.toString() ?? '',
      // offers: (json['offers'] as Map<String, dynamic>?) ?? {},
      variantsCount: json['variantsCount'] ?? 0,
      productName: json['productName']?.toString() ?? '',
      finalPriceList: FinalPriceList.fromJson(finalPriceListJson),
      images: imagesList,
      containsMeat: json['containsMeat'] ?? false,
      currencySymbol: json['currencySymbol']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      customizable: json['Customizable'] ?? false,
      storeCategoryId: json['storeCategoryId']?.toString() ?? '',
      storeTypeId: json['storeTypeId'] ?? -111,
      storeId: json['storeId']?.toString() ?? '',
        storeIsOpen: json['storeIsOpen'] ?? true,
        instock: json['instock'] ?? true,
        variantCount: json['variantCount'] ?? false,
        isPrimary: json['isPrimary'] ?? true,
        serviceRequireTime: json['serviceRequireTime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'parentProductId': parentProductId,
      'childProductId': childProductId,
      // 'offers': offers,
      'variantsCount': variantsCount,
      'productName': productName,
      'finalPriceList': finalPriceList.toJson(),
      'images': images,
      'containsMeat': containsMeat,
      'currencySymbol': currencySymbol,
      'currency': currency,
      'unitId': unitId,
      'Customizable': customizable,
      'storeCategoryId': storeCategoryId,
      'storeTypeId': storeTypeId,
      'storeId': storeId,
      'storeIsOpen': storeIsOpen,
      'instock': instock,
      'variantCount': variantCount,
      'isPrimary': isPrimary,
      'serviceRequireTime': serviceRequireTime,
    };
  }
}

// FinalPriceList Model
class FinalPriceList {
  final double basePrice;
  final double finalPrice;
  final double discountPrice;
  final double discountPercentage;
  final int discountType;
  final int taxRate;
  final double msrpPrice;

  FinalPriceList({
    required this.basePrice,
    required this.finalPrice,
    required this.discountPrice,
    required this.discountPercentage,
    required this.discountType,
    required this.taxRate,
    required this.msrpPrice,
  });

  factory FinalPriceList.fromJson(Map<String, dynamic> json) {
    return FinalPriceList(
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      discountPrice: (json['discountPrice'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 1,
      taxRate: json['taxRate'] ?? 0,
      msrpPrice: (json['msrpPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basePrice': basePrice,
      'finalPrice': finalPrice,
      'discountPrice': discountPrice,
      'discountPercentage': discountPercentage,
      'discountType': discountType,
      'taxRate': taxRate,
      'msrpPrice': msrpPrice,
    };
  }
}

/// Pricing details for a doctor (optional in API response).
class DoctorPricing {
  final int inCallFee;
  final int inCallAvgMin;
  final int outCallFee;
  final int outCallAvgMin;
  final int teleCallFee;
  final int teleCallAvgMin;
  final bool isInCallFee;
  final bool isOutCallFee;
  final bool isTeleCallFee;

  DoctorPricing({
    required this.inCallFee,
    required this.inCallAvgMin,
    required this.outCallFee,
    required this.outCallAvgMin,
    required this.teleCallFee,
    required this.teleCallAvgMin,
    required this.isInCallFee,
    required this.isOutCallFee,
    required this.isTeleCallFee,
  });

  factory DoctorPricing.fromJson(Map<String, dynamic> json) {
    return DoctorPricing(
      inCallFee: (json['inCallFee'] as num?)?.toInt() ?? 0,
      inCallAvgMin: (json['inCallAvgMin'] as num?)?.toInt() ?? 0,
      outCallFee: (json['outCallFee'] as num?)?.toInt() ?? 0,
      outCallAvgMin: (json['outCallAvgMin'] as num?)?.toInt() ?? 0,
      teleCallFee: (json['teleCallFee'] as num?)?.toInt() ?? 0,
      teleCallAvgMin: (json['teleCallAvgMin'] as num?)?.toInt() ?? 0,
      isInCallFee: json['isInCallFee'] ?? false,
      isOutCallFee: json['isOutCallFee'] ?? false,
      isTeleCallFee: json['isTeleCallFee'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inCallFee': inCallFee,
      'inCallAvgMin': inCallAvgMin,
      'outCallFee': outCallFee,
      'outCallAvgMin': outCallAvgMin,
      'teleCallFee': teleCallFee,
      'teleCallAvgMin': teleCallAvgMin,
      'isInCallFee': isInCallFee,
      'isOutCallFee': isOutCallFee,
      'isTeleCallFee': isTeleCallFee,
    };
  }
}

/// Doctor item from API doctorsList.
class Doctor {
  final String id;
  final int serviceAvailability;
  final String firstName;
  final String lastName;
  final String profilePic;
  final double? rating;
  final DoctorPricing? pricing;

  Doctor({
    required this.id,
    required this.serviceAvailability,
    required this.firstName,
    required this.lastName,
    required this.profilePic,
    this.rating,
    this.pricing,
  });

  String get fullName => '$firstName ${lastName.trim()}'.trim();

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final pricingJson = json['pricing'];
    return Doctor(
      id: (json['_id'] ?? '').toString(),
      serviceAvailability: (json['serviceAvailability'] as num?)?.toInt() ?? 0,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      profilePic: (json['profilePic'] ?? '').toString(),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      pricing: pricingJson != null && pricingJson is Map<String, dynamic>
          ? DoctorPricing.fromJson(pricingJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serviceAvailability': serviceAvailability,
      'firstName': firstName,
      'lastName': lastName,
      'profilePic': profilePic,
      if (rating != null) 'rating': rating,
      if (pricing != null) 'pricing': pricing!.toJson(),
    };
  }
}

// Store Model for stores widget (now includes nested products)
class Store {
  final String storename;
  final double avgRating;
  final String cuisineDetails;
  final String storeImage;
  final String distance;
  final String storeId;
  final String storeCategoryId;
  final String linkFromId;
  final int type;
  final bool isDoctore;// for Healthcare Store
  final bool storeListing;
  final bool hyperlocal;
  final List<Product> products;
  final List<Doctor> doctorsList;
  final int? storeTypeId;
  final bool storeIsOpen;
  final num supportedOrderTypes;
  final bool tableReservations;
  final List<String> cuisines;

  Store({
    required this.storename,
    required this.avgRating,
    required this.cuisineDetails,
    required this.storeImage,
    required this.distance,
    required this.storeId,
    required this.storeCategoryId,
    required this.products,
    required this.doctorsList,
    required this.linkFromId,
    required this.type,
    required this.isDoctore,
    required this.storeListing,
    required this.hyperlocal,
    this.storeTypeId,
    required this.storeIsOpen,
    required this.supportedOrderTypes,
    required this.tableReservations,
    required this.cuisines,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    final String name = (json['storename'] ?? json['store_name'] ?? '').toString();
    final double rating = ((json['avgRating'] ?? json['rating'] ?? 0) as num).toDouble();
    final String image = (json['storeImage'] ?? json['store_logo'] ?? '').toString();
    final String distance = (json['distance'] ?? '');
    final String storeId = (json['storeId'] ?? '');
    final String storeCategoryId = (json['storeCategoryId'] ?? '');
    final String linkFromId = (json['linkFromId'] ?? '');
    final int type = (json['type'] ?? 0);
    final bool isDoctore = (json['isDoctore'] ?? false);
    final bool storeListing = (json['storeListing'] ?? false);
    final bool hyperlocal = (json['hyperlocal'] ?? false);
    final int storeTypeId = (json['storeTypeId'] ?? 0);
    final bool storeIsOpen = (json['storeIsOpen'] ?? false);
    final int supportedOrderTypes = (json['supportedOrderTypes'] ?? 0);
    final bool tableReservations = (json['tableReservations'] ?? false);
    final List<Doctor> doctorsList = (json['doctorsList'] as List<dynamic>? ?? [])
        .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
        .toList();
    final List<Product> parsedProducts = (json['products'] as List<dynamic>? ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    final List<String> cuisines = (json['cuisines'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    // Process categorylist - remove duplicates before displaying
    String cuisineDetailsStr = '';
    if (json['cuisineDetails'] != null) {
      // If cuisineDetails is already a string, deduplicate it if it's comma-separated
      final cuisineDetailsValue = json['cuisineDetails'].toString();
      if (cuisineDetailsValue.contains(',')) {
        // Split by comma, trim whitespace, remove duplicates, and rejoin
        final categories = cuisineDetailsValue
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();
        cuisineDetailsStr = categories.join(', ');
      } else {
        cuisineDetailsStr = cuisineDetailsValue;
      }
    } else if (json['categorylist'] != null) {
      final categoryList = (json['categorylist'] as List<dynamic>?)
          ?.map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList() ?? [];
      // Remove duplicates by converting to Set and back to List
      final uniqueCategories = categoryList.toSet().toList();
      cuisineDetailsStr = uniqueCategories.join(', ');
    }

    return Store(
      storename: name,
      avgRating: rating,
      cuisineDetails: cuisineDetailsStr,
      storeImage: image,
      distance: distance,
      storeId: storeId,
      storeCategoryId: storeCategoryId,
      products: parsedProducts,
      doctorsList: doctorsList,
      linkFromId: linkFromId,
      type: type,
      isDoctore: isDoctore,
      storeListing: storeListing,
      hyperlocal: hyperlocal,
      storeTypeId: storeTypeId,
      storeIsOpen: storeIsOpen,
      supportedOrderTypes: supportedOrderTypes,
      tableReservations: tableReservations,
      cuisines: cuisines,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storename': storename,
      'avgRating': avgRating,
      'cuisineDetails': cuisineDetails,
      'storeImage': storeImage,
      'distance': distance,
      'storeId': storeId,
      'storeCategoryId': storeCategoryId,
      'products': products.map((p) => p.toJson()).toList(),
      'doctorsList': doctorsList.map((d) => d.toJson()).toList(),
      'storeIsOpen': storeIsOpen,
      'storeTypeId': storeTypeId,
      'supportedOrderTypes': supportedOrderTypes,
      'tableReservations': tableReservations,
      'isDoctore': isDoctore,
      'cuisines': cuisines,
    };
  }
}

// Hotel Destination Model
class HotelDestination {
  final String id;
  final String name;
  final String fullName;
  final String type;
  final String country;
  final String? state;
  final double lat;
  final double lng;
  final String title;
  final String contact;
  final String email;

  HotelDestination({
    required this.id,
    required this.name,
    required this.fullName,
    required this.type,
    required this.country,
    this.state,
    required this.lat,
    required this.lng,
    required this.title,
    required this.contact,
    required this.email,
  });

  factory HotelDestination.fromJson(Map<String, dynamic> json) {
    return HotelDestination(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      state: json['state']?.toString(),
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      title: (json['title'] ?? '').toString(),
      contact: (json['contact'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'type': type,
      'country': country,
      'state': state,
      'lat': lat,
      'lng': lng,
      'title': title,
      'contact': contact,
      'email': email,
    };
  }
}

// Airport / car pickup place model
class AirportCoordinates {
  final double lat;
  final double lon;

  AirportCoordinates({
    required this.lat,
    required this.lon,
  });

  factory AirportCoordinates.fromJson(Map<String, dynamic> json) {
    return AirportCoordinates(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }
}

class CarPickupPlace {
  final String id;
  final String name;
  final String cityName;
  final String countryName;
  final String iataCode;
  final String type;
  final AirportCoordinates coordinates;
  final String regionId;

  CarPickupPlace({
    required this.id,
    required this.name,
    required this.cityName,
    required this.countryName,
    required this.iataCode,
    required this.type,
    required this.coordinates,
    required this.regionId,
  });

  factory CarPickupPlace.fromJson(Map<String, dynamic> json) {
    final coordinatesJson = json['coordinates'];
    return CarPickupPlace(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      cityName: (json['city_name'] ?? json['city'] ?? '').toString(),
      countryName: (json['country_name'] ?? '').toString(),
      iataCode: (json['iata_code'] ?? json['code'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      coordinates: coordinatesJson is Map<String, dynamic>
          ? AirportCoordinates.fromJson(coordinatesJson)
          : AirportCoordinates(lat: 0.0, lon: 0.0),
      regionId: (json['region_id'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_name': cityName,
      'country_name': countryName,
      'iata_code': iataCode,
      'type': type,
      'coordinates': coordinates.toJson(),
      'region_id': regionId,
    };
  }
}

// Send package type model for package_types widget
class SendPackageType {
  final String id;
  final String sendPackageTypeName;
  final String sendPackageTypeImage;

  SendPackageType({
    required this.id,
    required this.sendPackageTypeName,
    required this.sendPackageTypeImage,
  });

  factory SendPackageType.fromJson(Map<String, dynamic> json) {
    return SendPackageType(
      id: (json['_id'] ?? '').toString(),
      sendPackageTypeName: (json['sendPackageTypeName'] ?? '').toString(),
      sendPackageTypeImage: (json['sendPackageTypeImage'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sendPackageTypeName': sendPackageTypeName,
      'sendPackageTypeImage': sendPackageTypeImage,
    };
  }
}

// Car Rental Search Model (vehicle rental search result)
class CarRentalSearch {
  final String id;
  final String name;
  final String vendor;
  final String currency;
  final double amount;
  final String availabilityToken;
  final String correlationId;
  final String pickupDate;
  final String returnDate;
  final int driverAge;
  final CarRentalSearchRaw raw;

  CarRentalSearch({
    required this.id,
    required this.name,
    required this.vendor,
    required this.currency,
    required this.amount,
    required this.availabilityToken,
    required this.correlationId,
    required this.pickupDate,
    required this.returnDate,
    required this.driverAge,
    required this.raw,
  });

  factory CarRentalSearch.fromJson(Map<String, dynamic> json) {
    if (_isAvailabilityApiItem(json)) {
      return CarRentalSearch.fromAvailabilityJson(json);
    }

    return CarRentalSearch(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      vendor: (json['vendor'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      availabilityToken: (json['availability_token'] ??
              json['availabilityToken'] ??
              '')
          .toString(),
      correlationId:
          (json['correlation_id'] ?? json['correlationId'] ?? '').toString(),
      pickupDate: (json['pickup_date'] ?? '').toString(),
      returnDate: (json['return_date'] ?? '').toString(),
      driverAge: (json['driver_age'] as num?)?.toInt() ?? 0,
      raw: CarRentalSearchRaw.fromJson(
        json['raw'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Parses GET /v1/xeni/cars/rentals `available_cars` items.
  factory CarRentalSearch.fromAvailabilityJson(
    Map<String, dynamic> json, {
    String correlationId = '',
    String pickupDate = '',
    String returnDate = '',
    int driverAge = 0,
  }) {
    final vehicleJson = json['vehicle'] as Map<String, dynamic>? ?? {};
    final vehicle = CarRentalVehicle.fromJson(vehicleJson);
    final preferredCharge = _preferredVehicleCharge(json);
    final id = (json['id'] ?? '').toString();
    final availabilityToken = (json['availability_token'] ??
            json['availabilityToken'] ??
            '')
        .toString();
    final vendor = (json['rental_car_brand'] ?? json['vendor'] ?? '')
        .toString();
    final name = vehicle.name.trim().isNotEmpty
        ? vehicle.name
        : (json['name'] ?? '').toString();

    return CarRentalSearch(
      id: id,
      name: name,
      vendor: vendor,
      currency: (preferredCharge['currency_code'] ?? json['currency'] ?? '')
          .toString(),
      amount: (preferredCharge['total_price'] as num?)?.toDouble() ??
          (preferredCharge['base_price'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          0.0,
      availabilityToken: availabilityToken,
      correlationId: correlationId.isNotEmpty
          ? correlationId
          : (json['correlation_id'] ?? json['correlationId'] ?? '').toString(),
      pickupDate: pickupDate.isNotEmpty
          ? pickupDate
          : (json['pickup_date'] ?? json['pick_up_date_time'] ?? '').toString(),
      returnDate: returnDate.isNotEmpty
          ? returnDate
          : (json['return_date'] ?? json['return_date_time'] ?? '').toString(),
      driverAge: driverAge > 0
          ? driverAge
          : (json['driver_age'] as num?)?.toInt() ?? 0,
      raw: CarRentalSearchRaw(
        id: id,
        availabilityToken: availabilityToken,
        status: (json['status'] ?? '').toString(),
        rentalCarBrand: vendor,
        vehicle: vehicle,
      ),
    );
  }

  static bool _isAvailabilityApiItem(Map<String, dynamic> json) {
    return json.containsKey('rental_car_brand') ||
        json.containsKey('rental_rate') ||
        json.containsKey('available_cars');
  }

  static Map<String, dynamic> _preferredVehicleCharge(Map<String, dynamic> json) {
    final rentalRate = json['rental_rate'];
    if (rentalRate is! Map) return {};

    final charges = rentalRate['vehicle_charges'];
    if (charges is! List) return {};

    for (final charge in charges) {
      if (charge is Map &&
          charge['purpose']?.toString().toLowerCase() == 'preferred') {
        return Map<String, dynamic>.from(charge);
      }
    }

    for (final charge in charges) {
      if (charge is Map && charge['total_price'] != null) {
        return Map<String, dynamic>.from(charge);
      }
    }

    if (charges.isNotEmpty && charges.first is Map) {
      return Map<String, dynamic>.from(charges.first as Map);
    }

    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vendor': vendor,
      'currency': currency,
      'amount': amount,
      'availability_token': availabilityToken,
      'correlation_id': correlationId,
      'pickup_date': pickupDate,
      'return_date': returnDate,
      'driver_age': driverAge,
      'raw': raw.toJson(),
    };
  }
}

// Flight Search Model (flight search result)
class FlightSearch {
  final List<FlightSearchSegment> segments;
  final List<FlightSearchCabin> cabins;
  final String correlationId;

  FlightSearch({
    required this.segments,
    required this.cabins,
    required this.correlationId,
  });

  factory FlightSearch.fromJson(Map<String, dynamic> json) {
    return FlightSearch(
      segments: (json['segments'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightSearchSegment.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      cabins: (json['cabins'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightSearchCabin.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      correlationId:
          (json['correlation_id'] ?? json['correlationId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segments': segments.map((e) => e.toJson()).toList(),
      'cabins': cabins.map((e) => e.toJson()).toList(),
      'correlation_id': correlationId,
    };
  }
}

class FlightSearchSegment {
  final String airlineName;
  final String departureAirport;
  final String departureDate;
  final String departureTime;
  final String arrivalAirport;
  final String arrivalDate;
  final String arrivalTime;
  final String duration;
  final List<String> stops;
  final List<String> marketingCarrier;
  final String operatedBy;
  final String airlineCode;
  final String airlineLogo;
  final List<FlightLayoverInfo> layoverInfo;

  FlightSearchSegment({
    required this.airlineName,
    required this.departureAirport,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.duration,
    required this.stops,
    required this.marketingCarrier,
    required this.operatedBy,
    required this.airlineCode,
    required this.airlineLogo,
    required this.layoverInfo,
  });

  factory FlightSearchSegment.fromJson(Map<String, dynamic> json) {
    return FlightSearchSegment(
      airlineName: (json['airline_name'] ?? '').toString(),
      departureAirport: (json['departure_airport'] ?? '').toString(),
      departureDate: (json['departure_date'] ?? '').toString(),
      departureTime: (json['departure_time'] ?? '').toString(),
      arrivalAirport: (json['arrival_airport'] ?? '').toString(),
      arrivalDate: (json['arrival_date'] ?? '').toString(),
      arrivalTime: (json['arrival_time'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      marketingCarrier: (json['marketing_carrier'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      operatedBy: (json['operated_by'] ?? '').toString(),
      airlineCode: (json['airline_code'] ?? '').toString(),
      airlineLogo: (json['airline_logo'] ?? '').toString(),
      layoverInfo: (json['layover_info'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightLayoverInfo.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airline_name': airlineName,
      'departure_airport': departureAirport,
      'departure_date': departureDate,
      'departure_time': departureTime,
      'arrival_airport': arrivalAirport,
      'arrival_date': arrivalDate,
      'arrival_time': arrivalTime,
      'duration': duration,
      'stops': stops,
      'marketing_carrier': marketingCarrier,
      'operated_by': operatedBy,
      'airline_code': airlineCode,
      'airline_logo': airlineLogo,
      'layover_info': layoverInfo.map((e) => e.toJson()).toList(),
    };
  }
}

class FlightLayoverInfo {
  final String airportCode;
  final String duration;

  FlightLayoverInfo({
    required this.airportCode,
    required this.duration,
  });

  factory FlightLayoverInfo.fromJson(Map<String, dynamic> json) {
    return FlightLayoverInfo(
      airportCode: (json['airport_code'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airport_code': airportCode,
      'duration': duration,
    };
  }
}

class FlightSearchCabin {
  final String id;
  final String cabin;
  final String cabinClassText;
  final String cabinSearchSessionId;
  final double baseRate;
  final double taxAndFees;
  final double totalRate;
  final List<FlightPassengerFare> passengerFare;
  final String currencyCode;
  final List<FlightBaggageDetail> baggageDetails;
  final List<FlightPenaltyInfo> penaltiesInfo;

  FlightSearchCabin({
    required this.id,
    required this.cabin,
    required this.cabinClassText,
    required this.cabinSearchSessionId,
    required this.baseRate,
    required this.taxAndFees,
    required this.totalRate,
    required this.passengerFare,
    required this.currencyCode,
    required this.baggageDetails,
    required this.penaltiesInfo,
  });

  factory FlightSearchCabin.fromJson(Map<String, dynamic> json) {
    return FlightSearchCabin(
      id: (json['id'] ?? '').toString(),
      cabin: (json['cabin'] ?? '').toString(),
      cabinClassText: (json['cabin_class_text'] ?? '').toString(),
      cabinSearchSessionId:
          (json['cabin_search_session_id'] ?? '').toString(),
      baseRate: (json['base_rate'] as num?)?.toDouble() ?? 0.0,
      taxAndFees: (json['tax_and_fees'] as num?)?.toDouble() ?? 0.0,
      totalRate: (json['total_rate'] as num?)?.toDouble() ?? 0.0,
      passengerFare: (json['passenger_fare'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightPassengerFare.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      currencyCode: (json['currency_code'] ?? '').toString(),
      baggageDetails: (json['baggage_details'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightBaggageDetail.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      penaltiesInfo: (json['penalties_info'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightPenaltyInfo.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cabin': cabin,
      'cabin_class_text': cabinClassText,
      'cabin_search_session_id': cabinSearchSessionId,
      'base_rate': baseRate,
      'tax_and_fees': taxAndFees,
      'total_rate': totalRate,
      'passenger_fare': passengerFare.map((e) => e.toJson()).toList(),
      'currency_code': currencyCode,
      'baggage_details': baggageDetails.map((e) => e.toJson()).toList(),
      'penalties_info': penaltiesInfo.map((e) => e.toJson()).toList(),
    };
  }
}

class FlightPassengerFare {
  final int quantity;
  final String type;
  final double basePrice;
  final double taxAndFees;
  final double totalPrice;

  FlightPassengerFare({
    required this.quantity,
    required this.type,
    required this.basePrice,
    required this.taxAndFees,
    required this.totalPrice,
  });

  factory FlightPassengerFare.fromJson(Map<String, dynamic> json) {
    return FlightPassengerFare(
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? '').toString(),
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      taxAndFees: (json['tax_and_fees'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'type': type,
      'base_price': basePrice,
      'tax_and_fees': taxAndFees,
      'total_price': totalPrice,
    };
  }
}

class FlightBaggageDetail {
  final String legIndicator;
  final List<FlightPassengerBaggage> passengerBaggages;

  FlightBaggageDetail({
    required this.legIndicator,
    required this.passengerBaggages,
  });

  factory FlightBaggageDetail.fromJson(Map<String, dynamic> json) {
    return FlightBaggageDetail(
      legIndicator: (json['leg_indicator'] ?? '').toString(),
      passengerBaggages: (json['passenger_baggages'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightPassengerBaggage.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leg_indicator': legIndicator,
      'passenger_baggages':
          passengerBaggages.map((e) => e.toJson()).toList(),
    };
  }
}

class FlightPassengerBaggage {
  final String passengerType;
  final List<FlightBaggageAllowance> baggage;

  FlightPassengerBaggage({
    required this.passengerType,
    required this.baggage,
  });

  factory FlightPassengerBaggage.fromJson(Map<String, dynamic> json) {
    return FlightPassengerBaggage(
      passengerType: (json['passenger_type'] ?? '').toString(),
      baggage: (json['baggage'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightBaggageAllowance.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passenger_type': passengerType,
      'baggage': baggage.map((e) => e.toJson()).toList(),
    };
  }
}

class FlightBaggageAllowance {
  final String type;
  final String freeQuantity;
  final String allowanceUnit;

  FlightBaggageAllowance({
    required this.type,
    required this.freeQuantity,
    required this.allowanceUnit,
  });

  factory FlightBaggageAllowance.fromJson(Map<String, dynamic> json) {
    return FlightBaggageAllowance(
      type: (json['type'] ?? '').toString(),
      freeQuantity: (json['free_quantity'] ?? '').toString(),
      allowanceUnit: (json['allowance_unit'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'free_quantity': freeQuantity,
      'allowance_unit': allowanceUnit,
    };
  }
}

class FlightPenaltyInfo {
  final String passengerType;
  final bool refundAllowed;
  final bool changeAllowed;

  FlightPenaltyInfo({
    required this.passengerType,
    required this.refundAllowed,
    required this.changeAllowed,
  });

  factory FlightPenaltyInfo.fromJson(Map<String, dynamic> json) {
    return FlightPenaltyInfo(
      passengerType: (json['passenger_type'] ?? '').toString(),
      refundAllowed: json['refund_allowed'] == true,
      changeAllowed: json['change_allowed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passenger_type': passengerType,
      'refund_allowed': refundAllowed,
      'change_allowed': changeAllowed,
    };
  }
}

class CarRentalSearchRaw {
  final String id;
  final String availabilityToken;
  final String status;
  final String rentalCarBrand;
  final CarRentalVehicle vehicle;

  CarRentalSearchRaw({
    required this.id,
    required this.availabilityToken,
    required this.status,
    required this.rentalCarBrand,
    required this.vehicle,
  });

  factory CarRentalSearchRaw.fromJson(Map<String, dynamic> json) {
    return CarRentalSearchRaw(
      id: (json['id'] ?? '').toString(),
      availabilityToken: (json['availability_token'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      rentalCarBrand: (json['rental_car_brand'] ?? '').toString(),
      vehicle: CarRentalVehicle.fromJson(
        json['vehicle'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'availability_token': availabilityToken,
      'status': status,
      'rental_car_brand': rentalCarBrand,
      'vehicle': vehicle.toJson(),
    };
  }
}

class CarRentalVehicle {
  final bool airConditioning;
  final String transmissionType;
  final String fuelType;
  final String driveType;
  final int passengerQuantity;
  final int baggageQuantity;
  final String vehicleSize;
  final String vehicleType;
  final String sippCode;
  final String name;
  final int doorCount;
  final String pictureUrl;

  CarRentalVehicle({
    required this.airConditioning,
    required this.transmissionType,
    required this.fuelType,
    required this.driveType,
    required this.passengerQuantity,
    required this.baggageQuantity,
    required this.vehicleSize,
    required this.vehicleType,
    required this.sippCode,
    required this.name,
    required this.doorCount,
    required this.pictureUrl,
  });

  factory CarRentalVehicle.fromJson(Map<String, dynamic> json) {
    return CarRentalVehicle(
      airConditioning: json['air_conditioning'] == true,
      transmissionType: (json['transmission_type'] ?? '').toString(),
      fuelType: (json['fuel_type'] ?? '').toString(),
      driveType: (json['drive_type'] ?? '').toString(),
      passengerQuantity: (json['passenger_quantity'] as num?)?.toInt() ?? 0,
      baggageQuantity: (json['baggage_quantity'] as num?)?.toInt() ?? 0,
      vehicleSize: (json['vehicle_size'] ?? '').toString(),
      vehicleType: (json['vehicle_type'] ?? '').toString(),
      sippCode: (json['sipp_code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      doorCount: (json['door_count'] as num?)?.toInt() ?? 0,
      pictureUrl: (json['picture_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'air_conditioning': airConditioning,
      'transmission_type': transmissionType,
      'fuel_type': fuelType,
      'drive_type': driveType,
      'passenger_quantity': passengerQuantity,
      'baggage_quantity': baggageQuantity,
      'vehicle_size': vehicleSize,
      'vehicle_type': vehicleType,
      'sipp_code': sippCode,
      'name': name,
      'door_count': doorCount,
      'picture_url': pictureUrl,
    };
  }
}

// Hotel Property Model (lodging search result)
class HotelProperty {
  final String propertyId;
  final double distance;
  final String name;
  final HotelPropertyContact contact;
  final HotelPropertyRatings ratings;
  final HotelPropertyRate rate;
  final HotelPropertyImage image;
  final String chain;
  final String correlationId;
  final String checkinDate;
  final String checkoutDate;
  final List<Map<String, dynamic>> occupancy;

  HotelProperty({
    required this.propertyId,
    required this.distance,
    required this.name,
    required this.contact,
    required this.ratings,
    required this.rate,
    required this.image,
    required this.chain,
    required this.correlationId,
    required this.checkinDate,
    required this.checkoutDate,
    required this.occupancy,
  });

  factory HotelProperty.fromJson(Map<String, dynamic> json) {
    return HotelProperty(
      propertyId: (json['property_id'] ?? '').toString(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      name: (json['name'] ?? '').toString(),
      contact: HotelPropertyContact.fromJson(
        json['contact'] as Map<String, dynamic>? ?? {},
      ),
      ratings: HotelPropertyRatings.fromJson(
        json['ratings'] as Map<String, dynamic>? ?? {},
      ),
      rate: HotelPropertyRate.fromJson(
        json['rate'] as Map<String, dynamic>? ?? {},
      ),
      image: HotelPropertyImage.fromJson(
        json['image'] as Map<String, dynamic>? ?? {},
      ),
      chain: (json['chain'] ?? '').toString(),
      correlationId: (json['correlation_id'] ?? '').toString(),
      checkinDate: (json['checkin_date'] ?? '').toString(),
      checkoutDate: (json['checkout_date'] ?? '').toString(),
      occupancy: (json['occupancy'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'distance': distance,
      'name': name,
      'contact': contact.toJson(),
      'ratings': ratings.toJson(),
      'rate': rate.toJson(),
      'image': image.toJson(),
      'chain': chain,
      'correlation_id': correlationId,
      'checkin_date': checkinDate,
      'checkout_date': checkoutDate,
      'occupancy': occupancy,
    };
  }
}

class HotelPropertyContact {
  final String phone;
  final HotelPropertyAddress address;

  HotelPropertyContact({
    required this.phone,
    required this.address,
  });

  factory HotelPropertyContact.fromJson(Map<String, dynamic> json) {
    return HotelPropertyContact(
      phone: (json['phone'] ?? '').toString(),
      address: HotelPropertyAddress.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'address': address.toJson(),
    };
  }
}

class HotelPropertyAddress {
  final String line1;
  final String country;
  final String state;
  final String city;
  final String postalCode;

  HotelPropertyAddress({
    required this.line1,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
  });

  factory HotelPropertyAddress.fromJson(Map<String, dynamic> json) {
    return HotelPropertyAddress(
      line1: (json['line_1'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      postalCode: (json['postal_code'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line_1': line1,
      'country': country,
      'state': state,
      'city': city,
      'postal_code': postalCode,
    };
  }
}

class HotelPropertyRatings {
  final double starRating;
  final double userRating;

  HotelPropertyRatings({
    required this.starRating,
    required this.userRating,
  });

  factory HotelPropertyRatings.fromJson(Map<String, dynamic> json) {
    return HotelPropertyRatings(
      starRating: (json['star_rating'] as num?)?.toDouble() ?? 0.0,
      userRating: (json['user_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'star_rating': starRating,
      'user_rating': userRating,
    };
  }
}

class HotelPropertyRate {
  final double recommendedSellingPrice;
  final double baseRate;
  final double totalRate;
  final double taxAndFees;
  final String currency;
  final double savedPrice;

  HotelPropertyRate({
    required this.recommendedSellingPrice,
    required this.baseRate,
    required this.totalRate,
    required this.taxAndFees,
    required this.currency,
    required this.savedPrice,
  });

  factory HotelPropertyRate.fromJson(Map<String, dynamic> json) {
    return HotelPropertyRate(
      recommendedSellingPrice:
          (json['recommended_selling_price'] as num?)?.toDouble() ?? 0.0,
      baseRate: (json['base_rate'] as num?)?.toDouble() ?? 0.0,
      totalRate: (json['total_rate'] as num?)?.toDouble() ?? 0.0,
      taxAndFees: (json['tax_and_fees'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? '').toString(),
      savedPrice: (json['saved_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended_selling_price': recommendedSellingPrice,
      'base_rate': baseRate,
      'total_rate': totalRate,
      'tax_and_fees': taxAndFees,
      'currency': currency,
      'saved_price': savedPrice,
    };
  }
}

class HotelPropertyImage {
  final String thumbnail;
  final String large;
  final String extraLarge;

  HotelPropertyImage({
    required this.thumbnail,
    required this.large,
    required this.extraLarge,
  });

  factory HotelPropertyImage.fromJson(Map<String, dynamic> json) {
    return HotelPropertyImage(
      thumbnail: (json['thumbnail'] ?? '').toString(),
      large: (json['large'] ?? '').toString(),
      extraLarge: (json['extra_large'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
      'large': large,
      'extra_large': extraLarge,
    };
  }
}

// Hotel Order Summary Model (checkout / booking confirmation)
class HotelOrderSummary {
  final String checkinDate;
  final String checkoutDate;
  final String roomName;
  final String roomBed;
  final String description;
  final int numberOfAdults;
  final String status;
  final bool refundable;
  final List<String> boardBasis;
  final double baseRate;
  final double taxAndFees;
  final double recommendedSellingPrice;
  final double totalPrice;
  final String currency;
  final List<Map<String, dynamic>> additionalCharges;
  final List<HotelCancellationPolicy> cancellationPolicy;
  final bool allGuestInfoRequired;
  final bool specialRequestSupported;
  final HotelBookingGuest guest;
  final HotelBookingPayment payment;
  final String pricingToken;

  HotelOrderSummary({
    required this.checkinDate,
    required this.checkoutDate,
    required this.roomName,
    required this.roomBed,
    required this.description,
    required this.numberOfAdults,
    required this.status,
    required this.refundable,
    required this.boardBasis,
    required this.baseRate,
    required this.taxAndFees,
    required this.recommendedSellingPrice,
    required this.totalPrice,
    required this.currency,
    required this.additionalCharges,
    required this.cancellationPolicy,
    required this.allGuestInfoRequired,
    required this.specialRequestSupported,
    required this.guest,
    required this.payment,
    required this.pricingToken,
  });

  factory HotelOrderSummary.fromJson(Map<String, dynamic> json) {
    return HotelOrderSummary(
      checkinDate: (json['checkin_date'] ?? '').toString(),
      checkoutDate: (json['checkout_date'] ?? '').toString(),
      roomName: (json['room_name'] ?? '').toString(),
      roomBed: (json['room_bed'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      numberOfAdults: (json['number_of_adults'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      refundable: json['refundable'] == true,
      boardBasis: (json['board_basis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      baseRate: (json['base_rate'] as num?)?.toDouble() ?? 0.0,
      taxAndFees: (json['tax_and_fees'] as num?)?.toDouble() ?? 0.0,
      recommendedSellingPrice:
          (json['recommended_selling_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? '').toString(),
      additionalCharges: (json['additional_charges'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const [],
      cancellationPolicy: (json['cancellation_policy'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => HotelCancellationPolicy.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      allGuestInfoRequired: json['all_guest_info_required'] == true,
      specialRequestSupported: json['special_request_supported'] == true,
      guest: HotelBookingGuest.fromJson(
        json['guest'] as Map<String, dynamic>? ?? {},
      ),
      payment: HotelBookingPayment.fromJson(
        json['payment'] as Map<String, dynamic>? ?? {},
      ),
      pricingToken: (json['pricingToken'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkin_date': checkinDate,
      'checkout_date': checkoutDate,
      'room_name': roomName,
      'room_bed': roomBed,
      'description': description,
      'number_of_adults': numberOfAdults,
      'status': status,
      'refundable': refundable,
      'board_basis': boardBasis,
      'base_rate': baseRate,
      'tax_and_fees': taxAndFees,
      'recommended_selling_price': recommendedSellingPrice,
      'total_price': totalPrice,
      'currency': currency,
      'additional_charges': additionalCharges,
      'cancellation_policy':
          cancellationPolicy.map((e) => e.toJson()).toList(),
      'all_guest_info_required': allGuestInfoRequired,
      'special_request_supported': specialRequestSupported,
      'guest': guest.toJson(),
      'payment': payment.toJson(),
      'pricingToken': pricingToken,
    };
  }
}

class HotelCancellationPolicy {
  final String start;
  final String end;
  final String type;
  final double value;
  final String currency;
  final double estimateAmount;
  final double billableAmount;
  final String billableCurrency;

  HotelCancellationPolicy({
    required this.start,
    required this.end,
    required this.type,
    required this.value,
    required this.currency,
    required this.estimateAmount,
    required this.billableAmount,
    required this.billableCurrency,
  });

  factory HotelCancellationPolicy.fromJson(Map<String, dynamic> json) {
    return HotelCancellationPolicy(
      start: (json['start'] ?? '').toString(),
      end: (json['end'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? '').toString(),
      estimateAmount: (json['estimate_amount'] as num?)?.toDouble() ?? 0.0,
      billableAmount: (json['billable_amount'] as num?)?.toDouble() ?? 0.0,
      billableCurrency: (json['billable_currency'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'type': type,
      'value': value,
      'currency': currency,
      'estimate_amount': estimateAmount,
      'billable_amount': billableAmount,
      'billable_currency': billableCurrency,
    };
  }
}

class HotelBookingGuest {
  final String name;
  final String email;
  final String phone;
  final List<HotelGuestRoomInfo> rooms;

  HotelBookingGuest({
    required this.name,
    required this.email,
    required this.phone,
    required this.rooms,
  });

  factory HotelBookingGuest.fromJson(Map<String, dynamic> json) {
    return HotelBookingGuest(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      rooms: (json['rooms'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => HotelGuestRoomInfo.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'rooms': rooms.map((e) => e.toJson()).toList(),
    };
  }
}

class HotelGuestRoomInfo {
  final String title;
  final String firstName;
  final String lastName;

  HotelGuestRoomInfo({
    required this.title,
    required this.firstName,
    required this.lastName,
  });

  factory HotelGuestRoomInfo.fromJson(Map<String, dynamic> json) {
    return HotelGuestRoomInfo(
      title: (json['title'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class HotelBookingPayment {
  final String cardTitle;
  final String cardId;

  HotelBookingPayment({
    required this.cardTitle,
    required this.cardId,
  });

  factory HotelBookingPayment.fromJson(Map<String, dynamic> json) {
    return HotelBookingPayment(
      cardTitle: (json['card_title'] ?? '').toString(),
      cardId: (json['card_id'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_title': cardTitle,
      'card_id': cardId,
    };
  }
}

// Car Order Summary Model (checkout / booking confirmation)
class CarOrderSummary {
  final String availabilityDetailsToken;
  final String pickUpDateTime;
  final String returnDateTime;
  final String rentalCarBrand;
  final CarRentalVehicle vehicle;
  final List<CarRentalLocationDetail> locationDetails;
  final String correlationId;
  final String availabilityToken;
  final String pickupCode;
  final String returnCode;
  final String pickupDate;
  final String returnDate;
  final String countryOfResidence;
  final int driverAge;
  final String driverName;
  final String pickupType;
  final String returnType;
  final String? carName;
  final double totalPrice;
  final String currencyCode;
  final HotelBookingPayment payment;

  CarOrderSummary({
    required this.availabilityDetailsToken,
    required this.pickUpDateTime,
    required this.returnDateTime,
    required this.rentalCarBrand,
    required this.vehicle,
    required this.locationDetails,
    required this.correlationId,
    required this.availabilityToken,
    required this.pickupCode,
    required this.returnCode,
    required this.pickupDate,
    required this.returnDate,
    required this.countryOfResidence,
    required this.driverAge,
    required this.driverName,
    required this.pickupType,
    required this.returnType,
    this.carName,
    required this.totalPrice,
    required this.currencyCode,
    required this.payment,
  });

  factory CarOrderSummary.fromJson(Map<String, dynamic> json) {
    return CarOrderSummary(
      availabilityDetailsToken:
          (json['availability_details_token'] ?? '').toString(),
      pickUpDateTime: (json['pick_up_date_time'] ?? '').toString(),
      returnDateTime: (json['return_date_time'] ?? '').toString(),
      rentalCarBrand: (json['rental_car_brand'] ?? '').toString(),
      vehicle: CarRentalVehicle.fromJson(
        json['vehicle'] as Map<String, dynamic>? ?? {},
      ),
      locationDetails: (json['location_details'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => CarRentalLocationDetail.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      correlationId: (json['correlationId'] ?? '').toString(),
      availabilityToken: (json['availabilityToken'] ?? '').toString(),
      pickupCode: (json['pickup_code'] ?? '').toString(),
      returnCode: (json['return_code'] ?? '').toString(),
      pickupDate: (json['pickup_date'] ?? '').toString(),
      returnDate: (json['return_date'] ?? '').toString(),
      countryOfResidence: (json['countryOfResidence'] ?? '').toString(),
      driverAge: (json['driver_age'] as num?)?.toInt() ?? 0,
      driverName: (json['driver_name'] ?? '').toString(),
      pickupType: (json['pickup_type'] ?? '').toString(),
      returnType: (json['return_type'] ?? '').toString(),
      carName: json['car_name']?.toString(),
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      currencyCode: (json['currency_code'] ?? '').toString(),
      payment: HotelBookingPayment.fromJson(
        json['payment'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availability_details_token': availabilityDetailsToken,
      'pick_up_date_time': pickUpDateTime,
      'return_date_time': returnDateTime,
      'rental_car_brand': rentalCarBrand,
      'vehicle': vehicle.toJson(),
      'location_details': locationDetails.map((e) => e.toJson()).toList(),
      'correlationId': correlationId,
      'availabilityToken': availabilityToken,
      'pickup_code': pickupCode,
      'return_code': returnCode,
      'pickup_date': pickupDate,
      'return_date': returnDate,
      'countryOfResidence': countryOfResidence,
      'driver_age': driverAge,
      'driver_name': driverName,
      'pickup_type': pickupType,
      'return_type': returnType,
      'car_name': carName,
      'total_price': totalPrice,
      'currency_code': currencyCode,
      'payment': payment.toJson(),
    };
  }
}

// Flight Order Summary Model (checkout / booking confirmation)
class FlightOrderSummary {
  final List<FlightOrderFlight> flights;
  final double basePrice;
  final double taxAndFees;
  final double totalPrice;
  final List<FlightPassengerFare> passengerFare;
  final String currencyCode;
  final FlightOrderTripInfo tripInfo;
  final String cabinAvailabilityToken;
  final List<FlightOrderPassengerTypeQuantity> passengerTypeQuantity;
  final List<FlightOrderPenaltyInfo> penaltiesInfo;
  final String correlationId;
  final String cabinSearchSessionId;
  final List<FlightOrderTravelerInfo> travelerInfo;
  final FlightOrderContact contact;
  final HotelBookingPayment payment;

  FlightOrderSummary({
    required this.flights,
    required this.basePrice,
    required this.taxAndFees,
    required this.totalPrice,
    required this.passengerFare,
    required this.currencyCode,
    required this.tripInfo,
    required this.cabinAvailabilityToken,
    required this.passengerTypeQuantity,
    required this.penaltiesInfo,
    required this.correlationId,
    required this.cabinSearchSessionId,
    required this.travelerInfo,
    required this.contact,
    required this.payment,
  });

  factory FlightOrderSummary.fromJson(Map<String, dynamic> json) {
    return FlightOrderSummary(
      flights: (json['flights'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightOrderFlight.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      taxAndFees: (json['tax_and_fees'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      passengerFare: (json['passenger_fare'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightPassengerFare.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      currencyCode: (json['currency_code'] ?? '').toString(),
      tripInfo: FlightOrderTripInfo.fromJson(
        json['trip_info'] as Map<String, dynamic>? ?? {},
      ),
      cabinAvailabilityToken:
          (json['cabin_availability_token'] ?? '').toString(),
      passengerTypeQuantity:
          (json['passenger_type_quantity'] as List<dynamic>?)
                  ?.whereType<Map>()
                  .map(
                    (e) => FlightOrderPassengerTypeQuantity.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList() ??
              const [],
      penaltiesInfo: (json['penalties_info'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightOrderPenaltyInfo.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      correlationId:
          (json['correlationId'] ?? json['correlation_id'] ?? '').toString(),
      cabinSearchSessionId: (json['cabinSearchSessionId'] ??
              json['cabin_search_session_id'] ??
              '')
          .toString(),
      travelerInfo: (json['travelerInfo'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightOrderTravelerInfo.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      contact: FlightOrderContact.fromJson(
        json['contact'] as Map<String, dynamic>? ?? {},
      ),
      payment: HotelBookingPayment.fromJson(
        json['payment'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flights': flights.map((e) => e.toJson()).toList(),
      'base_price': basePrice,
      'tax_and_fees': taxAndFees,
      'total_price': totalPrice,
      'passenger_fare': passengerFare.map((e) => e.toJson()).toList(),
      'currency_code': currencyCode,
      'trip_info': tripInfo.toJson(),
      'cabin_availability_token': cabinAvailabilityToken,
      'passenger_type_quantity':
          passengerTypeQuantity.map((e) => e.toJson()).toList(),
      'penalties_info': penaltiesInfo.map((e) => e.toJson()).toList(),
      'correlationId': correlationId,
      'cabinSearchSessionId': cabinSearchSessionId,
      'travelerInfo': travelerInfo.map((e) => e.toJson()).toList(),
      'contact': contact.toJson(),
      'payment': payment.toJson(),
    };
  }
}

class FlightOrderFlight {
  final List<FlightOrderSegment> flightSegments;
  final String totalDuration;
  final List<String> stops;
  final List<FlightLayoverInfo> layovers;

  FlightOrderFlight({
    required this.flightSegments,
    required this.totalDuration,
    required this.stops,
    required this.layovers,
  });

  factory FlightOrderFlight.fromJson(Map<String, dynamic> json) {
    return FlightOrderFlight(
      flightSegments: (json['flight_segments'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightOrderSegment.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
      totalDuration: (json['total_duration'] ?? '').toString(),
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      layovers: (json['layovers'] as List<dynamic>?)
              ?.whereType<Map>()
              .map(
                (e) => FlightLayoverInfo.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flight_segments': flightSegments.map((e) => e.toJson()).toList(),
      'total_duration': totalDuration,
      'stops': stops,
      'layovers': layovers.map((e) => e.toJson()).toList(),
    };
  }
}

class FlightOrderSegment {
  final String airlineName;
  final String departureAirport;
  final String departureAirportName;
  final String departureDate;
  final String arrivalAirport;
  final String arrivalAirportName;
  final String arrivalDate;
  final String duration;
  final String cabin;
  final String cabinClassText;
  final String flightNumber;
  final String aircraft;
  final String airlineCode;
  final String operatedBy;
  final String airlineLogo;

  FlightOrderSegment({
    required this.airlineName,
    required this.departureAirport,
    required this.departureAirportName,
    required this.departureDate,
    required this.arrivalAirport,
    required this.arrivalAirportName,
    required this.arrivalDate,
    required this.duration,
    required this.cabin,
    required this.cabinClassText,
    required this.flightNumber,
    required this.aircraft,
    required this.airlineCode,
    required this.operatedBy,
    required this.airlineLogo,
  });

  factory FlightOrderSegment.fromJson(Map<String, dynamic> json) {
    return FlightOrderSegment(
      airlineName: (json['airline_name'] ?? '').toString(),
      departureAirport: (json['departure_airport'] ?? '').toString(),
      departureAirportName:
          (json['departure_airport_name'] ?? '').toString(),
      departureDate: (json['departure_date'] ?? '').toString(),
      arrivalAirport: (json['arrival_airport'] ?? '').toString(),
      arrivalAirportName: (json['arrival_airport_name'] ?? '').toString(),
      arrivalDate: (json['arrival_date'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      cabin: (json['cabin'] ?? '').toString(),
      cabinClassText: (json['cabin_class_text'] ?? '').toString(),
      flightNumber: (json['flight_number'] ?? '').toString(),
      aircraft: (json['aircraft'] ?? '').toString(),
      airlineCode: (json['airline_code'] ?? '').toString(),
      operatedBy: (json['operated_by'] ?? '').toString(),
      airlineLogo: (json['airline_logo'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airline_name': airlineName,
      'departure_airport': departureAirport,
      'departure_airport_name': departureAirportName,
      'departure_date': departureDate,
      'arrival_airport': arrivalAirport,
      'arrival_airport_name': arrivalAirportName,
      'arrival_date': arrivalDate,
      'duration': duration,
      'cabin': cabin,
      'cabin_class_text': cabinClassText,
      'flight_number': flightNumber,
      'aircraft': aircraft,
      'airline_code': airlineCode,
      'operated_by': operatedBy,
      'airline_logo': airlineLogo,
    };
  }
}

class FlightOrderTripInfo {
  final int totalTravellers;
  final String tripOrigin;
  final String tripDestination;
  final String travelDate;
  final String routeType;

  FlightOrderTripInfo({
    required this.totalTravellers,
    required this.tripOrigin,
    required this.tripDestination,
    required this.travelDate,
    required this.routeType,
  });

  factory FlightOrderTripInfo.fromJson(Map<String, dynamic> json) {
    return FlightOrderTripInfo(
      totalTravellers: (json['total_travellers'] as num?)?.toInt() ?? 0,
      tripOrigin: (json['trip_origin'] ?? '').toString(),
      tripDestination: (json['trip_destination'] ?? '').toString(),
      travelDate: (json['travel_date'] ?? '').toString(),
      routeType: (json['route_type'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_travellers': totalTravellers,
      'trip_origin': tripOrigin,
      'trip_destination': tripDestination,
      'travel_date': travelDate,
      'route_type': routeType,
    };
  }
}

class FlightOrderPassengerTypeQuantity {
  final String code;
  final int quantity;

  FlightOrderPassengerTypeQuantity({
    required this.code,
    required this.quantity,
  });

  factory FlightOrderPassengerTypeQuantity.fromJson(Map<String, dynamic> json) {
    return FlightOrderPassengerTypeQuantity(
      code: (json['code'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'quantity': quantity,
    };
  }
}

class FlightOrderPenaltyInfo {
  final String passengerType;
  final bool refundAllowed;
  final double refundPenaltyAmount;
  final bool changeAllowed;
  final double changePenaltyAmount;
  final String currency;

  FlightOrderPenaltyInfo({
    required this.passengerType,
    required this.refundAllowed,
    required this.refundPenaltyAmount,
    required this.changeAllowed,
    required this.changePenaltyAmount,
    required this.currency,
  });

  factory FlightOrderPenaltyInfo.fromJson(Map<String, dynamic> json) {
    return FlightOrderPenaltyInfo(
      passengerType: (json['passenger_type'] ?? '').toString(),
      refundAllowed: json['refund_allowed'] == true,
      refundPenaltyAmount:
          (json['refund_penalty_amount'] as num?)?.toDouble() ?? 0.0,
      changeAllowed: json['change_allowed'] == true,
      changePenaltyAmount:
          (json['change_penalty_amount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passenger_type': passengerType,
      'refund_allowed': refundAllowed,
      'refund_penalty_amount': refundPenaltyAmount,
      'change_allowed': changeAllowed,
      'change_penalty_amount': changePenaltyAmount,
      'currency': currency,
    };
  }
}

class FlightOrderTravelerInfo {
  final String gender;
  final String firstName;
  final String lastName;
  final String? nationalId;
  final String title;
  final String dateOfBirth;
  final String passengerNationality;
  final String type;
  final FlightOrderPassport? passport;

  FlightOrderTravelerInfo({
    required this.gender,
    required this.firstName,
    required this.lastName,
    this.nationalId,
    required this.title,
    required this.dateOfBirth,
    required this.passengerNationality,
    required this.type,
    this.passport,
  });

  factory FlightOrderTravelerInfo.fromJson(Map<String, dynamic> json) {
    final passportJson = json['passport'];
    return FlightOrderTravelerInfo(
      gender: (json['gender'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      nationalId: json['nationalId']?.toString(),
      title: (json['title'] ?? '').toString(),
      dateOfBirth: (json['dateOfBirth'] ?? '').toString(),
      passengerNationality: (json['passengerNationality'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      passport: passportJson is Map
          ? FlightOrderPassport.fromJson(
              Map<String, dynamic>.from(passportJson),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'firstName': firstName,
      'lastName': lastName,
      'nationalId': nationalId,
      'title': title,
      'dateOfBirth': dateOfBirth,
      'passengerNationality': passengerNationality,
      'type': type,
      if (passport != null) 'passport': passport!.toJson(),
    };
  }
}

class FlightOrderPassport {
  final String expiryDate;
  final String country;
  final String passportNumber;

  FlightOrderPassport({
    required this.expiryDate,
    required this.country,
    required this.passportNumber,
  });

  factory FlightOrderPassport.fromJson(Map<String, dynamic> json) {
    return FlightOrderPassport(
      expiryDate: (json['expiryDate'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      passportNumber: (json['passportNumber'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expiryDate': expiryDate,
      'country': country,
      'passportNumber': passportNumber,
    };
  }
}

class FlightOrderContact {
  final String email;
  final String phone;
  final String countryCode;
  final String phoneNumber;
  final String postCode;
  final String areaCode;

  FlightOrderContact({
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.phoneNumber,
    required this.postCode,
    required this.areaCode,
  });

  factory FlightOrderContact.fromJson(Map<String, dynamic> json) {
    return FlightOrderContact(
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      countryCode: (json['countryCode'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      postCode: (json['postCode'] ?? '').toString(),
      areaCode: (json['areaCode'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'postCode': postCode,
      'areaCode': areaCode,
    };
  }
}

class CarRentalLocationDetail {
  final bool atAirport;
  final String name;
  final String iataCode;
  final CarRentalLocationAddress address;

  CarRentalLocationDetail({
    required this.atAirport,
    required this.name,
    required this.iataCode,
    required this.address,
  });

  factory CarRentalLocationDetail.fromJson(Map<String, dynamic> json) {
    return CarRentalLocationDetail(
      atAirport: json['at_airport'] == true,
      name: (json['name'] ?? '').toString(),
      iataCode: (json['iata_code'] ?? '').toString(),
      address: CarRentalLocationAddress.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'at_airport': atAirport,
      'name': name,
      'iata_code': iataCode,
      'address': address.toJson(),
    };
  }
}

class CarRentalLocationAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  CarRentalLocationAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory CarRentalLocationAddress.fromJson(Map<String, dynamic> json) {
    return CarRentalLocationAddress(
      street: (json['street'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      postalCode: (json['postal_code'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
    };
  }
}

// LogoImages Model
class LogoImages {
  final String logoImageMobile;
  final String logoImageThumb;
  final String logoImageweb;
  final String logoMobileFilePath;
  final String profileimgeFilePath;
  final String twitterfilePath;
  final String opengraphfilePath;

  LogoImages({
    required this.logoImageMobile,
    required this.logoImageThumb,
    required this.logoImageweb,
    required this.logoMobileFilePath,
    required this.profileimgeFilePath,
    required this.twitterfilePath,
    required this.opengraphfilePath,
  });

  factory LogoImages.fromJson(Map<String, dynamic> json) {
    return LogoImages(
      logoImageMobile: json['logoImageMobile'] ?? '',
      logoImageThumb: json['logoImageThumb'] ?? '',
      logoImageweb: json['logoImageweb'] ?? '',
      logoMobileFilePath: json['logoMobileFilePath'] ?? '',
      profileimgeFilePath: json['profileimgeFilePath'] ?? '',
      twitterfilePath: json['twitterfilePath'] ?? '',
      opengraphfilePath: json['opengraphfilePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logoImageMobile': logoImageMobile,
      'logoImageThumb': logoImageThumb,
      'logoImageweb': logoImageweb,
      'logoMobileFilePath': logoMobileFilePath,
      'profileimgeFilePath': profileimgeFilePath,
      'twitterfilePath': twitterfilePath,
      'opengraphfilePath': opengraphfilePath,
    };
  }
}

// Address Model
class Address {
  final String addressLine1;
  final String addressLine2;
  final String addressArea;
  final String city;
  final String postCode;
  final String state;
  final String lat;
  final String long;
  final String address;
  final String country;
  final String googlePlaceName;
  final String areaOrDistrict;
  final String locality;

  Address({
    required this.addressLine1,
    required this.addressLine2,
    required this.addressArea,
    required this.city,
    required this.postCode,
    required this.state,
    required this.lat,
    required this.long,
    required this.address,
    required this.country,
    required this.googlePlaceName,
    required this.areaOrDistrict,
    required this.locality,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      addressArea: json['addressArea'] ?? '',
      city: json['city'] ?? '',
      postCode: json['postCode'] ?? '',
      state: json['state'] ?? '',
      lat: json['lat'] ?? '',
      long: json['long'] ?? '',
      address: json['address'] ?? '',
      country: json['country'] ?? '',
      googlePlaceName: json['googlePlaceName'] ?? '',
      areaOrDistrict: json['areaOrDistrict'] ?? '',
      locality: json['locality'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'addressArea': addressArea,
      'city': city,
      'postCode': postCode,
      'state': state,
      'lat': lat,
      'long': long,
      'address': address,
      'country': country,
      'googlePlaceName': googlePlaceName,
      'areaOrDistrict': areaOrDistrict,
      'locality': locality,
    };
  }
}

// Enum for Widget Types (updated)
enum WidgetType {
  options('options'),
  stores('stores'),
  seeMore('see_more'),
  products('products'),
  button('button'),
  input('input'),
  image('image'),
  text('text'),
  unknown('unknown');

  const WidgetType(this.value);
  final String value;

  static WidgetType fromString(String value) {
    return WidgetType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => WidgetType.unknown,
    );
  }
}

// Extension for ChatWidget to work with enum
extension ChatWidgetExtension on ChatWidget {
  WidgetType get widgetType => WidgetType.fromString(type);
}

// Helper extension for parsing JSON strings
extension JsonParsingExtension on String {
  ChatResponse toChatResponse() {
    final Map<String, dynamic> json = jsonDecode(this);
    return ChatResponse.fromJson(json);
  }
}

class FlightInfo {
  final String departureDate;
  final String origin;
  final String destination;

  FlightInfo({
    required this.departureDate,
    required this.origin,
    required this.destination,
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) {
    return FlightInfo(
      departureDate:
          (json['departureDate'] ?? json['departure_date'] ?? '').toString(),
      origin: (json['origin'] ?? '').toString(),
      destination: (json['destination'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departureDate': departureDate,
      'origin': origin,
      'destination': destination,
    };
  }
}

// See More Action Model for widget
class WidgetAction {
  final String buttonText;
  final String title;
  final String subtitle;
  final String storeCategoryId;
  final String keyword;
  final String? quantity;
  final String? productName;
  final String? currencySymbol;
  final num? productPrice;
  final String? address;
  final String? name;
  final String? productID;
  final String? storeId;
  final String? storeName;
  final String? paymentTypeText;
  final int? storeTypeId;
  final bool? storeIsOpen;
  final String? storeCategoryName;
  final String? orderId;
  final String? addOns;
  final int? storeListing;
  final int? hyperlocal;
  final int? companyType;
  final String? emoji;
  final String? serviceType;
  final num? bookingType;
  final bool? isScheduled;
  final String? serviceRequestedTime;
  final String? orderAmount;
  final String? currency;
  final String? bookingDate;
  final String? bookingTime;
  final num? partySize;
  final bool? isTableBooking;
  final String? sectionName;
  final String? image;
  final String? checkinDate;
  final String? checkoutDate;
  final num? lat;
  final num? lng;
  final String? countryOfResidence;
  final bool? isAsync;
  final List<Map<String, dynamic>>? occupancy;
  final List<Map<String, dynamic>>? sort;
  final String? pricingToken;
  final bool? isForPickup;
  final String? country;
  final String? pickupDate;
  final String? returnDate;
  final String? pickupType;
  final String? returnType;
  final String? pickupCode;
  final String? returnCode;
  final String? pickupGeo;
  final int? driverAge;
  final String? correlationId;
  // final String? sortPrice;
  final int? page;
  final int? limit;
  final String? booking_id;
  final bool? isCarBookingFlow;
  final bool? isHotelBookingFlow;
  final String? tripType;
  final String? routeType;
  final String? cabinType;
  final int? adults;
  final int? children;
  final int? infants;
  final List<FlightInfo>? flightInfo;

  WidgetAction({
    required this.buttonText,
    required this.title,
    required this.subtitle,
    required this.storeCategoryId,
    required this.keyword,
    this.quantity,
    this.productName,
    this.currencySymbol,
    this.productPrice,
    this.address,
    this.name,
    this.productID,
    this.storeId,
    this.storeName,
    this.paymentTypeText,
    this.storeTypeId,
    this.storeIsOpen,
    this.storeCategoryName,
    this.orderId,
    this.addOns,
    this.storeListing,
    this.hyperlocal,
    this.companyType,
    this.emoji,
    this.serviceType,
    this.bookingType,
    this.isScheduled,
    this.serviceRequestedTime,
    this.orderAmount,
    this.currency,
    this.bookingDate,
    this.bookingTime,
    this.partySize,
    this.isTableBooking,
    this.sectionName,
    this.image,
    this.checkinDate,
    this.checkoutDate,
    this.lat,
    this.lng,
    this.countryOfResidence,
    this.isAsync,
    this.occupancy,
    this.sort,
    this.pricingToken,
    this.isForPickup,
    this.country,
    this.pickupDate,
    this.returnDate,
    this.pickupType,
    this.returnType,
    this.pickupCode,
    this.returnCode,
    this.pickupGeo,
    this.driverAge,
    this.correlationId,
    // this.sortPrice,
    this.page,
    this.limit,
    this.booking_id,
    this.isCarBookingFlow,
    this.isHotelBookingFlow,
    this.tripType,
    this.routeType,
    this.cabinType,
    this.adults,
    this.children,
    this.infants,
    this.flightInfo,
  });

  factory WidgetAction.fromJson(Map<String, dynamic> json) {
    return WidgetAction(
      buttonText: (json['button_text'] ?? json['buttonText'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      storeCategoryId: (json['storecategoryid'] ?? json['storeCategoryId'] ?? '').toString(),
      keyword: (json['keyword'] ?? '').toString(),
      quantity: json['quantity']?.toString(),
      productName: json['productName']?.toString(),
      currencySymbol: '${json['currencySymbol']?.toString() ?? ''} ',
      productPrice: json['productPrice'] is num 
          ? json['productPrice'] 
          : json['productPrice'] is String 
              ? num.tryParse(json['productPrice']) 
              : null,
      address: json['address']?.toString(),
      name: json['name']?.toString(),
      productID: json['productID']?.toString(),
      storeId: json['storeId']?.toString(),
      storeName: json['storeName']?.toString(),
      paymentTypeText: json['paymentTypeText']?.toString(),
      storeTypeId: json['storeTypeId'] ?? -111,
        storeIsOpen: json['storeIsOpen'] ?? true,
        storeCategoryName: json['storeCategoryName']?.toString(),
        orderId: json['orderId']?.toString(),
        addOns: json['addOns']?.toString(),
        storeListing: json['storeListing'] ?? 111,
        hyperlocal: json['hyperlocal'] ?? 111,
        companyType: json['companyType'] ?? 111,
        emoji: json['emoji']?.toString(),
        serviceType: json['serviceType']?.toString(),
        bookingType: json['bookingType'] ?? 111,
        isScheduled: json['isScheduled'] ?? false,
        serviceRequestedTime: json['serviceRequestedTime']?.toString(),
        orderAmount: json['orderAmount']?.toString(),
        currency: json['currency']?.toString(),
        bookingDate: json['bookingDate']?.toString(),
        bookingTime: json['bookingTime']?.toString(),
        partySize: json['partySize'] ?? 111,
        isTableBooking: json['isTableBooking'] ?? false,
        sectionName: json['sectionName']?.toString(),
        image: json['image']?.toString(),
        checkinDate: json['checkinDate']?.toString(),
        checkoutDate: json['checkoutDate']?.toString(),
        lat: json['lat'] ?? 0.0,
        lng: json['lng'] ?? 0.0,
        countryOfResidence: json['countryOfResidence']?.toString(),
        isAsync: json['isAsync'] ?? false,
        occupancy: _parseMapList(json['occupancy']),
        sort: _parseMapList(json['sort']),
        pricingToken: json['pricingToken']?.toString(),
        isForPickup: json['isForPickup'] ?? false,
        country: json['country']?.toString(),
        pickupDate: json['pickup_date']?.toString(),
        returnDate: json['return_date']?.toString(),
        pickupType: json['pickup_type']?.toString(),
        returnType: json['return_type']?.toString(),
        pickupCode: json['pickup_code']?.toString(),
        returnCode: json['return_code']?.toString(),
        pickupGeo: json['pickup_geo']?.toString(),
        driverAge: json['driver_age'] ?? 0,
        correlationId: json['correlationId']?.toString(),
        // sortPrice: json['sort']?.toString(),
        page: json['page'] ?? 1,
        limit: json['limit'] ?? 50,
        booking_id: json['booking_id']?.toString(),
        isCarBookingFlow: json['is_car_booking_flow'] ?? false,
        isHotelBookingFlow: json['is_hotel_booking_flow'] ?? false,
        tripType: json['trip_type']?.toString() ?? json['tripType']?.toString(),
        routeType: json['routeType']?.toString() ?? json['route_type']?.toString(),
        cabinType: json['cabinType']?.toString() ?? json['cabin_type']?.toString(),
        adults: json['adults'] ?? 0,
        children: json['children'] ?? 0,
        infants: json['infants'] ?? 0,
        flightInfo: _parseFlightInfoList(json['flightInfo'] ?? json['flight_info']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'button_text': buttonText,
      'title': title,
      'subtitle': subtitle,
      'storecategoryid': storeCategoryId,
      'keyword': keyword,
      'quantity': quantity,
      'productName': productName,
      'currencySymbol': currencySymbol,
      'productPrice': productPrice,
      'address': address,
      'name': name,
      'productID': productID,
      'storeId': storeId,
      'storeName': storeName,
      'paymentTypeText': paymentTypeText,
      'storeTypeId': storeTypeId,
      'storeIsOpen': storeIsOpen,
      'storeCategoryName': storeCategoryName,
      'orderId': orderId,
      'addOns': addOns,
      'storeListing': storeListing,
      'hyperlocal': hyperlocal,
      'companyType': companyType,
      'storeCategoryId': storeCategoryId,
      'emoji': emoji,
      'serviceType': serviceType,
      'bookingType': bookingType,
      'isScheduled': isScheduled,
      'serviceRequestedTime': serviceRequestedTime,
      'orderAmount': orderAmount,
      'currency': currency,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'partySize': partySize,
      'isTableBooking': isTableBooking,
      'sectionName': sectionName,
      'image': image,
      'checkinDate': checkinDate,
      'checkoutDate': checkoutDate,
      'lat': lat,
      'lng': lng,
      'countryOfResidence': countryOfResidence,
      'isAsync': isAsync,
      'occupancy': occupancy,
      'sort': sort,
      'pricingToken': pricingToken,
      'isForPickup': isForPickup,
      'country': country,
      'pickupDate': pickupDate,
      'returnDate': returnDate,
      'pickupType': pickupType,
      'returnType': returnType,
      'pickupCode': pickupCode,
      'returnCode': returnCode,
      'pickupGeo': pickupGeo,
      'driverAge': driverAge,
      'correlationId': correlationId,
      // 'sortPrice': sortPrice,
      'page': page,
      'limit': limit,
      'booking_id': booking_id,
      'isCarBookingFlow': isCarBookingFlow,
      'isHotelBookingFlow': isHotelBookingFlow,
      'tripType': tripType,
      'routeType': routeType,
      'cabinType': cabinType,
      'adults': adults,
      'children': children,
      'infants': infants,
      'flightInfo': flightInfo?.map((e) => e.toJson()).toList(),
    };
  }
}

List<FlightInfo>? _parseFlightInfoList(dynamic value) {
  if (value is! List) return null;

  final parsed = value
      .whereType<Map>()
      .map((e) => FlightInfo.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  return parsed.isEmpty ? null : parsed;
}

List<Map<String, dynamic>>? _parseMapList(dynamic value) {
  if (value is! List) return null;

  final parsed = value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();

  return parsed.isEmpty ? null : parsed;
}

double _parseDistanceKm(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(value);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 0.0;
    }
  }
  return 0.0;
}