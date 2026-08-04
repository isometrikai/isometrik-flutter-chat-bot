import 'package:flutter/material.dart';
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/services/services.dart';
import 'package:chat_bot/view/customization_summary_screen.dart';
import 'package:chat_bot/view/product_customization_screen.dart';

class RestaurantMenuCartActions {
  RestaurantMenuCartActions({
    required this.cartBloc,
    required this.storeId,
    required this.storeCategoryId,
    required this.storeTypeId,
  });

  final CartBloc cartBloc;
  final String storeId;
  final String storeCategoryId;
  final int storeTypeId;

  dynamic getAddToCartOnId(String productId) {
    try {
      final matchingProducts = cartBloc.cartData
          .expand((cart) => cart.sellers)
          .expand((seller) => seller.products)
          .where((product) => product.id == productId)
          .toList();

      if (matchingProducts.isEmpty) return null;
      return matchingProducts.last.addToCartOnId;
    } catch (e) {
      debugPrint('Error getting addToCartOnId: $e');
      return null;
    }
  }

  dynamic getExistingProductQuantity(String productId, num addToCartOnId) {
    try {
      final matchingProducts = cartBloc.cartData
          .expand((cart) => cart.sellers)
          .expand((seller) => seller.products)
          .where(
            (product) =>
                product.id == productId &&
                product.addToCartOnId == addToCartOnId,
          )
          .toList();

      if (matchingProducts.isEmpty) return null;
      return matchingProducts.last.quantity?.value ?? 0;
    } catch (e) {
      debugPrint('Error getting existing product quantity: $e');
      return null;
    }
  }

  void addSimpleItem({
    required String productId,
    required String centralProductId,
    required int quantity,
  }) {
    cartBloc.add(
      CartAddItemRequested(
        storeId: storeId,
        cartType: 1,
        action: 1,
        storeCategoryId: storeCategoryId,
        newQuantity: quantity,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: centralProductId,
        unitId: '',
      ),
    );
  }

  void increaseSimpleItem({
    required String productId,
    required String centralProductId,
    required int newQuantity,
  }) {
    cartBloc.add(
      CartAddItemRequested(
        storeId: storeId,
        cartType: 1,
        action: 2,
        storeCategoryId: storeCategoryId,
        newQuantity: newQuantity,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: centralProductId,
        unitId: '',
      ),
    );
  }

  void removeOrDecreaseItem({
    required String productId,
    required String centralProductId,
    required int currentQuantity,
    bool isCustomizable = false,
  }) {
    int? addToCartOnId;
    if (isCustomizable) {
      addToCartOnId = getAddToCartOnId(productId);
    }

    int existingProductQuantity = currentQuantity;
    if (addToCartOnId != null) {
      existingProductQuantity =
          getExistingProductQuantity(productId, addToCartOnId) ??
          currentQuantity;
    }

    final bool isLast = existingProductQuantity == 1;
    cartBloc.add(
      CartAddItemRequested(
        storeId: storeId,
        cartType: 2,
        action: isLast ? 3 : 2,
        storeCategoryId: storeCategoryId,
        newQuantity: isLast ? 0 : existingProductQuantity - 1,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: centralProductId,
        unitId: '',
        addToCartOnId: addToCartOnId,
      ),
    );
  }

  void removeLastItem({
    required String productId,
    required String centralProductId,
    bool isCustomizable = false,
  }) {
    int? addToCartOnId;
    if (isCustomizable) {
      addToCartOnId = getAddToCartOnId(productId);
    }

    cartBloc.add(
      CartAddItemRequested(
        storeId: storeId,
        cartType: 2,
        action: 3,
        storeCategoryId: storeCategoryId,
        newQuantity: 0,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: centralProductId,
        unitId: '',
        addToCartOnId: addToCartOnId,
      ),
    );
  }

  void repeatCustomizableItem({
    required String productId,
    required String centralProductId,
  }) {
    final addToCartOnId = getAddToCartOnId(productId);
    final existingProductQuantity = getExistingProductQuantity(
      productId,
      addToCartOnId,
    );

    cartBloc.add(
      CartAddItemRequested(
        storeId: storeId,
        cartType: 1,
        action: 2,
        storeCategoryId: storeCategoryId,
        newQuantity: existingProductQuantity + 1,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: centralProductId,
        unitId: '',
        addToCartOnId: addToCartOnId,
      ),
    );
  }

