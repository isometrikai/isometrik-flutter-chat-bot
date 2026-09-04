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
  String packageName = '';
  try {
    packageName = (await PackageInfo.fromPlatform()).packageName;
  } catch (e) {
    print('Could not read package name: $e');
  }
  final productId = IapProductIds.androidSubscription;

  // Play Store does not handle this URL with externalNonBrowserApplication.
  final specificUri = Uri.https(
    'play.google.com',
    '/store/account/subscriptions',
    {
      if (productId.isNotEmpty) 'sku': productId,
      if (packageName.isNotEmpty) 'package': packageName,
    },
  );
  final allSubscriptionsUri = Uri.https(
    'play.google.com',
    '/store/account/subscriptions',
  );

  if (await _launchUri(specificUri, LaunchMode.externalApplication)) {
    return true;
  }
  return _launchUri(allSubscriptionsUri, LaunchMode.externalApplication);
}
