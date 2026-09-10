import 'dart:io';

import '../api_service.dart';

/// Store product identifiers for zAIn Pro plans.
///
/// iOS uses two separate products (staging vs production IDs), Android uses
/// one subscription product (`zain_pro`) with two base plans.
class IapProductIds {
  IapProductIds._();

  /// iOS staging — auto-renewable monthly subscription.
  static const String stagingAutoRenewMonthly = 'plan_autorenew_monthly';

  /// iOS staging — non-renewable 30-day access.
  static const String stagingManual30Days = 'plan_manual_30days';

  /// iOS production — auto-renewable monthly subscription.
  static const String productionAutoRenewMonthly =
      'plan_autorenew_monthly_prod';

  /// iOS production — non-renewable 30-day access.
  static const String productionManual30Days = 'plan_manual_30days_prod';

  /// iOS — auto-renewable monthly subscription for the active environment.
  static String get autoRenewMonthly => ApiService.isProduction
      ? productionAutoRenewMonthly
      : stagingAutoRenewMonthly;

  /// iOS — non-renewable 30-day access for the active environment.
  static String get manual30Days =>
      ApiService.isProduction ? productionManual30Days : stagingManual30Days;

  /// Android — subscription product holding both base plans.
  static const String androidSubscription = 'zain_pro';

  /// Android — auto-renewing base plan.
  static const String androidAutoRenewBasePlan = 'autorenew-monthly';

  /// Android — prepaid (manual) base plan.
  static const String androidManualBasePlan = 'prepaid-30days';

  static const Set<String> _iosProductIds = {
    stagingAutoRenewMonthly,
    stagingManual30Days,
    productionAutoRenewMonthly,
    productionManual30Days,
  };

  /// Product IDs queried from the active store.
  static Set<String> get all => Platform.isAndroid
      ? const {androidSubscription}
      : {autoRenewMonthly, manual30Days};

  /// Store product ID for the selected plan.
  static String forAutoRenew(bool autoRenew) {
    if (Platform.isAndroid) return androidSubscription;
    return autoRenew ? autoRenewMonthly : manual30Days;
  }

  /// Play base plan ID for the selected plan (Android only).
  static String basePlanForAutoRenew(bool autoRenew) =>
      autoRenew ? androidAutoRenewBasePlan : androidManualBasePlan;

  static bool isKnown(String productId) {
    if (Platform.isAndroid) return productId == androidSubscription;
    return _iosProductIds.contains(productId);
  }

  /// True for iOS auto-renew product IDs (staging or production).
  static bool isAutoRenewProduct(String productId) {
    if (Platform.isAndroid) return false;
    return productId == stagingAutoRenewMonthly ||
        productId == productionAutoRenewMonthly;
  }
}
