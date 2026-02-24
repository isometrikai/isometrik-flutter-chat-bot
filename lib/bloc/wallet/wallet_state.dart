import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/wallet_response.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoadInProgress extends WalletState {}

class WalletLoadSuccess extends WalletState {
  const WalletLoadSuccess(this.response, {this.availablePoints});

  final WalletResponse response;
  /// Zinrelo member points (from /v1/zinrelo/member/points), fetched after wallet.
  final int? availablePoints;

  @override
  List<Object?> get props => [response, availablePoints];
}

class WalletLoadFailure extends WalletState {
  const WalletLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
