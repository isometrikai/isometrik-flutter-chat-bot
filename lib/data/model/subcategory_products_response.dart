import 'package:chat_bot/data/model/chat_response.dart';

// Main response model for subCategoryProducts API
class SubCategoryProductsResponse {
  final String id;
  final String catName;
  final String imageUrl;
  final String bannerImageUrl;
  final String websiteImageUrl;
  final String websiteBannerImageUrl;
  final List<CategoryData> categoryData;
  final List<dynamic> offers; // Added offers field
  final int type;
  final int seqId;

  SubCategoryProductsResponse({
    required this.id,
    required this.catName,
    required this.imageUrl,
    required this.bannerImageUrl,
    required this.websiteImageUrl,
    required this.websiteBannerImageUrl,
    required this.categoryData,
    required this.offers,
    required this.type,
    required this.seqId,
  });

  factory SubCategoryProductsResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryProductsResponse(
      id: json['id']?.toString() ?? '',
      catName: json['catName']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      bannerImageUrl: json['bannerImageUrl']?.toString() ?? '',
      websiteImageUrl: json['websiteImageUrl']?.toString() ?? '',
      websiteBannerImageUrl: json['websiteBannerImageUrl']?.toString() ?? '',
      categoryData: (json['categoryData'] as List<dynamic>?)
          ?.map((item) => CategoryData.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      offers: (json['offers'] as List<dynamic>?) ?? [],
      type: json['type'] ?? 0,
      seqId: json['seqId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'catName': catName,
      'imageUrl': imageUrl,
      'bannerImageUrl': bannerImageUrl,
      'websiteImageUrl': websiteImageUrl,
      'websiteBannerImageUrl': websiteBannerImageUrl,
      'categoryData': categoryData.map((item) => item.toJson()).toList(),
      'offers': offers,
      'type': type,
      'seqId': seqId,
    };
  }
}

// Category data model
class CategoryData {
  final String firstCategoryId;
  final String secondCategoryId;
  final String thirdCategoryId;
  final String subCategoryName;
  final String catName;
  final List<SubCategoryProduct> subCategory;

  CategoryData({
    required this.firstCategoryId,
    required this.secondCategoryId,
    required this.thirdCategoryId,
    required this.subCategoryName,
    required this.catName,
    required this.subCategory,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      firstCategoryId: json['firstCategoryId']?.toString() ?? '',
      secondCategoryId: json['secondCategoryId']?.toString() ?? '',
      thirdCategoryId: json['thirdCategoryId']?.toString() ?? '',
      subCategoryName: json['subCategoryName']?.toString() ?? '',
      catName: json['catName']?.toString() ?? '',
      subCategory: (json['subCategory'] as List<dynamic>?)
          ?.map((item) => SubCategoryProduct.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstCategoryId': firstCategoryId,
      'secondCategoryId': secondCategoryId,
      'thirdCategoryId': thirdCategoryId,
      'subCategoryName': subCategoryName,
      'catName': catName,
      'subCategory': subCategory.map((item) => item.toJson()).toList(),
    };
  }
}

// SubCategory product model - using Product class from chat_response.dart
class SubCategoryProduct {
  final bool outOfStock;
  final String parentProductId;
  final int totalStarRating;
  final String childProductId;
  final String productName;
  final int maxQuantityPerUser;
  final int b2cminimumOrderQty;
  final String unitId;
  final List<VariantData> variantData;
  final int availableQuantity;
  final String images;
  final Map<String, dynamic> offers;
  final bool needsIdProof;
  final bool isFavourite;
  final bool variantCount;
  final bool prescriptionRequired;
  final bool allowOrderOutOfStock;
  final String storeCategoryId;
  final FinalPriceList finalPriceList;
  final MOQData moqData;
  final String currencySymbol;
  final String currency;
  final int adult;
  final String storeId;
  final String brandName;
  final bool isManufacturing;
  final int numberOfDaysManufacture;

  SubCategoryProduct({
    required this.outOfStock,
    required this.parentProductId,
    required this.totalStarRating,
    required this.childProductId,
    required this.productName,
    required this.maxQuantityPerUser,
    required this.b2cminimumOrderQty,
    required this.unitId,
    required this.variantData,
    required this.availableQuantity,
    required this.images,
    required this.offers,
    required this.needsIdProof,
    required this.isFavourite,
    required this.variantCount,
    required this.prescriptionRequired,
    required this.allowOrderOutOfStock,
    required this.storeCategoryId,
    required this.finalPriceList,
    required this.moqData,
    required this.currencySymbol,
    required this.currency,
    required this.adult,
    required this.storeId,
    required this.brandName,
    required this.isManufacturing,
    required this.numberOfDaysManufacture,
  });

