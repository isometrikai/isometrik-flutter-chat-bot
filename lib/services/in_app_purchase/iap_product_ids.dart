import 'dart:io';

/// Store product identifiers for zAIn Pro plans.
///
/// iOS uses two separate products, Android uses one subscription product
/// (`zain_pro`) with two base plans.
class IapProductIds {
  IapProductIds._();

  /// iOS — auto-renewable monthly subscription.
  static const String autoRenewMonthly = 'plan_autorenew_monthly';

  /// iOS — non-renewable 30-day access.
  static const String manual30Days = 'plan_manual_30days';

  /// Android — subscription product holding both base plans.
  static const String androidSubscription = 'zain_pro';

  /// Android — auto-renewing base plan.
  static const String androidAutoRenewBasePlan = 'autorenew-monthly';

  /// Android — prepaid (manual) base plan.
  static const String androidManualBasePlan = 'prepaid-30days';

  /// Product IDs queried from the active store.
  static Set<String> get all => Platform.isAndroid
      ? const {androidSubscription}
      : const {autoRenewMonthly, manual30Days};

  /// Store product ID for the selected plan.
  static String forAutoRenew(bool autoRenew) {
    if (Platform.isAndroid) return androidSubscription;
    return autoRenew ? autoRenewMonthly : manual30Days;
  }

  /// Play base plan ID for the selected plan (Android only).
  static String basePlanForAutoRenew(bool autoRenew) =>
      autoRenew ? androidAutoRenewBasePlan : androidManualBasePlan;

  static bool isKnown(String productId) => all.contains(productId);
}
