import 'package:flutter/material.dart';
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/restaurant_menu/helpers/menu_filter.dart';
import 'package:chat_bot/view/restaurant_menu/helpers/restaurant_menu_cart_actions.dart';
import 'package:chat_bot/view/restaurant_menu/restaurant_menu_colors.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/category_chips.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/category_section.dart';

class RestaurantMenuContent extends StatelessWidget {
  const RestaurantMenuContent({
    super.key,
    required this.state,
    required this.selectedMainCategoryIndex,
    required this.selectedSubIndex,
    required this.subIndexByCategory,
    required this.filterCriteria,
    required this.cartData,
    required this.cartActions,
    required this.actionData,
    required this.onMainCategorySelected,
    required this.onSubSelected,
  });

  final RestaurantMenuState state;
  final int selectedMainCategoryIndex;
  final int selectedSubIndex;
  final Map<String, int> subIndexByCategory;
  final MenuFilterCriteria filterCriteria;
  final List<UniversalCartData> cartData;
  final RestaurantMenuCartActions cartActions;
  final chat.WidgetAction? actionData;
  final ValueChanged<int> onMainCategorySelected;
  final void Function(ProductCategory category, int index) onSubSelected;

  @override
  Widget build(BuildContext context) {
    if (state is RestaurantMenuInitial ||
        state is RestaurantMenuLoadInProgress) {
      return const SizedBox.shrink();
    }

    if (state is RestaurantMenuLoadFailure) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text(
          (state as RestaurantMenuLoadFailure).message,
          style: AppTextStyles.bodyText.copyWith(color: Colors.red),
        ),
      );
    }

    final categories = (state as RestaurantMenuLoadSuccess).categories;
    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Text(
          AppTranslations.noMenuAvailable,
          style: AppTextStyles.bodyText.copyWith(
            color: RestaurantMenuColors.emptyMessage,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RestaurantMainCategoryChips(
          categories: categories,
          selectedIndex: selectedMainCategoryIndex,
          onSelected: onMainCategorySelected,
        ),
        const SizedBox(height: 24),
        _CategorySections(
          categories: categories,
          selectedMainCategoryIndex: selectedMainCategoryIndex,
          selectedSubIndex: selectedSubIndex,
          subIndexByCategory: subIndexByCategory,
          filterCriteria: filterCriteria,
          cartData: cartData,
          cartActions: cartActions,
          actionData: actionData,
          onSubSelected: onSubSelected,
        ),
      ],
    );
  }
}

class _CategorySections extends StatelessWidget {
  const _CategorySections({
    required this.categories,
    required this.selectedMainCategoryIndex,
    required this.selectedSubIndex,
    required this.subIndexByCategory,
    required this.filterCriteria,
    required this.cartData,
    required this.cartActions,
    required this.actionData,
    required this.onSubSelected,
  });

  final List<ProductCategory> categories;
  final int selectedMainCategoryIndex;
  final int selectedSubIndex;
  final Map<String, int> subIndexByCategory;
  final MenuFilterCriteria filterCriteria;
  final List<UniversalCartData> cartData;
  final RestaurantMenuCartActions cartActions;
  final chat.WidgetAction? actionData;
  final void Function(ProductCategory category, int index) onSubSelected;

  Widget _emptyProducts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Text(
          AppTranslations.noProductsFound,
          style: AppTextStyles.bodyText.copyWith(
            color: RestaurantMenuColors.emptyMessage,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool storeIsOpen = actionData?.storeIsOpen ?? true;
    final ProductCategory? currentCategory =
        (categories.isNotEmpty && selectedMainCategoryIndex > 0)
            ? categories[selectedMainCategoryIndex - 1]
            : null;

    if (currentCategory == null) {
      final List<Widget> sections = <Widget>[];
      for (final ProductCategory category in categories) {
        if (!MenuFilter.hasMatchingProducts(
          category,
          filterCriteria,
          storeIsOpen: storeIsOpen,
        )) {
          continue;
        }
        sections.add(
          RestaurantCategorySection(
            category: category,
            selectedSubIndex: subIndexByCategory[category.catName] ?? 0,
            onSubSelected: (int idx) => onSubSelected(category, idx),
            filterCriteria: filterCriteria,
            cartData: cartData,
            cartActions: cartActions,
            actionData: actionData,
            categories: categories,
          ),
        );
        sections.add(const SizedBox(height: 24));
      }

      if (sections.isEmpty) return _emptyProducts();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections,
      );
    }

    if (!MenuFilter.hasMatchingProducts(
      currentCategory,
      filterCriteria,
      storeIsOpen: storeIsOpen,
    )) {
      return _emptyProducts();
    }

    return RestaurantCategorySection(
      category: currentCategory,
      selectedSubIndex: selectedSubIndex,
      onSubSelected: (int idx) => onSubSelected(currentCategory, idx),
      filterCriteria: filterCriteria,
      cartData: cartData,
      cartActions: cartActions,
      actionData: actionData,
      categories: categories,
    );
  }
}
