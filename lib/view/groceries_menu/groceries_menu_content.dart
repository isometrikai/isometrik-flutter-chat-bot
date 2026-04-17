import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../data/data.dart' as chat;
import '../../utils/utils.dart';
import 'grocery_category_filter_chips.dart';
import 'grocery_products_grid.dart';

class GroceriesMenuContent extends StatelessWidget {
  final chat.WidgetAction? actionData;
  final SubCategoryProductsResponse subCategoryProducts;
  final int selectedMainCategoryIndex;
  final ValueChanged<int> onSelectedMainCategoryIndexChanged;
  final List<UniversalCartData> cartData;
  final Color purple;
  final Color border;
  final Color vegColor;
  final Color nonVegColor;

  final GroceryOnQuantityChanged onQuantityChanged;
  final VoidCallback onProductTap;
  final GroceryOnAddToCart onAddToCart;

  const GroceriesMenuContent({
    super.key,
    required this.actionData,
    required this.subCategoryProducts,
    required this.selectedMainCategoryIndex,
    required this.onSelectedMainCategoryIndexChanged,
    required this.cartData,
    required this.purple,
    required this.border,
    required this.vegColor,
    required this.nonVegColor,
    required this.onQuantityChanged,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (actionData?.storeTypeId != FoodCategory.services.value) ...[
            GroceryCategoryFilterChips(
              subCategoryProducts: subCategoryProducts,
              selectedIndex: selectedMainCategoryIndex,
              onSelected: onSelectedMainCategoryIndexChanged,
              purple: purple,
              border: border,
            ),
            const SizedBox(height: 16),
          ],

          GroceryProductsGrid(
            subCategoryProducts: subCategoryProducts,
            selectedMainCategoryIndex: selectedMainCategoryIndex,
            cartData: cartData,
            storeIsOpen: actionData?.storeIsOpen ?? true,
            storeTypeId: actionData?.storeTypeId ?? -111,
            purple: purple,
            vegColor: vegColor,
            nonVegColor: nonVegColor,
            onQuantityChanged: onQuantityChanged,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ],
      ),
    );
  }
}

