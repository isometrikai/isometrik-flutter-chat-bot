import 'dart:convert';

// Main Chat Response Model
class ChatResponse {
  final String response;
  final String requestId;
  final List<ChatWidget> widgets;

  ChatResponse({
    required this.response,
    required this.requestId,
    required this.widgets,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] ?? '',
      requestId: json['request_id'] ?? '',
      widgets: (json['widgets'] as List<dynamic>?)
          ?.map((item) => ChatWidget.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'request_id': requestId,
      'widgets': widgets.map((widget) => widget.toJson()).toList(),
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

  @override
  String toString() {
    return 'ChatResponse(response: $response, requestId: $requestId, widgets: ${widgets.length})';
  }
}

// Chat Widget Model
class ChatWidget {
  final int widgetId;
  final int widgetsType;
  final String type;
  final List<dynamic> widget; // Changed from List<String> to List<dynamic>

  ChatWidget({
    required this.widgetId,
    required this.widgetsType,
    required this.type,
    required this.widget,
  });

  factory ChatWidget.fromJson(Map<String, dynamic> json) {
    return ChatWidget(
      widgetId: json['widgetId'] ?? 0,
      widgetsType: json['widgets_type'] ?? 0,
      type: json['type'] ?? '',
      widget: (json['widget'] as List<dynamic>?) ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'widgetId': widgetId,
      'widgets_type': widgetsType,
      'type': type,
      'widget': widget,
    };
  }

  // Helper methods for different widget types
  bool get isOptionsWidget => type == 'options';
  bool get isStoresWidget => type == 'stores';
  bool get isProductsWidget => type == 'products';
  bool get isButtonWidget => type == 'button';
  bool get isInputWidget => type == 'input';
  bool get isImageWidget => type == 'image';
  bool get isTextWidget => type == 'text';

  // Get options for options widget
  List<String> get options => isOptionsWidget 
      ? widget.map((e) => e.toString()).toList() 
      : [];

  // Get stores for stores widget
  List<Store> get stores => isStoresWidget 
      ? widget.map((e) => Store.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get products for products widget
  List<Product> get products => isProductsWidget 
      ? widget.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList()
      : [];

  // Get first option (useful for single selection)
  String? get firstOption => widget.isNotEmpty ? widget.first.toString() : null;

  @override
  String toString() {
    return 'ChatWidget(id: $widgetId, type: $type, items: ${widget.length})';
  }
}

// Product Model for products widget
class Product {
  final String id;
  final String productId;
  final String productName;
  final double finalPrice;
  final bool inStock;
  final int tag;
  final FinalPriceList finalPriceList;
  final Map<String, dynamic> offers;
  final String productImage;
  final double averageRating;
  final String currencySymbol;
  final String currency;
  final String url;
  final String store;
  final String storeId;

  Product({
    required this.id,
    required this.productId,
    required this.productName,
    required this.finalPrice,
    required this.inStock,
    required this.tag,
    required this.finalPriceList,
    required this.offers,
    required this.productImage,
    required this.averageRating,
    required this.currencySymbol,
    required this.currency,
    required this.url,
    required this.store,
    required this.storeId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      inStock: json['inStock'] ?? false,
      tag: json['tag'] ?? 0,
      finalPriceList: FinalPriceList.fromJson(json['finalPriceList'] ?? {}),
      offers: json['offers'] ?? {},
      productImage: json['product_image'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      currencySymbol: json['currencySymbol'] ?? '',
      currency: json['currency'] ?? '',
      url: json['url'] ?? '',
      store: json['store'] ?? '',
      storeId: json['storeId'] ?? '',
    );
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
}

// Store Model for stores widget
class Store {
  final String id;
  final String storename;
  final double avgRating;
  final bool storeIsOpen;
  final String storeTag;
  final LogoImages logoImages;
  final bool isTempClose;
  final Address address;
  final String cuisineDetails;
  final String storeImage;
  final double distanceKm;
  final double distanceMiles;
  final bool tableReservations;
  final int supportedOrderTypes;
  final int averageCostForMealForTwo;
  final String currencyCode;
  final String currencySymbol;

  Store({
    required this.id,
    required this.storename,
    required this.avgRating,
    required this.storeIsOpen,
    required this.storeTag,
    required this.logoImages,
    required this.isTempClose,
    required this.address,
    required this.cuisineDetails,
    required this.storeImage,
    required this.distanceKm,
    required this.distanceMiles,
    required this.tableReservations,
    required this.supportedOrderTypes,
    required this.averageCostForMealForTwo,
    required this.currencyCode,
    required this.currencySymbol,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      storename: json['storename'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      storeIsOpen: json['store_is_open'] ?? false,
      storeTag: json['store_tag'] ?? '',
      logoImages: LogoImages.fromJson(json['logoImages'] ?? {}),
      isTempClose: json['is_temp_close'] ?? false,
      address: Address.fromJson(json['address'] ?? {}),
      cuisineDetails: json['cuisineDetails'] ?? '',
      storeImage: json['storeImage'] ?? '',
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      distanceMiles: (json['distance_miles'] ?? 0).toDouble(),
      tableReservations: json['tableReservations'] ?? false,
      supportedOrderTypes: json['supportedOrderTypes'] ?? 0,
      averageCostForMealForTwo: json['averageCostForMealForTwo'] ?? 0,
      currencyCode: json['currencyCode'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
    );
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
}

// Enum for Widget Types (updated)
enum WidgetType {
  options('options'),
  stores('stores'),
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
