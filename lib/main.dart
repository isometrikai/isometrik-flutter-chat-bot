import 'package:chat_bot/view/launch_screen.dart';
import 'package:flutter/material.dart';
import 'model/chat_response.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'view/chat_screen.dart';
import 'model/chat_message.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformService.initializeFromPlatform();
  runApp(const MyApp());
}

// @pragma('vm:entry-point')
// void chatMain() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await PlatformService.initializeFromPlatform();
//   runApp(const MyApp());
// }
class MyApp extends StatelessWidget {
  static const platform = MethodChannel('chat_bot/orders');
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up callbacks when app initializes
    _setupCallbacks();
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  LaunchScreen(),//ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
  void _setupCallbacks() {
    OrderService().setProductCallback((Product product) {
      _sendEventToiOS(product.toJson(), 'product');
    });
    
    OrderService().setStoreCallback((Store store) {
      _sendEventToiOS(store.toJson(), 'store');
    });

    // Add dismiss callback
    OrderService().setDismissCallback(() {
      _sendEventToiOS({}, 'dismissChat');
    });
  }
  Future<void> _sendEventToiOS(Map<String, dynamic> data, String type) async {
    try {
      await platform.invokeMethod('handleOrder', {
        'type': type,
        'data': data,
      });
    } catch (e) {
      print('Failed to send $type event to iOS: $e');
    }
  }
}


class PlatformService {
  static const MethodChannel _channel = MethodChannel('chatbot_config');

  static Future<void> initializeFromPlatform() async {
    try {
      print('🔄 Attempting to get config from iOS...');
      final Map<dynamic, dynamic> config = await _channel.invokeMethod('getConfig');

      print('✅ Config received from iOS: $config');

      // Handle string to double conversion safely
      double? longitude;
      double? latitude;

      if (config['longitude'] != null) {
        longitude = double.tryParse(config['longitude'].toString());
      }

      if (config['latitude'] != null) {
        latitude = double.tryParse(config['latitude'].toString());
      }

      ApiService.configure(
        chatBotId: config['chatBotId'] ?? '2',
        appSecret: config['appSecret'] ?? '',
        licenseKey: config['licenseKey'] ?? '',
        location: config['location'],
        longitude: longitude,
        latitude: latitude,
      );

      print('✅ ApiService configured successfully');
    } catch (e) {
      print('❌ Error getting config from platform: $e');
      // Fallback to default values if iOS config fails
      ApiService.configure(
        chatBotId: '2',
        appSecret: '',
        licenseKey: '',
      );
    }
  }
}
