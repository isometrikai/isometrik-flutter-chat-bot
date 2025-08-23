import 'dart:convert';

import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';
import 'package:chat_bot/utils/api_result.dart';

class HawkSearchService {
  HawkSearchService._internal();
  static final HawkSearchService instance = HawkSearchService._internal();

  /// Calls HawkSearch and returns a list of `Store` grouped with their `Product`s.
  /// Only required fields are bound. We do not bind the entire response.
  Future<List<Store>> fetchStoresGroupedByStoreId({
    double latitude = 13.040803909301758,
    double longitude = 77.562980651855469,
    String clientGuid = '528a7d439df44f2b9457342b7b865be2',
    String indexName = 'hitechnology.20250821.105131',//'hitechnology.20250626.060135',
    String visitId = '3c6b9339-c602-4af9-b454-0ec0df067181',
    String visitorId = '47daf829-b5df-4358-83ea-207aa4eaae15',
    String keyword = '',
  }) async {
    final client = ChatApiServices.instance
        .createCustomClient('https://searchapi-dev.hawksearch.net');

    final body = {
      'FacetSelections': {},
      'ClientData': {
        'Origin': {
          'Latitude': latitude,
          'Longitude': longitude,
        },
        'VisitId': visitId,
        'VisitorId': visitorId,
        'UserAgent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'PreviewBuckets': [],
      },
      'ClientGuid': clientGuid,
      'Keyword': keyword,
      'IndexName': indexName,
    };

    final ApiResult res = await client.post('/api/v2/search', body);
    if (!res.isSuccess || res.data == null) {
      return [];
    }

    final dynamic data = res.data;
    if (data is! Map<String, dynamic>) return [];

    final List<dynamic> results = (data['Results'] as List<dynamic>? ?? []);

    // Group products by storeId
    final Map<String, List<Product>> storeIdToProducts = {};
    final Map<String, Map<String, dynamic>> storeIdToDoc = {};

    for (final dynamic r in results) {
      if (r is! Map<String, dynamic>) continue;
      final doc = (r['Document'] as Map<String, dynamic>?);
      if (doc == null) continue;

      final String storeId = _firstString(doc['storeid']);
      if (storeId.isEmpty) continue;

      final Product? product = _mapDocumentToProduct(doc);
      if (product == null) continue;

      storeIdToProducts.putIfAbsent(storeId, () => <Product>[]).add(product);
      // Keep one representative doc for store-level info
      storeIdToDoc.putIfAbsent(storeId, () => doc);
    }

    // Build Store list
    final List<Store> stores = [];
    storeIdToProducts.forEach((storeId, products) {
      final doc = storeIdToDoc[storeId] ?? {};
      final store = _mapDocumentToStore(doc, products);
      stores.add(store);
    });

    return stores;
  }