  void addWithAddOns({
    required String selectedProductId,
    required String centralProductId,
    required dynamic variant,
    required List<Map<String, dynamic>> addOns,
    int quantity = 1,
  }) {
    final num? addToCartId = getAddToCartOnId(selectedProductId);
    if (addToCartId != null) {
      final existingProductQuantity = getExistingProductQuantity(
        selectedProductId,
        addToCartId,
      );
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          action: 2,
          storeCategoryId: storeCategoryId,
          newQuantity: existingProductQuantity + 1,
          storeTypeId: storeTypeId,
          productId: selectedProductId,
          centralProductId: centralProductId,
          unitId: variant?.unitId ?? '',
          addToCartOnId: addToCartId,
        ),
      );
    } else {
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          action: 1,
          storeCategoryId: storeCategoryId,
          newQuantity: quantity,
          storeTypeId: storeTypeId,
          productId: selectedProductId,
          centralProductId: centralProductId,
          unitId: variant?.unitId ?? '',
          newAddOns: addOns,
        ),
      );
    }
  }

  void onQuantityChanged({
    required BuildContext context,
    required String productId,
    required String centralProductId,
    required int currentQuantity,
    required bool isIncrease,
    required bool isCustomizable,
    required String productName,
    required String productImage,
  }) {
    try {
      if (!isIncrease && currentQuantity == 1) {
        removeLastItem(
          productId: productId,
          centralProductId: centralProductId,
          isCustomizable: isCustomizable,
        );
        return;
      }

      if (currentQuantity > 0 && isIncrease) {
        if (isCustomizable) {
          _showCustomizationSummary(
            context: context,
            productId: productId,
            centralProductId: centralProductId,
            productName: productName,
            productImage: productImage,
          );
        } else {
          increaseSimpleItem(
            productId: productId,
            centralProductId: centralProductId,
            newQuantity: currentQuantity + 1,
          );
        }
        return;
      }

      removeOrDecreaseItem(
        productId: productId,
        centralProductId: centralProductId,
        currentQuantity: currentQuantity,
        isCustomizable: isCustomizable,
      );
    } catch (e) {
      debugPrint('Error changing quantity: $e');
    }
  }

  void onAddToCart({
    required BuildContext context,
    required String productId,
    required String centralProductId,
    required int quantity,
    required bool isCustomizable,
    required String productName,
    required String? productImage,
  }) {
    if (isCustomizable) {
      openProductCustomization(
        context: context,
        productId: productId,
        centralProductId: centralProductId,
        productName: productName,
        productImage: productImage,
        quantity: quantity,
      );
      return;
    }

    addSimpleItem(
      productId: productId,
      centralProductId: centralProductId,
      quantity: quantity,
    );
  }

  void openProductCustomization({
    required BuildContext context,
    required String productId,
    required String centralProductId,
    required String productName,
    required String? productImage,
    int quantity = 1,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ProductCustomizationScreen(
        productId: productId,
        centralProductId: centralProductId,
        storeId: storeId,
        productName: productName,
        productImage: productImage,
        isFromMenuScreen: true,
        onAddToCartWithAddOns: (
          product,
          store,
          variant,
          addOns,
          selectedProductId,
        ) {
          try {
            addWithAddOns(
              selectedProductId: selectedProductId,
              centralProductId: centralProductId,
              variant: variant,
              addOns: addOns,
              quantity: quantity,
            );
          } catch (e) {
            debugPrint(
              'RestaurantMenuScreen: Error dispatching CartAddItemRequested with addons: $e',
            );
          }
        },
      ),
    );
  }

  void _showCustomizationSummary({
    required BuildContext context,
    required String productId,
    required String centralProductId,
    required String productName,
    required String productImage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CustomizationSummaryScreen(
        cartData: cartBloc.cartData,
        productId: productId,
        centralProductId: centralProductId,
        storeTypeId: storeTypeId,
        onChooseClicked: () {
          openProductCustomization(
            context: context,
            productId: productId,
            centralProductId: centralProductId,
            productName: productName,
            productImage: productImage,
          );
        },
        onRepeatClicked: () {
          repeatCustomizableItem(
            productId: productId,
            centralProductId: centralProductId,
          );
        },
      ),
    );
  }

  void triggerProductOrder({
    required chat.Product product,
    required chat.WidgetAction? actionData,
  }) {
    final Map<String, dynamic> productJson = product.toJson();
    productJson['storeId'] = actionData?.storeId;
    productJson['storeCategoryId'] = actionData?.storeCategoryId;
    productJson['storeTypeId'] = actionData?.storeTypeId;
    OrderService().triggerProductOrder(productJson);
  }

  static chat.Product? findProduct(
    List<ProductCategory> categories,
    String? productId,
  ) {
    if (productId == null) return null;
    for (final category in categories) {
      if (category.isSubCategories && category.subCategories.isNotEmpty) {
        for (final subCategory in category.subCategories) {
          for (final product in subCategory.products) {
            if (product.childProductId == productId) return product;
          }
        }
      } else {
        for (final product in category.products) {
          if (product.childProductId == productId) return product;
        }
      }
    }
    return null;
  }
}
