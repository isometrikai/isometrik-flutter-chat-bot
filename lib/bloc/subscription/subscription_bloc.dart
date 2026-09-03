import 'dart:async';

import 'package:chat_bot/bloc/subscription/subscription_event.dart';
import 'package:chat_bot/bloc/subscription/subscription_state.dart';
import 'package:chat_bot/services/in_app_purchase/iap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({IapService? iapService})
      : _iap = iapService ?? IapService.instance,
        super(const SubscriptionInitial()) {
    on<SubscriptionStarted>(_onStarted);
    on<SubscriptionAutoRenewToggled>(_onAutoRenewToggled);
    on<SubscriptionPurchaseRequested>(_onPurchaseRequested);
    on<SubscriptionRestoreRequested>(_onRestoreRequested);
    on<_SubscriptionPurchaseUpdate>(_onPurchaseUpdate);
  }

  static const String _tag = 'IAP-BLOC';

  final IapService _iap;
  StreamSubscription<IapPurchaseResult>? _purchaseSub;
  bool _autoRenew = false;
  String? _lastSuccessKey;

  void _log(String message) => print('$_tag | $message');

  void _logInfo(String message) => print('$_tag | INFO | $message');

  void _logSuccess(String message) => print('$_tag | SUCCESS | $message');

  void _logError(String message) => print('$_tag | ERROR | $message');

  Future<void> _onStarted(
    SubscriptionStarted event,
    Emitter<SubscriptionState> emit,
  ) async {
    _logInfo('event=SubscriptionStarted');
    emit(const SubscriptionLoadInProgress());

    await _iap.initialize();
    await _purchaseSub?.cancel();
    _purchaseSub = _iap.purchaseUpdates.listen((result) {
      _log('purchaseUpdates → status=${result.status} | '
          'productId=${result.productId} | '
          'transactionId=${result.transactionId} | '
          'error=${result.errorMessage}');
      add(_SubscriptionPurchaseUpdate(result));
    });

    final entitlement = await _iap.getEntitlement();
    if (entitlement != null) {
      _autoRenew = entitlement.autoRenew;
      _log('existing entitlement found | autoRenew=$_autoRenew');
    } else {
      _log('no existing entitlement');
    }

    _logSuccess(
      'ready | storeAvailable=${_iap.isAvailable} | '
      'autoRenew=$_autoRenew | '
      'autoRenewProduct=${_iap.autoRenewProduct?.id} '
      '(${_iap.autoRenewProduct?.price}) | '
      'manualProduct=${_iap.manualProduct?.id} '
      '(${_iap.manualProduct?.price})',
    );

    emit(
      SubscriptionReady(
        storeAvailable: _iap.isAvailable,
        autoRenew: _autoRenew,
        autoRenewProduct: _iap.autoRenewProduct,
        manualProduct: _iap.manualProduct,
        entitlement: entitlement,
      ),
    );
  }

  void _onAutoRenewToggled(
    SubscriptionAutoRenewToggled event,
    Emitter<SubscriptionState> emit,
  ) {
    _logInfo('event=AutoRenewToggled → ${event.autoRenew} | '
        'productId=${IapProductIds.forAutoRenew(event.autoRenew)}');
    _autoRenew = event.autoRenew;
    final current = state;
    if (current is SubscriptionReady) {
      emit(current.copyWith(autoRenew: event.autoRenew));
    } else if (current is SubscriptionFailure) {
      emit(
        SubscriptionReady(
          storeAvailable: _iap.isAvailable,
          autoRenew: event.autoRenew,
          autoRenewProduct: _iap.autoRenewProduct,
          manualProduct: _iap.manualProduct,
        ),
      );
    }
  }

  Future<void> _onPurchaseRequested(
    SubscriptionPurchaseRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    _logInfo('event=PurchaseRequested | autoRenew=$_autoRenew | '
        'productId=${IapProductIds.forAutoRenew(_autoRenew)}');
    final current = state;
    if (current is SubscriptionReady) {
      emit(current.copyWith(purchaseInProgress: true));
    }

    final started =
        await _iap.purchaseSelectedPlan(autoRenew: _autoRenew);
    _log('purchaseSelectedPlan started=$started');
    if (!started && state is SubscriptionReady) {
      emit(
        (state as SubscriptionReady).copyWith(purchaseInProgress: false),
      );
    }
  }

  Future<void> _onRestoreRequested(
    SubscriptionRestoreRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    _logInfo('event=RestoreRequested');
    final current = state;
    if (current is SubscriptionReady) {
      emit(current.copyWith(purchaseInProgress: true));
    }
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(
    _SubscriptionPurchaseUpdate event,
    Emitter<SubscriptionState> emit,
  ) async {
    final result = event.result;
    _logInfo('event=PurchaseUpdate | status=${result.status} | '
        'productId=${result.productId} | error=${result.errorMessage}');

    switch (result.status) {
      // case IapPurchaseStatus.restoreEmpty:
      //   _log('store restore finished with no purchases');
      //   break;
      case IapPurchaseStatus.pending:
        if (state is SubscriptionReady) {
          emit(
            (state as SubscriptionReady).copyWith(purchaseInProgress: true),
          );
        }
        break;

      case IapPurchaseStatus.purchased:
      case IapPurchaseStatus.restored:
        final successKey =
            '${result.productId ?? ''}|${result.transactionId ?? ''}';
        if (_lastSuccessKey == successKey && successKey != '|') {
          _logInfo('skip duplicate success emit | key=$successKey');
          break;
        }
        _lastSuccessKey = successKey;
        _logSuccess('purchase ${result.status.name} — emitting success');
        final entitlement = await _iap.getEntitlement();
        emit(
          SubscriptionPurchaseSuccess(
            result: result,
            autoRenew: _autoRenew,
          ),
        );
        emit(
          SubscriptionReady(
            storeAvailable: _iap.isAvailable,
            autoRenew: _autoRenew,
            autoRenewProduct: _iap.autoRenewProduct,
            manualProduct: _iap.manualProduct,
            entitlement: entitlement,
          ),
        );
        break;

      case IapPurchaseStatus.canceled:
        _log('purchase canceled');
        if (state is SubscriptionReady) {
          emit(
            (state as SubscriptionReady).copyWith(purchaseInProgress: false),
          );
        }
        break;

      case IapPurchaseStatus.error:
        _logError('purchase error: ${result.errorMessage}');
        emit(
          SubscriptionFailure(
            message: result.errorMessage ?? 'Purchase failed.',
            autoRenew: _autoRenew,
          ),
        );
        emit(
          SubscriptionReady(
            storeAvailable: _iap.isAvailable,
            autoRenew: _autoRenew,
            autoRenewProduct: _iap.autoRenewProduct,
            manualProduct: _iap.manualProduct,
            entitlement: await _iap.getEntitlement(),
          ),
        );
        break;
    }
  }

  @override
  Future<void> close() async {
    _log('bloc close()');
    await _purchaseSub?.cancel();
    return super.close();
  }
}

/// Internal event bridging purchase stream → bloc.
class _SubscriptionPurchaseUpdate extends SubscriptionEvent {
  final IapPurchaseResult result;

  const _SubscriptionPurchaseUpdate(this.result);

  @override
  List<Object?> get props => [result];
}
