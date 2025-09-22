import 'dart:convert';

import '../../utils/enum.dart';
import '../../widgets/choose_address_widget.dart';
import '../../widgets/choose_card_widget.dart';

// Main Chat Response Model
class ChatResponse {
  final String text;
  final String requestId;
  final List<ChatWidget> widgets;
  final int? cartCount;

  ChatResponse({
    required this.text,
    required this.requestId,
    required this.widgets,
    this.cartCount,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'request_id': requestId,
      'widgets': widgets.map((widget) => widget.toJson()).toList(),
      'cartCount': cartCount,
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
  final List<dynamic> widget; // Raw JSON data

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
  bool get isOptionsWidget => type == WidgetEnum.options.value;
  bool get isStoresWidget => type == WidgetEnum.stores.value;
  bool get isProductsWidget => type == WidgetEnum.products.value;
  bool get isSeeMoreWidget => type == WidgetEnum.see_more.value;
  bool get isMenuWidget => type == WidgetEnum.menu.value;
  bool get isCartWidget => type == WidgetEnum.cart.value;
  bool get isChooseAddressWidget => type == WidgetEnum.choose_address.value;
  bool get isChooseCardWidget => type == WidgetEnum.choose_card.value;
  bool get isAddAddressWidget => type == WidgetEnum.add_address.value;
  bool get isAddPaymentWidget => type == WidgetEnum.add_payment.value;
  bool get isOrderSummaryWidget => type == WidgetEnum.order_summary.value;
  bool get isOrderConfirmedWidget => type == WidgetEnum.order_confirmed.value;
  bool get isOrderTrackingWidget => type == WidgetEnum.order_tracking.value;
  bool get isOrderDetailsWidget => type == WidgetEnum.order_details.value;
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
  final bool? variantCount;// For Grocery Only

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
      customizable: json['customizable'] ?? false,
      storeCategoryId: json['storeCategoryId']?.toString() ?? '',
      storeTypeId: json['storeTypeId'] ?? -111,
      storeId: json['storeId']?.toString() ?? '',
        storeIsOpen: json['storeIsOpen'] ?? true,
        instock: json['instock'] ?? true,
        variantCount: json['variantCount'] ?? false,
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
      'customizable': customizable,
      'storeCategoryId': storeCategoryId,
      'storeTypeId': storeTypeId,
      'storeId': storeId,
      'storeIsOpen': storeIsOpen,
      'instock': instock,
      'variantCount': variantCount,
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
  final bool isDoctored;
  final bool storeListing;
  final bool hyperlocal;
  final List<Product> products;
  final int? storeTypeId;
  final bool storeIsOpen;
  final num supportedOrderTypes;
  final bool tableReservations;

  Store({
    required this.storename,
    required this.avgRating,
    required this.cuisineDetails,
    required this.storeImage,
    required this.distance,
    required this.storeId,
    required this.storeCategoryId,
    required this.products,
    required this.linkFromId,
    required this.type,
    required this.isDoctored,
    required this.storeListing,
    required this.hyperlocal,
    this.storeTypeId,
    required this.storeIsOpen,
    required this.supportedOrderTypes,
    required this.tableReservations,
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
    final bool isDoctored = (json['isDoctored'] ?? false);
    final bool storeListing = (json['storeListing'] ?? false);
    final bool hyperlocal = (json['hyperlocal'] ?? false);
    final int storeTypeId = (json['storeTypeId'] ?? 0);
    final bool storeIsOpen = (json['storeIsOpen'] ?? false);
    final int supportedOrderTypes = (json['supportedOrderTypes'] ?? 0);
    final bool tableReservations = (json['tableReservations'] ?? false);
    final List<Product> parsedProducts = (json['products'] as List<dynamic>? ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return Store(
      storename: name,
      avgRating: rating,
      cuisineDetails: (json['cuisineDetails'] ?? (json['categorylist']?.join(', ') ?? '')).toString(),
      storeImage: image,
      distance: distance,
      storeId: storeId,
      storeCategoryId: storeCategoryId,
      products: parsedProducts,
      linkFromId: linkFromId,
      type: type,
      isDoctored: isDoctored,
      storeListing: storeListing,
      hyperlocal: hyperlocal,
      storeTypeId: storeTypeId,
      storeIsOpen: storeIsOpen,
      supportedOrderTypes: supportedOrderTypes,
      tableReservations: tableReservations,
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
      'storeIsOpen': storeIsOpen,
      'storeTypeId': storeTypeId,
      'supportedOrderTypes': supportedOrderTypes,
      'tableReservations': tableReservations,
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
      currencySymbol: json['currencySymbol']?.toString(),
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
    };
  }
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