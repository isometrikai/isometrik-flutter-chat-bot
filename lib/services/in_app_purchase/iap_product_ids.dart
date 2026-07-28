/// App Store / Play Store product identifiers for zAIn Pro plans.
class IapProductIds {
  IapProductIds._();

  /// Auto-renewable monthly subscription.
  static const String autoRenewMonthly = 'plan_autorenew_monthly';

  /// Non-renewable 30-day access.
  static const String manual30Days = 'plan_manual_30days';

  /// All product IDs queried from the store.
  static const Set<String> all = {
    autoRenewMonthly,
    manual30Days,
  };

  static String forAutoRenew(bool autoRenew) =>
      autoRenew ? autoRenewMonthly : manual30Days;

  static bool isKnown(String productId) => all.contains(productId);
}
