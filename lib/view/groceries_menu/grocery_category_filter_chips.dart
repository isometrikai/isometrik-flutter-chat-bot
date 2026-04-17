import 'package:chat_bot/utils/text_styles.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';

class GroceryCategoryFilterChips extends StatelessWidget {
  final SubCategoryProductsResponse subCategoryProducts;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color purple;
  final Color border;

  const GroceryCategoryFilterChips({
    super.key,
    required this.subCategoryProducts,
    required this.selectedIndex,
    required this.onSelected,
    required this.purple,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subCategoryProducts.categoryData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final categoryData = subCategoryProducts.categoryData[index];
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF9FF) : Colors.white,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: isSelected ? purple : border),
              ),
              alignment: Alignment.center,
              child: Text(
                categoryData.subCategoryName,
                style: AppTextStyles.button.copyWith(
                  color: const Color(0xFF242424),
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

