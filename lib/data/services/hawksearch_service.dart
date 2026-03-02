import 'dart:convert';

import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';
import 'package:chat_bot/utils/api_result.dart';

class HawkSearchService {
  HawkSearchService._internal();
  static final HawkSearchService instance = HawkSearchService._internal();

  // Configuration parameters
  String _clientGuid = '';
  String _indexName = '';
  String _visitId = '';
  String _visitorId = '';
  String _searchApiUrl = '';
  double _latitude = -1;
  double _longitude = -1;

  /// Configure HawkSearch service with required parameters
  void configure({
    required String clientGuid,
    required String indexName,
    required String visitId,
    required String visitorId,
    required String searchApiUrl,
    required double latitude,
    required double longitude,
  }) {
    _clientGuid = clientGuid;
    _indexName = indexName;
    _visitId = visitId;
    _visitorId = visitorId;
    _searchApiUrl = searchApiUrl;
    _latitude = latitude;
    _longitude = longitude;
  }

  /// Calls HawkSearch and returns a list of `Store` grouped with their `Product`s.
  /// Only required fields are bound. We do not bind the entire response.
  Future<List<Store>> fetchStoresGroupedByStoreId({
    String keyword = '',
    String storeCategoryName = '',
    String storeCategoryId = '',
  }) async {
    final client = ChatApiServices.instance
        .createCustomClient(_searchApiUrl);

    final body = {
      // 'FacetSelections': {
      //   'storeCategoryName': [storeCategoryName],
      // },
      "SearchWithin": storeCategoryId,
      'ClientData': {
        'Origin': {
          'Latitude': _latitude,
          'Longitude': _longitude,
        },
        'VisitId': _visitId,
        'VisitorId': _visitorId,
        'UserAgent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'PreviewBuckets': [],
      },
      'ClientGuid': _clientGuid,
      'Keyword': keyword,
      'IndexName': _indexName,
      "FacetSelections": {
        "storeLocation": [
            "4"
        ]
    }
    };

    final ApiResult res = await client.post('/search', body);
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
      if (product.isPrimary == false) continue;

      storeIdToProducts.putIfAbsent(storeId, () => <Product>[]).add(product);
      // Keep one representative doc for store-level info
      storeIdToDoc.putIfAbsent(storeId, () => doc);
    }

    // Build Store list - show all stores with all their products
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
      
      // final String id = _firstString(doc['id']); // Currently unused
      final String parentProductId = _firstString(doc['parentproductid']);
      final String childProductId = _firstString(doc['childproductid']);
      final int variantsCount = int.tryParse(_firstString(doc['variantcount'])) ?? 0;
      final String productName = _firstString(doc['metadata']).isNotEmpty
          ? _firstString(doc['metadata'])
          : _firstString(doc['size']);

