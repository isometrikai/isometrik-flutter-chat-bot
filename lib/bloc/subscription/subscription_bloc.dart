import 'dart:async';

import 'package:chat_bot/bloc/subscription/subscription_event.dart';
import 'package:chat_bot/bloc/subscription/subscription_state.dart';
import 'package:chat_bot/services/in_app_purchase/iap.dart';
import 'package:chat_bot/utils/app_translations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({IapService? iapService})
      : _iap = iapService ?? IapService.instance,
        super(const SubscriptionInitial()) {
    on<SubscriptionStarted>(_onStarted);
    on<SubscriptionAutoRenewToggled>(_onAutoRenewToggled);
    on<SubscriptionPurchaseRequested>(_onPurchaseRequested);
    on<SubscriptionRestoreRequested>(_onRestoreRequested);
    on<_SubscriptionPurchaseUpdate>(
      _onPurchaseUpdate,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }

  static const String _tag = 'IAP-BLOC';

  final IapService _iap;
  StreamSubscription<IapPurchaseResult>? _purchaseSub;
  bool _autoRenew = false;
  String? _lastSuccessKey;

  /// True after the user taps Subscribe or Restore on this paywall.
  /// Startup Play Billing replays must not drive UI (toggle / toasts / success).
  bool _awaitingStoreResult = false;

  /// Restore/Subscribe can yield several store events (iOS: purchased+restored
  /// per product). Show the success sheet only once per user action.
  bool _didShowSuccessForCurrentAction = false;

  void _log(String message) {
    final line = '$_tag | $message';
    print(line);
    IapLogCollector.instance.log(line);
  }

  void _logInfo(String message) {
    final line = '$_tag | INFO | $message';
    print(line);
    IapLogCollector.instance.log(line);
  }

  void _logSuccess(String message) {
    final line = '$_tag | SUCCESS | $message';
    print(line);
    IapLogCollector.instance.log(line);
  }

  void _logError(String message) {
    final line = '$_tag | ERROR | $message';
    print(line);
    IapLogCollector.instance.log(line);
  }

  String _sessionContext() =>
      'awaiting=$_awaitingStoreResult | inFlight=${_iap.isPurchaseInFlight} | '
      'subscribe=${_iap.isSubscribeSessionActive} | '
      'didShowSuccess=$_didShowSuccessForCurrentAction';

  Future<void> _onStarted(
    SubscriptionStarted event,
    Emitter<SubscriptionState> emit,
  ) async {
    _logInfo('event=SubscriptionStarted');
    emit(const SubscriptionLoadInProgress());

    // Paywall always starts on the manual plan. Do not copy entitlement.autoRenew
    // — on Android that cache is often true from a previous auto-renew buy, which
    // paints the toggle ON and then snaps it OFF.
    _autoRenew = false;

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
      _log('existing entitlement found | autoRenew=${entitlement.autoRenew} '
          '(ignored for toggle; paywall default is manual)');
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
    _awaitingStoreResult = true;
    _didShowSuccessForCurrentAction = false;
    _logInfo('paywall session START | Subscribe | ${_sessionContext()}');
    final current = state;
    if (current is SubscriptionReady) {
      emit(current.copyWith(purchaseInProgress: true));
    }

    final started =
        await _iap.purchaseSelectedPlan(autoRenew: _autoRenew);
    _log('purchaseSelectedPlan started=$started');
    // Do not clear _awaitingStoreResult here. buyNonConsumable can emit
    // canceled/error and return false; clearing the flag drops that event
    // (iOS duplicate pending transaction). PurchaseUpdate owns the flag.
  }

  Future<void> _onRestoreRequested(
    SubscriptionRestoreRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    _logInfo('event=RestoreRequested');
    _awaitingStoreResult = true;
    _didShowSuccessForCurrentAction = false;
    _logInfo('paywall session START | Restore | ${_sessionContext()}');
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
        'productId=${result.productId} | tx=${result.transactionId} | '
        'error=${result.errorMessage} | ${_sessionContext()}');

    if (!_awaitingStoreResult && !_iap.isPurchaseInFlight) {
      _logInfo(
        'ignore store update (background replay) | status=${result.status} | '
        'productId=${result.productId} | tx=${result.transactionId}',
      );
      return;
    }

    switch (result.status) {
      case IapPurchaseStatus.pending:
        if (state is SubscriptionReady) {
          emit(
            (state as SubscriptionReady).copyWith(purchaseInProgress: true),
          );
        }
        break;

      case IapPurchaseStatus.purchased:
      case IapPurchaseStatus.restored:
        if (_didShowSuccessForCurrentAction) {
          _logInfo(
            'skip extra ${result.status.name} UI — success already shown '
            'for this Subscribe/Restore',
          );
          break;
        }
        final successKey =
            '${result.productId ?? ''}|${result.transactionId ?? ''}';
        if (_lastSuccessKey == successKey && successKey != '|') {
          _logInfo('skip duplicate success emit | key=$successKey');
          break;
        }
        _lastSuccessKey = successKey;
        _didShowSuccessForCurrentAction = true;
        _awaitingStoreResult = false;
        _logSuccess(
          'paywall session END | success | tx=${result.transactionId} | '
          '${_sessionContext()}',
        );
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

      case IapPurchaseStatus.alreadySubscribed:
        _awaitingStoreResult = false;
        _logInfo(
          'paywall session END | alreadySubscribed | tx=${result.transactionId} | '
          '${_sessionContext()}',
        );
        emit(
          SubscriptionAlreadySubscribed(
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
            entitlement: await _iap.getEntitlement(),
          ),
        );
        break;

      case IapPurchaseStatus.canceled:
        _log('purchase canceled | ${_sessionContext()}');
        _awaitingStoreResult = false;
        _iap.abandonSubscribeSession();
        _logInfo('paywall session END | canceled');
        if (state is SubscriptionReady) {
          emit(
            (state as SubscriptionReady).copyWith(purchaseInProgress: false),
          );
        }
        break;

      case IapPurchaseStatus.error:
        _logError('purchase error: ${result.errorMessage}');
        // Stale sandbox renewals can surface as activation errors while a new
        // Subscribe is still in flight — do not drop the paywall session yet.
        const activationFailed =
            'Purchase succeeded in store, but activating plan failed. '
            'Please try again.';
        if (_awaitingStoreResult &&
            result.errorMessage == activationFailed &&
            (_iap.isPurchaseInFlight || _iap.isSubscribeSessionActive)) {
          _logInfo(
            'ignore transient activation error while subscribe in flight | '
            'tx=${result.transactionId} | ${_sessionContext()}',
          );
          break;
        }
        _awaitingStoreResult = false;
        _iap.abandonSubscribeSession();
        _logInfo(
          'paywall session END | error | message=${result.errorMessage} | '
          'tx=${result.transactionId}',
        );
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

      case IapPurchaseStatus.restoreEmpty:
        _log('restore finished with no purchases | ${_sessionContext()}');
        _awaitingStoreResult = false;
        _logInfo('paywall session END | restoreEmpty');
        if (_didShowSuccessForCurrentAction) break;
        emit(
          SubscriptionFailure(
            message: AppTranslations.planPriceRestoreEmpty,
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
