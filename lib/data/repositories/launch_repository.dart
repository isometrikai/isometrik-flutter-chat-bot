import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/data/services/auth_service.dart';

class LaunchRepository {
  const LaunchRepository();

  Future<void> initialize() => AuthService.instance.initialize();

  Future<MyGPTsResponse?> getChatbotData() => AuthService.instance.getChatbotData();

  Future<GreetingResponse?> getInitialOptionData() => AuthService.instance.getInitialOptionData();
}


