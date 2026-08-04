import 'package:flutter/material.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/restaurant_menu/restaurant_menu_colors.dart';

class RestaurantMainCategoryChips extends StatelessWidget {
  const RestaurantMainCategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<ProductCategory> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: isSelected
                    ? RestaurantMenuColors.selectedChipBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(
                  color: isSelected
                      ? RestaurantMenuColors.purple
                      : RestaurantMenuColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                index == 0
                    ? AppTranslations.filterAllCaps
                    : categories[index - 1].catName,
                style: AppTextStyles.button.copyWith(
                  color: RestaurantMenuColors.title,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RestaurantSubcategoryChips extends StatelessWidget {
  const RestaurantSubcategoryChips({
    super.key,
    required this.category,
    required this.selectedIndex,
    required this.onSelected,
  });

  final ProductCategory category;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 31,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: category.subCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              height: 31,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? RestaurantMenuColors.selectedChipBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? RestaurantMenuColors.purple
                      : RestaurantMenuColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category.subCategories[index].name,
                style: AppTextStyles.restaurantDescription.copyWith(
                  color: RestaurantMenuColors.title,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
