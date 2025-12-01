import 'package:chat_bot/data/data.dart';

class ApiService {
  static String _baseApiUrl = 'https://apisuperapp-staging.eazy-online.com';

  static String get baseApiUrl => _baseApiUrl;

  static Future<void> initialize() async {
    await AuthService.instance.initialize();
    await ChatApiServices.instance.initialize();
  }

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
    required String clientGuid,
    required String indexName,
    required String visitId,
    required String visitorId,
    required String searchApiUrl,
    required String baseApiUrl,
  }) {
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
      clientGuid: clientGuid,
      indexName: indexName,
      visitId: visitId,
      visitorId: visitorId,
      searchApiUrl: removeTrailingSlash(searchApiUrl),
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


