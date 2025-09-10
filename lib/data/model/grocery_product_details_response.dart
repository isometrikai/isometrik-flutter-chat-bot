class GroceryProductDetailsResponse {
  final GroceryProductData data;

  GroceryProductDetailsResponse({
    required this.data,
  });

  factory GroceryProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return GroceryProductDetailsResponse(
      data: GroceryProductData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class GroceryProductData {
  final GroceryProductDataInner productData;

  GroceryProductData({
    required this.productData,
  });

  factory GroceryProductData.fromJson(Map<String, dynamic> json) {
    return GroceryProductData(
      productData: GroceryProductDataInner.fromJson(json['productData'] as Map<String, dynamic>),
    );
  }
}

class GroceryProductDataInner {
  final List<GroceryProduct> data;
  final String message;

  GroceryProductDataInner({
    required this.data,
    required this.message,
  });

  factory GroceryProductDataInner.fromJson(Map<String, dynamic> json) {
    return GroceryProductDataInner(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => GroceryProduct.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      message: json['message'] ?? '',
    );
  }
}

class GroceryProduct {
  final String parentProductId;
  final String childProductId;
  final String productName;
  final String brandName;
  final String detailDesc;
  final List<GroceryProductImage> images;
  final List<GroceryProductVariant> variants;
  final GroceryProductSupplier supplier;
  final GroceryProductPrice finalPriceList;
  final int availableQuantity;
  final bool outOfStock;
  final String currency;
  final String currencySymbol;
  final List<GroceryProductAttribute> attributes;
  final String mouDataUnit;
  final GroceryProductMouData mouData;

  GroceryProduct({
    required this.parentProductId,
    required this.childProductId,
    required this.productName,
    required this.brandName,
    required this.detailDesc,
    required this.images,
    required this.variants,
    required this.supplier,
    required this.finalPriceList,
    required this.availableQuantity,
    required this.outOfStock,
    required this.currency,
    required this.currencySymbol,
    required this.attributes,
    required this.mouDataUnit,
    required this.mouData,
  });

  factory GroceryProduct.fromJson(Map<String, dynamic> json) {
    return GroceryProduct(
      parentProductId: json['parentProductId'] ?? '',
      childProductId: json['childProductId'] ?? '',
      productName: json['productName'] ?? '',
      brandName: json['brandName'] ?? '',
      detailDesc: json['detailDesc'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((item) => GroceryProductImage.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      variants: (json['variants'] as List<dynamic>?)
          ?.map((item) => GroceryProductVariant.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      supplier: GroceryProductSupplier.fromJson(json['supplier'] as Map<String, dynamic>),
      finalPriceList: GroceryProductPrice.fromJson(json['finalPriceList'] as Map<String, dynamic>),
      availableQuantity: json['availableQuantity'] ?? 0,
      outOfStock: json['outOfStock'] ?? false,
      currency: json['currency'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((item) => GroceryProductAttribute.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      mouDataUnit: json['mouDataUnit'] ?? '',
      mouData: GroceryProductMouData.fromJson(json['mouData'] as Map<String, dynamic>),
    );
  }
}

class GroceryProductImage {
  final String small;
  final String medium;
  final String large;
  final String extraLarge;
  final String altText;

  GroceryProductImage({
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
    required this.altText,
  });

  factory GroceryProductImage.fromJson(Map<String, dynamic> json) {
    return GroceryProductImage(
      small: json['small'] ?? '',
      medium: json['medium'] ?? '',
      large: json['large'] ?? '',
      extraLarge: json['extraLarge'] ?? '',
      altText: json['altText'] ?? '',
    );
  }
}

class GroceryProductVariant {
  final String name;
  final String keyName;
  final String image;
  final String extraLarge;
  final String unitId;
  final bool isPrimary;
  final List<GroceryProductSizeData> sizeData;

  GroceryProductVariant({
    required this.name,
    required this.keyName,
    required this.image,
    required this.extraLarge,
    required this.unitId,
    required this.isPrimary,
    required this.sizeData,
  });

  factory GroceryProductVariant.fromJson(Map<String, dynamic> json) {
    return GroceryProductVariant(
      name: json['name'] ?? '',
      keyName: json['keyName'] ?? '',
      image: json['image'] ?? '',
      extraLarge: json['extraLarge'] ?? '',
      unitId: json['unitId'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      sizeData: (json['sizeData'] as List<dynamic>?)
          ?.map((item) => GroceryProductSizeData.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class GroceryProductSizeData {
  final String childProductId;
  final String size;
  final String keyName;
  final String unitData;
  final bool isPrimary;
  final GroceryProductPrice finalPriceList;
  final String unitId;
  final String name;
  final bool visible;
  final String image;
  final String extraLarge;
  final bool outOfStock;
  final int availableStock;

  GroceryProductSizeData({
    required this.childProductId,
    required this.size,
    required this.keyName,
    required this.unitData,
    required this.isPrimary,
    required this.finalPriceList,
    required this.unitId,
    required this.name,
    required this.visible,
    required this.image,
    required this.extraLarge,
    required this.outOfStock,
    required this.availableStock,
  });

  factory GroceryProductSizeData.fromJson(Map<String, dynamic> json) {
    return GroceryProductSizeData(
      childProductId: json['childProductId'] ?? '',
      size: json['size'] ?? '',
      keyName: json['keyName'] ?? '',
      unitData: json['unitData'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      finalPriceList: GroceryProductPrice.fromJson(json['finalPriceList'] as Map<String, dynamic>),
      unitId: json['unitId'] ?? '',
      name: json['name'] ?? '',
      visible: json['visible'] ?? true,
      image: json['image'] ?? '',
      extraLarge: json['extraLarge'] ?? '',
      outOfStock: json['outOfStock'] ?? false,
      availableStock: json['availableStock'] ?? 0,
    );
  }
}

class GroceryProductSupplier {
  final String id;
  final String supplierName;
  final String storeAliasName;
  final String storeType;
  final String cityName;
  final double rating;
  final int totalRating;
  final GroceryProductLogoImages logoImages;

  GroceryProductSupplier({
    required this.id,
    required this.supplierName,
    required this.storeAliasName,
    required this.storeType,
    required this.cityName,
    required this.rating,
    required this.totalRating,
    required this.logoImages,
  });

  factory GroceryProductSupplier.fromJson(Map<String, dynamic> json) {
    return GroceryProductSupplier(
      id: json['id'] ?? '',
      supplierName: json['supplierName'] ?? '',
      storeAliasName: json['storeAliasName'] ?? '',
      storeType: json['storeType'] ?? '',
      cityName: json['cityName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRating: json['totalRating'] ?? 0,
      logoImages: GroceryProductLogoImages.fromJson(json['logoImages'] as Map<String, dynamic>),
    );
  }
}

class GroceryProductLogoImages {
  final String logoImageMobile;
  final String logoImageThumb;
  final String logoImageweb;

  GroceryProductLogoImages({
    required this.logoImageMobile,
    required this.logoImageThumb,
    required this.logoImageweb,
  });

  factory GroceryProductLogoImages.fromJson(Map<String, dynamic> json) {
    return GroceryProductLogoImages(
      logoImageMobile: json['logoImageMobile'] ?? '',
      logoImageThumb: json['logoImageThumb'] ?? '',
      logoImageweb: json['logoImageweb'] ?? '',
    );
  }
}

class GroceryProductPrice {
  final double basePrice;
  final double discountPrice;
  final double finalPrice;
  final double discountPercentage;

  GroceryProductPrice({
    required this.basePrice,
    required this.discountPrice,
    required this.finalPrice,
    required this.discountPercentage,
  });

  factory GroceryProductPrice.fromJson(Map<String, dynamic> json) {
    return GroceryProductPrice(
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      discountPrice: (json['discountPrice'] ?? 0.0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0.0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0.0).toDouble(),
    );
  }
}

class GroceryProductAttribute {
  final List<GroceryProductInnerAttribute> innerAttributes;
  final int seqId;
  final String name;

  GroceryProductAttribute({
    required this.innerAttributes,
    required this.seqId,
    required this.name,
  });

  factory GroceryProductAttribute.fromJson(Map<String, dynamic> json) {
    return GroceryProductAttribute(
      innerAttributes: (json['innerAttributes'] as List<dynamic>?)
          ?.map((item) => GroceryProductInnerAttribute.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      seqId: json['seqId'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class GroceryProductInnerAttribute {
  final String name;
  final String value;
  final String attributeImage;
  final int attriubteType;
  final int customizable;
  final bool isHtml;

  GroceryProductInnerAttribute({
    required this.name,
    required this.value,
    required this.attributeImage,
    required this.attriubteType,
    required this.customizable,
    required this.isHtml,
  });

  factory GroceryProductInnerAttribute.fromJson(Map<String, dynamic> json) {
    return GroceryProductInnerAttribute(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      attributeImage: json['attributeImage'] ?? '',
      attriubteType: json['attriubteType'] ?? 0,
      customizable: json['customizable'] ?? 0,
      isHtml: json['isHtml'] ?? false,
    );
  }
}

class GroceryProductMouData {
  final String mesurmentQuantity;

  GroceryProductMouData({
    required this.mesurmentQuantity,
  });

  factory GroceryProductMouData.fromJson(Map<String, dynamic> json) {
    return GroceryProductMouData(
      mesurmentQuantity: json['mesurmentQuantity'] ?? '',
    );
  }
}
