import 'package:chat_bot/bloc/product_customization/product_customization_bloc.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_event.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_state.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';

class ProductCustomizationContent extends StatelessWidget {
  final ProductCustomizationLoaded state;

  const ProductCustomizationContent({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSizeSection(context),
          const SizedBox(height: 16),

          // Dynamically show add-on sections based on API data
          ...state.selectedVariant!.addOns.map(
            (addOnCategory) => Column(
              children: [
                _buildAddOnSection(context, addOnCategory),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSizeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your size*',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF242424),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Required | Select any 1',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6E4185),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEEF4FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              ...state.variants.map(
                (variant) => _buildSizeOption(context, variant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSizeOption(BuildContext context, ProductPortion variant) {
    final isSelected = state.selectedVariant?.id == variant.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${variant.name} (${variant.currency} ${variant.price.toStringAsFixed(0)})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF242424),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context
                  .read<ProductCustomizationBloc>()
                  .add(SelectProductVariant(variant: variant));
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppConstants.appThemeColor : const Color(0xFFE9DFFB),
                  width: 0.83,
                ),
                color: isSelected ? AppConstants.appThemeColor : Colors.white,
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnSection(BuildContext context, AddOnCategory addOnCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              addOnCategory.name,
              style: AppTextStyles.addonTitle.copyWith(
                color: const Color(0xFF242424),
              ),
            ),
            if (addOnCategory.mandatory)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          addOnCategory.mandatory
              ? 'Required | Select any ${addOnCategory.maximumLimit}'
              : 'Optional | You can select up to ${addOnCategory.maximumLimit} items',
          style: AppTextStyles.addonDescription.copyWith(
            color: const Color(0xFF6E4185),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEEF4FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: addOnCategory.addOns.isNotEmpty
              ? Column(
                  children: [
                    ...addOnCategory.addOns.map(
                      (addOn) => _buildAddOnOption(context, addOn, addOnCategory),
                    ),
                  ],
                )
              : const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No options available',
                    style: TextStyle(
                      color: Color(0xFF979797),
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAddOnOption(
    BuildContext context,
    AddOnItem addOn,
    AddOnCategory addOnCategory,
  ) {
    final isSelected =
        state.selectedAddOns[addOnCategory.name]?.contains(addOn.id) ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${addOn.name} (${addOn.currency} ${addOn.price.toStringAsFixed(0)})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF242424),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              context
                  .read<ProductCustomizationBloc>()
                  .add(ToggleAddOnItem(
                    addOnCategoryName: addOnCategory.name,
                    addOnItemId: addOn.id,
                    isSelected: !isSelected,
                  ));
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                // Use radio button for single selection, checkbox for multiple selection
                shape:
                    addOnCategory.multiple ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: addOnCategory.multiple
                    ? BorderRadius.circular(3.33)
                    : null,
                border: Border.all(
                  color: isSelected ? AppConstants.appThemeColor : const Color(0xFFB0C4FF),
                  width: 0.83,
                ),
                color: isSelected ? AppConstants.appThemeColor : Colors.white,
              ),
              child: isSelected
                  ? addOnCategory.multiple
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 13.33,
                        )
                      : Container(
                          margin: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

