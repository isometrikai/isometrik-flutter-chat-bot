import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_bot/data/repositories/subscription_purchase_repository.dart';
import 'package:chat_bot/services/in_app_purchase/iap_models.dart';
import 'package:chat_bot/services/in_app_purchase/iap_product_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef IapPurchaseCallback = void Function(IapPurchaseResult result);

enum _BackendReportOutcome { success, expired, failed }

/// Central In-App Purchase service.
///
/// Responsibilities:
/// - Store availability + product loading
/// - Purchase / restore (iOS products, Android base plans)
/// - Completing transactions
/// - Reporting purchases to backend
///   (`/v1/customer/eazysubscription/purchase` on iOS,
///   `/v1/customer/eazysubscription/android/purchase` on Android)
/// - Local entitlement cache (server verification can also hook via [onPurchaseVerified])
class IapService {
  IapService._({SubscriptionPurchaseRepository? purchaseRepository})
      : _purchaseRepository =
            purchaseRepository ?? SubscriptionPurchaseRepository();

  static final IapService instance = IapService._();

  static const String _entitlementPrefsKey = 'iap_entitlement_v1';
  static const String _tag = 'IAP';

  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionPurchaseRepository _purchaseRepository;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final _purchaseController = StreamController<IapPurchaseResult>.broadcast();

  final Map<String, ProductDetails> _products = {};

  /// Every product/offer returned by the store. On Android a subscription
  /// product yields one entry per base plan, all sharing the same product id.
  final List<ProductDetails> _storeProducts = [];

  final Set<String> _handledSuccessKeys = {};
  /// iOS purchases we did not `completePurchase` yet (backend failed).
  /// StoreKit blocks a second buy of the same product until these are finished.
  final Map<String, PurchaseDetails> _unfinishedPurchases = {};
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _purchaseInFlight = false;
  int _inFlightPurchaseHandlers = 0;
  bool _restoreSession = false;

  /// While clearing stale iOS StoreKit transactions, do not push errors to the
  /// paywall — sandbox renewal replays would clear Subscribe state early.
  int _suppressPurchaseUi = 0;

  /// Product id for an in-flight user Subscribe tap (not Restore). Cleared on
  /// terminal purchase outcomes for that plan.
  String? _subscribeSessionProductId;

  /// Plan the user selected for the in-flight purchase. On Android the product
  /// id is the same for both base plans, so this is how we tell them apart.
  bool _pendingAutoRenew = false;

  /// Optional host/backend verification hook after a successful store purchase.
  IapPurchaseCallback? onPurchaseVerified;

  Stream<IapPurchaseResult> get purchaseUpdates => _purchaseController.stream;

  bool get isAvailable => _storeAvailable;

  bool get isInitialized => _initialized;

  bool get isPurchaseInFlight => _purchaseInFlight;

  /// True between [purchaseSelectedPlan] and a terminal Subscribe outcome.
  bool get isSubscribeSessionActive => _subscribeSessionProductId != null;

  /// Clears an in-flight Subscribe session after the paywall gives up on errors.
  void abandonSubscribeSession() => _clearSubscribeSession();

  List<ProductDetails> get products => List.unmodifiable(_storeProducts);

  ProductDetails? productFor(String productId) => _products[productId];

  ProductDetails? get autoRenewProduct => _productForPlan(autoRenew: true);

  ProductDetails? get manualProduct => _productForPlan(autoRenew: false);

  void _log(String message) => print('$_tag | $message');

  void _logInfo(String message) => print('$_tag | INFO | $message');

  void _logSuccess(String message) => print('$_tag | SUCCESS | $message');

  void _logError(String message, [StackTrace? stackTrace]) {
    print('$_tag | ERROR | $message');
    if (stackTrace != null) {
      print('$_tag | ERROR STACK | $stackTrace');
    }
  }

  /// Compact snapshot of internal purchase-session flags (for debugging).
  String _sessionContext() =>
      'inFlight=$_purchaseInFlight | suppressUi=$_suppressPurchaseUi | '
      'restore=$_restoreSession | subscribe=${_subscribeSessionProductId ?? "none"} | '
      'unfinished=${_unfinishedPurchases.length} | '
      'handledKeys=${_handledSuccessKeys.length}';

  String _outcomeLabel(_BackendReportOutcome outcome) => switch (outcome) {
        _BackendReportOutcome.success => 'SUCCESS',
        _BackendReportOutcome.expired => 'EXPIRED_STALE',
        _BackendReportOutcome.failed => 'FAILED',
      };

  String _productSummary(ProductDetails p) {
    final base = 'id=${p.id}, title=${p.title}, description=${p.description}, '
        'price=${p.price}, rawPrice=${p.rawPrice}, '
        'currencyCode=${p.currencyCode}, currencySymbol=${p.currencySymbol}';
    if (p is GooglePlayProductDetails) {
      return '$base, basePlanId=${_basePlanIdOf(p)}, '
          'offerId=${_offerIdOf(p)}, hasOfferToken=${p.offerToken != null}';
    }
    return base;
  }

