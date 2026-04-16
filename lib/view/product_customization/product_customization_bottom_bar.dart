import 'package:chat_bot/bloc/product_customization/product_customization_bloc.dart';
import 'package:chat_bot/bloc/product_customization/product_customization_state.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';
import 'product_customization_helpers.dart';

class ProductCustomizationBottomBar extends StatelessWidget {
  final Product? product;
  final Store? store;
  final bool? isFromMenuScreen;
  final Function(Product?, Store?, ProductPortion?, List<Map<String, dynamic>>, String)?
      onAddToCartWithAddOns;

  const ProductCustomizationBottomBar({
    super.key,
    required this.product,
    required this.store,
    required this.isFromMenuScreen,
    required this.onAddToCartWithAddOns,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCustomizationBloc, ProductCustomizationState>(
      builder: (context, state) {
        if (state is! ProductCustomizationLoaded) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FF),
          ),
          child: Column(
            children: [
              Container(
                width: 343,
                height: 62,
                decoration: BoxDecoration(
                  color: AppConstants.appThemeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate required options first
                    if (!validateRequiredOptions(
                      context: context,
                      state: state,
                    )) {
                      return; // Stop execution if validation fails
                    }

                    if (state.selectedVariant != null) {
                      final formattedAddOns =
                          formatAddOnsForAPI(state);

                      if (formattedAddOns.isNotEmpty) {
                        // Addons selected, use the new callback
                        if (onAddToCartWithAddOns != null) {
                          if (isFromMenuScreen == true) {
                            onAddToCartWithAddOns!(
                              product,
                              store,
                              state.selectedVariant,
                              formattedAddOns,
                              state.selectedVariant?.childProductId ?? '',
                            );
                          } else {
                            onAddToCartWithAddOns!(
                              product,
                              store,
                              state.selectedVariant,
                              formattedAddOns,
                              state.selectedVariant?.childProductId ?? '',
                            );
                          }
                          Navigator.of(context).pop();
                        }
                      } else {
                        // No addons selected, proceed with original logic.
                        onAddToCartWithAddOns!(
                          product,
                          store,
                          state.selectedVariant,
                          formattedAddOns,
                          state.selectedVariant?.childProductId ?? '',
                        );
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Add',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Home indicator
              Container(
                width: 132.26,
                height: 4.93,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(98.7),
                ),
              ),
              const SizedBox(height: 7.45),
            ],
          ),
        );
      },
    );
  }
}

