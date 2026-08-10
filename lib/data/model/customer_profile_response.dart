/// Response for GET /v1/customer/profile.
class CustomerProfileResponse {
  const CustomerProfileResponse({
    this.zainPersonalization = false,
    this.subscription,
  });

  final bool zainPersonalization;
  final CustomerSubscription? subscription;

  factory CustomerProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const CustomerProfileResponse();
    }
    return CustomerProfileResponse(
      zainPersonalization: data['zain_personalization'] == true,
      subscription: CustomerSubscription.tryParse(data['subscription']),
    );
  }
}

class CustomerSubscription {
  const CustomerSubscription({
    this.subscriptionId = '',
    this.planId = '',
    this.planName = '',
    this.messageLimit,
    this.status = '',
    this.paymentProvider = '',
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.createdAt,
    this.updatedAt,
  });

  final String subscriptionId;
  final String planId;
  final String planName;
  final int? messageLimit;
  final String status;
  final String paymentProvider;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => (status.toLowerCase() == 'active' && planId == "premium");

  static CustomerSubscription? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return CustomerSubscription.fromJson(json);
  }

  factory CustomerSubscription.fromJson(Map<String, dynamic> json) {
    return CustomerSubscription(
      subscriptionId: (json['subscriptionId'] ?? '').toString(),
      planId: (json['planId'] ?? '').toString(),
      planName: (json['planName'] ?? '').toString(),
      messageLimit: _parseInt(json['messageLimit']),
      status: (json['status'] ?? '').toString(),
      paymentProvider: (json['paymentProvider'] ?? '').toString(),
      currentPeriodStart: _parseDate(json['currentPeriodStart']),
      currentPeriodEnd: _parseDate(json['currentPeriodEnd']),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