  String _purchaseSummary(PurchaseDetails p) =>
      'productID=${p.productID}, purchaseID=${p.purchaseID}, '
      'status=${p.status}, transactionDate=${p.transactionDate}, '
      'pendingCompletePurchase=${p.pendingCompletePurchase}, '
      'error=${p.error}, '
      'verificationDataSource=${p.verificationData.source}, '
      'localVerificationDataLen=${p.verificationData.localVerificationData.length}, '
      'serverVerificationDataLen=${p.verificationData.serverVerificationData.length}';

  /// Clears the in-flight Subscribe product id.
  void _clearSubscribeSession() {
    _subscribeSessionProductId = null;
  }

  void _clearSubscribeSessionFor(String? productId) {
    if (productId != null && _subscribeSessionProductId == productId) {
      _clearSubscribeSession();
    }
  }

  /// True only during an explicit Subscribe tap: same plan, active entitlement,
  /// matching transaction id, and not stale cleanup replay.
  Future<bool> _shouldEmitAlreadySubscribed(PurchaseDetails purchase) async {
    if (_restoreSession) return false;
    if (_suppressPurchaseUi > 0) return false;

    final targetProductId = _subscribeSessionProductId;
    if (targetProductId == null || purchase.productID != targetProductId) {
      return false;
    }

    final entitlement = await getEntitlement();
    if (entitlement == null || !entitlement.isActive) return false;
    if (entitlement.productId != purchase.productID) return false;

    final txId = (purchase.purchaseID ?? '').trim();
    final entTxId = (entitlement.transactionId ?? '').trim();
    if (txId.isEmpty || entTxId.isEmpty || txId != entTxId) {
      return false;
    }

    _logInfo(
      'alreadySubscribed eligible | product=${purchase.productID} | tx=$txId',
    );
    return true;
  }

