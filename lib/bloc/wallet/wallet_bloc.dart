import 'package:chat_bot/bloc/wallet/wallet_event.dart';
import 'package:chat_bot/bloc/wallet/wallet_state.dart';
import 'package:chat_bot/data/model/member_points_response.dart';
import 'package:chat_bot/data/model/wallet_response.dart';
import 'package:chat_bot/data/repositories/wallet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({WalletRepository? repository})
      : _repository = repository ?? WalletRepository(),
        super(WalletInitial()) {
    on<WalletFetchRequested>(_onFetchRequested);
  }

  final WalletRepository _repository;

  Future<void> _onFetchRequested(
    WalletFetchRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoadInProgress());
    try {
      final pointsFuture = _repository.fetchMemberPoints();
      final result = await _repository.fetchWallet(
        userId: event.userId,
        userType: event.userType,
      );
      if (!result.isSuccess || result.data is! WalletResponse) {
        emit(WalletLoadFailure(result.message ?? 'Failed to load wallet'));
        return;
      }

      final walletResponse = result.data as WalletResponse;

      int? availablePoints;
      try {
        final pointsResult = await pointsFuture;
        if (pointsResult.isSuccess &&
            pointsResult.data is MemberPointsResponse) {
          availablePoints =
              (pointsResult.data as MemberPointsResponse).availablePoints;
        }
      } catch (_) {
        // Fall back to wallet earning balance in UI when points are unavailable.
      }

      emit(WalletLoadSuccess(walletResponse, availablePoints: availablePoints));
    } catch (e) {
      emit(WalletLoadFailure(e.toString()));
    }
  }
}
