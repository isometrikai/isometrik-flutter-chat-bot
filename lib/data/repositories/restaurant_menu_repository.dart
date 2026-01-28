import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:chat_bot/data/model/subcategory_products_response.dart';
import 'package:chat_bot/data/services/universal_api_client.dart';
import 'package:chat_bot/utils/api_result.dart';

class RestaurantMenuRepository {
  const RestaurantMenuRepository();

  Future<RestaurantMenuData> fetchMenu({
    required String storeId,
    double latitude = 25.20485,
    double longitude = 55.270782,
    String timezone = 'Asia/Kolkata',
    String cuisineMeatFilter = '1',
  }) async {
    final client = UniversalApiClient.instance.appClient;
    final Map<String, String> queryParams = {
      'containsMeat': cuisineMeatFilter,
      'lat': latitude.toString(),
      'long': longitude.toString(),
      'storeId': storeId,
      'timezone': timezone,
      'z_id': '636dfc8c89b6a857b500ccd1',
    };

    final ApiResult res = await client.get(
      '/get/storeMenu',
      queryParameters: queryParams,
    );

    if (!res.isSuccess || res.data == null) {
      throw Exception(res.message ?? 'Failed to load menu');
    }

    final RestaurantMenuResponse parsed = RestaurantMenuResponse.fromJson(
      res.data as Map<String, dynamic>,
    );
    return parsed.data;
  }

  Future<SubCategoryProductsResponse> fetchSubCategoryProducts({
    required String storeId,
    required String subCategoryId,
  }) async {
    // Get dynamic headers with the provided storeId
    final headers = await UniversalApiClient.instance
        .buildGroceryHeadersWithStoreId(storeId, subCategoryId);

    // Make API call with custom headers
    final ApiResult res = await UniversalApiClient.instance
        .getWithCustomHeaders(
          '/python/subCategoryProducts/',
          customHeaders: headers,
        );

    try {
      final SubCategoryProductsResponse parsed =
          SubCategoryProductsResponse.fromJson(
            res.data as Map<String, dynamic>,
          );
      return parsed;
    } catch (e) {
      print('❌ Error parsing SubCategoryProductsResponse: $e');
      print('❌ Raw data type: ${res.data.runtimeType}');
      print('❌ Raw data: ${res.data}');
      throw Exception('Failed to parse subcategory products response: $e');
    }
  }

  Future<SubCategoryProductsResponse> fetchServiceGenieProducts({
    required String storeId,
    required String storeCategoryId,
    String? storeCategoryName,
  }) async {
    final headers = await UniversalApiClient.instance.buildServiceGenieHeaders(
      storeCategoryId: storeCategoryId,
    );

    final ApiResult res = await UniversalApiClient.instance
        .getWithCustomHeaders(
          '/v1/product/search',
          queryParameters: {'page': '1', 'sId': storeId},
          customHeaders: headers,
        );

    if (!res.isSuccess || res.data == null) {
      throw Exception(res.message ?? 'Failed to load service products');
    }

    if (res.data is! Map<String, dynamic>) {
      throw Exception('Unexpected response format for service products');
    }

    return _mapServiceGenieResponse(
      res.data as Map<String, dynamic>,
      storeId,
      storeCategoryId,
      storeCategoryName,
    );
  }

  SubCategoryProductsResponse _mapServiceGenieResponse(
    Map<String, dynamic> json,
    String storeId,
    String storeCategoryId,
    String? storeCategoryName,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final productsJson = data['products'] as List<dynamic>? ?? const [];

    final products =
        productsJson
            .map(
              (item) =>
                  item is Map<String, dynamic>
                      ? _mapServiceGenieProduct(item, storeId, storeCategoryId)
                      : null,
            )
            .whereType<SubCategoryProduct>()
            .toList();

    final displayName =
        (storeCategoryName ?? '').isNotEmpty ? storeCategoryName! : 'Services';

    return SubCategoryProductsResponse(
      id: storeCategoryId,
      catName: displayName,
      imageUrl: '',
      bannerImageUrl: '',
      websiteImageUrl: '',
      websiteBannerImageUrl: '',
      categoryData: [
        CategoryData(
          firstCategoryId: storeCategoryId,
          secondCategoryId: storeCategoryId,
          thirdCategoryId: storeCategoryId,
          subCategoryName: displayName,
          catName: displayName,
          subCategory: products,
        ),
      ],
      offers: const [],
      type: 0,
      seqId: 0,
    );
  }

