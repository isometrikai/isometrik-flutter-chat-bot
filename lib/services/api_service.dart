import 'package:chat_bot/data/repositories/chat_history_repository.dart';
import 'package:chat_bot/data/services/auth_service.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';
import 'package:chat_bot/data/services/hawksearch_service.dart';

class ApiService {
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
  }) {
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
      searchApiUrl: searchApiUrl,
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
      searchApiUrl: searchApiUrl,
    );

    // Configure HawkSearchService
    HawkSearchService.instance.configure(
      clientGuid: clientGuid,
      indexName: indexName,
      visitId: visitId,
      visitorId: visitorId,
      searchApiUrl: searchApiUrl,
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
    );

    ChatHistoryRepository.instance.configure(
      userId: userId,
    );
  }

}


