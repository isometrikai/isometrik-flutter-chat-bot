import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/view/views.dart';
import 'package:flutter/material.dart';

/// Cart add/update/remove actions for [RestaurantScreen].
class RestaurantCartActions {
  RestaurantCartActions({
    required this.cartBloc,
    required this.context,
    required this.cartData,
  });

  final CartBloc cartBloc;
  final BuildContext context;
  final List<UniversalCartData> cartData;

  void addWithAddOns(
    Product? product,
    Store? store,
    dynamic variant,
    List<Map<String, dynamic>> addOns,
    String selectedProductId,
  ) {
    try {
      final addToCartId = _getAddToCartOnId(selectedProductId);
      if (addToCartId != null) {
        final existingProductQuantity =
            _getExistingProductQuantity(selectedProductId, addToCartId);
        cartBloc.add(
          CartAddItemRequested(
            storeId: store?.storeId ?? '',
            cartType: 1,
            action: 2,
            storeCategoryId: store?.storeCategoryId ?? '',
            newQuantity: existingProductQuantity + 1,
            storeTypeId: store?.type ?? -111,
            productId: selectedProductId,
            centralProductId: product?.parentProductId ?? '',
            unitId: variant.unitId,
            addToCartOnId: addToCartId,
          ),
        );
      } else {
        cartBloc.add(
          CartAddItemRequested(
            storeId: store?.storeId ?? '',
            cartType: 1,
            action: 1,
            storeCategoryId: store?.storeCategoryId ?? '',
            newQuantity: 1,
            storeTypeId: store?.type ?? -111,
            productId: selectedProductId,
            centralProductId: product?.parentProductId ?? '',
            unitId: variant.unitId,
            newAddOns: addOns,
          ),
        );
      }
    } catch (e) {
      print('RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e');
    }
  }

  void addForGrocery({
    required String parentProductId,
    required String productId,
    required String unitId,
    required String storeId,
    required String storeCategoryId,
    required int storeTypeId,
    int? addToCartOnId,
  }) {
    try {
      final addToCartId = _getAddToCartOnId(productId);
      if (addToCartId != null) {
        final existingProductQuantity =
            _getExistingProductQuantity(productId, addToCartId);
        cartBloc.add(
          CartAddItemRequested(
            storeId: storeId,
            cartType: 1,
            action: 2,
            storeCategoryId: storeCategoryId,
            newQuantity: existingProductQuantity + 1,
            storeTypeId: storeTypeId,
            productId: productId,
            centralProductId: parentProductId,
            unitId: unitId,
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
            newQuantity: 1,
            storeTypeId: storeTypeId,
            productId: productId,
            centralProductId: parentProductId,
            unitId: unitId,
            addToCartOnId: addToCartOnId,
          ),
        );
      }
    } catch (e) {
      print('RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e');
    }
  }

  void openGroceryCustomization({
    required String parentProductId,
    required String productId,
    required String unitId,
    required String storeId,
    required String storeCategoryId,
    required int storeTypeId,
    required String productName,
    required String productImage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GroceryCustomizationScreen(
        parentProductId: parentProductId,
        productId: productId,
        storeId: storeId,
        productName: productName,
        productImage: productImage,
        onAddToCart: (parentId, childId, selectedUnitId) {
          addForGrocery(
            parentProductId: parentId,
            productId: childId,
            unitId: selectedUnitId,
            storeId: storeId,
            storeCategoryId: storeCategoryId,
            storeTypeId: storeTypeId,
          );
        },
      ),
    );
  }