  factory SubCategoryProduct.fromJson(Map<String, dynamic> json) {
    return SubCategoryProduct(
      outOfStock: json['outOfStock'] ?? false,
      parentProductId: json['parentProductId']?.toString() ?? '',
      totalStarRating: json['TotalStarRating'] ?? 0,
      childProductId: json['childProductId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      maxQuantityPerUser: json['maxQuantityPerUser'] ?? 1,
      b2cminimumOrderQty: json['b2cminimumOrderQty'] ?? 1,
      unitId: json['unitId']?.toString() ?? '',
      variantData: (json['variantData'] as List<dynamic>?)
          ?.map((item) => VariantData.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      availableQuantity: json['availableQuantity'] ?? 0,
      images: json['images']?.toString() ?? '',
      offers: (json['offers'] as Map<String, dynamic>?) ?? {},
      needsIdProof: json['needsIdProof'] ?? false,
      isFavourite: json['isFavourite'] ?? false,
      variantCount: json['variantCount'] ?? false,
      prescriptionRequired: json['prescriptionRequired'] ?? false,
      allowOrderOutOfStock: json['allowOrderOutOfStock'] ?? false,
      storeCategoryId: json['storeCategoryId']?.toString() ?? '',
      finalPriceList: FinalPriceList.fromJson((json['finalPriceList'] ?? {}) as Map<String, dynamic>),
      moqData: MOQData.fromJson((json['MOQData'] ?? {}) as Map<String, dynamic>),
      currencySymbol: json['currencySymbol']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      adult: json['adult'] ?? 0,
      storeId: json['storeId']?.toString() ?? '',
      brandName: json['brandName']?.toString() ?? '',
      isManufacturing: json['isManufacturing'] ?? false,
      numberOfDaysManufacture: json['numberOfDaysManufacture'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outOfStock': outOfStock,
      'parentProductId': parentProductId,
      'TotalStarRating': totalStarRating,
      'childProductId': childProductId,
      'productName': productName,
      'maxQuantityPerUser': maxQuantityPerUser,
      'b2cminimumOrderQty': b2cminimumOrderQty,
      'unitId': unitId,
      'variantData': variantData.map((item) => item.toJson()).toList(),
      'availableQuantity': availableQuantity,
      'images': images,
      'offers': offers,
      'needsIdProof': needsIdProof,
      'isFavourite': isFavourite,
      'variantCount': variantCount,
      'prescriptionRequired': prescriptionRequired,
      'allowOrderOutOfStock': allowOrderOutOfStock,
      'storeCategoryId': storeCategoryId,
      'finalPriceList': finalPriceList.toJson(),
      'MOQData': moqData.toJson(),
      'currencySymbol': currencySymbol,
      'currency': currency,
      'adult': adult,
      'storeId': storeId,
      'brandName': brandName,
      'isManufacturing': isManufacturing,
      'numberOfDaysManufacture': numberOfDaysManufacture,
    };
  }

  // Convert to Product class from chat_response.dart for compatibility
  Product toProduct() {
    return Product(
      parentProductId: parentProductId,
      childProductId: childProductId,
      variantsCount: variantCount ? 1 : 0,
      productName: productName,
      finalPriceList: finalPriceList,
      images: [images],
      containsMeat: false, // Default to false for groceries
      currencySymbol: currencySymbol,
      currency: currency,
      unitId: unitId,
      customizable: variantCount,
      storeCategoryId: storeCategoryId,
      storeTypeId: 8, // Grocery store type
      storeId: storeId,
      storeIsOpen: true, // Default to true
      instock: !outOfStock,
      variantCount: variantCount,
    );
  }
}

// Variant data model
class VariantData {
  final String value;
  final String name;

  VariantData({
    required this.value,
    required this.name,
  });

  factory VariantData.fromJson(Map<String, dynamic> json) {
    return VariantData(
      value: json['value']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'name': name,
    };
  }
}

// MOQ (Minimum Order Quantity) data model
class MOQData {
  final int minimumOrderQty;
  final String unitPackageType;
  final String unitMoqType;
  final String moq;

  MOQData({
    required this.minimumOrderQty,
    required this.unitPackageType,
    required this.unitMoqType,
    required this.moq,
  });

  factory MOQData.fromJson(Map<String, dynamic> json) {
    return MOQData(
      minimumOrderQty: json['minimumOrderQty'] ?? 1,
      unitPackageType: json['unitPackageType']?.toString() ?? '',
      unitMoqType: json['unitMoqType']?.toString() ?? '',
      moq: json['MOQ']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimumOrderQty': minimumOrderQty,
      'unitPackageType': unitPackageType,
      'unitMoqType': unitMoqType,
      'MOQ': moq,
    };
  }
}
