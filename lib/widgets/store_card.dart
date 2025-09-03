import 'package:chat_bot/services/cart_manager.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/services/callback_manage.dart';
import '../utils/asset_helper.dart';
import '../view/product_customization_screen.dart';
import '../view/customization_summary_screen.dart';

class StoreCard extends StatelessWidget {
  final Store store;
  final ChatWidget? storesWidget;
  final int index;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Function(String, Product, Store, int)? onAddToCart;
  final VoidCallback? onHide; // New callback to hide the widget

  final CartManager cartManager = CartManager();

   StoreCard({
    super.key,
    required this.store,
    required this.storesWidget,
    required this.index,
    this.margin,
    this.onTap,
    this.onAddToCart,
    this.onHide, // Add the new parameter
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!.call();
          return;
        }
        if (storesWidget != null) {
          final Map<String, dynamic>? storeJson = storesWidget!.getRawStore(index);
          OrderService().triggerStoreOrder(storeJson ?? {});
        }
      },
      child: Container(
        // margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          border: Border.all(color: const Color(0xFFEEF4FF), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store name
                      Text(
                        store.storename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          height: 1.2,
                          color: Color(0xFF242424),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Rating | ETA
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFA674BF)),
                          const SizedBox(width: 4),
                          Text(
                            store.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFF242424),
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            '|',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFFD7CDE9),
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(Icons.access_time, size: 14, color: Color(0xFFA674BF)),
                          const SizedBox(width: 4),
                          Text(
                            store.distance,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFF242424),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Cuisine subtitle
                      Text(
                        store.cuisineDetails.isNotEmpty ? store.cuisineDetails : ' ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF6E4185),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (store.products.isNotEmpty)
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, i) => _ProductPreviewTile(
                    product: store.products[i],
                    store: store,
                    cartManager: cartManager,
                    onAddToCart: onAddToCart,
                    onHide: onHide, // Pass the onHide callback
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: store.products.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 69,
        height: 69,
        color: const Color(0xFFFFF067),
        child: store.storeImage.isNotEmpty
            ? Image.network(
          store.storeImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _defaultLogo(),
        )
            : _defaultLogo(),
      ),
    );
  }

  Widget _defaultLogo() {
    return const Center(
      child: Icon(
        Icons.storefront,
        size: 28,
        color: Color(0xFF363648),
      ),
    );
  }

  static String _formatEta(double distanceKm) {
    // Very rough heuristic: 1 km ~ 2 min delivery time
    if (distanceKm <= 0) return '15–20 min';
    final int minutes = (distanceKm * 2).clamp(10, 45).round();
    final int minLow = (minutes - 3).clamp(8, minutes);
    final int minHigh = (minutes + 2).clamp(minutes, 50);
    return '$minLow–$minHigh min';
  }
}

class _ProductPreviewTile extends StatelessWidget {
  final Product product;
  final Store store;
  final CartManager cartManager;
  final Function(String, Product, Store, int)? onAddToCart;
  final VoidCallback? onHide; // New parameter for hiding the widget

