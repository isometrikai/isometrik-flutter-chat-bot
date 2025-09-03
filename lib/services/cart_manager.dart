import 'dart:async';

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  // Map to store product quantities: productId -> quantity
  final Map<String, int> _productQuantities = {};
  
  // Map to store product customizations: productId -> Map<category, List<selectedOptions>>
  final Map<String, Map<String, List<String>>> _productCustomizations = {};
  
  // Map to store unique customization IDs for products with variants
  // This ensures each customization combination is treated as a separate cart item
  final Map<String, String> _customizationIdMap = {};
  
  // Store the last added customization for "Repeat last" functionality
  Map<String, dynamic>? _lastAddedCustomization;
  
  // Stream controller for notifying listeners of quantity changes
  final StreamController<Map<String, int>> _quantityController = 
      StreamController<Map<String, int>>.broadcast();

  // Stream to listen to quantity changes
  Stream<Map<String, int>> get quantityStream => _quantityController.stream;

  // Get current quantities map
  Map<String, int> get productQuantities => Map.from(_productQuantities);
  
  // Get current customizations map
  Map<String, Map<String, List<String>>> get productCustomizations => 
      Map.from(_productCustomizations);
      
  // Get customization ID map
  Map<String, String> get customizationIdMap => Map.from(_customizationIdMap);
  
  // Get last added customization
  Map<String, dynamic>? get lastAddedCustomization => _lastAddedCustomization;
  
  // Set last added customization
  void setLastAddedCustomization(String productId, String productName, Map<String, List<String>> customizations) {
    _lastAddedCustomization = {
      'productId': productId,
      'productName': productName,
      'customizations': customizations,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  // Get quantity for a specific product
  int getQuantity(String productId) {
    return _productQuantities[productId] ?? 0;
  }
  
  // Get customizations for a specific product
  Map<String, List<String>>? getCustomizations(String productId) {
    return _productCustomizations[productId];
  }
  
  // Generate unique customization ID for products with variants
  String _generateCustomizationId(String productId, Map<String, List<String>> customizations) {
    // Create a unique string based on customizations
    final sortedKeys = customizations.keys.toList()..sort();
    final customizationString = sortedKeys.map((key) {
      final values = customizations[key]!..sort();
      return '$key:${values.join(',')}';
    }).join('|');
    
    return '${productId}_$customizationString';
  }
  
  // Get or create unique ID for a product with customizations
  String getCustomizationId(String productId, Map<String, List<String>> customizations) {
    final customizationId = _generateCustomizationId(productId, customizations);
    
    // Check if this customization combination already exists
    if (_customizationIdMap.containsKey(customizationId)) {
      return _customizationIdMap[customizationId]!;
    }
    
    // Generate a new unique ID
    final uniqueId = '${productId}_${DateTime.now().millisecondsSinceEpoch}';
    _customizationIdMap[customizationId] = uniqueId;
    return uniqueId;
  }

  // Set quantity for a specific product
  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _productQuantities.remove(productId);
      _productCustomizations.remove(productId); // Remove customizations when quantity is 0
    } else {
      _productQuantities[productId] = quantity;
    }
    _notifyListeners();
  }
  
  // Set customizations for a specific product
  void setCustomizations(String productId, Map<String, List<String>> customizations) {
    if (_productQuantities.containsKey(productId) && _productQuantities[productId]! > 0) {
      _productCustomizations[productId] = customizations;
      _notifyListeners();
    }
  }
  
  // Add product with customizations (for products with variants)
  // This creates a new cart item with quantity 1 for each unique customization
  void addProductWithCustomizations(String productId, Map<String, List<String>> customizations) {
    final customizationId = getCustomizationId(productId, customizations);
    
    // Check if this exact customization combination already exists
    if (_productCustomizations.containsKey(customizationId)) {
      // If it exists, increment the quantity
      final currentQuantity = _productQuantities[customizationId] ?? 0;
      _productQuantities[customizationId] = currentQuantity + 1;
    } else {
      // If it's new, create with quantity 1
      _productQuantities[customizationId] = 1;
      _productCustomizations[customizationId] = customizations;
    }
    
    _notifyListeners();
  }

  // Update quantity for a specific product (add/subtract)
  void updateQuantity(String productId, int delta) {
    final currentQuantity = _productQuantities[productId] ?? 0;
    final newQuantity = currentQuantity + delta;
    
    if (newQuantity <= 0) {
      _productQuantities.remove(productId);
      _productCustomizations.remove(productId); // Remove customizations when quantity is 0
    } else {
      _productQuantities[productId] = newQuantity;
    }
    _notifyListeners();
  }

  // Add product to cart (increment quantity by 1)
  void addProduct(String productId) {
    updateQuantity(productId, 1);
  }

  // Remove product from cart (decrement quantity by 1)
  void removeProduct(String productId) {
    updateQuantity(productId, -1);
  }

  // Clear all products
  void clearCart() {
    _productQuantities.clear();
    _productCustomizations.clear();
    _customizationIdMap.clear();
    _lastAddedCustomization = null;
    _notifyListeners();
  }

  // Get total number of items in cart
  int get totalItems {
    return _productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // Get total number of unique products
  int get uniqueProductCount {
    return _productQuantities.length;
  }

  // Check if cart is empty
  bool get isEmpty => _productQuantities.isEmpty;

  // Check if cart has items
  bool get isNotEmpty => _productQuantities.isNotEmpty;

  // Check if a specific product is in cart
  bool hasProduct(String productId) {
    return _productQuantities.containsKey(productId) && 
           _productQuantities[productId]! > 0;
  }

  // Load quantities from external data (e.g., from API response)
  void loadFromData(Map<String, int> quantities) {
    _productQuantities.clear();
    _productQuantities.addAll(quantities);
    _notifyListeners();
  }

  // Load quantities from cart data (from CartFetchRequested event)
  void loadFromCartData(List<dynamic> cartItems) {
    _productQuantities.clear();
    
    for (var item in cartItems) {
      if (item is Map<String, dynamic> && 
          item.containsKey('productId') && 
          item.containsKey('quantity')) {
        final productId = item['productId'].toString();
        final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
        
        if (quantity > 0) {
          _productQuantities[productId] = quantity;
        }
      }
    }
    
    _notifyListeners();
  }

  // Notify all listeners of quantity changes
  void _notifyListeners() {
    if (!_quantityController.isClosed) {
      _quantityController.add(Map.from(_productQuantities));
    }
  }

  // Dispose the stream controller
  void dispose() {
    _quantityController.close();
  }
}
