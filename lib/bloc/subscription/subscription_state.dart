import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../services/in_app_purchase/iap_models.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoadInProgress extends SubscriptionState {
  const SubscriptionLoadInProgress();
}

class SubscriptionReady extends SubscriptionState {
  final bool storeAvailable;
  final bool autoRenew;
  final ProductDetails? autoRenewProduct;
  final ProductDetails? manualProduct;
  final IapEntitlement? entitlement;
  final bool purchaseInProgress;

  const SubscriptionReady({
    required this.storeAvailable,
    required this.autoRenew,
    this.autoRenewProduct,
    this.manualProduct,
    this.entitlement,
    this.purchaseInProgress = false,
  });

  ProductDetails? get selectedProduct =>
      autoRenew ? autoRenewProduct : manualProduct;

  String get displayPrice {
    final product = selectedProduct;
    if (product != null && product.price.isNotEmpty) {
      return product.price;
    }
    return 'AED 49.99';
  }

  SubscriptionReady copyWith({
    bool? storeAvailable,
    bool? autoRenew,
    ProductDetails? autoRenewProduct,
    ProductDetails? manualProduct,
    IapEntitlement? entitlement,
    bool? purchaseInProgress,
    bool clearEntitlement = false,
  }) {
    return SubscriptionReady(
      storeAvailable: storeAvailable ?? this.storeAvailable,
      autoRenew: autoRenew ?? this.autoRenew,
      autoRenewProduct: autoRenewProduct ?? this.autoRenewProduct,
      manualProduct: manualProduct ?? this.manualProduct,
      entitlement:
          clearEntitlement ? null : (entitlement ?? this.entitlement),
      purchaseInProgress: purchaseInProgress ?? this.purchaseInProgress,
    );
  }

  @override
  List<Object?> get props => [
        storeAvailable,
        autoRenew,
        autoRenewProduct?.id,
        autoRenewProduct?.price,
        manualProduct?.id,
        manualProduct?.price,
        entitlement,
        purchaseInProgress,
      ];
}

class SubscriptionPurchaseSuccess extends SubscriptionState {
  final IapPurchaseResult result;
  final bool autoRenew;

  const SubscriptionPurchaseSuccess({
    required this.result,
    required this.autoRenew,
  });

  @override
  List<Object?> get props => [result, autoRenew];
}

class SubscriptionFailure extends SubscriptionState {
  final String message;
  final bool autoRenew;

  const SubscriptionFailure({
    required this.message,
    this.autoRenew = true,
  });

  @override
  List<Object?> get props => [message, autoRenew];
}
