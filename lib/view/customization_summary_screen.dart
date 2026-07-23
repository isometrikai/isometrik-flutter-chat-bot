import 'package:chat_bot/data/model/universal_cart_response.dart' as cart_models;
import '../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/data.dart';
import '../utils/text_styles.dart';



class CustomizationSummaryScreen extends StatefulWidget {
  final Store? store;
  final Product? product;
  final String? productId;
  final String? centralProductId;
  final int? storeTypeId;
  final VoidCallback? onChooseClicked; 
  final VoidCallback? onRepeatClicked;
  final List<cart_models.UniversalCartData> cartData; // Callback when "I'll choose" is clicked

  const CustomizationSummaryScreen({
    super.key,
    this.store,
    this.product,
    this.productId,
    this.centralProductId,
    required this.storeTypeId,
    this.onChooseClicked,
    this.onRepeatClicked,
    required this.cartData,
  });

  @override
  State<CustomizationSummaryScreen> createState() => _CustomizationSummaryScreenState();
}

class _CustomizationSummaryScreenState extends State<CustomizationSummaryScreen> {

  @override
  Widget build(BuildContext context) {
    return AppLocale.wrap(
      ClipRRect(
      borderRadius: const BorderRadiusDirectional.only(
        topStart: Radius.circular(16),
        topEnd: Radius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6, // Max 60% of screen height
          minHeight: 250, // Minimum height
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Flexible(
                child: _buildCustomizationsList(),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    ),
    );
  }

    /// Get product object from cart data for a specific product ID
  cart_models.Product? _getCartProductObject(String productId, String centralProductId) {
    try {
      // Use filter to find the product with matching ID
      final cartProduct =
          widget.cartData
              .expand((cart) => cart.sellers)
              .expand((seller) => seller.products)
              .where((product) => product.id == productId && product.centralProductId == centralProductId)
              .toList();

      if (cartProduct.isEmpty) {
        return null;
      }

      return cartProduct.last;
    } catch (e) {
      print('Error getting cart product object: $e');
      return null;
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      // 'Your customisations',
                      _getCartProductObject(widget.productId ?? '', widget.centralProductId ?? '')?.name ?? '',
                      style: AppTextStyles.launchTitle.copyWith(
                        color: const Color(0xFF242424),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   _getCartProductObject(widget.productId ?? '', widget.centralProductId ?? '')?.name ?? '',
                    //   style: const TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w400,
                    //     color: Color(0xFF6E4185),
                    //   ),
                    // ),
                    const SizedBox(height: 4),
                     Text(
                      '${'AED'} ${_getCartProductObject(widget.productId ?? '', widget.centralProductId ?? '')?.singleUnitPrice?.unitPriceWithTax.toString() ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6E4185),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(38),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    size: 9.6,
                    color: Color(0xFF585C77),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Group add-ons by category and combine options
  List<Map<String, String>> _groupAddOnsByCategory(List<cart_models.SelectedAddOn> addOns) {
    Map<String, List<String>> groupedAddOns = {};
    
    for (final addOn in addOns) {
      final category = addOn.addOnName;
      final option = addOn.name;
      
      if (!groupedAddOns.containsKey(category)) {
        groupedAddOns[category] = [];
      }
      groupedAddOns[category]!.add(option);
    }
    
    return groupedAddOns.entries.map((entry) => {
      'category': entry.key,
      'options': entry.value.join(', '),
    }).toList();
  }

  Widget _buildCustomizationsList() {
    final cartProduct = _getCartProductObject(widget.productId ?? '', widget.centralProductId ?? '');
    
    // Debug information
    print('CustomizationSummaryScreen Debug:');
    print('Product ID: ${widget.productId}');
    print('Central Product ID: ${widget.centralProductId}');
    print('Cart Product found: ${cartProduct != null}');
    if (cartProduct != null) {
      print('Cart Product Name: ${cartProduct.name}');
      print('Selected Add-ons: ${cartProduct.selectedAddOns?.length ?? 0}');
      print('Attributes: ${cartProduct.attributes?.length ?? 0}');
    }
    
    if (cartProduct == null) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            AppTranslations.noCustomizationsFound,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ),
      );
    }

    // Get selected add-ons from the cart product
    final selectedAddOns = cartProduct.selectedAddOns ?? [];
    final attributes = cartProduct.attributes ?? [];
    
    if (selectedAddOns.isEmpty && attributes.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            AppTranslations.noCustomizationsAvailable,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        shrinkWrap: true,
        children: [
          // Display selected add-ons grouped by category
          if (selectedAddOns.isNotEmpty) ...[
            ..._groupAddOnsByCategory(selectedAddOns).map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry['category']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF242424),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry['options']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6E4185),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
           ] else if (attributes.isNotEmpty && widget.storeTypeId != FoodCategory.food.value) ...[
             ...attributes.where((attribute) => attribute.value.isNotEmpty).map((attribute) => Container(
               margin: const EdgeInsets.only(bottom: 8),
               padding: const EdgeInsets.all(15),
               decoration: BoxDecoration(
                 color: const Color(0xFFF5F7FF),
                 borderRadius: BorderRadius.circular(10),
               ),
               child: Row(
                 children: [
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           attribute.attrname,
                           style: const TextStyle(
                             fontSize: 14,
                             fontWeight: FontWeight.w600,
                             color: Color(0xFF242424),
                           ),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           attribute.value,
                           style: const TextStyle(
                             fontSize: 14,
                             fontWeight: FontWeight.w400,
                             color: Color(0xFF6E4185),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             )).toList(),
           ],
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
    ),
    child: Row(
      children: [
        // Left button - "I'll choose" (Outlined)
        Expanded(
          child: SizedBox(
            height: 62,
            child: OutlinedButton(
              onPressed: () {
                print("I'll choose button clicked for: ${widget.product?.productName}");
                Navigator.of(context).pop();
                
                // Call the callback to let parent know "I'll choose" was clicked
                if (widget.onChooseClicked != null) {
                  widget.onChooseClicked!();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppConstants.appThemeColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                AppTranslations.illChoose,
                style: AppTextStyles.button.copyWith(
                  fontSize: 16,
                  color: AppConstants.appThemeColor,
                ),
              ),
            ),
          ),
        ),
        
        // Spacing between buttons
        const SizedBox(width: 16),
        
        // Right button - "Repeat last" (Gradient)
        Expanded(
          child: SizedBox(
            height: 62,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onRepeatClicked != null) {
                  widget.onRepeatClicked!();
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  color: AppConstants.appThemeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 62,
                  alignment: Alignment.center,
                  child: Text(
                    AppTranslations.repeat,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
