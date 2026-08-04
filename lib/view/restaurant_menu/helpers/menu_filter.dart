import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/view/restaurant_menu/helpers/menu_item_mapper.dart';
import 'package:chat_bot/view/restaurant_menu/models/menu_item.dart';

class MenuFilterCriteria {
  final bool filterVeg;
  final bool filterNonVeg;
  final String searchQuery;

  const MenuFilterCriteria({
    this.filterVeg = false,
    this.filterNonVeg = false,
    this.searchQuery = '',
  });
}

abstract final class MenuFilter {
  static bool matches(MenuItem item, MenuFilterCriteria criteria) {
    final String query = criteria.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty && !item.title.toLowerCase().contains(query)) {
      return false;
    }

    if (!criteria.filterVeg && !criteria.filterNonVeg) {
      return true;
    }
    if (criteria.filterVeg && !criteria.filterNonVeg && !item.isVeg) {
      return false;
    }
    if (criteria.filterNonVeg && !criteria.filterVeg && item.isVeg) {
      return false;
    }
    return true;
  }

  static List<MenuItem> filterItems(
    List<MenuItem> items,
    MenuFilterCriteria criteria,
  ) {
    return items.where((item) => matches(item, criteria)).toList();
  }

  static List<MenuItem> productsForCategory({
    required ProductCategory category,
    required int selectedSubIndex,
    required bool storeIsOpen,
  }) {
    if (category.isSubCategories && category.subCategories.isNotEmpty) {
      final int subIndex =
          (selectedSubIndex >= 0 &&
                  selectedSubIndex < category.subCategories.length)
              ? selectedSubIndex
              : 0;
      return category.subCategories[subIndex].products
          .map(
            (p) => MenuItemMapper.fromProduct(p, storeIsOpen: storeIsOpen),
          )
          .toList();
    }
    return category.products
        .map((p) => MenuItemMapper.fromProduct(p, storeIsOpen: storeIsOpen))
        .toList();
  }

  static List<MenuItem> allProductsInCategory(
    ProductCategory category, {
    required bool storeIsOpen,
  }) {
    if (category.isSubCategories && category.subCategories.isNotEmpty) {
      return category.subCategories
          .expand((sub) => sub.products)
          .map((p) => MenuItemMapper.fromProduct(p, storeIsOpen: storeIsOpen))
          .toList();
    }
    return category.products
        .map((p) => MenuItemMapper.fromProduct(p, storeIsOpen: storeIsOpen))
        .toList();
  }

  static bool hasMatchingProducts(
    ProductCategory category,
    MenuFilterCriteria criteria, {
    required bool storeIsOpen,
  }) {
    final items = allProductsInCategory(category, storeIsOpen: storeIsOpen);
    return filterItems(items, criteria).isNotEmpty;
  }
}
