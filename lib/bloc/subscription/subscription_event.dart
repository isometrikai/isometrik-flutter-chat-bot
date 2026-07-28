import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionStarted extends SubscriptionEvent {
  const SubscriptionStarted();
}

class SubscriptionAutoRenewToggled extends SubscriptionEvent {
  final bool autoRenew;

  const SubscriptionAutoRenewToggled(this.autoRenew);

  @override
  List<Object?> get props => [autoRenew];
}

class SubscriptionPurchaseRequested extends SubscriptionEvent {
  const SubscriptionPurchaseRequested();
}

class SubscriptionRestoreRequested extends SubscriptionEvent {
  const SubscriptionRestoreRequested();
}
