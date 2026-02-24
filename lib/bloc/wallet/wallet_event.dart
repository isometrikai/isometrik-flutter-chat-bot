import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch wallet for the given user (e.g. when profile screen opens).
class WalletFetchRequested extends WalletEvent {
  const WalletFetchRequested({
    required this.userId,
    this.userType = 'customer',
  });

  final String userId;
  final String userType;

  @override
  List<Object?> get props => [userId, userType];
}
