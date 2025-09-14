import 'package:chat_bot/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart' as chat;
import 'package:chat_bot/data/model/universal_cart_response.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/asset_helper.dart';
import '../utils/asset_helper_svg.dart';
import '../utils/asset_path.dart';
import 'black_toast_view.dart';
import '../utils/text_styles.dart';

class StoreCard extends StatelessWidget {
  final chat.Store store;
  final chat.ChatWidget? storesWidget;
  final int index;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Function(String, chat.Product, chat.Store, int)? onAddToCart;
  final VoidCallback? onHide; // New callback to hide the widget
  final Function(chat.Product, chat.Store)? onAddToCartRequested; // New callback for cart requests
  final List<UniversalCartData>? cartData; // Cart data from getCart API
  final Function(chat.Product, chat.Store, int, bool)? onQuantityChanged; // Callback for quantity changes

   StoreCard({
    super.key,
    required this.store,
    required this.storesWidget,
    required this.index,
    this.margin,
    this.onTap,
    this.onAddToCart,
    this.onHide, // Add the new parameter
    this.onAddToCartRequested, // Add the new parameter
    this.cartData, // Add cart data parameter
    this.onQuantityChanged, // Add quantity change callback
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store name
                      Text(
                        store.storename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.restaurantTitle.copyWith(
                          color: const Color(0xFF242424),
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
                            style: AppTextStyles.restaurantDescription.copyWith(
                              color: const Color(0xFF242424),
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
                            style: AppTextStyles.restaurantDescription.copyWith(
                              color: const Color(0xFF242424),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Cuisine subtitle
                      if (store.storeIsOpen) ...[
                      Text(
                        store.cuisineDetails.isNotEmpty ? store.cuisineDetails : ' ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.restaurantDescription.copyWith(
                          color: const Color(0xFF6E4185),
                        ),
                      ),
                      ]else ...[
                        Text(
                          'Store is closed',
                          maxLines: 1,
                          style: AppTextStyles.restaurantDescription.copyWith(
                            color: const Color(0xFFF44336),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,

                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (store.products.isNotEmpty)
              SizedBox(
                height: 113,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, i) => _ProductPreviewTile(
                    product: store.products[i],
                    store: store,
                    onAddToCart: onAddToCart,
                    onHide: onHide, // Pass the onHide callback
                    onAddToCartRequested: onAddToCartRequested, // Pass the new callback
                    cartData: cartData, // Pass cart data
                    onQuantityChanged: onQuantityChanged, // Pass quantity change callback
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: store.products.length,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const SizedBox(width: 3),
                 SvgPicture.asset(
                          AssetPath.get('images/ic_eazy_app.svg'),
                          fit: BoxFit.contain,
                        ),
                  const SizedBox(width: 5),
                   Text('Open in Eazy app'
                    ,style: AppTextStyles.restaurantDescription.copyWith(
                      color: const Color(0xFF8E2FFD),
                    ),
              )
                ],
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
        child: store.storeImage.isNotEmpty
            ? Image.network(
          store.storeImage,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _placeholderLogo();
          },
          errorBuilder: (context, error, stackTrace) => _placeholderLogo(),
        )
            : _placeholderLogo(),
      ),
    );
  }

  Widget _placeholderLogo() {
    return Center(
      child: SvgPicture.asset(
        AssetPath.get(
        'images/ic_placeHolder.svg',
        ),
        width: 69,
        height: 69,
        fit: BoxFit.cover,
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
  final chat.Product product;
  final chat.Store store;
  final Function(String, chat.Product, chat.Store, int)? onAddToCart;
  final VoidCallback? onHide; // New parameter for hiding the widget
  final Function(chat.Product, chat.Store)? onAddToCartRequested; // New parameter for cart requests
  final List<UniversalCartData>? cartData; // Cart data from getCart API
  final Function(chat.Product, chat.Store, int, bool)? onQuantityChanged; // Callback for quantity changes

  const _ProductPreviewTile({
    required this.product,
    required this.store,
    this.onAddToCart,
    this.onHide, // Add the new parameter
    this.onAddToCartRequested, // Add the new parameter
    this.cartData, // Add cart data parameter
    this.onQuantityChanged, // Add quantity change callback
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
                    Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: product.containsMeat ? const Color(0xFFF44336) : const Color(0xFF66BB6A),
                        width: 1.05,
                      ),
                      borderRadius: BorderRadius.circular(3.5),
                    ),
                    child: Center(
                      child: Container(
                        width: 8.4,
                        height: 8.4,
                        decoration: BoxDecoration(
                          color: product.containsMeat ? const Color(0xFFF44336) : const Color(0xFF66BB6A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                    const SizedBox(height: 5),
                    Text(
                      product.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.productTitle.copyWith(
                        color: const Color(0xFF242424),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          '${product.currencySymbol}${product.finalPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.productPrice.copyWith(
                            color: const Color(0xFF242424),
                            fontSize: 12,
                          ),
                        ),
                        if (product.finalPriceList.basePrice != product.finalPriceList.finalPrice) ...[
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${product.currencySymbol}${product.finalPriceList.basePrice.toStringAsFixed(0)}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.productPrice.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF979797),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ]
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
                  // color: const Color(0xFFD9D9D9),
                  child: product.productImage.isNotEmpty
                      ? Image.network(
                          product.productImage,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _placeholderProductImage();
                          },
                          errorBuilder: (context, error, stackTrace) => _placeholderProductImage(),
                        )
                      : _placeholderProductImage(),
                ),
              ),
            ],
          ),
          // if (product.instock == true) ...[
            Positioned(
              right: 0,
              bottom: -4,
              child: _buildAddButton(context),
            ),
          // ],
        ],
      ),
    );
  }

  // Helper method to check if product is in cart and get its quantity
  int? _getProductCartQuantity() {
    if (cartData == null) return null;
    
    try {
      // Use functional programming approach with firstWhere for better performance
      final cartProduct = cartData!
          .expand((cartItem) => cartItem.sellers)
          .expand((seller) => seller.products)
          .firstWhere(
            (cartProduct) => cartProduct.id == product.childProductId,
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

  Widget _placeholderProductImage() {
    return Center(
      child: SvgPicture.asset(
        AssetPath.get(
        'images/ic_placeHolder.svg',),
        width: 78,
        height: 78,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final cartQuantity = _getProductCartQuantity();
    final isInCart = _isProductInCart();
    
    if (isInCart && cartQuantity != null && cartQuantity > 0) {
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
            // Decrease button
            GestureDetector(
              onTap: () {
                if (onQuantityChanged != null) {
                  onQuantityChanged!(product, store, cartQuantity, false);
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
                child: const Icon(
                  Icons.remove,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            // Quantity display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$cartQuantity',
                style: AppTextStyles.button.copyWith(
                  color: const Color(0xFF8E2FFD),
                ),
              ),
            ),
            // Increase button
            GestureDetector(
              onTap: () {
                if (onQuantityChanged != null) {
                  onQuantityChanged!(product, store, cartQuantity, true);
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
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Show Add button when product is not in cart
      return GestureDetector(
        onTap: () {
          if (store.storeIsOpen == false && store.type == FoodCategory.grocery.value) {
            print("STORE IS CLOSED");
            BlackToastView.show(context, 'Store is closed. Please try again later');
            return;
          }else if (product.instock == false && store.type == FoodCategory.grocery.value) {
            print('Product is not in stock');
            BlackToastView.show(context, 'Product is not in stock. Please try again later');
            return;
          }
          if (onAddToCartRequested != null) {
            onAddToCartRequested!(product, store);
          }
          // Call onHide callback if provided
          if (onHide != null) {
            onHide!();
          }
        },
        child: Container(
          height: 27,
          width: 78,
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
          child: Text(
            'Add',
            style: AppTextStyles.button.copyWith(
              color: const Color(0xFF8E2FFD),
            ),
          ),
        ),
      );
    }
  }
}