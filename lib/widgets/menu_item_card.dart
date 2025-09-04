import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/services/cart_manager.dart';

class MenuItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String originalPrice;
  final bool isVeg;
  final String? imageUrl;
  final String? productId;
  final VoidCallback? onClick;
  final Function(String, String, int)? onAddToCart; // message, productId, quantity

  final Color purple;
  final Color vegColor;
  final Color nonVegColor;
  final CartManager cartManager = CartManager();

  MenuItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isVeg,
    this.imageUrl,
    this.productId,
    this.onClick,
    this.onAddToCart,
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
                      ?
                  Image.network(
                    imageUrl!,
                    width: 108,
                    height: 108,
                    fit: BoxFit.cover,
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

    return StreamBuilder<Map<String, int>>(
      stream: cartManager.quantityStream,
      builder: (context, snapshot) {
        final currentQuantity = cartManager.getQuantity(productId!);
        
        if (currentQuantity == 0) {
          // Show "Add" button when product is not in cart
          return _buildAddButton();
        } else {
          // Show quantity controls when product is in cart
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
                // Minus button
                GestureDetector(
                  onTap: () {
                    if (productId != null && productId!.isNotEmpty) {
                      cartManager.removeProduct(productId!);
                      if (onAddToCart != null) {
                        final newQuantity = cartManager.getQuantity(productId!);
                        onAddToCart!("Removed 1X $title from cart", productId!, newQuantity);
                      }
                    }
                  },
                  child: Container(
                    width: 37,
                    height: 37,
                    decoration: BoxDecoration(
                      color: purple,
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
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      currentQuantity.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.2,
                        color: purple,
                      ),
                    ),
                  ),
                ),
                
                // Plus button
                GestureDetector(
                  onTap: () {
                    if (productId != null && productId!.isNotEmpty) {
                      cartManager.addProduct(productId!);
                      if (onAddToCart != null) {
                        final newQuantity = cartManager.getQuantity(productId!);
                        onAddToCart!("Added 1X $title to cart", productId!, newQuantity);
                      }
                    }
                  },
                  child: Container(
                    width: 37,
                    height: 37,
                    decoration: BoxDecoration(
                      color: purple,
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
        if (onAddToCart != null && productId != null && productId!.isNotEmpty) {
          final newQuantity = cartManager.getQuantity(productId!) + 1;
          onAddToCart!("Add 1X $title to cart", productId!, newQuantity);
          cartManager.setQuantity(productId!, newQuantity);
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