  SubCategoryProduct _mapServiceGenieProduct(
    Map<String, dynamic> json,
    String fallbackStoreId,
    String fallbackStoreCategoryId,
  ) {
    final supplier =
        (json['supplier'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final priceJson =
        (json['finalPriceList'] as Map<String, dynamic>?) ?? const {};
    final moqJson = (json['MOQData'] as Map<String, dynamic>?) ?? const {};
    final imagesJson = json['images'] as List<dynamic>? ?? const [];
    final mobImages = (json['mobimages'] as Map<String, dynamic>?) ?? const {};

    String imageUrl =
        mobImages['large']?.toString() ??
        mobImages['medium']?.toString() ??
        mobImages['small']?.toString() ??
        '';

    if (imageUrl.isEmpty && imagesJson.isNotEmpty) {
      final firstImage = imagesJson.first;
      if (firstImage is Map<String, dynamic>) {
        imageUrl =
            firstImage['large']?.toString() ??
            firstImage['medium']?.toString() ??
            firstImage['small']?.toString() ??
            '';
      } else {
        imageUrl = firstImage.toString();
      }
    }

    final variantFlag = _parseBool(json['variantCount']);
    final maxQuantity =
        int.tryParse(json['maxQuantity']?.toString() ?? '') ?? 1;


    return SubCategoryProduct(
      outOfStock: json['outOfStock'] ?? false,
      parentProductId: json['parentProductId']?.toString() ?? '',
      totalStarRating: _parseDouble(json['TotalStarRating']),
      childProductId: json['childProductId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      maxQuantityPerUser: maxQuantity,
      b2cminimumOrderQty:
          json['b2cminimumOrderQty'] is int
              ? json['b2cminimumOrderQty'] as int
              : int.tryParse(json['b2cminimumOrderQty']?.toString() ?? '') ?? 1,
      unitId: json['unitId']?.toString() ?? '',
      variantData: const <VariantData>[],
      availableQuantity:
          int.tryParse(json['storeCount']?.toString() ?? '') ?? 0,
      images: imageUrl,
      offers: (json['offers'] as Map<String, dynamic>?) ?? const {},
      needsIdProof: json['needsIdProof'] ?? false,
      isFavourite: json['isFavourite'] ?? false,
      variantCount: variantFlag,
      prescriptionRequired: json['prescriptionRequired'] ?? false,
      allowOrderOutOfStock: json['allowOrderOutOfStock'] ?? false,
      storeCategoryId:
          json['storeCategoryId']?.toString() ?? fallbackStoreCategoryId,
      finalPriceList: FinalPriceList(
        basePrice: _parseDouble(priceJson['basePrice']),
        finalPrice: _parseDouble(priceJson['finalPrice']),
        discountPrice: _parseDouble(priceJson['discountPrice']),
        discountPercentage: _parseDouble(priceJson['discountPercentage']),
        discountType: _parseInt(priceJson['discountType']),
        taxRate: _parseInt(priceJson['taxRate']),
        msrpPrice: _parseDouble(priceJson['msrpPrice']),
      ),
      currencySymbol: json['currencySymbol']?.toString() ?? '',
      currency: json['currency']?.toString() ?? '',
      adult: _parseInt(json['adult']),
      storeId: supplier['id']?.toString() ?? fallbackStoreId,
      brandName: supplier['supplierName']?.toString() ?? '',
      isManufacturing: json['isManufacturing'] ?? false,
      numberOfDaysManufacture: _parseInt(json['numberOfDaysManufacture']),
      storeTypeId: _parseInt(
        supplier['storeTypeId'] ?? json['storeTypeId'],
        fallback: 25,
      ),
      storeIsOpen: json['storeIsOpen'] ?? supplier['storeIsOpen'] ?? true,
      serviceRequireTime: json['serviceRequireTime']?.toString() ?? '',
      supplierName: supplier['supplierName']?.toString() ?? '',
    );
  }

  double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }
}
