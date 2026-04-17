import 'package:chat_bot/utils/text_styles.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

typedef GroceryOnQuantityChanged = void Function(
  String productId,
  String centralProductId,
  int quantity,
  bool isIncrease,
  bool isCustomizable,
);

typedef GroceryOnProductTap = void Function();

typedef GroceryOnAddToCart = void Function(
  String productId,
  String centralProductId,
  int quantity,
  bool isCustomizable,
);

class GroceryProductsGrid extends StatelessWidget {
  final SubCategoryProductsResponse subCategoryProducts;
  final int selectedMainCategoryIndex;
  final List<UniversalCartData> cartData;
  final bool storeIsOpen;
  final int storeTypeId;
  final Color purple;
  final Color vegColor;
  final Color nonVegColor;

  final GroceryOnQuantityChanged onQuantityChanged;
  final GroceryOnProductTap onProductTap;
  final GroceryOnAddToCart onAddToCart;

  const GroceryProductsGrid({
    super.key,
    required this.subCategoryProducts,
    required this.selectedMainCategoryIndex,
    required this.cartData,
    required this.storeIsOpen,
    required this.storeTypeId,
    required this.purple,
    required this.vegColor,
    required this.nonVegColor,
    required this.onQuantityChanged,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (subCategoryProducts.categoryData.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: Color(0xFF979797),
              ),
              const SizedBox(height: 16),
              Text(
                'No products available',
                style: AppTextStyles.restaurantTitle.copyWith(
                  color: const Color(0xFF979797),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or check back later',
                style: AppTextStyles.restaurantDescription.copyWith(
                  color: const Color(0xFF979797),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get products from selected category or all categories
    List<SubCategoryProduct> allProducts = [];
    if (selectedMainCategoryIndex < subCategoryProducts.categoryData.length) {
      allProducts = subCategoryProducts
          .categoryData[selectedMainCategoryIndex]
          .subCategory;
    } else {
      for (final categoryData in subCategoryProducts.categoryData) {
        allProducts.addAll(categoryData.subCategory);
      }
    }

    return Expanded(
      child: Builder(
        builder: (context) {
          final dimensions = _calculateDynamicDimensions(context);
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: dimensions['aspectRatio']!,
              crossAxisSpacing: dimensions['spacing']!,
              mainAxisSpacing: dimensions['spacing']!,
            ),
            itemCount: allProducts.length,
            itemBuilder: (BuildContext context, int index) {
              final subCategoryProduct = allProducts[index];
              final product = subCategoryProduct.toProduct();
              final menuItem = _mapProduct(product);

              return MenuItemCard(
                title: menuItem.title,
                price: menuItem.price,
                originalPrice: menuItem.originalPrice,
                isVeg: menuItem.isVeg,
                imageUrl: menuItem.imageUrl,
                productId: menuItem.productId,
                centralProductId: menuItem.centralProductId,
                isCustomizable: menuItem.isCustomizable,
                purple: purple,
                vegColor: vegColor,
                nonVegColor: nonVegColor,
                imageWidth: dimensions['itemWidth']!,
                imageHeight: dimensions['itemWidth']! * 0.9,
                cardWidth: dimensions['itemWidth']!,
                cartData: cartData,
                instock: product.instock ?? true,
                storeIsOpen: storeIsOpen,
                storeType: product.storeTypeId ?? -111,
                serviceRequireTime: menuItem.serviceRequireTime,
                onQuantityChanged: (
                  productId,
                  centralProductId,
                  quantity,
                  isIncrease,
                  isCustomizable,
                ) {
                  onQuantityChanged(
                    productId,
                    centralProductId,
                    quantity,
                    isIncrease,
                    isCustomizable,
                  );
                },
                onClick: onProductTap,
                onAddToCart: (
                  productId,
                  centralProductId,
                  quantity,
                  isCustomizable,
                ) {
                  onAddToCart(
                    productId,
                    centralProductId,
                    quantity,
                    isCustomizable,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Map<String, double> _calculateDynamicDimensions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate available width (screen width - horizontal padding - spacing)
    final horizontalPadding = 40.0; // 20px on each side
    final availableWidth = screenWidth - horizontalPadding;

    double itemWidth;
    double itemHeight;
    double spacing;

    const double fixedContentHeight = 130.0;

    if (screenWidth < 360) {
      itemWidth = (availableWidth - 12) / 2;
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight + fixedContentHeight;
      spacing = 8.0;
    } else if (screenWidth < 400) {
      itemWidth = (availableWidth - 16) / 2;
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight + fixedContentHeight;
      spacing = 10.0;
    } else {
      itemWidth = (availableWidth - 20) / 2;
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight +
          fixedContentHeight +
          (storeTypeId == FoodCategory.services.value ? 38 : 0);
      spacing = 12.0;
    }

    return {
      'itemWidth': itemWidth,
      'itemHeight': itemHeight,
      'spacing': spacing,
      'aspectRatio': itemWidth / itemHeight,
    };
  }

  _MenuItem _mapProduct(Product p) {
    final String priceText = _formatCurrency(
      p.currency,
      p.finalPriceList.finalPrice,
    );
    final String basePriceText = _formatCurrency(
      p.currency,
      p.finalPriceList.basePrice,
    );
    final String? imageUrl = _extractImageUrl(p.images);
    return _MenuItem(
      title: p.productName,
      price: priceText,
      originalPrice: basePriceText,
      isVeg: !p.containsMeat,
      assetPath: imageUrl ?? '',
      imageUrl: imageUrl,
      productId: p.childProductId,
      centralProductId: p.parentProductId,
      isCustomizable: p.variantCount ?? false,
      serviceRequireTime: p.serviceRequireTime,
    );
  }

  String _formatCurrency(String symbol, double value) {
    if (symbol.isNotEmpty) {
      return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  String? _extractImageUrl(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      return images.isNotEmpty ? images : null;
    }
    if (images is List && images.isNotEmpty) {
      final dynamic first = images.first;
      if (first is String && first.isNotEmpty) return first;
    }
    return null;
  }
}

class _MenuItem {
  final String title;
  final String price;
  final String originalPrice;
  final bool isVeg;
  final String assetPath;
  final String? imageUrl;
  final String? productId;
  final String? centralProductId;
  final bool isCustomizable;
  final String? serviceRequireTime;

  const _MenuItem({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isVeg,
    required this.assetPath,
    this.imageUrl,
    this.productId,
    this.centralProductId,
    this.isCustomizable = false,
    this.serviceRequireTime,
  });
}