  Product? _mapDocumentToProduct(Map<String, dynamic> doc) {
    try {
      final String id = _firstString(doc['id']);
      final String parentProductId = _firstString(doc['parentproductid']);
      final String childProductId = _firstString(doc['childproductid']);
      final int variantsCount = int.tryParse(_firstString(doc['variantcount'])) ?? 0;
      final String productName = _firstString(doc['productunitname']).isNotEmpty
          ? _firstString(doc['productunitname'])
          : _firstString(doc['size']);

      final List<String> images = (doc['image'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      final bool containsMeat = _firstBool(doc['containsmeat']);
      final String currencySymbol = _firstString(doc['currencysymbol']);
      final String currency = _firstString(doc['currency']);

      // Parse final price list (string with single quotes)
      final String finalPriceListRaw = _firstString(doc['finalpricelist']);
      final Map<String, dynamic> finalPriceMap = _tryParseLooseJson(finalPriceListRaw);

      final double basePrice = _toDouble(finalPriceMap['basePrice']);
      final double finalPrice = _toDouble(finalPriceMap['finalPrice']);
      final double discountPrice = _toDouble(finalPriceMap['discountPrice']);
      final int discountType = _toInt(finalPriceMap['discountType'], fallback: 0);

      final FinalPriceList priceList = FinalPriceList(
        basePrice: basePrice,
        finalPrice: finalPrice,
        discountPrice: discountPrice,
        discountPercentage: 0,
        discountType: discountType,
        taxRate: 0,
        msrpPrice: 0,
      );

      return Product(
        id: id,
        parentProductId: parentProductId,
        childProductId: childProductId,
        variantsCount: variantsCount,
        productName: productName.isEmpty ? 'Product' : productName,
        finalPriceList: priceList,
        images: images,
        containsMeat: containsMeat,
        currencySymbol: currencySymbol,
        currency: currency,
      );
    } catch (_) {
      return null;
    }
  }

  Store _mapDocumentToStore(Map<String, dynamic> doc, List<Product> products) {
    // Prefer values from `storedata` when available
    final String storeDataRaw = _firstString(doc['storedata']);
    final Map<String, dynamic> storeData = _tryParseLooseJson(storeDataRaw);

    final String storename = _firstString(doc['storename']).isNotEmpty
        ? _firstString(doc['storename'])
        : (storeData['storeName']?.toString() ?? '');

    final double avgRating = (() {
      final String r = _firstString(doc['avgrating']);
      if (r.isNotEmpty) return double.tryParse(r) ?? 0.0;
      final dynamic sd = storeData['avgRating'];
      if (sd is num) return sd.toDouble();
      return 0.0;
    })();

    final String cuisineDetails = (() {
      final List<dynamic> cl = (doc['categorylist'] as List<dynamic>? ?? []);
      if (cl.isNotEmpty) return cl.map((e) => e.toString()).join(', ');
      return '';
    })();

    final String storeImage = (() {
      final String si = storeData['logoImage']?.toString() ?? '';
      if (si.isNotEmpty) return si;
      // Fallback to first product image if needed
      return products.isNotEmpty && products.first.images.isNotEmpty
          ? products.first.images.first
          : '';
    })();

    final String distanceStr = (() {
      // distance array: [{ 'storelocation': miles, 'unit': 'Miles' }]
      final List<dynamic> dl = (doc['distance'] as List<dynamic>? ?? []);
      if (dl.isNotEmpty && dl.first is Map<String, dynamic>) {
        final dynamic milesVal = (dl.first as Map<String, dynamic>)['storelocation'];
        final double miles = milesVal is num ? milesVal.toDouble() : 0.0;
        final double km = miles * 1.60934;
        return km.toStringAsFixed(1);
      }
      return '0.0';
    })();

    final String storeId = (() {
      final String fromDoc = _firstString(doc['storeid']);
      if (fromDoc.isNotEmpty) return fromDoc;
      return storeData['storeId']?.toString() ?? '';
    })();

    final String storeCategoryId = (() {
      final String fromDoc = _firstString(doc['storecategoryid']);
      if (fromDoc.isNotEmpty) return fromDoc;
      return storeData['storeCategoryId']?.toString() ?? '';
    })();

    // Extra fields from storeData.metaData
    final Map<String, dynamic> metaData = (() {
      final dynamic raw = storeData['metaData'];
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      return <String, dynamic>{};
    })();

    final String linkFromId = metaData['linkFromId']?.toString() ?? '';
    final int type = _toInt(metaData['type'], fallback: 0);
    final bool isDoctored = _toBool(metaData['isDoctore'] ?? metaData['isDoctored']);
    final bool storeListing = _toBool(metaData['storeListing']);
    final bool hyperlocal = _toBool(metaData['hyperlocal']);

    return Store(
      storename: storename,
      avgRating: avgRating,
      cuisineDetails: cuisineDetails,
      storeImage: storeImage,
      distance: distanceStr,
      products: products,
      storeId: storeId,
      storeCategoryId: storeCategoryId,
      linkFromId: linkFromId,
      type: type,
      isDoctored: isDoctored,
      storeListing: storeListing,
      hyperlocal: hyperlocal,
    );
  }

  String _firstString(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first?.toString() ?? '';
    }
    return '';
  }

  bool _firstBool(dynamic value) {
    if (value is List && value.isNotEmpty) {
      final dynamic v = value.first;
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
      if (v is num) return v != 0;
    }
    return false;
  }

  Map<String, dynamic> _tryParseLooseJson(String raw) {
    if (raw.isEmpty) return {};
    try {
      // Normalize: single quotes -> double quotes, Python booleans -> JSON booleans
      String fixed = raw
          .replaceAll("'", '"')
          .replaceAll('False', 'false')
          .replaceAll('True', 'true');
      final decoded = jsonDecode(fixed);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
    }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String v = value.toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes' || v == 'y') return true;
      if (v == 'false' || v == '0' || v == 'no' || v == 'n') return false;
    }
    return false;
  }
}