  Future<void> initialize() async {
    _logInfo('initialize() called | alreadyInitialized=$_initialized');
    if (_initialized) {
      _log('initialize() skipped — already initialized | '
          'storeAvailable=$_storeAvailable | products=${_products.length}');
      return;
    }

    _log('platform=${Platform.operatingSystem} '
        '| isIOS=${Platform.isIOS} | isAndroid=${Platform.isAndroid} '
        '| debugMode=$kDebugMode '
        '| productIds=${IapProductIds.all}');

    _log('checking store availability via InAppPurchase.isAvailable()...');
    _storeAvailable = await _iap.isAvailable();
    _logInfo('storeAvailable=$_storeAvailable');

    if (!_storeAvailable) {
      _logError('store NOT available — cannot load products or purchase');
      _initialized = true;
      return;
    }

    _log('subscribing to purchaseStream...');
    _purchaseSub = _iap.purchaseStream.listen(
      (purchases) {
        _logInfo('purchaseStream event | count=${purchases.length}');
        _onPurchaseUpdated(purchases);
      },
      onDone: () {
        _log('purchaseStream onDone');
        _purchaseSub = null;
      },
      onError: (Object error, StackTrace stack) {
        _logError('purchaseStream onError: $error', stack);
        _purchaseInFlight = false;
        _purchaseController.add(
          IapPurchaseResult(
            status: IapPurchaseStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
    _logSuccess('purchaseStream listener attached');

    _initialized = true;
    _logSuccess('initialize() complete — loading products next');
    await loadProducts();
  }

  /// Query App Store / Play Store for configured product IDs.
  Future<List<ProductDetails>> loadProducts() async {
    _logInfo('loadProducts() start | productIds=${IapProductIds.all}');
    await _ensureInitialized();

    if (!_storeAvailable) {
      _logError('loadProducts() aborted — store not available');
      return const [];
    }

    try {
      _log('queryProductDetails() requesting: ${IapProductIds.all}');
      final response = await _iap.queryProductDetails(IapProductIds.all);

      _log('queryProductDetails() returned | '
          'found=${response.productDetails.length} | '
          'notFound=${response.notFoundIDs} | '
          'error=${response.error}');

      if (response.error != null) {
        final err = response.error!;
        _logError(
          'queryProductDetails ERROR | '
          'code=${err.code} | source=${err.source} | '
          'message=${err.message} | details=${err.details}',
        );
      }

      if (response.notFoundIDs.isNotEmpty) {
        _logError('products NOT FOUND in store: ${response.notFoundIDs}');
      }

      if (response.productDetails.isEmpty) {
        _logError('productDetails list is EMPTY');
      }

      for (final p in response.productDetails) {
        _logSuccess('product loaded → ${_productSummary(p)}');
      }

      _products
        ..clear()
        ..addEntries(
          response.productDetails.map((p) => MapEntry(p.id, p)),
        );
      _storeProducts
        ..clear()
        ..addAll(response.productDetails);

      _logInfo(
        'loadProducts() done | cached=${_products.keys.toList()} | '
        'offers=${_storeProducts.length} | '
        'autoRenew=${autoRenewProduct != null} | '
        'manual=${manualProduct != null}',
      );
    } catch (e, st) {
      _logError('loadProducts() exception: $e', st);
    }

    return products;
  }

  /// Buy auto-renew or manual plan based on [autoRenew].
  ///
  /// iOS buys a dedicated product, Android buys the matching base plan of the
  /// single `zain_pro` subscription product.
  Future<bool> purchaseSelectedPlan({required bool autoRenew}) async {
    final productId = IapProductIds.forAutoRenew(autoRenew);
    _logInfo(
      'purchaseSelectedPlan(autoRenew=$autoRenew) → productId=$productId'
      '${Platform.isAndroid ? " | basePlanId=${IapProductIds.basePlanForAutoRenew(autoRenew)}" : ""}',
    );
    _pendingAutoRenew = autoRenew;
    _subscribeSessionProductId = productId;

    await _ensureInitialized();

    if (!_storeAvailable) {
      _clearSubscribeSession();
      _logError('purchaseSelectedPlan() aborted — store not available');
      _emitError('In-app purchases are not available on this device.');
      return false;
    }
    if (_purchaseInFlight) {
      _clearSubscribeSession();
      _logError('purchaseSelectedPlan() aborted — purchase already in flight');
      _emitError('A purchase is already in progress.');
      return false;
    }

    var product = _productForPlan(autoRenew: autoRenew);
    if (product == null) {
      _log('plan not in cache (autoRenew=$autoRenew) — reloading products...');
      await loadProducts();
      product = _productForPlan(autoRenew: autoRenew);
    }

    if (product == null) {
      _clearSubscribeSession();
      _logError(
        'purchaseSelectedPlan() aborted — plan not available | '
        'productId=$productId | cached=${_products.keys.toList()}',
      );
      _emitError('Plan is not available. Please try again later.');
      return false;
    }

    if (Platform.isIOS) {
      _logInfo(
        'iOS pre-buy cleanup start | productId=$productId | '
        '${_sessionContext()}',
      );
      _purchaseInFlight = true;
      try {
        final claimed = await _resolveUnfinishedIosPurchase(productId);
        if (claimed) {
          _purchaseInFlight = false;
          _logSuccess(
            'iOS pre-buy cleanup claimed active plan | productId=$productId | '
            '${_sessionContext()}',
          );
          return true;
        }
        _logInfo(
          'iOS pre-buy cleanup done — opening store sheet | '
          'productId=$productId | ${_sessionContext()}',
        );
      } catch (e, st) {
        _logError('resolve unfinished iOS purchase failed: $e', st);
      }
      _purchaseInFlight = false;
    }

    return _startPurchase(product);
  }

  /// Start purchase for [productId]. Returns false if purchase could not start.
  Future<bool> purchaseProduct(String productId) async {
    _logInfo('purchaseProduct() start | productId=$productId | '
        'inFlight=$_purchaseInFlight | cachedProducts=${_products.keys.toList()}');

    await _ensureInitialized();

    if (!_storeAvailable) {
      _logError('purchaseProduct() aborted — store not available');
      _emitError('In-app purchases are not available on this device.');
      return false;
    }
    if (_purchaseInFlight) {
      _logError('purchaseProduct() aborted — purchase already in flight');
      _emitError('A purchase is already in progress.');
      return false;
    }

    var product = _products[productId];
    if (product == null) {
      _log('product $productId not in cache — reloading products...');
      await loadProducts();
      product = _products[productId];
    }

    if (product == null) {
      _logError('purchaseProduct() aborted — product $productId not available');
      _emitError('Plan is not available. Please try again later.');
      return false;
    }

    return _startPurchase(product);
  }

  Future<bool> _startPurchase(ProductDetails product) async {
    _log('buying non-consumable → ${_productSummary(product)}');
    _purchaseInFlight = true;

    final param = product is GooglePlayProductDetails
        ? GooglePlayPurchaseParam(
            productDetails: product,
            offerToken: product.offerToken,
          )
        : PurchaseParam(productDetails: product);

    if (product is GooglePlayProductDetails) {
      _log('using GooglePlayPurchaseParam | basePlanId=${_basePlanIdOf(product)} '
          '| offerTokenLen=${product.offerToken?.length ?? 0}');
    }

    try {
      final started = await _iap.buyNonConsumable(purchaseParam: param);
      _logInfo('buyNonConsumable() returned started=$started');
      if (!started) {
        _purchaseInFlight = false;
        _logError('buyNonConsumable() failed to start');
        _emitError('Unable to start purchase.');
      } else {
        _logSuccess(
          'purchase sheet started for ${product.id} — waiting for stream',
        );
      }
      return started;
    } on PlatformException catch (e, st) {
      _purchaseInFlight = false;
      // StoreKit often reports Sandbox auth cancel/fail as userCancelled.
      if (_isUserCancelled(e)) {
        _logInfo('buyNonConsumable() cancelled by user / sandbox auth | $e');
        _purchaseController.add(
          IapPurchaseResult(
            status: IapPurchaseStatus.canceled,
            productId: product.id,
            errorMessage: e.message,
          ),
        );
        return false;
      }
      if (_isDuplicatePendingTransactionError(e)) {
        _logInfo(
          'pending StoreKit transaction for ${product.id} — resolving then retry',
        );
        final claimed = await _resolveUnfinishedIosPurchase(product.id);
        if (claimed) return true;
        return _retryBuyAfterFinishingPending(product, param);
      }
      _logError('buyNonConsumable() PlatformException: $e', st);
      _emitError(e.message ?? e.toString());
      return false;
    } catch (e, st) {
      _purchaseInFlight = false;
      if (_isDuplicatePendingTransactionError(e)) {
        _logInfo(
          'pending StoreKit transaction for ${product.id} — resolving then retry',
        );
        final claimed = await _resolveUnfinishedIosPurchase(product.id);
        if (claimed) return true;
        return _retryBuyAfterFinishingPending(product, param);
      }
      _logError('buyNonConsumable() exception: $e', st);
      _emitError(e.toString());
      return false;
    }
  }

  /// Resolve the store product for a plan.
  ///
  /// Android: matches the base plan of the `zain_pro` subscription, preferring
  /// the plain base plan over discounted offers.
  ProductDetails? _productForPlan({required bool autoRenew}) {
    if (!Platform.isAndroid) {
      return _products[IapProductIds.forAutoRenew(autoRenew)];
    }

    final basePlanId = IapProductIds.basePlanForAutoRenew(autoRenew);
    final matches = _storeProducts
        .whereType<GooglePlayProductDetails>()
        .where((p) => _basePlanIdOf(p) == basePlanId)
        .toList(growable: false);

    if (matches.isEmpty) return null;
    return matches.firstWhere(
      (p) => _offerIdOf(p) == null,
      orElse: () => matches.first,
    );
  }

  String? _basePlanIdOf(GooglePlayProductDetails product) =>
      _offerDetailsOf(product)?.basePlanId;

  String? _offerIdOf(GooglePlayProductDetails product) =>
      _offerDetailsOf(product)?.offerId;

  SubscriptionOfferDetailsWrapper? _offerDetailsOf(
    GooglePlayProductDetails product,
  ) {
    final index = product.subscriptionIndex;
    final offers = product.productDetails.subscriptionOfferDetails;
    if (index == null || offers == null || index >= offers.length) return null;
    return offers[index];
  }

  bool _isUserCancelled(PlatformException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();
    return code == 'usercancelled' ||
        code.contains('cancel') ||
        message.contains('usercancelled') ||
        message.contains('cancelled') ||
        message.contains('canceled');
  }

  bool _isDuplicatePendingTransactionError(Object e) {
    if (e is PlatformException) {
      final code = e.code.toLowerCase();
      final message = (e.message ?? '').toLowerCase();
      return code == 'storekit_duplicate_product_object' ||
          message.contains('pending transaction') ||
          message.contains('duplicate_product');
    }
    final message = e.toString().toLowerCase();
    return message.contains('storekit_duplicate_product_object') ||
        message.contains('pending transaction');
  }

  Future<bool> _retryBuyAfterFinishingPending(
    ProductDetails product,
    PurchaseParam param,
  ) async {
    _purchaseInFlight = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final started = await _iap.buyNonConsumable(purchaseParam: param);
      _logInfo('retry buyNonConsumable() returned started=$started');
      if (!started) {
        _purchaseInFlight = false;
        _emitError('Unable to start purchase.');
      }
      return started;
    } on PlatformException catch (e, st) {
      _purchaseInFlight = false;
      if (_isUserCancelled(e)) {
        _purchaseController.add(
          IapPurchaseResult(
            status: IapPurchaseStatus.canceled,
            productId: product.id,
            errorMessage: e.message,
          ),
        );
        return false;
      }
      _logError('retry buyNonConsumable() PlatformException: $e', st);
      _emitError(e.message ?? e.toString());
      return false;
    } catch (e, st) {
      _purchaseInFlight = false;
      _logError('retry buyNonConsumable() exception: $e', st);
      _emitError(e.toString());
      return false;
    }
  }

  /// Clears leftover iOS transactions for [productId] so StoreKit will allow
  /// another buy. If the leftover purchase can be activated, emits success.
  Future<bool> _resolveUnfinishedIosPurchase(String productId) async {
    if (!Platform.isIOS) return false;
    _suppressPurchaseUi++;
    _logInfo(
      'resolveUnfinishedIosPurchase START | productId=$productId | '
      '${_sessionContext()}',
    );
    try {
      var claimed = false;

      final cached = _unfinishedPurchases.remove(productId);
      if (cached != null) {
        _logInfo(
          'retry cached unfinished | productId=$productId | '
          'tx=${cached.purchaseID}',
        );
        claimed = await _activateThenFinishIosPurchase(cached);
      }

      claimed = await _finishStoreKit2Unfinished(productId) || claimed;
      _logInfo(
        'resolveUnfinishedIosPurchase END | productId=$productId | '
        'claimed=$claimed | ${_sessionContext()}',
      );
      return claimed;
    } finally {
      _suppressPurchaseUi--;
    }
  }

  Future<bool> _finishStoreKit2Unfinished(String productId) async {
    var claimed = false;
    var finishedCount = 0;
    var expiredCount = 0;
    var failedCount = 0;
    try {
      for (var attempt = 0; attempt < 3; attempt++) {
        final unfinished = await SK2Transaction.unfinishedTransactions();
        final matches =
            unfinished.where((tx) => tx.productId == productId).toList()
              ..sort(
                (a, b) => b.purchaseDate.compareTo(a.purchaseDate),
              );
        _logInfo(
          'SK2 cleanup attempt=$attempt | totalUnfinished=${unfinished.length} | '
          'matching=$productId:${matches.length} | txIds='
          '${matches.map((t) => t.id).join(",")}',
        );
        if (matches.isEmpty) break;

        for (var i = 0; i < matches.length; i++) {
          final tx = matches[i];
          final txId = tx.id.trim();
          final receipt =
              (tx.receiptData ?? tx.jsonRepresentation ?? '').trim();
          final successKey = '$productId|$txId';
          final isNewest = i == 0;

          _BackendReportOutcome outcome = _BackendReportOutcome.failed;
          if (isNewest && txId.isNotEmpty && receipt.isNotEmpty) {
            outcome = await _reportAppleReceipt(
              productId: productId,
              transactionId: txId,
              receiptData: receipt,
            );
            _logInfo(
              'SK2 newest tx backend → ${_outcomeLabel(outcome)} | tx=$txId',
            );
          } else if (!isNewest) {
            _logInfo('SK2 stale tx — skip backend, finish only | tx=$txId');
            outcome = _BackendReportOutcome.expired;
          }

          final idNum = int.tryParse(txId);
          if (idNum != null) {
            try {
              await SK2Transaction.finish(idNum);
              finishedCount++;
              _logSuccess('SK2Transaction.finish($idNum) | product=$productId');
            } catch (e, st) {
              _logError('SK2Transaction.finish($idNum) failed: $e', st);
            }
          }

          switch (outcome) {
            case _BackendReportOutcome.success:
              if (!_handledSuccessKeys.contains(successKey)) {
                _handledSuccessKeys.add(successKey);
                await _persistEntitlementFields(
                  productId: productId,
                  autoRenew: productId == IapProductIds.autoRenewMonthly,
                  transactionId: txId,
                );
                _emitPurchaseUpdate(
                  IapPurchaseResult(
                    status: IapPurchaseStatus.purchased,
                    productId: productId,
                    transactionId: txId,
                  ),
                );
              }
              claimed = true;
            case _BackendReportOutcome.expired:
              expiredCount++;
              _handledSuccessKeys.add(successKey);
            case _BackendReportOutcome.failed:
              if (isNewest) failedCount++;
          }
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      _logInfo(
        'SK2 cleanup summary | product=$productId | claimed=$claimed | '
        'finished=$finishedCount | expired=$expiredCount | failed=$failedCount',
      );
    } catch (e, st) {
      _logError('SK2 unfinishedTransactions failed: $e', st);
    }
    return claimed;
  }

  Future<bool> _activateThenFinishIosPurchase(PurchaseDetails purchase) async {
    final txId = purchase.purchaseID ?? '';
    _BackendReportOutcome outcome = _BackendReportOutcome.failed;
    try {
      outcome = await _reportApplePurchase(purchase);
    } catch (e, st) {
      _logError('activate unfinished purchase failed: $e', st);
    }
    _logInfo(
      'activateThenFinish | product=${purchase.productID} | tx=$txId | '
      'outcome=${_outcomeLabel(outcome)}',
    );

    if (outcome == _BackendReportOutcome.success) {
      _handledSuccessKeys.add(_successKey(purchase));
      await _persistEntitlement(purchase);
      _emitPurchaseUpdate(
        IapPurchaseResult(
          status: IapPurchaseStatus.purchased,
          productId: purchase.productID,
          transactionId: purchase.purchaseID,
          raw: purchase,
        ),
      );
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
        _logSuccess('completePurchase() after activate | tx=$txId');
      }
      return true;
    }

    if (outcome == _BackendReportOutcome.expired) {
      _handledSuccessKeys.add(_successKey(purchase));
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
        _logInfo('discarded stale cached tx | product=${purchase.productID} | '
            'tx=$txId');
      }
      return false;
    }

    _unfinishedPurchases[purchase.productID] = purchase;
    _logInfo(
      'cached unfinished for retry | product=${purchase.productID} | tx=$txId',
    );
    return false;
  }

  Future<void> restorePurchases() async {
    _logInfo('restorePurchases() start');
    await _ensureInitialized();
    if (!_storeAvailable) {
      _logError('restorePurchases() aborted — store not available');
      _emitError('In-app purchases are not available on this device.');
      return;
    }
    _restoreSession = true;
    try {
      if (Platform.isAndroid) {
        await _restoreAndroidPurchases();
      } else {
        await _iap.restorePurchases();
        _logSuccess('restorePurchases() request sent — waiting for stream');
      }
    } catch (e, st) {
      _logError('restorePurchases() exception: $e', st);
      _emitError(e.toString());
    } finally {
      _restoreSession = false;
    }
  }

  /// Android Restore does not always push a stream event. Query Play directly
  /// so the paywall always gets success, empty, or error — iOS is unchanged.
  Future<void> _restoreAndroidPurchases() async {
    _logInfo('_restoreAndroidPurchases() queryPastPurchases');
    final addition =
        _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await addition.queryPastPurchases();
    if (response.error != null) {
      final err = response.error!;
      _logError(
        'queryPastPurchases ERROR | code=${err.code} | message=${err.message}',
      );
      _emitError(err.message ?? 'Failed to restore purchases.');
      return;
    }

    final past = response.pastPurchases;
    _logInfo('queryPastPurchases found=${past.length}');
    if (past.isEmpty) {
      _emitPurchaseUpdate(
        const IapPurchaseResult(status: IapPurchaseStatus.restoreEmpty),
      );
      return;
    }

    await _onPurchaseUpdated(past);
  }

  void _emitPurchaseUpdate(IapPurchaseResult result) {
    if (_suppressPurchaseUi > 0 &&
        !_restoreSession &&
        result.status != IapPurchaseStatus.purchased &&
        result.status != IapPurchaseStatus.restored &&
        result.status != IapPurchaseStatus.alreadySubscribed) {
      _logInfo(
        'UI suppressed | status=${result.status} | '
        'productId=${result.productId} | tx=${result.transactionId} | '
        '${_sessionContext()}',
      );
      return;
    }
    if (result.status == IapPurchaseStatus.purchased ||
        result.status == IapPurchaseStatus.alreadySubscribed) {
      _clearSubscribeSessionFor(result.productId);
    }
    _logInfo(
      'UI emit | status=${result.status} | productId=${result.productId} | '
      'tx=${result.transactionId} | error=${result.errorMessage} | '
      '${_sessionContext()}',
    );
    _purchaseController.add(result);
  }

  Future<IapEntitlement?> getEntitlement() async {
    _log('getEntitlement() reading prefs key=$_entitlementPrefsKey');
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entitlementPrefsKey);
    if (raw == null || raw.isEmpty) {
      _log('getEntitlement() → none stored');
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final entitlement = IapEntitlement.fromJson(map);
      _logInfo(
        'getEntitlement() → productId=${entitlement.productId} | '
        'autoRenew=${entitlement.autoRenew} | '
        'transactionId=${entitlement.transactionId} | '
        'purchasedAt=${entitlement.purchasedAt} | '
        'expiresAt=${entitlement.expiresAt} | '
        'isActive=${entitlement.isActive}',
      );
      return entitlement.isActive ? entitlement : null;
    } catch (e, st) {
      _logError('getEntitlement() parse error: $e', st);
      return null;
    }
  }

  Future<bool> hasActiveEntitlement() async {
    final entitlement = await getEntitlement();
    final active = entitlement?.isActive ?? false;
    _log('hasActiveEntitlement() → $active');
    return active;
  }

  Future<void> dispose() async {
    _logInfo('dispose()');
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    if (!_purchaseController.isClosed) {
      await _purchaseController.close();
    }
    _initialized = false;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _log('_ensureInitialized() → calling initialize()');
      await initialize();
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    _logInfo(
      '_onPurchaseUpdated | count=${purchases.length} | ${_sessionContext()}',
    );
    _inFlightPurchaseHandlers++;
    try {
      for (var i = 0; i < purchases.length; i++) {
        _log('purchase[$i] → ${_purchaseSummary(purchases[i])}');
        await _handlePurchase(purchases[i]);
      }
    } finally {
      _inFlightPurchaseHandlers--;
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    _logInfo(
      '_handlePurchase | status=${purchase.status} | '
      'productID=${purchase.productID} | tx=${purchase.purchaseID} | '
      '${_sessionContext()}',
    );

    switch (purchase.status) {
      case PurchaseStatus.pending:
        _log('status=pending — showing pending UI');
        _emitPurchaseUpdate(
          IapPurchaseResult(
            status: IapPurchaseStatus.pending,
            productId: purchase.productID,
            transactionId: purchase.purchaseID,
            raw: purchase,
          ),
        );
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        _purchaseInFlight = false;

        final successKey = _successKey(purchase);
        if (_handledSuccessKeys.contains(successKey)) {
          _logInfo(
            'skip duplicate ${purchase.status} | key=$successKey '
            '(already activated)',
          );
          if (_restoreSession) {
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            _emitPurchaseUpdate(
              IapPurchaseResult(
                status: IapPurchaseStatus.restored,
                productId: purchase.productID,
                transactionId: purchase.purchaseID,
                raw: purchase,
              ),
            );
            break;
          }

          if (await _shouldEmitAlreadySubscribed(purchase)) {
            _purchaseInFlight = false;
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            _emitPurchaseUpdate(
              IapPurchaseResult(
                status: IapPurchaseStatus.alreadySubscribed,
                productId: purchase.productID,
                transactionId: purchase.purchaseID,
                raw: purchase,
              ),
            );
            break;
          }

          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        }

        _logSuccess(
          'status=${purchase.status} — reporting to backend | '
          '${_purchaseSummary(purchase)}',
        );

        final outcome = await _reportPurchaseToBackend(purchase);
        _logInfo(
          'backend report | product=${purchase.productID} | '
          'tx=${purchase.purchaseID} | outcome=${_outcomeLabel(outcome)}',
        );
        if (outcome == _BackendReportOutcome.expired) {
          _logInfo(
            'stale StoreKit renewal — finish quietly | '
            'product=${purchase.productID} | tx=${purchase.purchaseID}',
          );
          _handledSuccessKeys.add(successKey);
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        }
        if (outcome != _BackendReportOutcome.success) {
          _logError(
            'backend activation FAILED — keeping StoreKit open for retry | '
            'product=${purchase.productID} | tx=${purchase.purchaseID}',
          );
          _unfinishedPurchases[purchase.productID] = purchase;
          _emitPurchaseUpdate(
            IapPurchaseResult(
              status: IapPurchaseStatus.error,
              productId: purchase.productID,
              transactionId: purchase.purchaseID,
              errorMessage:
                  'Purchase succeeded in store, but activating plan failed. '
                  'Please try again.',
              raw: purchase,
            ),
          );
          break;
        }

        _unfinishedPurchases.remove(purchase.productID);
        _handledSuccessKeys.add(successKey);

        final result = IapPurchaseResult(
          status: purchase.status == PurchaseStatus.restored
              ? IapPurchaseStatus.restored
              : IapPurchaseStatus.purchased,
          productId: purchase.productID,
          transactionId: purchase.purchaseID,
          raw: purchase,
        );

        await _persistEntitlement(purchase);
        onPurchaseVerified?.call(result);
        _log('onPurchaseVerified callback '
            '${onPurchaseVerified == null ? "NOT set" : "invoked"}');
        _emitPurchaseUpdate(result);

        if (purchase.pendingCompletePurchase) {
          _log('completePurchase() for ${purchase.productID}');
          await _iap.completePurchase(purchase);
          _logSuccess('completePurchase() done');
        }
        break;

      case PurchaseStatus.error:
        _purchaseInFlight = false;
        _clearSubscribeSessionFor(purchase.productID);
        _logError(
          'status=error | code=${purchase.error?.code} | '
          'source=${purchase.error?.source} | '
          'message=${purchase.error?.message} | '
          'details=${purchase.error?.details}',
        );
        _emitPurchaseUpdate(
          IapPurchaseResult(
            status: IapPurchaseStatus.error,
            productId: purchase.productID,
            transactionId: purchase.purchaseID,
            errorMessage: purchase.error?.message ?? 'Purchase failed.',
            raw: purchase,
          ),
        );
        if (purchase.pendingCompletePurchase) {
          _log('completePurchase() after error for ${purchase.productID}');
          await _iap.completePurchase(purchase);
        }
        break;

      case PurchaseStatus.canceled:
        _purchaseInFlight = false;
        _clearSubscribeSessionFor(purchase.productID);
        _logInfo('status=canceled | productID=${purchase.productID}');
        _emitPurchaseUpdate(
          IapPurchaseResult(
            status: IapPurchaseStatus.canceled,
            productId: purchase.productID,
            transactionId: purchase.purchaseID,
            raw: purchase,
          ),
        );
        break;
    }
  }

  Future<void> _persistEntitlement(PurchaseDetails purchase) async {
    if (!IapProductIds.isKnown(purchase.productID)) {
      _logError('_persistEntitlement skipped — unknown product '
          '${purchase.productID}');
      return;
    }

    // Android uses one product id for both base plans, so fall back to the
    // plan the user selected for this purchase.
    final autoRenew = Platform.isAndroid
        ? _pendingAutoRenew
        : purchase.productID == IapProductIds.autoRenewMonthly;

    await _persistEntitlementFields(
      productId: purchase.productID,
      autoRenew: autoRenew,
      transactionId: purchase.purchaseID,
    );
  }

  Future<void> _persistEntitlementFields({
    required String productId,
    required bool autoRenew,
    String? transactionId,
  }) async {
    final purchasedAt = DateTime.now();
    final expiresAt = autoRenew
        ? null
        : purchasedAt.add(const Duration(days: 30));

    final entitlement = IapEntitlement(
      productId: productId,
      autoRenew: autoRenew,
      transactionId: transactionId,
      purchasedAt: purchasedAt,
      expiresAt: expiresAt,
    );

    _log('_persistEntitlement → ${jsonEncode(entitlement.toJson())}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _entitlementPrefsKey,
      jsonEncode(entitlement.toJson()),
    );
    _logSuccess('_persistEntitlement saved');
  }

  String _successKey(PurchaseDetails purchase) {
    final transactionId = (purchase.purchaseID ?? '').trim();
    if (transactionId.isNotEmpty) {
      return '${purchase.productID}|$transactionId';
    }
    final receipt = purchase.verificationData.serverVerificationData.isNotEmpty
        ? purchase.verificationData.serverVerificationData
        : purchase.verificationData.localVerificationData;
    return '${purchase.productID}|$receipt';
  }

  bool _isExpiredSubscriptionBackendMessage(String? message, [dynamic data]) {
    final buffer = StringBuffer(message ?? '');
    if (data is Map) {
      final nested = data['message'];
      if (nested != null) buffer.write(' $nested');
    } else if (data != null) {
      buffer.write(' $data');
    }
    final text = buffer.toString().toLowerCase();
    return text.contains('subscription has expired') ||
        text.contains('apple subscription has expired');
  }

  /// POST purchase details to eazylife backend (platform specific endpoint).
  Future<_BackendReportOutcome> _reportPurchaseToBackend(
    PurchaseDetails purchase,
  ) {
    return Platform.isAndroid
        ? _reportAndroidPurchase(purchase)
        : _reportApplePurchase(purchase);
  }

  Future<_BackendReportOutcome> _reportAppleReceipt({
    required String productId,
    required String transactionId,
    required String receiptData,
  }) async {
    try {
      final result = await _purchaseRepository.reportPurchase(
        planId: SubscriptionPurchaseRepository.defaultPlanId,
        productId: productId,
        transactionId: transactionId,
        receiptData: receiptData,
      );
      if (result.isSuccess) {
        _logSuccess('_reportAppleReceipt OK | tx=$transactionId');
        return _BackendReportOutcome.success;
      }
      if (_isExpiredSubscriptionBackendMessage(result.message, result.data)) {
        _logInfo(
          '_reportAppleReceipt EXPIRED_STALE | tx=$transactionId | '
          'message=${result.message}',
        );
        return _BackendReportOutcome.expired;
      }
      _logError(
        '_reportAppleReceipt FAILED | tx=$transactionId | '
        'message=${result.message}',
      );
      return _BackendReportOutcome.failed;
    } catch (e, st) {
      _logError('_reportAppleReceipt exception: $e', st);
      return _BackendReportOutcome.failed;
    }
  }

  Future<_BackendReportOutcome> _reportApplePurchase(
    PurchaseDetails purchase,
  ) async {
    final transactionId = (purchase.purchaseID ?? '').trim();
    final serverReceipt = purchase.verificationData.serverVerificationData;
    final localReceipt = purchase.verificationData.localVerificationData;
    final receiptData =
        serverReceipt.isNotEmpty ? serverReceipt : localReceipt;

    _logInfo(
      '_reportApplePurchase | '
      'transactionId=$transactionId | '
      'serverReceiptLen=${serverReceipt.length} | '
      'localReceiptLen=${localReceipt.length} | '
      'using=${serverReceipt.isNotEmpty ? "server" : "local"}',
    );

    if (transactionId.isEmpty) {
      _logError('_reportApplePurchase aborted — empty transactionId');
      return _BackendReportOutcome.failed;
    }
    if (receiptData.isEmpty) {
      _logError('_reportApplePurchase aborted — empty receiptData');
      return _BackendReportOutcome.failed;
    }

    try {
      final result = await _purchaseRepository.reportPurchase(
        planId: SubscriptionPurchaseRepository.defaultPlanId,
        productId: purchase.productID,
        transactionId: transactionId,
        receiptData: receiptData,
      );
      if (result.isSuccess) {
        _logSuccess('_reportApplePurchase OK | tx=$transactionId');
        return _BackendReportOutcome.success;
      }
      if (_isExpiredSubscriptionBackendMessage(result.message, result.data)) {
        _logInfo(
          '_reportApplePurchase EXPIRED_STALE | tx=$transactionId | '
          'message=${result.message}',
        );
        return _BackendReportOutcome.expired;
      }
      _logError(
        '_reportApplePurchase FAILED | tx=$transactionId | '
        'message=${result.message}',
      );
      return _BackendReportOutcome.failed;
    } catch (e, st) {
      _logError('_reportApplePurchase exception: $e', st);
      return _BackendReportOutcome.failed;
    }
  }

  Future<_BackendReportOutcome> _reportAndroidPurchase(
    PurchaseDetails purchase,
  ) async {
    // On Android serverVerificationData is the Play purchase token and
    // purchaseID is the Play order id (can be empty for test purchases).
    final purchaseToken =
        purchase.verificationData.serverVerificationData.trim();
    final orderId = (purchase.purchaseID ?? '').trim();

    _logInfo(
      '_reportAndroidPurchase | '
      'productId=${purchase.productID} | '
      'orderId=${orderId.isEmpty ? "(empty)" : orderId} | '
      'purchaseTokenLen=${purchaseToken.length} | '
      'autoRenew=$_pendingAutoRenew',
    );

    if (purchaseToken.isEmpty) {
      _logError('_reportAndroidPurchase aborted — empty purchaseToken');
      return _BackendReportOutcome.failed;
    }

    try {
      final result = await _purchaseRepository.reportAndroidPurchase(
        planId: SubscriptionPurchaseRepository.defaultPlanId,
        productId: purchase.productID,
        purchaseToken: purchaseToken,
        orderId: orderId,
      );
      if (result.isSuccess) {
        _logSuccess('_reportAndroidPurchase OK');
        return _BackendReportOutcome.success;
      }
      _logError('_reportAndroidPurchase failed | message=${result.message}');
      return _BackendReportOutcome.failed;
    } catch (e, st) {
      _logError('_reportAndroidPurchase exception: $e', st);
      return _BackendReportOutcome.failed;
    }
  }

  void _emitError(String message) {
    _logError('_emitError → $message');
    if (_subscribeSessionProductId != null) {
      _clearSubscribeSession();
    }
    if (_suppressPurchaseUi > 0 && !_restoreSession) {
      _logInfo(
        'UI error suppressed | message=$message | ${_sessionContext()}',
      );
      return;
    }
    _logInfo('UI error emit | message=$message | ${_sessionContext()}');
    _purchaseController.add(
      IapPurchaseResult(
        status: IapPurchaseStatus.error,
        errorMessage: message,
      ),
    );
  }
}
