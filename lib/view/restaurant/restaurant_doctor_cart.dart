import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/view/doctor_service_type_sheet.dart';
import 'package:flutter/material.dart';

/// Doctor service add-to-cart flow for [RestaurantScreen].
abstract final class RestaurantDoctorCart {
  static void handle({
    required BuildContext context,
    required CartBloc cartBloc,
    required Store store,
    required Doctor doctor,
  }) {
    DoctorServiceTypeSheet.show(
      context,
      doctor: doctor,
      store: store,
      onServiceTypeSelected: (selectedType, product) {
        final int serviceLocationAt;
        final String productName;
        final int? estimatedProductPrice;

        switch (selectedType) {
          case DoctorServiceType.inCall:
            serviceLocationAt = 1;
            productName = "Visit at doctor's clinic";
            estimatedProductPrice = doctor.pricing?.inCallFee ?? 0;
            break;
          case DoctorServiceType.outCall:
            serviceLocationAt = 2;
            productName = "Doctor's at home";
            estimatedProductPrice = doctor.pricing?.outCallFee ?? 0;
            break;
          case DoctorServiceType.teleCall:
            serviceLocationAt = 3;
            productName = 'Tele appointment';
            estimatedProductPrice = doctor.pricing?.teleCallFee ?? 0;
            break;
        }

        final doctorParams = <String, dynamic>{
          'estimatedProductPrice': estimatedProductPrice,
          'productName': productName,
          'providerId': doctor.id,
          'cartType': 2,
          'storeId': store.storeId,
          'newQuantity': 0,
          'productId': '',
          'userType': 1,
          'unitId': '',
          'isDoctorFlow': true,
          'serviceLocationAt': serviceLocationAt,
          'longitude': ChatApiServices.instance.longitude ?? 0,
          'latitude': ChatApiServices.instance.latitude ?? 0,
          'centralProductId': '',
          'storeTypeId': store.storeTypeId ?? 25,
          'storeCategoryId': store.storeCategoryId,
          'offers': {
            'discountValue': 0,
            'offerFor': 0,
            'offerId': '',
            'offerName': {},
            'status': 0,
            'discountType': 0,
          },
          'action': 1,
        };

        cartBloc.add(
          CartAddItemRequested(
            storeId: store.storeId,
            cartType: 2,
            action: 1,
            storeCategoryId: store.storeCategoryId,
            newQuantity: 0,
            storeTypeId: store.storeTypeId ?? 25,
            productId: '',
            centralProductId: '',
            unitId: '',
            doctorParams: doctorParams,
          ),
        );

        if (product != null) {
          cartBloc.stream
              .firstWhere((state) => state is CartProductAdded)
              .then((state) {
            if (state is CartProductAdded) {
              cartBloc.add(
                CartAddItemRequested(
                  storeId: store.storeId,
                  cartType: 2,
                  action: 1,
                  storeCategoryId: store.storeCategoryId,
                  newQuantity: 1,
                  storeTypeId: store.storeTypeId ?? -111,
                  productId: product.childProductId,
                  centralProductId: product.parentProductId,
                  unitId: product.unitId,
                  needToShowLoaderForCartFetch: true,
                ),
              );
            }
          });
        }
      },
    );
  }
}
