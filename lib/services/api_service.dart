import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/utility.dart';

class ApiService {
  static String _baseApiUrl = 'https://apisuperapp-staging.eazy-online.com';
  static bool _isProduction = false;

  static String get baseApiUrl => _baseApiUrl;
  static bool get isProduction => _isProduction;

  // static Future<void> initialize() async {
  //   await AuthService.instance.initialize();
  //   await ChatApiServices.instance.initialize();
  // }

  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    required String name,
    required String timestamp,
    required String userToken,
    String? location,
    double? longitude,
    double? latitude,
    bool? needToShowTutorial,
    bool? needToShowCompleteSetup,
    required String clientGuid,
    required String indexName,
    required String visitId,
    required String visitorId,
    required String searchApiUrl,
    required String baseApiUrl,
    required String currencycode,
    required String currencysymbol,
    required String zoneId,
    required String timezone,
    required String platform,
  }) {
    _isProduction = isProduction;
    _baseApiUrl = baseApiUrl.isNotEmpty 
        ? removeTrailingSlash(baseApiUrl) 
        : 'https://apisuperapp-staging.eazy-online.com';
    // Configure AuthService (legacy support)
    AuthService.instance.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
      isProduction: isProduction,
      userId: userId,
      name: name,
      timestamp: timestamp,
      userToken: userToken,
      location: location,
      longitude: longitude,
      latitude: latitude,
        needToShowTutorial: needToShowTutorial,
        needToShowCompleteSetup: needToShowCompleteSetup,
      clientGuid: clientGuid,
      indexName: indexName,
      visitId: visitId,
      visitorId: visitorId,
      searchApiUrl: removeTrailingSlash(searchApiUrl),
      currencycode: currencycode,
      currencysymbol: currencysymbol,
    );

    // Configure ComprehensiveApiService (new system)
    ChatApiServices.instance.configure(
      chatBotId: chatBotId,
      userId: userId,
      name: name,
      timestamp: timestamp,
      userToken: userToken,
      location: location,
      longitude: longitude,
      latitude: latitude,
      clientGuid: clientGuid,
      indexName: indexName,
      visitId: visitId,
      visitorId: visitorId,
      searchApiUrl: removeTrailingSlash(searchApiUrl),
      zoneId: zoneId,
      timezone: timezone,
    );

    // Configure HawkSearchService
    HawkSearchService.instance.configure(
      clientGuid: clientGuid,
      indexName: indexName,
      visitId: visitId,
      visitorId: visitorId,
      searchApiUrl: removeTrailingSlash(searchApiUrl),
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
    );

    ChatHistoryRepository.instance.configure(
      userId: userId,
    );

    Utility.setCurrencySymbol(currencysymbol);
    Utility.setCurrencyCode(currencycode);
    Utility.setPlatform(platform);
  }

  static String removeTrailingSlash(String url) {
  // Check if the URL ends with a slash
  if (url.endsWith('/')) {
    // Remove the last character (the slash)
    return url.substring(0, url.length - 1);
  }
  // Return the URL unchanged if no trailing slash
  return url;
}

}


