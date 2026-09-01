import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// High-level purchase outcome for UI / host callbacks.
enum IapPurchaseStatus {
  pending,
  purchased,
  restored,
  canceled,
  error,
  /// Store restore finished with no purchases delivered (typical on Android).
  restoreEmpty,
}

/// Normalized purchase result from the store stream.
class IapPurchaseResult extends Equatable {
  final IapPurchaseStatus status;
  final String? productId;
  final String? transactionId;
  final String? errorMessage;
  final PurchaseDetails? raw;

  const IapPurchaseResult({
    required this.status,
    this.productId,
    this.transactionId,
    this.errorMessage,
    this.raw,
  });

  bool get isSuccess =>
      status == IapPurchaseStatus.purchased ||
      status == IapPurchaseStatus.restored;

  @override
  List<Object?> get props =>
      [status, productId, transactionId, errorMessage];
}

/// Locally persisted entitlement snapshot.
class IapEntitlement extends Equatable {
  final String productId;
  final bool autoRenew;
  final String? transactionId;
  final DateTime purchasedAt;
  final DateTime? expiresAt;

  const IapEntitlement({
    required this.productId,
    required this.autoRenew,
    required this.purchasedAt,
    this.transactionId,
    this.expiresAt,
  });

  bool get isActive {
    if (expiresAt == null) return true;
    return expiresAt!.isAfter(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'autoRenew': autoRenew,
        'transactionId': transactionId,
        'purchasedAt': purchasedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory IapEntitlement.fromJson(Map<String, dynamic> json) {
    return IapEntitlement(
      productId: json['productId'] as String,
      autoRenew: json['autoRenew'] as bool? ?? false,
      transactionId: json['transactionId'] as String?,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [productId, autoRenew, transactionId, purchasedAt, expiresAt];
}
