class ProductPortionResponse {
  final String message;
  final List<ProductPortion> data;

  ProductPortionResponse({
    required this.message,
    required this.data,
  });

  factory ProductPortionResponse.fromJson(Map<String, dynamic> json) {
    return ProductPortionResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ProductPortion.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ProductPortion {
  final String id;
  final bool isPrimary;
  final String childProductId;
  final String name;
  final double price;
  final List<AddOnCategory> addOns;
  final String currencySymbol;
  final String currency;
  final String unitId;
  final String parentProductId;

  ProductPortion({
    required this.id,
    required this.isPrimary,
    required this.childProductId,
    required this.name,
    required this.price,
    required this.addOns,
    required this.currencySymbol,
    required this.currency,
    required this.unitId,
    required this.parentProductId,
  });

  factory ProductPortion.fromJson(Map<String, dynamic> json) {
    return ProductPortion(
      id: json['id'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      childProductId: json['childProductId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      addOns: (json['addOns'] as List<dynamic>?)
          ?.map((item) => AddOnCategory.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      currencySymbol: json['currencySymbol'] ?? '',
      currency: json['currency'] ?? '',
      unitId: json['unitId'] ?? '',
      parentProductId: json['parentProductId'] ?? '',
    );
  }
}

class AddOnCategory {
  final String name;
  final List<AddOnItem> addOns;
  final String currencySymbol;
  final String currency;
  final String storeId;
  final String description;
  final int minimumLimit;
  final int maximumLimit;
  final bool mandatory;
  final bool multiple;
  final int addOnLimit;
  final String unitAddOnId;
  final int seqId;

  AddOnCategory({
    required this.name,
    required this.addOns,
    required this.currencySymbol,
    required this.currency,
    required this.storeId,
    required this.description,
    required this.minimumLimit,
    required this.maximumLimit,
    required this.mandatory,
    required this.multiple,
    required this.addOnLimit,
    required this.unitAddOnId,
    required this.seqId,
  });

  factory AddOnCategory.fromJson(Map<String, dynamic> json) {
    return AddOnCategory(
      name: json['name'] ?? '',
      addOns: (json['addOns'] as List<dynamic>?)
          ?.map((item) => AddOnItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      currencySymbol: json['currencySymbol'] ?? '',
      currency: json['currency'] ?? '',
      storeId: json['storeId'] ?? '',
      description: json['description'] ?? '',
      minimumLimit: json['minimumLimit'] ?? 0,
      maximumLimit: json['maximumLimit'] ?? 0,
      mandatory: json['mandatory'] == 1,
      multiple: json['multiple'] == 1,
      addOnLimit: json['addOnLimit'] ?? 0,
      unitAddOnId: json['unitAddOnId'] ?? '',
      seqId: json['seqId'] ?? 0,
    );
  }
}

class AddOnItem {
  final String id;
  final String name;
  final String currencySymbol;
  final String currency;
  final double price;

  AddOnItem({
    required this.id,
    required this.name,
    required this.currencySymbol,
    required this.currency,
    required this.price,
  });

  factory AddOnItem.fromJson(Map<String, dynamic> json) {
    return AddOnItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
      currency: json['currency'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
