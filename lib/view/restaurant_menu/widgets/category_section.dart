import 'package:flutter/material.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:chat_bot/view/restaurant_menu/helpers/menu_filter.dart';
import 'package:chat_bot/view/restaurant_menu/helpers/restaurant_menu_cart_actions.dart';
import 'package:chat_bot/view/restaurant_menu/models/menu_item.dart';
import 'package:chat_bot/view/restaurant_menu/restaurant_menu_colors.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/category_chips.dart';

class RestaurantCategorySection extends StatelessWidget {
  const RestaurantCategorySection({
    super.key,
    required this.category,
    required this.selectedSubIndex,
    required this.onSubSelected,
    required this.filterCriteria,
    required this.cartData,
    required this.cartActions,
    required this.actionData,
    required this.categories,
  });

  final ProductCategory category;
  final int selectedSubIndex;
  final ValueChanged<int> onSubSelected;
  final MenuFilterCriteria filterCriteria;
  final List<UniversalCartData> cartData;
  final RestaurantMenuCartActions cartActions;
  final chat.WidgetAction? actionData;
  final List<ProductCategory> categories;

  @override
  Widget build(BuildContext context) {
    final bool storeIsOpen = actionData?.storeIsOpen ?? true;
    final List<MenuItem> items = MenuFilter.productsForCategory(
      category: category,
      selectedSubIndex: selectedSubIndex,
      storeIsOpen: storeIsOpen,
    );
    final List<MenuItem> filtered = MenuFilter.filterItems(items, filterCriteria);

    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          category.catName,
          style: AppTextStyles.restaurantTitle.copyWith(
            color: RestaurantMenuColors.title,
          ),
        ),
        const SizedBox(height: 8),
        if (category.isSubCategories &&
            category.subCategories.isNotEmpty) ...<Widget>[
          RestaurantSubcategoryChips(
            category: category,
            selectedIndex: selectedSubIndex,
            onSelected: onSubSelected,
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 222 + 18,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final MenuItem item = filtered[index];
              return MenuItemCard(
                title: item.title,
                price: item.price,
                originalPrice: item.originalPrice,
                isVeg: item.isVeg,
                imageUrl: item.imageUrl,
                productId: item.productId,
                centralProductId: item.centralProductId,
                isCustomizable: item.isCustomizable,
                purple: RestaurantMenuColors.purple,
                vegColor: RestaurantMenuColors.veg,
                nonVegColor: RestaurantMenuColors.nonVeg,
                cartData: cartData,
                instock: item.instock,
                storeIsOpen: storeIsOpen,
                storeType: actionData?.storeTypeId ?? -111,
                onQuantityChanged: (
                  productId,
                  centralProductId,
                  quantity,
                  isIncrease,
                  isCustomizable,
                ) {
                  cartActions.onQuantityChanged(
                    context: context,
                    productId: productId,
                    centralProductId: centralProductId,
                    currentQuantity: quantity,
                    isIncrease: isIncrease,
                    isCustomizable: isCustomizable,
                    productName: item.title,
                    productImage: item.imageUrl ?? '',
                  );
                },
                onClick: () {
                  final chat.Product? foundProduct =
                      RestaurantMenuCartActions.findProduct(
                    categories,
                    item.productId,
                  );
                  if (foundProduct != null) {
                    cartActions.triggerProductOrder(
                      product: foundProduct,
                      actionData: actionData,
                    );
                  }
                },
                onAddToCart: (
                  productId,
                  centralProductId,
                  quantity,
                  isCustomizable,
                ) {
                  cartActions.onAddToCart(
                    context: context,
                    productId: productId,
                    centralProductId: centralProductId,
                    quantity: quantity,
                    isCustomizable: isCustomizable,
                    productName: item.title,
                    productImage:
                        item.imageUrl?.isNotEmpty ?? false
                            ? item.imageUrl
                            : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
