import 'package:chat_bot/data/model/chat_response.dart';

class RestaurantMenuResponse {
  final String message;
  final RestaurantMenuData data;

  RestaurantMenuResponse({
    required this.message,
    required this.data,
  });

  factory RestaurantMenuResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantMenuResponse(
      message: json['message'] ?? '',
      data: RestaurantMenuData.fromJson(json['data'] ?? {}),
    );
  }
}

class RestaurantMenuData {
  final StoreData storeData;
  final List<ProductCategory> productData;

  RestaurantMenuData({
    required this.storeData,
    required this.productData,
  });

  factory RestaurantMenuData.fromJson(Map<String, dynamic> json) {
    return RestaurantMenuData(
      storeData: StoreData.fromJson(json['storeData'] ?? {}),
      productData: (json['productData'] as List<dynamic>?)
          ?.map((item) => ProductCategory.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class StoreData {
  final String storeId;
  final String storeName;
  final String address;
  final String cuisines;
  final double avgRating;
  final bool storeIsOpen;

  StoreData({
    required this.storeId,
    required this.storeName,
    required this.address,
    required this.cuisines,
    required this.avgRating,
    required this.storeIsOpen,
  });

  factory StoreData.fromJson(Map<String, dynamic> json) {
    return StoreData(
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      address: json['address'] ?? '',
      cuisines: json['cuisines'] ?? '',
      avgRating: (json['avgRating'] ?? 0.0).toDouble(),
      storeIsOpen: json['storeIsOpen'] ?? false,
    );
  }
}

class ProductCategory {
  final String catName;
  final bool isSubCategories;
  final List<SubCategory> subCategories;
  final List<Product> products; // Added direct products support
  final int seqId;

  ProductCategory({
    required this.catName,
    required this.isSubCategories,
    required this.subCategories,
    required this.products, // Added direct products
    required this.seqId,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      catName: json['catName'] ?? '',
      isSubCategories: json['isSubCategories'] ?? false,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((item) => SubCategory.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      products: (json['products'] as List<dynamic>?) // Added direct products parsing
          ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      seqId: json['seqId'] ?? 0,
    );
  }
}

class SubCategory {
  final String name;
  final int penCount;
  final List<Product> products;

  SubCategory({
    required this.name,
    required this.penCount,
    required this.products,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      name: json['name'] ?? '',
      penCount: json['penCount'] ?? 0,
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

// class RestaurantProduct {
//   final String parentProductId;
//   final String childProductId;
//   final PriceList finalPriceList;
//   final bool addOnsCount;
//   final String productName;
//   final dynamic images; // Can be String, List, or null
//   final bool containsMeat;
//   final String currencySymbol;
//   final String currency;
//   final bool customizable;
//   final bool productStatus;

//   RestaurantProduct({
//     required this.parentProductId,
//     required this.childProductId,
//     required this.finalPriceList,
//     required this.addOnsCount,
//     required this.productName,
//     required this.images,
//     required this.containsMeat,
//     required this.currencySymbol,
//     required this.currency,
//     required this.customizable,
//     required this.productStatus,
//   });

//   factory RestaurantProduct.fromJson(Map<String, dynamic> json) {
//     return RestaurantProduct(
//       parentProductId: json['parentProductId'] ?? '',
//       childProductId: json['childProductId'] ?? '',
//       finalPriceList: PriceList.fromJson(json['finalPriceList'] ?? {}),
//       addOnsCount: json['addOnsCount'] ?? false,
//       productName: json['productName'] ?? '',
//       images: json['images'],
//       containsMeat: json['containsMeat'] ?? false,
//       currencySymbol: json['currencySymbol'] ?? '',
//       currency: json['currency'] ?? '',
//       customizable: json['Customizable'] ?? false,
//       productStatus: json['productStatus'] ?? false,
//     );
//   }
// }

class PriceList {
  final double basePrice;
  final double finalPrice;
  final int discountType;
  final double discountPrice;

  PriceList({
    required this.basePrice,
    required this.finalPrice,
    required this.discountType,
    required this.discountPrice,
  });

  factory PriceList.fromJson(Map<String, dynamic> json) {
    return PriceList(
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 0,
      discountPrice: (json['discountPrice'] ?? 0).toDouble(),
    );
  }
}