  const _ProductPreviewTile({
    required this.product,
    required this.store,
    required this.cartManager,
    this.onAddToCart,
    this.onHide, // Add the new parameter
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 241,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF4FF), width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // Make the left content flexible to avoid pixel rounding overflows
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.variantsCount.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.2,
                        color: Color(0xFF242424),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '${product.currencySymbol}${product.finalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF242424),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${product.currencySymbol}${product.finalPriceList.basePrice.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              decoration: TextDecoration.lineThrough,
                              color: Color(0xFF979797),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 78,
                  height: 78,
                  color: const Color(0xFFD9D9D9),
                  child: product.productImage.isNotEmpty
                      ? Image.network(product.productImage, fit: BoxFit.cover)
                      : AssetHelper.imageAsset('images/men.png', fit: BoxFit.cover),
                ),
              ),
            ],
          ),
          Positioned(
            right: 10,
            bottom: -4,
            child: _buildQuantityControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls() {
    return StreamBuilder<Map<String, int>>(
      stream: cartManager.quantityStream,
      builder: (context, snapshot) {
        // Check if this product or any of its variants are in the cart
        final currentQuantities = cartManager.productQuantities;
        
        // For products with variants, check if any customization combination exists
        // For single variant products, check the direct product ID
        bool isInCart = false;
        int totalQuantity = 0;
        String? cartProductId = null;
        
        if (product.variantsCount > 1) {
          // Check if any customization combination exists for this product
          for (final entry in currentQuantities.entries) {
            if (entry.key.startsWith(product.childProductId + '_') && entry.value > 0) {
              isInCart = true;
              totalQuantity += entry.value;
              cartProductId = entry.key;
            }
          }
        } else {
          // Single variant product - check direct ID
          final quantity = currentQuantities[product.childProductId] ?? 0;
          if (quantity > 0) {
            isInCart = true;
            totalQuantity = quantity;
            cartProductId = product.childProductId;
          }
        }
        
        if (!isInCart) {
            // Show "Add" button when product is not in cart
            return GestureDetector(
              onTap: () {
                                // Check if product has multiple variants
                print("Product: ${product.productName}, variantsCount: ${product.variantsCount}"); // Debug log
                if (product.variantsCount > 1) {
                  // Present ProductCustomizationScreen as a modal for products with multiple variants
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ProductCustomizationScreen(
                      product: product,
                      store: store,
                                                onAddToCart: onAddToCart != null ? (message) {
                            print("StoreCard received callback from ProductCustomizationScreen: $message"); // Debug log
                            // Call the existing onAddToCart callback with the variant message
                            // Get the current quantity when the callback is executed
                            final currentQuantity = cartManager.getQuantity(product.childProductId);
                            print("StoreCard calling onAddToCart with message: $message, quantity: $currentQuantity"); // Debug log
                            print("About to execute final onAddToCart callback..."); // Debug log
                            onAddToCart!(message, product, store, currentQuantity);
                            print("Final onAddToCart callback executed successfully"); // Debug log
                          } : null,
                    ),
                  );
                } else {
                  // Use existing logic for products with single variant
                  print("Using single variant logic for: ${product.productName}"); // Debug log
                  if (onAddToCart != null) {
                    final currentQuantity = cartManager.getQuantity(product.childProductId);
                    final newQuantity = currentQuantity + 1;
                    final quantityToAdd = newQuantity - currentQuantity; // Always 1 for "Add" button
                    
                    // Store basic customization info for single variant products
                    final customizations = <String, List<String>>{
                      'variant': [product.productName], // Use product name as variant for single variant products
                    };
                    cartManager.setCustomizations(product.childProductId, customizations);
                    
                    // Store this as the last added customization for "Repeat last" functionality
                    cartManager.setLastAddedCustomization(
                      product.childProductId,
                      product.productName,
                      customizations,
                    );
                    
                    onAddToCart!("Add ${quantityToAdd}X ${product.productName} to cart", product, store, newQuantity);
                    cartManager.setQuantity(product.childProductId, newQuantity);
                  }
                  
                  if (onHide != null) {
                    onHide!();
                  }
                }
              },
            child: Container(
              height: 27,
              padding: const EdgeInsets.symmetric(horizontal: 17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Add',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  height: 1.2,
                  color: Color(0xFF8E2FFD),
                ),
              ),
            ),
          );
        } else {
          // Show quantity controls when product is in cart
          return Container(
            height: 27,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus button
                GestureDetector(
                  onTap: () {
                    if (product.variantsCount > 1 && cartProductId != null) {
                      // For variant products, remove from the specific customization
                      cartManager.removeProduct(cartProductId);
                    } else {
                      // For single variant products, remove from the direct ID
                      cartManager.removeProduct(product.childProductId);
                    }
                    
                    if (onAddToCart != null) {
                      final newQuantity = cartManager.getQuantity(cartProductId ?? product.childProductId);
                      onAddToCart!("Removed 1X ${product.productName} from cart", product, store, newQuantity);
                    }
                  },
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8E2FFD),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Quantity display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  child: Text(
                    totalQuantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.2,
                      color: Color(0xFF8E2FFD),
                    ),
                  ),
                ),
                
                // Plus button
                GestureDetector(
                  onTap: () {
                    // Check if product has multiple variants
                    print("Plus button clicked for: ${product.productName}, variantsCount: ${product.variantsCount}"); // Debug log
                    if (product.variantsCount > 1) {
                      print("Opening CustomizationSummaryScreen for: ${product.productName}"); // Debug log
                      // Present CustomizationSummaryScreen as a modal for products with multiple variants
                      // This ensures each customization combination is treated as a separate cart item
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CustomizationSummaryScreen(
                          store: store,
                          product: product,
                          onAddToCart: onAddToCart,
                        ),
                      );
                    } else {
                      print("Using single variant logic for plus button: ${product.productName}"); // Debug log
                      // Use existing logic for products with single variant
                      cartManager.addProduct(product.childProductId);
                      
                      // Preserve existing customizations or set default ones
                      final existingCustomizations = cartManager.getCustomizations(product.childProductId);
                      if (existingCustomizations == null) {
                        final customizations = <String, List<String>>{
                          'variant': [product.productName],
                        };
                        cartManager.setCustomizations(product.childProductId, customizations);
                      }
                      
                      if (onAddToCart != null) {
                        final newQuantity = cartManager.getQuantity(product.childProductId);
                        onAddToCart!("Added 1X ${product.productName} to cart", product, store, newQuantity);
                      }
                    }
                  },
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8E2FFD),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}