      final List<String> images = (doc['image'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      final String unitId = _firstString(doc['unitid']);
      final bool instock = (_firstString(doc['instock']) == '1' ? true : false);

      final bool containsMeat = _firstBool(doc['containsmeat']);
      final String currencySymbol = _firstString(doc['currencysymbol']);
      final String currency = _firstString(doc['currency']);

      // Extract isPrimary from storedata.metaData
      final String storeDataRaw = _firstString(doc['storedata']);
      final Map<String, dynamic> storeData = _tryParseLooseJson(storeDataRaw);
      final Map<String, dynamic> metaData = (() {
        final dynamic raw = storeData['metaData'];
        if (raw is Map) {
          return Map<String, dynamic>.from(raw);
        }
        return <String, dynamic>{};
      })();
      final bool isPrimary = _toBool(metaData['isPrimary']);

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
        // id: id,
        parentProductId: parentProductId,
        childProductId: childProductId,
        variantsCount: variantsCount,
        productName: productName.isEmpty ? 'Product' : productName,
        finalPriceList: priceList,
        images: images,
        containsMeat: containsMeat,
        currencySymbol: currencySymbol,
        currency: currency,
        unitId: unitId,
        customizable: false,
        instock: instock,
        isPrimary: isPrimary,
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
    
    
    // final double avgRating = (() {
    //   final String r = _firstString(doc['avgrating']);
    //   if (r.isNotEmpty) return double.tryParse(r) ?? 0.0;
    //   final dynamic sd = storeData['avgRating'];
    //   if (sd is num) return sd.toDouble();
    //   return 0.0;
    // })();

    final String cuisineDetails = (() {
      final List<dynamic> cl = (doc['categorylist'] as List<dynamic>? ?? []);
      if (cl.isNotEmpty) {
        // Remove duplicates by converting to Set and back to List
        final categoryList = cl
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();
        return categoryList.join(', ');
      }
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
      final distances = doc['distance'] as List<dynamic>? ?? [];

      if (distances.isEmpty) return '0.0';

      final firstDistance = distances.first;
      if (firstDistance is! Map<String, dynamic>) return '0.0';

      final milesValue = firstDistance['storelocation'];
      final miles = milesValue is num ? milesValue.toDouble() : 0.0;

      final kilometers = miles * 1.60934;
      return kilometers.toStringAsFixed(1) + ' km';
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

    final double avgRating = (() {
      final dynamic sd = storeData['avgRating'];
      if (sd is num) {
        return double.parse(sd.toDouble().toStringAsFixed(1));
      }
      return 0.0;
    })();

    final bool storeIsOpen = (() {
      final dynamic sd = storeData['storeIsOpen'];
      if (sd == 'True' || sd == true) {
        return true;
      }
      return false;
    })();

     final bool tableReservations = (() {
      final dynamic sd = storeData['tableReservations'];
      if (sd == 'True' || sd == true) {
        return true;
      }
      return false;
    })();

    final num supportedOrderTypes = (() {
      final dynamic sd = storeData['supportedOrderTypes'];
      if (sd is num) return sd;
      return 0; 
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
    final bool isDoctore = _toBool(metaData['isDoctore'] ?? metaData['isDoctored']);
    final bool storeListing = _toBool(metaData['storeListing']);
    final bool hyperlocal = _toBool(metaData['hyperlocal']);

    final List<Doctor> doctorsList = _parseDoctorsListFromStoreData(storeData);

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
      storeTypeId: type,
      isDoctore: isDoctore,
      storeListing: storeListing,
      hyperlocal: hyperlocal,
        storeIsOpen: storeIsOpen,
        supportedOrderTypes: supportedOrderTypes,
        tableReservations: tableReservations,
        doctorsList: doctorsList,
    );
  }

  /// Parses serviceProvider from HawkSearch storedata into List<Doctor>.
  List<Doctor> _parseDoctorsListFromStoreData(Map<String, dynamic> storeData) {
    final dynamic raw = storeData['serviceProvider'];
    if (raw is! List || raw.isEmpty) return [];
    final List<Doctor> result = [];
    for (final dynamic item in raw) {
      if (item is! Map<String, dynamic>) continue;
      try {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        // Normalize _id if it came as "ObjectId('hex')" string from fallback parser
        final dynamic idRaw = map['_id'];
        if (idRaw is String && idRaw.startsWith('ObjectId(')) {
          // Extract hex id from ObjectId('hex') or ObjectId("hex")
          final match = RegExp(r'ObjectId\s*\(\s*.(.+?).\s*\)').firstMatch(idRaw);
          if (match != null) {
            final hex = match.group(1)?.replaceAll('"', '').replaceAll("'", '') ?? '';
            if (hex.isNotEmpty) map['_id'] = hex;
          }
        }
        result.add(Doctor.fromJson(map));
      } catch (_) {
        // Skip malformed provider entries
      }
    }
    return result;
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
      // Handle Python dictionary string format
      String fixed = raw;

      // Replace ObjectId('hex') or ObjectId("hex") with "hex" for valid JSON
      const objectIdPattern = r'ObjectId\s*\(\s*.(.+?).\s*\)';
      fixed = fixed.replaceAllMapped(
        RegExp(objectIdPattern),
        (Match m) {
          final hex = (m.group(1) ?? '').replaceAll('"', '').replaceAll("'", '');
          return '"$hex"';
        },
      );

      // Replace Python boolean values with JSON boolean values
      fixed = fixed.replaceAll('True', 'true');
      fixed = fixed.replaceAll('False', 'false');

      // Handle None values
      fixed = fixed.replaceAll('None', 'null');

      // More careful quote replacement to handle nested structures
      fixed = _replaceQuotesSafely(fixed);
      
      // Handle any remaining Python-specific formatting
      // Remove any trailing commas before closing braces/brackets
      fixed = fixed.replaceAll(RegExp(r',\s*}'), '}');
      fixed = fixed.replaceAll(RegExp(r',\s*]'), ']');
      
      final decoded = jsonDecode(fixed);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      // If JSON parsing fails, try a more robust approach
      try {
        final result = _parsePythonDict(raw);
        return result;
      } catch (e2) {
        return {};
      }
    }
  }

  /// Safely replace single quotes with double quotes while preserving nested structures
  String _replaceQuotesSafely(String input) {
    final StringBuffer result = StringBuffer();
    bool inString = false;
    bool inDoubleQuotes = false;
    
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      
      // Handle escaped characters
      if (i > 0 && input[i - 1] == '\\') {
        result.write(char);
        continue;
      }
      
      if (char == '"' && !inString) {
        inDoubleQuotes = !inDoubleQuotes;
        result.write(char);
      } else if (char == "'" && !inString && !inDoubleQuotes) {
        // Start of a string
        inString = true;
        result.write('"');
      } else if (char == "'" && inString && !inDoubleQuotes) {
        // Check if this is the end of the string
        bool isEndOfString = false;
        
        // Skip whitespace after the quote
        int j = i + 1;
        while (j < input.length && input[j].trim().isEmpty) {
          j++;
        }
        
        if (j < input.length) {
          final nextChar = input[j];
          if (nextChar == ':' || nextChar == ',' || nextChar == '}' || nextChar == ']') {
            isEndOfString = true;
          }
        } else {
          isEndOfString = true;
        }
        
        if (isEndOfString) {
          inString = false;
          result.write('"');
        } else {
          // This is an apostrophe within a string, keep it as is
          result.write("'");
        }
      } else {
        result.write(char);
      }
    }
    
    return result.toString();
  }

  /// Fallback method to parse Python dictionary strings more robustly
  Map<String, dynamic> _parsePythonDict(String raw) {
    final Map<String, dynamic> result = {};
    
    // Remove outer braces
    String content = raw.trim();
    if (content.startsWith('{') && content.endsWith('}')) {
      content = content.substring(1, content.length - 1);
    }
    
    // Split by comma, but be careful with nested structures
    final List<String> pairs = [];
    int braceCount = 0;
    int bracketCount = 0;
    int singleQuoteCount = 0;
    int doubleQuoteCount = 0;
    String currentPair = '';
    
    for (int i = 0; i < content.length; i++) {
      final char = content[i];
      
      // Handle escaped characters
      if (i > 0 && content[i - 1] == '\\') {
        currentPair += char;
        continue;
      }
      
      if (char == "'" && doubleQuoteCount % 2 == 0) {
        singleQuoteCount++;
      } else if (char == '"' && singleQuoteCount % 2 == 0) {
        doubleQuoteCount++;
      } else if (char == '{' && singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0) {
        braceCount++;
      } else if (char == '}' && singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0) {
        braceCount--;
      } else if (char == '[' && singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0) {
        bracketCount++;
      } else if (char == ']' && singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0) {
        bracketCount--;
      } else if (char == ',' && braceCount == 0 && bracketCount == 0 && singleQuoteCount % 2 == 0 && doubleQuoteCount % 2 == 0) {
        pairs.add(currentPair.trim());
        currentPair = '';
        continue;
      }
      
      currentPair += char;
    }
    
    if (currentPair.trim().isNotEmpty) {
      pairs.add(currentPair.trim());
    }
    
    
    // Parse each key-value pair
    for (final pair in pairs) {
      final colonIndex = pair.indexOf(':');
      if (colonIndex == -1) continue;
      
      String key = pair.substring(0, colonIndex).trim();
      String value = pair.substring(colonIndex + 1).trim();
      
      // Remove quotes from key
      if ((key.startsWith("'") && key.endsWith("'")) || (key.startsWith('"') && key.endsWith('"'))) {
        key = key.substring(1, key.length - 1);
      }
      
      // Parse value
      dynamic parsedValue = _parseValue(value);
      result[key] = parsedValue;
    }
    
    return result;
  }
  
  /// Parse individual values from Python dictionary
  dynamic _parseValue(String value) {
    value = value.trim();
    
    // Handle strings (both single and double quotes)
    if ((value.startsWith("'") && value.endsWith("'")) || (value.startsWith('"') && value.endsWith('"'))) {
      return value.substring(1, value.length - 1);
    }
    
    // Handle booleans
    if (value == 'True') return true;
    if (value == 'False') return false;
    
    // Handle None
    if (value == 'None') return null;
    
    // Handle numbers
    if (RegExp(r'^-?\d+$').hasMatch(value)) {
      return int.tryParse(value);
    }
    if (RegExp(r'^-?\d+\.\d+$').hasMatch(value)) {
      return double.tryParse(value);
    }
    
    // Handle lists
    if (value.startsWith('[') && value.endsWith(']')) {
      final List<dynamic> list = [];
      final content = value.substring(1, value.length - 1).trim();
      if (content.isNotEmpty) {
        final items = content.split(',');
        for (final item in items) {
          list.add(_parseValue(item.trim()));
        }
      }
      return list;
    }
    
    // Handle dictionaries
    if (value.startsWith('{') && value.endsWith('}')) {
      return _parsePythonDict(value);
    }
    
    // Default to string
    return value;
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
    if (value == null) return false;
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


