import 'dart:io';

import 'package:chat_bot/services/in_app_purchase/iap_product_ids.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device's default browser / external app.
Future<bool> openUrl(String url, {LaunchMode? mode}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    print('Could not parse url: $url');
    return false;
  }
  return _launchUri(uri, mode ?? LaunchMode.externalApplication);
}

Future<bool> _launchUri(Uri uri, LaunchMode mode) async {
  try {
    final launched = await launchUrl(uri, mode: mode);
    if (!launched) {
      print('Could not launch $uri (mode=$mode)');
    }
    return launched;
  } catch (e) {
    print('Could not launch $uri: $e');
    return false;
  }
}

/// Opens the platform subscription management page (App Store / Play Store).
Future<bool> openStoreSubscriptions() async {
  if (Platform.isIOS) {
    return openUrl('https://apps.apple.com/account/subscriptions');
  }
  return _openAndroidStoreSubscriptions();
}

Future<bool> _openAndroidStoreSubscriptions() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final packageName = packageInfo.packageName;
  final productId = IapProductIds.androidSubscription;

  final subscriptionUri = Uri.https(
    'play.google.com',
    '/store/account/subscriptions',
    {'sku': productId, 'package': packageName},
  );
  final allSubscriptionsUri = Uri.https(
    'play.google.com',
    '/store/account/subscriptions',
  );
  final playStoreIntentUri = Uri.parse(
    'intent://play.google.com/store/account/subscriptions'
    '?sku=$productId&package=$packageName'
    '#Intent;scheme=https;package=com.android.vending;end',
  );

  // Prefer Play Store app over browser (Android 11+ needs manifest queries).
  for (final uri in [
    subscriptionUri,
    playStoreIntentUri,
    allSubscriptionsUri,
  ]) {
    if (await _launchUri(uri, LaunchMode.externalNonBrowserApplication)) {
      return true;
    }
  }

  return _launchUri(subscriptionUri, LaunchMode.externalApplication);
}
