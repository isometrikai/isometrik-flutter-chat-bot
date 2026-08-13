import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device's default browser / external app.
Future<bool> openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    print('Could not parse url: $url');
    return false;
  }
  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      print('Could not launch $url');
    }
    return launched;
  } catch (e) {
    print('Could not launch $url: $e');
    return false;
  }
}

/// Opens the platform subscription management page (App Store / Play Store).
Future<bool> openStoreSubscriptions() {
  final url = Platform.isIOS
      ? 'https://apps.apple.com/account/subscriptions'
      : 'https://play.google.com/store/account/subscriptions';
  return openUrl(url);
}
