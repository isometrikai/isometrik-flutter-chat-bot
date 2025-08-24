import 'package:chat_bot/view/launch_screen.dart';
import 'package:chat_bot/view/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'view/chat_screen.dart';
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
    OrderService().setProductCallback((Map<String, dynamic> product) {
      _sendEventToiOS(product, 'product');
    });
    
    OrderService().setStoreCallback((Map<String, dynamic> store) {
      _sendEventToiOS(store, 'store');
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
      final Map<dynamic, dynamic> config = await _channel
          .invokeMethod('getConfig')
          .timeout(const Duration(seconds: 5));

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
        isProduction: config['isProduction'] ?? false,
        userId: config['userId'] ?? '',
        name: config['name'] ?? '',
        timestamp: config['timestamp'] ?? '',
        userToken: config['userToken'] ?? '',
        location: config['location'],
        longitude: longitude,
        latitude: latitude,
      );

      print('✅ ApiService configured successfully');
    } catch (e) {
      print('❌ Error getting config from platform: $e');
      // Fallback to default values if iOS config fails
      ApiService.configure(
        chatBotId: '1476',
        appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
        licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
        userId: "user_12345678910",
        name: 'Chintu',
        timestamp: '2025-07-28T12:30:00Z',
        userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.MF0rQcJe9Z4fllfF9MOmWSvaHF8wP3H-sLWJZEGzkZ_-SeKmijur8Roiqff7LGi8Q3uOtUzqGe16qZktQIGI3tazEbVIT8OCD6QVEZUeVauE9g48UBxgdf7PLNhV5hq8hBYJAjeM-vrsDgYQrGStXb8u_t7WK8xBYuRrBubgkuE._KO4NJPc0vrHuGv6.4cbF9gWArQvjK6AYd3o7VTvwoP9HDbPsK6EhWq9M-iwLi1Yg68M6HXVvM-YncmVDF121x_rMnf3E5NmZS44xXoDiakqWaeEWBKBq83S5-lpMS70zpzywqGEaalauJSR44TiHhG2vDh1CKqbAFQNQ880v52qgNdwlWnZpO8J1vWb0jsKuMFI5tXGtfgB8cA_W3Gi8ujn1kpmaqAIe5Bdj7dBWVoaV8Fa5iEYZDSuiKmUMLiiN3Hbv_kLG7y6FzotrplQCN2ZZUCJBGIFvf7wcv6nEnOj6MpZxu3ebYREj7zICtHJzfEEVNkJQOJYLQDBhv6YqXClG3lqsnxYO06E1cgrNslDMistA9bUUK-u_4Fr0_qODFA4BQ2On5KkS8wURODQTgibSLw4HyPzGYVlk0Fc2Y5vAheLTnq0h2YwkWrMt2oPSL_wZFM_4o33F-BbiY9JFkJTZ7d-45xeR0D6Fre7JTH_7BnTy-nZ0SHsmAMX7d3tAc7feq4OWo6_XRaPFeHOb8WIxjhoAy60fc64t404OvesmmRF-Yc9XLH4LQSErbnxnhJWQoV-jT_HCP-LH0wDeDmxCfSx2saPB5_8qq_CUwbwOHNPGLaeNcRhX1z-hmhh2-L7Jg35bD5gRmw5PJOW9Wq7R-N1O7rTDCx7B2iSmaf2bfME4BGEAy-7VjYMBfymysy8SiX_iZVuD3snFYG81QPbLGNWnvJDI5XZeDWiz0f__qMIK9UNaMoCAVAICCaamv3qdTkUBalji7CrRQpZFcb1rLI-UsX0oMkzapspr_tDrMR8M_rANU2mYO1FQga6D7r6_efyo5ClIF0W9aBhRn9KO4wtHXzuWVttgrfDgcB4S1un8K8l0TT64-JV2KzoxPJFWydmH4IjZVguZpiWb6UaHMrj48sg4wm9h43IXk0TVbHMhSnlgEHzhNJny4BqYJGXuwC_XBoqUg74k_dZq2g2zXhWTQRfqVcGlvgECg-02A7wbo0DC6hvuQMn_9WRgdSNWsagi-5Y9Jhr-rsYjnDRrUplOi3kL1mMvtwDtElAzMX4xQd4jAPKFG4fu_hc2lFH90IkO2E51GzTmo3xDWNHw8hffFctOBt-ZW7EaDI3EO7aDpA3w10ivF-Gn2hW9IUPMZKzB0FeXUbu33DGjF6b_5JEOO4HbB8XGm7gcStGkBnSP9Nqgu-gJaaIU83vf7iP2EVBpQ8xBj0ImVHUvV9RizUgTfJKmd9varp1GD1lNLf0kHTFuW9j_ACpQX-zZaYRLMScfxGbW-B3HeRsaJtDiNBWvA97TzRuo-ALDhI812Xb5TuzrOO6b6K3cpPBqOKcMdVDnB6mmvU7PBPwiYs1XsWZhGyy2wqtgdYLMnysuRlgKKlV6FwAPTi5FLj1a7tYoSWgrg0eSwu0c_FM_pONtpOa_R9msCkzXf1jNLKrO_6eaH9Nn8g-LZddcEnrrlcKjFBCbuELEU4-zplkZ8yVOKyWWeM52zlg1VDeg-UzZXrSupR2SI4a0l1LirnwO6g_F2Q3fpVX91vQ0sPAvihvZdYZB07AMy0sitNu_Cw2ys2UcqWYCEVm4pJVrWWKXHrC5Xep9Xx5Zgicqb1DagVmwPr-NpCLThtrkSktR9N1LIafv53l_BNQXaRjFVmBHQ_KBXe4Gdl86mOcK3vE8OyNWirmC80Z9K8JL1WdxZ8LkkaNKd50jnu9g4f86FXDMeaOVCklLdD_9u8l2o3BEgr3x2G5bg3b08-k4zl1YavyhEJhR-RTIKFjuCvfXX9Rhss1EpM1Dcyh9LzMDsrpR1H-VQsb1E96bGwdDDMO-Kg.-PTlUaqPZnnjWftXWoOHoQ',
        location: 'Dubai Marina',
        isProduction: false,
        latitude: 40.7128,
        longitude: 74.0060,
      );
    }
  }
}
