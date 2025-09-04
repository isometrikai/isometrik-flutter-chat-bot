// import 'dart:async';
//
// class CartManager {
//   static final CartManager _instance = CartManager._internal();
//   factory CartManager() => _instance;
//   CartManager._internal();
//
//   // Map to store product quantities: productId -> quantity
//   final Map<String, int> _productQuantities = {};
//
//   // Stream controller for notifying listeners of quantity changes
//   final StreamController<Map<String, int>> _quantityController =
//       StreamController<Map<String, int>>.broadcast();
//
//   // Stream to listen to quantity changes
//   Stream<Map<String, int>> get quantityStream => _quantityController.stream;
//
//   // Get current quantities map
//   Map<String, int> get productQuantities => Map.from(_productQuantities);
//
//   // Get quantity for a specific product
//   int getQuantity(String productId) {
//     return _productQuantities[productId] ?? 0;
//   }
//
//   // Set quantity for a specific product
//   void setQuantity(String productId, int quantity) {
//     if (quantity <= 0) {
//       _productQuantities.remove(productId);
//     } else {
//       _productQuantities[productId] = quantity;
//     }
//     _notifyListeners();
//   }
//
//   // Update quantity for a specific product (add/subtract)
//   void updateQuantity(String productId, int delta) {
//     final currentQuantity = _productQuantities[productId] ?? 0;
//     final newQuantity = currentQuantity + delta;
//
//     if (newQuantity <= 0) {
//       _productQuantities.remove(productId);
//     } else {
//       _productQuantities[productId] = newQuantity;
//     }
//     _notifyListeners();
//   }
//
//   // Add product to cart (increment quantity by 1)
//   void addProduct(String productId) {
//     updateQuantity(productId, 1);
//   }
//
//   // Remove product from cart (decrement quantity by 1)
//   void removeProduct(String productId) {
//     updateQuantity(productId, -1);
//   }
//
//   // Clear all products
//   void clearCart() {
//     _productQuantities.clear();
//     _notifyListeners();
//   }
//
//   // Get total number of items in cart
//   int get totalItems {
//     return _productQuantities.values.fold(0, (sum, quantity) => sum + quantity);
//   }
//
//   // Get total number of unique products
//   int get uniqueProductCount {
//     return _productQuantities.length;
//   }
//
//   // Check if cart is empty
//   bool get isEmpty => _productQuantities.isEmpty;
//
//   // Check if cart has items
//   bool get isNotEmpty => _productQuantities.isNotEmpty;
//
//   // Check if a specific product is in cart
//   bool hasProduct(String productId) {
//     return _productQuantities.containsKey(productId) &&
//            _productQuantities[productId]! > 0;
//   }
//
//   // Load quantities from external data (e.g., from API response)
//   void loadFromData(Map<String, int> quantities) {
//     _productQuantities.clear();
//     _productQuantities.addAll(quantities);
//     _notifyListeners();
//   }
//
//   // Load quantities from cart data (from CartFetchRequested event)
//   void loadFromCartData(List<dynamic> cartItems) {
//     _productQuantities.clear();
//
//     for (var item in cartItems) {
//       if (item is Map<String, dynamic> &&
//           item.containsKey('productId') &&
//           item.containsKey('quantity')) {
//         final productId = item['productId'].toString();
//         final quantity = int.tryParse(item['quantity'].toString()) ?? 0;
//
//         if (quantity > 0) {
//           _productQuantities[productId] = quantity;
//         }
//       }
//     }
//
//     _notifyListeners();
//   }
//
//   // Notify all listeners of quantity changes
//   void _notifyListeners() {
//     if (!_quantityController.isClosed) {
//       _quantityController.add(Map.from(_productQuantities));
//     }
//   }
//
//   // Dispose the stream controller
//   void dispose() {
//     _quantityController.close();
//   }
// }
