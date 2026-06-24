import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/services/services.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/restaurant/restaurant_cart_actions.dart';
import 'package:chat_bot/view/restaurant/restaurant_doctor_cart.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/search_result_states.dart';

const _noRestaurantsMessage = 'No restaurants found!';

class RestaurantStoreList extends StatelessWidget {
  final bool isTableBookingFlow;
  final List<UniversalCartData> cartData;
  final RestaurantCartActions cartActions;
  final CartBloc cartBloc;
  final void Function(Store store)? onTableBookingTap;
  final void Function(Store store, Product? product)? onDonationTap;

  const RestaurantStoreList({
    super.key,
    required this.isTableBookingFlow,
    required this.cartData,
    required this.cartActions,
    required this.cartBloc,
    this.onTableBookingTap,
    this.onDonationTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        return switch (state) {
          RestaurantInitial() || RestaurantLoadInProgress() =>
            const SearchResultLoading(),
          RestaurantLoadFailure() => const _RestaurantEmptyState(),
          RestaurantLoadSuccess(:final restaurants) when restaurants.isEmpty =>
            const _RestaurantEmptyState(),
          RestaurantLoadSuccess(:final restaurants) => ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: restaurants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, index) => _RestaurantStoreCard(
                store: restaurants[index],
                index: index,
                isTableBookingFlow: isTableBookingFlow,
                cartData: cartData,
                cartActions: cartActions,
                cartBloc: cartBloc,
                onTableBookingTap: onTableBookingTap,
                onDonationTap: onDonationTap,
              ),
            ),
          _ => const _RestaurantEmptyState(),
        };
      },
    );
  }
}

class _RestaurantStoreCard extends StatelessWidget {
  final Store store;
  final int index;
  final bool isTableBookingFlow;
  final List<UniversalCartData> cartData;
  final RestaurantCartActions cartActions;
  final CartBloc cartBloc;
  final void Function(Store store)? onTableBookingTap;
  final void Function(Store store, Product? product)? onDonationTap;

  const _RestaurantStoreCard({
    required this.store,
    required this.index,
    required this.isTableBookingFlow,
    required this.cartData,
    required this.cartActions,
    required this.cartBloc,
    this.onTableBookingTap,
    this.onDonationTap,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return StoreCard(
        isTableBookingFlow: isTableBookingFlow,
        store: store,
        storesWidget: null,
        index: index,
        cartData: cartData,
        onTap: () {
          OrderService().triggerStoreOrder(store.toJson());
        },
        onTableBookingTap: (selectedStore) {
          onTableBookingTap?.call(selectedStore);
          Navigator.pop(context);
        },
        onDonationTap: (selectedStore, product) {
          onDonationTap?.call(selectedStore, product);
          Navigator.pop(context);
        },
        onAddToCartRequested: (product, selectedStore, doctor) {
          if (selectedStore.isDoctore == true && doctor != null) {
            RestaurantDoctorCart.handle(
              context: context,
              cartBloc: cartBloc,
              store: selectedStore,
              doctor: doctor,
            );
            return;
          }

          if (product != null && product.variantsCount > 0) {
            if (selectedStore.type == FoodCategory.grocery.value ||
                selectedStore.type == 0) {
              cartActions.openGroceryCustomization(
                parentProductId: product.parentProductId,
                productId: product.childProductId,
                unitId: product.unitId,
                storeId: selectedStore.storeId,
                storeCategoryId: selectedStore.storeCategoryId,
                storeTypeId: selectedStore.type,
                productName: product.productName,
                productImage: product.productImage,
              );
            } else {
              cartActions.openProductCustomization(product, selectedStore);
            }
            return;
          }

          try {
            cartBloc.add(
              CartAddItemRequested(
                storeId: selectedStore.storeId,
                cartType: 1,
                action: 1,
                storeCategoryId: selectedStore.storeCategoryId,
                newQuantity: 1,
                storeTypeId: selectedStore.type,
                productId: product?.childProductId ?? '',
                centralProductId: product?.parentProductId ?? '',
                unitId: product?.unitId ?? '',
              ),
            );
          } catch (e) {
            print('RestaurantScreen: Error dispatching CartAddItemRequeste: $e');
          }
        },
        onQuantityChanged: (product, selectedStore, newQuantity, isIncrease) {
          if (selectedStore.type == FoodCategory.grocery.value) {
            cartActions.changeGroceryQuantity(
              parentProductId: product?.parentProductId ?? '',
              productId: product?.childProductId ?? '',
              unitId: product?.unitId ?? '',
              storeId: selectedStore.storeId,
              storeCategoryId: selectedStore.storeCategoryId,
              storeTypeId: selectedStore.type,
              variantsCount: product?.variantsCount ?? 0,
              newQuantity: newQuantity,
              isIncrease: isIncrease,
              productName: product?.productName ?? '',
              productImage: product?.productImage ?? '',
            );
          } else {
            cartActions.changeQuantity(
              product,
              selectedStore,
              newQuantity,
              isIncrease,
            );
          }
        },
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          border: Border.all(color: const Color(0xFFEEF4FF)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          store.storename,
          style: AppTextStyles.restaurantTitle.copyWith(
            color: const Color(0xFF242424),
          ),
        ),
      );
    }
  }
}

class _RestaurantEmptyState extends StatelessWidget {
  const _RestaurantEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetPath.get('images/ic_emptyRestaurents.svg'),
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          Text(
            _noRestaurantsMessage,
            style: AppTextStyles.restaurantTitle.copyWith(
              color: const Color(0xFF242424),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
