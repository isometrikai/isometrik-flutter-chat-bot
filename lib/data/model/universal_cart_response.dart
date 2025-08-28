import 'dart:convert';
import 'chat_response.dart';

class UniversalCartResponse {
  final String message;
  final List<UniversalCartData> data;

  UniversalCartResponse({
    required this.message,
    required this.data,
  });

  factory UniversalCartResponse.fromJson(Map<String, dynamic> json) {
    return UniversalCartResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => UniversalCartData.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  /// Convert universal cart data to WidgetAction format for compatibility
  List<WidgetAction> toWidgetActions() {
    List<WidgetAction> widgetActions = [];
    
    if (data.isNotEmpty) {
      final cartData = data.first;
      final seller = cartData.sellers.isNotEmpty ? cartData.sellers.first : null;
      
      // Store info is handled separately in the cart screen, not as a cart item
      
      // Extract actual cart items from seller products
      if (seller != null && seller.products.isNotEmpty) {
        for (final product in seller.products) {
          // Get quantity from product.quantity or fallback
          int totalQuantity = 1;
          if (product.quantity != null) {
            totalQuantity = product.quantity?.value ?? 1;
          }
          
          // Get unit price with tax from accounting
          double unitPrice = 0;
          if (product.accounting != null) {
            unitPrice = product.accounting!.unitPriceWithTax;
          }
          
          // Get product name
          String productName = product.name ?? 'Unknown Product';
          
          widgetActions.add(WidgetAction(
            buttonText: '',
            title: '',
            subtitle: '',
            storeCategoryId: cartData.storeCategoryId,
            keyword: '',
            quantity: '${totalQuantity}x',
            productName: productName,
            currencySymbol: cartData.currencySymbol,
            productPrice: unitPrice,
          ));
        }
      }
      
      // Add delivery fee from cart accounting
      double deliveryFee = 0;
      if (cartData.accounting != null) {
        deliveryFee = cartData.accounting!.deliveryFee;
      }
      
      if (deliveryFee > 0) {
        widgetActions.add(WidgetAction(
          buttonText: '',
          title: '',
          subtitle: '',
          storeCategoryId: cartData.storeCategoryId,
          keyword: '',
          productName: 'Delivery fee',
          currencySymbol: cartData.currencySymbol,
          productPrice: deliveryFee,
        ));
      }
      
      // Add total from cart accounting
      double finalTotal = 0;
      if (cartData.accounting != null) {
        finalTotal = cartData.accounting!.finalTotal;
      }
      
      widgetActions.add(WidgetAction(
        buttonText: '',
        title: '',
        subtitle: '',
        storeCategoryId: cartData.storeCategoryId,
        keyword: '',
        productName: 'Total To Pay',
        currencySymbol: cartData.currencySymbol,
        productPrice: finalTotal,
      ));
    }
    
    return widgetActions;
  }
}

class UniversalCartData {
  final String id;
  final String parentCartId;
  final String categoryId;
  final String storeSubCategoryId;
  final String deliveryAddressId;
  final String pickUpAddressId;
  final String sessionId;
  final String storeCategoryId;
  final String storeCategory;
  final String storeSubCategory;
  final bool hyperlocal;
  final int storeListing;
  final bool ecommerce;
  final int storeTypeId;
  final String storeType;
  final int cartType;
  final String cartTypeInTxt;
  final int typeOfCart;
  final String typeOfCartInTxt;
  final String currencyCode;
  final String currencySymbol;
  final String userTypeMsg;
  final int userType;
  final int orderType;
  final int customerPaymentType;
  final int deliveryFeePayBy;
  final int numberOfBags;
  final String activezAinChatId;
  final List<String> zAinChatIds;
  final int budget;
  final bool negotiation;
  final String vehicleTypeId;
  final String vehicleTypeName;
  final int visitFee;
  final List<Seller> sellers;
  final Accounting? accounting;

