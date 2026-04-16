import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter/material.dart';

import '../../bloc/product_customization/product_customization_state.dart';

List<Map<String, dynamic>> formatAddOnsForAPI(ProductCustomizationLoaded state) {
  final List<Map<String, dynamic>> formattedAddOns = [];

  for (final entry in state.selectedAddOns.entries) {
    if (entry.value.isNotEmpty) {
      final addOnCategory = state.selectedVariant!.addOns.firstWhere(
        (category) => category.name == entry.key,
      );

      if (addOnCategory.unitAddOnId.isNotEmpty) {
        formattedAddOns.add({
          "addOnGroup": entry.value.toList(),
          "id": addOnCategory.unitAddOnId,
        });
      }
    }
  }

  return formattedAddOns;
}

bool validateRequiredOptions({
  required BuildContext context,
  required ProductCustomizationLoaded state,
}) {
  // Check if size is selected (always required)
  if (state.selectedVariant == null) {
    BlackToastView.show(context, 'Please select a size');
    return false;
  }

  // Check mandatory add-on categories
  for (final addOnCategory in state.selectedVariant!.addOns) {
    if (addOnCategory.mandatory) {
      final selectedItems =
          state.selectedAddOns[addOnCategory.name] ?? <String>{};

      if (selectedItems.isEmpty) {
        BlackToastView.show(context, 'Please Select Option');
        return false;
      }

      // Check minimum required items are selected
      if (selectedItems.length < addOnCategory.minimumLimit) {
        BlackToastView.show(
          context,
          'Please select at least ${addOnCategory.minimumLimit} items from ${addOnCategory.name}',
        );
        return false;
      }

      // Check if maximum limit is not exceeded
      if (selectedItems.length > addOnCategory.maximumLimit) {
        BlackToastView.show(
          context,
          'You can select maximum ${addOnCategory.maximumLimit} items from ${addOnCategory.name}',
        );
        return false;
      }
    }
  }

  return true;
}

