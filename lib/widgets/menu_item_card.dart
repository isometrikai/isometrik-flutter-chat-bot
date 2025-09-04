import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/universal_cart_response.dart';

class MenuItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String originalPrice;
  final bool isVeg;
  final String? imageUrl;
  final String? productId;
  final String? centralProductId;
  final VoidCallback? onClick;
  final Function(String, String, int, bool)? onAddToCart; // productId, centralProductId, quantity, isCustomizable
  final List<UniversalCartData>? cartData; // Cart data from getCart API
  final Function(String, String, int, bool, bool)? onQuantityChanged; // Callback for quantity changes
  final bool isCustomizable;
  final Color purple;
  final Color vegColor;
  final Color nonVegColor;
  

  MenuItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isVeg,
    this.imageUrl,
    this.productId,
    this.centralProductId,
    this.onClick,
    this.onAddToCart,
    this.cartData,
    this.onQuantityChanged,
    this.isCustomizable = false,
    this.purple = const Color(0xFF8E2FFD),
    this.vegColor = const Color(0xFF66BB6A),
    this.nonVegColor = const Color(0xFFF44336),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: SizedBox(
        width: 108,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          width: 108,
                          height: 108,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(
                            width: 108,
                            height: 108,
                            child: ColoredBox(color: Color(0xFFF5F5F5)),
                          ),
                          errorWidget: (context, url, error) => const SizedBox(
                            width: 108,
                            height: 108,
                            child: ColoredBox(color: Color(0xFFF5F5F5)),
                          ),
                        )
                      : const SizedBox(
                          width: 108,
                          height: 108,
                          child: ColoredBox(color: Color(0xFFF5F5F5)),
                        ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isVeg ? vegColor : nonVegColor,
                        width: 1.05,
                      ),
                      borderRadius: BorderRadius.circular(3.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 8.4,
                        height: 8.4,
                        decoration: BoxDecoration(
                          color: isVeg ? vegColor : nonVegColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SizedBox(
              height: 34,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242424),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF242424),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  originalPrice,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF979797),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 37,
              child: _buildQuantityControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls() {
    if (productId == null || productId!.isEmpty) {
      return _buildAddButton();
    }

    // Check if product is in cart and get its quantity
    final cartQuantity = _getProductCartQuantity();
    final isInCart = _isProductInCart();

    if (isInCart && cartQuantity != null && cartQuantity > 0) {
      // Show quantity controls when product is in cart
      return _buildQuantityControlsUI(cartQuantity);
    } else {
      // Show Add button when product is not in cart
      return _buildAddButton();
    }
  }

  // Helper method to check if product is in cart and get its quantity
  int? _getProductCartQuantity() {
    if (cartData == null || productId == null) return null;
    
    try {
      // Use functional programming approach with firstWhere for better performance
      final cartProduct = cartData!
          .expand((cartItem) => cartItem.sellers)
          .expand((seller) => seller.products)
          .firstWhere(
            (cartProduct) => cartProduct.id == productId,
            orElse: () => throw StateError('Product not found'),
          );
      
      return cartProduct.quantity?.value ?? 0;
    } catch (e) {
      // Product not found in cart
      return null;
    }
  }

  // Helper method to check if product is in cart
  bool _isProductInCart() {
    return _getProductCartQuantity() != null && _getProductCartQuantity()! > 0;
  }

  Widget _buildQuantityControlsUI(int quantity) {
    return Container(
      height: 37,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: purple, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          GestureDetector(
            onTap: () {
              if (onQuantityChanged != null && productId != null && centralProductId != null) {
                onQuantityChanged!(productId!, centralProductId!, quantity, false, isCustomizable);
              }
            },
            child: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.remove,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          // Quantity display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.2,
                  color: purple,
                ),
              ),
            ),
          ),
          // Increase button
          GestureDetector(
            onTap: () {
              if (onQuantityChanged != null && productId != null && centralProductId != null) {
                onQuantityChanged!(productId!, centralProductId!, quantity, true, isCustomizable);
              }
            },
            child: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: purple, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      onPressed: () {
        if (onAddToCart != null && productId != null && productId!.isNotEmpty && centralProductId != null && centralProductId!.isNotEmpty) {
          onAddToCart!(productId!, centralProductId!, 1, isCustomizable);
        }
      },
      child: Text(
        'Add',
        style: TextStyle(
          color: purple,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}