  UniversalCartData({
    required this.id,
    required this.parentCartId,
    required this.categoryId,
    required this.storeSubCategoryId,
    required this.deliveryAddressId,
    required this.pickUpAddressId,
    required this.sessionId,
    required this.storeCategoryId,
    required this.storeCategory,
    required this.storeSubCategory,
    required this.hyperlocal,
    required this.storeListing,
    required this.ecommerce,
    required this.storeTypeId,
    required this.storeType,
    required this.cartType,
    required this.cartTypeInTxt,
    required this.typeOfCart,
    required this.typeOfCartInTxt,
    required this.currencyCode,
    required this.currencySymbol,
    required this.userTypeMsg,
    required this.userType,
    required this.orderType,
    required this.customerPaymentType,
    required this.deliveryFeePayBy,
    required this.numberOfBags,
    required this.activezAinChatId,
    required this.zAinChatIds,
    required this.budget,
    required this.negotiation,
    required this.vehicleTypeId,
    required this.vehicleTypeName,
    required this.visitFee,
    required this.sellers,
    this.accounting,
  });

  factory UniversalCartData.fromJson(Map<String, dynamic> json) {
    return UniversalCartData(
      id: json['_id'] ?? '',
      parentCartId: json['parentCartId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      storeSubCategoryId: json['storeSubCategoryId'] ?? '',
      deliveryAddressId: json['deliveryAddressId'] ?? '',
      pickUpAddressId: json['pickUpAddressId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      storeCategoryId: json['storeCategoryId'] ?? '',
      storeCategory: json['storeCategory'] ?? '',
      storeSubCategory: json['storeSubCategory'] ?? '',
      hyperlocal: json['hyperlocal'] ?? false,
      storeListing: json['storeListing'] ?? 0,
      ecommerce: json['ecommerce'] ?? false,
      storeTypeId: json['storeTypeId'] ?? 0,
      storeType: json['storeType'] ?? '',
      cartType: json['cartType'] ?? 0,
      cartTypeInTxt: json['cartTypeInTxt'] ?? '',
      typeOfCart: json['typeOfCart'] ?? 0,
      typeOfCartInTxt: json['typeOfCartInTxt'] ?? '',
      currencyCode: json['currencyCode'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
      userTypeMsg: json['userTypeMsg'] ?? '',
      userType: json['userType'] ?? 0,
      orderType: json['orderType'] ?? 0,
      customerPaymentType: json['customerPaymentType'] ?? 0,
      deliveryFeePayBy: json['deliveryFeePayBy'] ?? 0,
      numberOfBags: json['numberOfBags'] ?? 0,
      activezAinChatId: json['activezAinChatId'] ?? '',
      zAinChatIds: (json['zAinChatIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      budget: json['budget'] ?? 0,
      negotiation: json['negotiation'] ?? false,
      vehicleTypeId: json['vehicleTypeId'] ?? '',
      vehicleTypeName: json['vehicleTypeName'] ?? '',
      visitFee: json['visitFee'] ?? 0,
      sellers: (json['sellers'] as List<dynamic>?)
          ?.map((e) => Seller.fromJson(e))
          .toList() ?? [],
      accounting: json['accounting'] != null ? Accounting.fromJson(json['accounting']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'parentCartId': parentCartId,
      'categoryId': categoryId,
      'storeSubCategoryId': storeSubCategoryId,
      'deliveryAddressId': deliveryAddressId,
      'pickUpAddressId': pickUpAddressId,
      'sessionId': sessionId,
      'storeCategoryId': storeCategoryId,
      'storeCategory': storeCategory,
      'storeSubCategory': storeSubCategory,
      'hyperlocal': hyperlocal,
      'storeListing': storeListing,
      'ecommerce': ecommerce,
      'storeTypeId': storeTypeId,
      'storeType': storeType,
      'cartType': cartType,
      'cartTypeInTxt': cartTypeInTxt,
      'typeOfCart': typeOfCart,
      'typeOfCartInTxt': typeOfCartInTxt,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'userTypeMsg': userTypeMsg,
      'userType': userType,
      'orderType': orderType,
      'customerPaymentType': customerPaymentType,
      'deliveryFeePayBy': deliveryFeePayBy,
      'numberOfBags': numberOfBags,
      'activezAinChatId': activezAinChatId,
      'zAinChatIds': zAinChatIds,
      'budget': budget,
      'negotiation': negotiation,
      'vehicleTypeId': vehicleTypeId,
      'vehicleTypeName': vehicleTypeName,
      'visitFee': visitFee,
      'sellers': sellers.map((e) => e.toJson()).toList(),
      'accounting': accounting?.toJson(),
    };
  }
}

class Seller {
  final String fullfilledBy;
  final String fullFillMentCenterId;
  final bool isInventoryCheck;
  final Logo logo;
  final String name;
  final String storeAliasName;
  final String storeShopifyId;
  final bool shopifyEnable;
  final String contactPersonName;
  final String contactPersonEmail;
  final String phone;
  // final int targetAmtForFreeDelivery;
  // final int minOrder;
  final int storeFrontTypeId;
  final String storeFrontType;
  final int sellerTypeId;
  final String sellerType;
  final int storeTypeId;
  final String storeType;
  final String cityName;
  final String cityId;
  final String areaName;
  final int supportedOrderTypes;
  final int driverTypeId;
  final String driverType;
  final String storeBusinessUserId;
  final bool autoDispatch;
  final bool autoAcceptOrders;
  final bool allowSellerShipToBuyer;
  final bool allowSellerBillingToBuyer;
  final int totalProductWeightInKG;
  final bool storeIsOpen;
  final List<Product> products;

  Seller({
    required this.fullfilledBy,
    required this.fullFillMentCenterId,
    required this.isInventoryCheck,
    required this.logo,
    required this.name,
    required this.storeAliasName,
    required this.storeShopifyId,
    required this.shopifyEnable,
    required this.contactPersonName,
    required this.contactPersonEmail,
    required this.phone,
    // required this.targetAmtForFreeDelivery,
    // required this.minOrder,
    required this.storeFrontTypeId,
    required this.storeFrontType,
    required this.sellerTypeId,
    required this.sellerType,
    required this.storeTypeId,
    required this.storeType,
    required this.cityName,
    required this.cityId,
    required this.areaName,
    required this.supportedOrderTypes,
    required this.driverTypeId,
    required this.driverType,
    required this.storeBusinessUserId,
    required this.autoDispatch,
    required this.autoAcceptOrders,
    required this.allowSellerShipToBuyer,
    required this.allowSellerBillingToBuyer,
    required this.totalProductWeightInKG,
    required this.storeIsOpen,
    required this.products,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      fullfilledBy: json['fullfilledBy'] ?? '',
      fullFillMentCenterId: json['fullFillMentCenterId'] ?? '',
      isInventoryCheck: json['isInventoryCheck'] ?? false,
      logo: Logo.fromJson(json['logo'] ?? {}),
      name: json['name'] ?? '',
      storeAliasName: json['storeAliasName'] ?? '',
      storeShopifyId: json['storeShopifyId'] ?? '',
      shopifyEnable: json['shopifyEnable'] ?? false,
      contactPersonName: json['contactPersonName'] ?? '',
      contactPersonEmail: json['contactPersonEmail'] ?? '',
      phone: json['phone'] ?? '',
      // targetAmtForFreeDelivery: json['targetAmtForFreeDelivery'] ?? 0,
      // minOrder: json['minOrder'] ?? 0,
      storeFrontTypeId: json['storeFrontTypeId'] ?? 0,
      storeFrontType: json['storeFrontType'] ?? '',
      sellerTypeId: json['sellerTypeId'] ?? 0,
      sellerType: json['sellerType'] ?? '',
      storeTypeId: json['storeTypeId'] ?? 0,
      storeType: json['storeType'] ?? '',
      cityName: json['cityName'] ?? '',
      cityId: json['cityId'] ?? '',
      areaName: json['areaName'] ?? '',
      supportedOrderTypes: json['supportedOrderTypes'] ?? 0,
      driverTypeId: json['driverTypeId'] ?? 0,
      driverType: json['driverType'] ?? '',
      storeBusinessUserId: json['storeBusinessUserId'] ?? '',
      autoDispatch: json['autoDispatch'] ?? false,
      autoAcceptOrders: json['autoAcceptOrders'] ?? false,
      allowSellerShipToBuyer: json['allowSellerShipToBuyer'] ?? false,
      allowSellerBillingToBuyer: json['allowSellerBillingToBuyer'] ?? false,
      totalProductWeightInKG: json['totalProductWeightInKG'] ?? 0,
      storeIsOpen: json['storeIsOpen'] ?? false,
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullfilledBy': fullfilledBy,
      'fullFillMentCenterId': fullFillMentCenterId,
      'isInventoryCheck': isInventoryCheck,
      'logo': logo.toJson(),
      'name': name,
      'storeAliasName': storeAliasName,
      'storeShopifyId': storeShopifyId,
      'shopifyEnable': shopifyEnable,
      'contactPersonName': contactPersonName,
      'contactPersonEmail': contactPersonEmail,
      'phone': phone,
      // 'targetAmtForFreeDelivery': targetAmtForFreeDelivery,
      // 'minOrder': minOrder,
      'storeFrontTypeId': storeFrontTypeId,
      'storeFrontType': storeFrontType,
      'sellerTypeId': sellerTypeId,
      'sellerType': sellerType,
      'storeTypeId': storeTypeId,
      'storeType': storeType,
      'cityName': cityName,
      'cityId': cityId,
      'areaName': areaName,
      'supportedOrderTypes': supportedOrderTypes,
      'driverTypeId': driverTypeId,
      'driverType': driverType,
      'storeBusinessUserId': storeBusinessUserId,
      'autoDispatch': autoDispatch,
      'autoAcceptOrders': autoAcceptOrders,
      'allowSellerShipToBuyer': allowSellerShipToBuyer,
      'allowSellerBillingToBuyer': allowSellerBillingToBuyer,
      'totalProductWeightInKG': totalProductWeightInKG,
      'storeIsOpen': storeIsOpen,
      'products': products.map((e) => e.toJson()).toList(),
    };
  }
}

class Logo {
  final String logoImageMobile;
  final String logoImageThumb;
  final String logoImageweb;
  final String logoMobileFilePath;
  final String profileimgeFilePath;
  final String twitterfilePath;
  final String opengraphfilePath;

  Logo({
    required this.logoImageMobile,
    required this.logoImageThumb,
    required this.logoImageweb,
    required this.logoMobileFilePath,
    required this.profileimgeFilePath,
    required this.twitterfilePath,
    required this.opengraphfilePath,
  });

  factory Logo.fromJson(Map<String, dynamic> json) {
    return Logo(
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

class Quantity {
  final int value;
  final String unit;

  Quantity({
    required this.value,
    required this.unit,
  });

  factory Quantity.fromJson(Map<String, dynamic> json) {
    return Quantity(
      value: json['value'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}

class Product {
  final String id;
  final String name;
  final Accounting? accounting;
  final Quantity? quantity;

  Product({
    required this.id,
    required this.name,
    required this.accounting,
    this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      accounting: json['accounting'] != null ? Accounting.fromJson(json['accounting']) : null,
      quantity: json['quantity'] != null ? Quantity.fromJson(json['quantity']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'accounting': accounting?.toJson(),
      'quantity': quantity?.toJson(),
    };
  }
}

class Accounting {
  final int totalQuantity;
  final double unitPriceWithTax;
  final double finalTotal;
  final double deliveryFee;

  Accounting({
    required this.totalQuantity,
    required this.unitPriceWithTax,
    required this.finalTotal,
    required this.deliveryFee,
  });

  factory Accounting.fromJson(Map<String, dynamic> json) {
    return Accounting(
      totalQuantity: json['totalQuantity'] ?? 0,
      unitPriceWithTax: json['unitPriceWithTax']?.toDouble() ?? 0,
      finalTotal: json['finalTotal']?.toDouble() ?? 0,
      deliveryFee: json['deliveryFee']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuantity': totalQuantity,
      'unitPriceWithTax': unitPriceWithTax,
      'finalTotal': finalTotal,
      'deliveryFee': deliveryFee,
    };
  }
}