  void openProductCustomization(Product product, Store store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductCustomizationScreen(
        product: product,
        store: store,
        onAddToCartWithAddOns: addWithAddOns,
      ),
    );
  }

  void changeGroceryQuantity({
    required String parentProductId,
    required String productId,
    required String unitId,
    required String storeId,
    required String storeCategoryId,
    required int storeTypeId,
    required int variantsCount,
    required int newQuantity,
    required bool isIncrease,
    required String productName,
    required String productImage,
  }) {
    if (!isIncrease && newQuantity == 1) {
      _removeItem(
        storeId: storeId,
        storeCategoryId: storeCategoryId,
        storeTypeId: storeTypeId,
        productId: productId,
        parentProductId: parentProductId,
        unitId: unitId,
        variantsCount: variantsCount,
      );
      return;
    }

    if (newQuantity > 0 && isIncrease) {
      if (variantsCount > 0) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CustomizationSummaryScreen(
            cartData: cartData,
            productId: productId,
            centralProductId: parentProductId,
            storeTypeId: storeTypeId,
            onChooseClicked: () {
              openGroceryCustomization(
                parentProductId: parentProductId,
                productId: productId,
                unitId: unitId,
                storeId: storeId,
                storeCategoryId: storeCategoryId,
                storeTypeId: storeTypeId,
                productName: productName,
                productImage: productImage,
              );
            },
            onRepeatClicked: () {
              final addToCartOnId = _getAddToCartOnId(productId);
              if (addToCartOnId == null) return;

              final existingProductQuantity =
                  _getExistingProductQuantity(productId, addToCartOnId);
              cartBloc.add(
                CartAddItemRequested(
                  storeId: storeId,
                  cartType: 1,
                  action: 2,
                  storeCategoryId: storeCategoryId,
                  newQuantity: existingProductQuantity + 1,
                  storeTypeId: storeTypeId,
                  productId: productId,
                  centralProductId: parentProductId,
                  unitId: unitId,
                  addToCartOnId: addToCartOnId,
                ),
              );
            },
          ),
        );
      } else {
        final addToCartOnId = _getAddToCartOnId(productId);
        cartBloc.add(
          CartAddItemRequested(
            storeId: storeId,
            cartType: 1,
            action: 2,
            storeCategoryId: storeCategoryId,
            newQuantity: newQuantity + 1,
            storeTypeId: storeTypeId,
            productId: productId,
            centralProductId: parentProductId,
            unitId: unitId,
            addToCartOnId: addToCartOnId,
          ),
        );
      }
      return;
    }

    _decrementQuantity(
      storeId: storeId,
      storeCategoryId: storeCategoryId,
      storeTypeId: storeTypeId,
      productId: productId,
      parentProductId: parentProductId,
      unitId: unitId,
      variantsCount: variantsCount,
      newQuantity: newQuantity,
    );
  }

  void changeQuantity(
    Product? product,
    Store store,
    int newQuantity,
    bool isIncrease,
  ) {
    if (!isIncrease && newQuantity == 1) {
      _removeItem(
        storeId: store.storeId,
        storeCategoryId: store.storeCategoryId,
        storeTypeId: store.type,
        productId: product?.childProductId ?? '',
        parentProductId: product?.parentProductId ?? '',
        unitId: product?.unitId ?? '',
        variantsCount: product?.variantsCount ?? 0,
      );
      return;
    }

    if (newQuantity > 0 && isIncrease) {
      if (product != null && product.variantsCount > 0) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CustomizationSummaryScreen(
            cartData: cartData,
            productId: product.childProductId,
            centralProductId: product.parentProductId,
            storeTypeId: store.type,
            store: store,
            product: product,
            onChooseClicked: () => openProductCustomization(product, store),
            onRepeatClicked: () {
              final addToCartOnId = _getAddToCartOnId(product.childProductId);
              if (addToCartOnId == null) return;

              final existingProductQuantity = _getExistingProductQuantity(
                product.childProductId,
                addToCartOnId,
              );
              cartBloc.add(
                CartAddItemRequested(
                  storeId: store.storeId,
                  cartType: 1,
                  action: 2,
                  storeCategoryId: store.storeCategoryId,
                  newQuantity: existingProductQuantity + 1,
                  storeTypeId: store.type,
                  productId: product.childProductId,
                  centralProductId: product.parentProductId,
                  unitId: product.unitId,
                  addToCartOnId: addToCartOnId,
                ),
              );
            },
          ),
        );
      } else {
        cartBloc.add(
          CartAddItemRequested(
            storeId: store.storeId,
            cartType: 1,
            action: 2,
            storeCategoryId: store.storeCategoryId,
            newQuantity: newQuantity + 1,
            storeTypeId: store.type,
            productId: product?.childProductId ?? '',
            centralProductId: product?.parentProductId ?? '',
            unitId: product?.unitId ?? '',
          ),
        );
      }
      return;
    }

    _decrementQuantity(
      storeId: store.storeId,
      storeCategoryId: store.storeCategoryId,
      storeTypeId: store.type,
      productId: product?.childProductId ?? '',
      parentProductId: product?.parentProductId ?? '',
      unitId: product?.unitId ?? '',
      variantsCount: product?.variantsCount ?? 0,
      newQuantity: newQuantity,
    );
  }

  void _removeItem({
    required String storeId,
    required String storeCategoryId,
    required int storeTypeId,
    required String productId,
    required String parentProductId,
    required String unitId,
    required int variantsCount,
  }) {
    num? addToCartOnId;
    if (variantsCount > 0) {
      addToCartOnId = _getAddToCartOnId(productId);
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
        centralProductId: parentProductId,
        unitId: unitId,
        addToCartOnId: addToCartOnId,
      ),
    );
  }

  void _decrementQuantity({
    required String storeId,
    required String storeCategoryId,
    required int storeTypeId,
    required String productId,
    required String parentProductId,
    required String unitId,
    required int variantsCount,
    required int newQuantity,
  }) {
    num? addToCartOnId;
    if (variantsCount > 0) {
      addToCartOnId = _getAddToCartOnId(productId);
    }

    dynamic existingProductQuantity = newQuantity;
    if (addToCartOnId != null) {
      existingProductQuantity =
          _getExistingProductQuantity(productId, addToCartOnId);
    }

    final resolvedQuantity = existingProductQuantity is num
        ? existingProductQuantity.toInt()
        : newQuantity;

    cartBloc.add(
      CartAddItemRequested(
        storeId: storeId,
        cartType: 2,
        action: (resolvedQuantity == 1) ? 3 : 2,
        storeCategoryId: storeCategoryId,
        newQuantity:
            (resolvedQuantity == 1) ? 0 : resolvedQuantity - 1,
        storeTypeId: storeTypeId,
        productId: productId,
        centralProductId: parentProductId,
        unitId: unitId,
        addToCartOnId: addToCartOnId,
      ),
    );
  }

  num? _getAddToCartOnId(String productId) {
    try {
      final matchingProducts = cartBloc.cartData
          .expand((cart) => cart.sellers)
          .expand((seller) => seller.products)
          .where((product) => product.id == productId)
          .toList();

      if (matchingProducts.isEmpty) return null;
      return matchingProducts.last.addToCartOnId;
    } catch (e) {
      print('Error getting addToCartOnId: $e');
      return null;
    }
  }

  dynamic _getExistingProductQuantity(String productId, num addToCartOnId) {
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
      print('Error getting existing product quantity: $e');
      return null;
    }
  }
}
