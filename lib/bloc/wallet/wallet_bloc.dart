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
      final result = await _repository.fetchWallet(
        userId: event.userId,
        userType: event.userType,
      );
      if (result.isSuccess && result.data is WalletResponse) {
        final walletResponse = result.data as WalletResponse;
        emit(WalletLoadSuccess(walletResponse));
        // Fetch member points after wallet (no loader).
        try {
          final pointsResult = await _repository.fetchMemberPoints();
          if (pointsResult.isSuccess && pointsResult.data is MemberPointsResponse) {
            final points = (pointsResult.data as MemberPointsResponse).availablePoints;
            emit(WalletLoadSuccess(walletResponse, availablePoints: points));
          }
        } catch (_) {
          // Keep wallet success state; points stay null
        }
      } else {
        emit(WalletLoadFailure(result.message ?? 'Failed to load wallet'));
      }
    } catch (e) {
      emit(WalletLoadFailure(e.toString()));
    }
  }
}
