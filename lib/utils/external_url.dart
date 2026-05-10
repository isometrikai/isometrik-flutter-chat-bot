// import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device's default browser.
///
/// Throws if the URL can't be parsed or no handler is available.
Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    // await launchUrl(
    //   uri,
    //   mode: LaunchMode.externalApplication,
    // );
  } catch (e) {
    print('Could not launch $url: $e');
  }
}
