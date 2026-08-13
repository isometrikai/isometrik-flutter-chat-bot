/// Response for GET `/v1/customer/eazysubscription/apple/history`.
class SubscriptionHistoryResponse {
  const SubscriptionHistoryResponse({
    this.total = 0,
    this.limit = 20,
    this.skip = 0,
    this.items = const [],
  });

  final int total;
  final int limit;
  final int skip;
  final List<SubscriptionHistoryItem> items;

  bool get hasMore => items.length + skip < total;

  factory SubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const SubscriptionHistoryResponse();
    }
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(SubscriptionHistoryItem.fromJson)
            .toList(growable: false)
        : const <SubscriptionHistoryItem>[];

    return SubscriptionHistoryResponse(
      total: _parseInt(data['total']) ?? 0,
      limit: _parseInt(data['limit']) ?? 20,
      skip: _parseInt(data['skip']) ?? 0,
      items: items,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class SubscriptionHistoryItem {
  const SubscriptionHistoryItem({
    this.id = '',
    this.subscriptionId = '',
    this.eventType = '',
    this.planId = '',
    this.planName = '',
    this.messageLimit,
    this.status = '',
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.appleTransactionId = '',
    this.appleOriginalTransactionId = '',
    this.appleProductId = '',
    this.appleEnvironment = '',
    this.notificationType,
    this.createdAt,
  });

  final String id;
  final String subscriptionId;
  final String eventType;
  final String planId;
  final String planName;
  final int? messageLimit;
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final String appleTransactionId;
  final String appleOriginalTransactionId;
  final String appleProductId;
  final String appleEnvironment;
  final String? notificationType;
  final DateTime? createdAt;

  /// Period is still running (used for Active vs Ended in the list).
  bool get isPeriodActive {
    final end = currentPeriodEnd;
    if (end == null) return status.toLowerCase() == 'active';
    return end.toLocal().isAfter(DateTime.now());
  }

  bool get isMonthlyProduct {
    final productId = appleProductId.toLowerCase();
    return productId.contains('month') ||
        productId.contains('30day') ||
        productId.contains('30_day');
  }

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryItem(
      id: (json['id'] ?? '').toString(),
      subscriptionId: (json['subscriptionId'] ?? '').toString(),
      eventType: (json['eventType'] ?? '').toString(),
      planId: (json['planId'] ?? '').toString(),
      planName: (json['planName'] ?? '').toString(),
      messageLimit: _parseInt(json['messageLimit']),
      status: (json['status'] ?? '').toString(),
      currentPeriodStart: _parseDate(json['currentPeriodStart']),
      currentPeriodEnd: _parseDate(json['currentPeriodEnd']),
      appleTransactionId: (json['appleTransactionId'] ?? '').toString(),
      appleOriginalTransactionId:
          (json['appleOriginalTransactionId'] ?? '').toString(),
      appleProductId: (json['appleProductId'] ?? '').toString(),
      appleEnvironment: (json['appleEnvironment'] ?? '').toString(),
      notificationType: json['notificationType']?.toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }
}
