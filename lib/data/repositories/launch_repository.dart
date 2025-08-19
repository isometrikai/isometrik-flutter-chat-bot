import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/services/api_service.dart';

class LaunchRepository {
  const LaunchRepository();

  Future<void> initialize() => ApiService.initialize();

  Future<MyGPTsResponse?> getChatbotData() => ApiService.getChatbotData();

  Future<GreetingResponse?> getInitialOptionData() => ApiService.getInitialOptionData();
}


