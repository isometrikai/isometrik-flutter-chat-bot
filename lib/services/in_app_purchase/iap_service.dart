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
import 'package:shared_preferences/shared_preferences.dart';

typedef IapPurchaseCallback = void Function(IapPurchaseResult result);

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
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _purchaseInFlight = false;

  /// Plan the user selected for the in-flight purchase. On Android the product
  /// id is the same for both base plans, so this is how we tell them apart.
  bool _pendingAutoRenew = false;

  /// Optional host/backend verification hook after a successful store purchase.
  IapPurchaseCallback? onPurchaseVerified;

  Stream<IapPurchaseResult> get purchaseUpdates => _purchaseController.stream;

  bool get isAvailable => _storeAvailable;

  bool get isInitialized => _initialized;

  bool get isPurchaseInFlight => _purchaseInFlight;

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

  /// Initialize store connection and purchase listener. Safe to call multiple times.
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

    await _ensureInitialized();

    if (!_storeAvailable) {
      _logError('purchaseSelectedPlan() aborted — store not available');
      _emitError('In-app purchases are not available on this device.');
      return false;
    }
    if (_purchaseInFlight) {
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
      _logError(
        'purchaseSelectedPlan() aborted — plan not available | '
        'productId=$productId | cached=${_products.keys.toList()}',
      );
      _emitError('Plan is not available. Please try again later.');
      return false;
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
      _logError('buyNonConsumable() PlatformException: $e', st);
      _emitError(e.message ?? e.toString());
      return false;
    } catch (e, st) {
      _purchaseInFlight = false;
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

  Future<void> restorePurchases() async {
    _logInfo('restorePurchases() start');
    await _ensureInitialized();
    if (!_storeAvailable) {
      _logError('restorePurchases() aborted — store not available');
      _emitError('In-app purchases are not available on this device.');
      return;
    }
    try {
      await _iap.restorePurchases();
      _logSuccess('restorePurchases() request sent — waiting for stream');
    } catch (e, st) {
      _logError('restorePurchases() exception: $e', st);
      _emitError(e.toString());
    }
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
    _logInfo('_onPurchaseUpdated | count=${purchases.length}');
    for (var i = 0; i < purchases.length; i++) {
      _log('purchase[$i] → ${_purchaseSummary(purchases[i])}');
      await _handlePurchase(purchases[i]);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    _logInfo('_handlePurchase status=${purchase.status} '
        'productID=${purchase.productID}');

    switch (purchase.status) {
      case PurchaseStatus.pending:
        _log('status=pending — showing pending UI');
        _purchaseController.add(
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
            '(Apple often emits purchased + restored for one buy)',
          );
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          break;
        }
        _handledSuccessKeys.add(successKey);

        _logSuccess(
          'status=${purchase.status} — reporting to backend | '
          '${_purchaseSummary(purchase)}',
        );

        final backendOk = await _reportPurchaseToBackend(purchase);
        if (!backendOk) {
          _logError(
            'backend purchase API failed — not completing store transaction '
            '(will retry on next launch)',
          );
          _purchaseController.add(
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
          // Do not completePurchase — Apple will redeliver so we can retry API.
          break;
        }

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
        _purchaseController.add(result);

        if (purchase.pendingCompletePurchase) {
          _log('completePurchase() for ${purchase.productID}');
          await _iap.completePurchase(purchase);
          _logSuccess('completePurchase() done');
        }
        break;

      case PurchaseStatus.error:
        _purchaseInFlight = false;
        _logError(
          'status=error | code=${purchase.error?.code} | '
          'source=${purchase.error?.source} | '
          'message=${purchase.error?.message} | '
          'details=${purchase.error?.details}',
        );
        _purchaseController.add(
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
        _logInfo('status=canceled | productID=${purchase.productID}');
        _purchaseController.add(
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
    final purchasedAt = DateTime.now();
    final expiresAt = autoRenew
        ? null
        : purchasedAt.add(const Duration(days: 30));

    final entitlement = IapEntitlement(
      productId: purchase.productID,
      autoRenew: autoRenew,
      transactionId: purchase.purchaseID,
      purchasedAt: purchasedAt,
      expiresAt: expiresAt,
    );

    _log(
      '_persistEntitlement → ${jsonEncode(entitlement.toJson())}',
    );

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

  /// POST purchase details to eazylife backend (platform specific endpoint).
  Future<bool> _reportPurchaseToBackend(PurchaseDetails purchase) {
    return Platform.isAndroid
        ? _reportAndroidPurchase(purchase)
        : _reportApplePurchase(purchase);
  }

  Future<bool> _reportApplePurchase(PurchaseDetails purchase) async {
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
      return false;
    }
    if (receiptData.isEmpty) {
      _logError('_reportApplePurchase aborted — empty receiptData');
      return false;
    }

    try {
      final result = await _purchaseRepository.reportPurchase(
        planId: SubscriptionPurchaseRepository.defaultPlanId,
        productId: purchase.productID,
        transactionId: transactionId,
        receiptData: receiptData,
      );
      if (result.isSuccess) {
        _logSuccess('_reportApplePurchase OK');
        return true;
      }
      _logError('_reportApplePurchase failed | message=${result.message}');
      return false;
    } catch (e, st) {
      _logError('_reportApplePurchase exception: $e', st);
      return false;
    }
  }

  Future<bool> _reportAndroidPurchase(PurchaseDetails purchase) async {
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
      return false;
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
        return true;
      }
      _logError('_reportAndroidPurchase failed | message=${result.message}');
      return false;
    } catch (e, st) {
      _logError('_reportAndroidPurchase exception: $e', st);
      return false;
    }
  }

  void _emitError(String message) {
    _logError('_emitError → $message');
    _purchaseController.add(
      IapPurchaseResult(
        status: IapPurchaseStatus.error,
        errorMessage: message,
      ),
    );
  }
}
