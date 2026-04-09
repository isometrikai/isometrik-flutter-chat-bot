import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/data/model/universal_cart_response.dart' as cart_models;
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/services/services.dart';

class StoreCard extends StatelessWidget {
  final chat.Store store;
  final chat.ChatWidget? storesWidget;
  final chat.Doctor? doctor;
  final int index;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Function(String, chat.Product, chat.Store, int)? onAddToCart;
  final VoidCallback? onHide; // New callback to hide the widget
  final Function(chat.Product?, chat.Store, chat.Doctor?)? onAddToCartRequested; // New callback for cart requests
  final List<cart_models.UniversalCartData>? cartData; // Cart data from getCart API
  final Function(chat.Product?, chat.Store, int, bool)? onQuantityChanged; // Callback for quantity changes
  final Function(chat.Store)? onTableBookingTap;
  final bool isFromChatHistory;
  final bool isTableBookingFlow;

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
    this.isFromChatHistory = false,
    this.doctor,
    this.isTableBookingFlow = false,
    this.onTableBookingTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // if (onTap != null) {
        //   onTap!.call();
        //   return;
        // }
        // if (storesWidget != null) {
        //   final Map<String, dynamic>? storeJson = storesWidget!.getRawStore(index);
        //   OrderService().triggerStoreOrder(storeJson ?? {});
        // }
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
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppConstants.appThemeColor,
                          ),
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
                          SvgPicture.asset(
                            AssetPath.get('images/ic_pin.svg'),
                            width: 14,
                            height: 14,
                            fit: BoxFit.contain,
                          ),
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
                      if ((store.storeTypeId ?? store.type) == FoodCategory.food.value) ...[
                        if (store.storeIsOpen) ...[
                          if (store.supportedOrderTypes == 4) ...[
                            Text(
                              store.tableReservations
                                  ? 'Only table booking or preorders are available.'
                                  : 'Delivery and self-pickup are not available.',
                              maxLines: 1,
                              style: AppTextStyles.restaurantDescription
                                  .copyWith(
                                    color: const Color(0xFFF44336),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                            ),
                          ] else ...[
                            Text(
                              store.cuisineDetails.isNotEmpty
                                  ? store.cuisineDetails
                                  : ' ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.restaurantDescription
                                  .copyWith(color: const Color(0xFF6E4185)),
                            ),
                          ],
                        ] else ...[
                          Text(
                            'Store is closed',
                            maxLines: 1,
                            style: AppTextStyles.restaurantDescription.copyWith(
                              color: const Color(0xFFF44336),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ] else if (store.storeCategoryId == FoodStoreCategoryId.healthCare.value) ...[
                        // if (store.storeIsOpen) ...[
                          Text(
                            '${store.cuisines.isNotEmpty ? store.cuisines.join(', ') : ''}',
                            maxLines: 1,
                            style: AppTextStyles.restaurantDescription.copyWith(
                              color: const Color(0xFF6E4185),
                            ),
                          ),
                        // ] else ...[
                        //   Text(
                        //     'Store is closed',
                        //     maxLines: 1,
                        //     style: AppTextStyles.restaurantDescription.copyWith(
                        //       color: const Color(0xFFF44336),
                        //       fontWeight: FontWeight.w600,
                        //       fontSize: 12,
                        //     ),
                        //   ),
                        // ],
                      ] else ...[
                        if (store.storeIsOpen) ...[
                          Text(
                            store.cuisineDetails.isNotEmpty
                                ? store.cuisineDetails
                                : ' ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.restaurantDescription.copyWith(
                              color: const Color(0xFF6E4185),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Store is closed',
                            maxLines: 1,
                            style: AppTextStyles.restaurantDescription.copyWith(
                              color: const Color(0xFFF44336),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isTableBookingFlow == false) ...[
             const SizedBox(height: 12),
              SizedBox(
                height: 113,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemBuilder:
                      (context, i) => _ProductPreviewTile(
                        product: store.isDoctore == false ? store.products[i] : null,
                        doctor: store.isDoctore == false ? null : store.doctorsList[i],
                        store: store,
                        onAddToCart: onAddToCart,
                        onHide: onHide,
                        // Pass the onHide callback
                        onAddToCartRequested: onAddToCartRequested,
                        // Pass the new callback
                        cartData: cartData,
                        // Pass cart data
                        onQuantityChanged:
                            onQuantityChanged, // Pass quantity change callback
                        isFromChatHistory: isFromChatHistory,
                      ),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: store.isDoctore == false ? store.products.length : store.doctorsList.length,
                ),
              ),
            ],
              if (isFromChatHistory == false) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (onTap != null) {
                      onTap!.call();
                      return;
                    }
                    if (storesWidget != null) {
                      print('StoreCard: onTap called - $index');
                      final Map<String, dynamic>? storeJson =
                          storesWidget!.getRawStore(index);
                      print('StoreCard: storeJson - $storeJson');
                      OrderService().triggerStoreOrder(storeJson ?? {});
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 3),
                      SvgPicture.asset(
                        AssetPath.get('images/ic_eazy_app.svg'),
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          AppConstants.appThemeColor, // Your desired color
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Open in app',
                        style: AppTextStyles.restaurantDescription.copyWith(
                          color: AppConstants.appThemeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isTableBookingFlow == true)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (onTap != null) {
                        onTap!.call();
                        return;
                      }
                      if (storesWidget != null) {
                        onTableBookingTap?.call(store);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        'Book a Table',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.restaurantDescription.copyWith(
                          color: AppConstants.appThemeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            ],
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
        child:
            store.storeImage.isNotEmpty
                ? Image.network(
                  store.storeImage,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _placeholderLogo();
                  },
                  errorBuilder:
                      (context, error, stackTrace) => _placeholderLogo(),
                )
                : _placeholderLogo(),
      ),
    );
  }

  Widget _placeholderLogo() {
    return Center(
      child: SvgPicture.asset(
        AssetPath.get('images/ic_placeHolder.svg'),
        width: 69,
        height: 69,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ProductPreviewTile extends StatelessWidget {
  final chat.Product? product;
  final chat.Store store;
  final chat.Doctor? doctor;
  final Function(String, chat.Product, chat.Store, int)? onAddToCart;
  final VoidCallback? onHide; // New parameter for hiding the widget
  final Function(chat.Product?, chat.Store, chat.Doctor?)? onAddToCartRequested; // New parameter for cart requests
  final List<cart_models.UniversalCartData>? cartData; // Cart data from getCart API
  final Function(chat.Product?, chat.Store, int, bool)? onQuantityChanged; // Callback for quantity changes
  final bool isFromChatHistory;

  const _ProductPreviewTile({
    this.product,
    required this.store,
    this.doctor,
    this.onAddToCart,
    this.onHide, // Add the new parameter
    this.onAddToCartRequested, // Add the new parameter
    this.cartData, // Add cart data parameter
    this.onQuantityChanged, // Add quantity change callback
    this.isFromChatHistory = false,
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
                    if (store.isDoctore == false && product != null) ...[
                      SvgPicture.asset(
                        AssetPath.get(
                          product!.containsMeat
                              ? 'images/ic_NonVeg.svg'
                              : 'images/ic_Veg.svg',
                        ),
                        width: 14,
                        height: 14,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 5),
                    ],
                    Text(
                      store.isDoctore == false && product != null ? product?.productName ?? '' : ('${doctor?.firstName} ${doctor?.lastName}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.productTitle.copyWith(
                        color: const Color(0xFF242424),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (store.isDoctore == false && product != null) ...[
                      Row(
                        children: [
                          Text(
                            '${product?.currency} ${product?.finalPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.productPrice.copyWith(
                              color: const Color(0xFF242424),
                              fontSize: 12,
                            ),
                          ),
                          if (product?.finalPriceList.basePrice !=
                              product?.finalPriceList.finalPrice) ...[
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '${product!.currencySymbol}${product!.finalPriceList.basePrice.toStringAsFixed(0)}',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.productPrice.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: const Color(0xFF979797),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ]else ...[
                      if (doctor?.rating != null && doctor?.rating != 0.0) ...[
                       Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppConstants.appThemeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor?.rating?.toStringAsFixed(1) ?? ''}',
                            style: AppTextStyles.restaurantDescription.copyWith(
                              color: const Color(0xFF242424),
                            ),
                          ),
                        ],
                      ),
                      ]
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 78,
                      height: 78,
                      // color: const Color(0xFFD9D9D9),
                      child: () {
                          final String imageUrl = store.isDoctore == false && product != null
                              ? product?.productImage ?? ''
                              : doctor?.profilePic ?? '';
                          return imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return _placeholderProductImage();
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          _placeholderProductImage(),
                                )
                              : _placeholderProductImage();
                        }(),
                    ),
                  ),
                  if (((store.storeTypeId ?? store.type) != FoodCategory.food.value) && ((store.storeTypeId ?? store.type) != FoodCategory.services.value)) ...[
                    if (product?.instock == false) ...[
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: _buildOutOfStockBadge(),
                      ),
                    ],
                  ],
                ],
              ),
            ],
          ),
          if (isFromChatHistory == false) ...[
           if ((store.storeTypeId ?? store.type) == FoodCategory.food.value) ...[
            if (store.storeIsOpen == true) ...[
              if (store.supportedOrderTypes == 4)
                ...[]
              else
                ...[
                  Positioned(
                      right: 0, bottom: -4, child: _buildAddButton(context)),
                ],
            ] else
              ...[
              ]
          ] else if (((store.storeTypeId ?? store.type) == FoodCategory.services.value)) ...[
              Positioned(
                  right: 0, bottom: -4, child: _buildAddButton(context)),
          ] else ...[
              if (product != null && product?.instock == true) ...[
                Positioned(
                    right: 0, bottom: -4, child: _buildAddButton(context)),
              ],
            ],
          ],
        ],
      ),
    );
  }

  int? _getProductCartQuantity() {
    if (cartData == null || product == null) return null;
    
    try {
      // Find all products with matching ID and sum their quantities
      final matchingProducts = cartData!
          .expand((cartItem) => cartItem.sellers)
          .expand((seller) => seller.products.where((p) => p.id == product?.childProductId))
          .toList();
      
      if (matchingProducts.isEmpty) {
        return null;
      }
      
      // Sum up all quantities for products with the same ID
      int totalQuantity = 0;
      for (final cartProduct in matchingProducts) {
        final qty = cartProduct.quantity?.value ?? 0;
        totalQuantity += qty.toInt();
      }
      
      return totalQuantity;
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
        AssetPath.get('images/ic_placeHolder.svg'),
        width: 78,
        height: 78,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildOutOfStockBadge() {
    return Container(
      width: 70,
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFB),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'OUT OF STOCK',
          style: AppTextStyles.restaurantDescription.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 8,
            height: 1.2,
            color: Color(0xFFF44336),
          ),
        ),
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
                if (onQuantityChanged != null && product != null) {
                  onQuantityChanged!(product, store, cartQuantity, false);
                }
              },
              child: Container(
                width: 27,
                height: 27,
                decoration: const BoxDecoration(
                  color: AppConstants.appThemeColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Icon(Icons.remove, size: 16, color: Colors.white),
              ),
            ),
            // Quantity display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$cartQuantity',
                style: AppTextStyles.button.copyWith(
                  color: AppConstants.appThemeColor,
                ),
              ),
            ),
            // Increase button
            GestureDetector(
              onTap: () {
                if (onQuantityChanged != null && product != null) {
                  onQuantityChanged!(product, store, cartQuantity, true);
                }
              },
              child: Container(
                width: 27,
                height: 27,
                decoration: const BoxDecoration(
                  color: AppConstants.appThemeColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      // Show Add button when product is not in cart
      return GestureDetector(
        onTap: () {
          if (onAddToCartRequested != null) {
            if (doctor != null) {
              onAddToCartRequested!(product, store, doctor);
            } else {
              onAddToCartRequested!(product, store, null);
            }
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
              color: AppConstants.appThemeColor,
            ),
          ),
        ),
      );
    }
  }
}
