import 'package:chat_bot/view/launch_screen.dart';
import 'package:chat_bot/view/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'view/chat_screen.dart';
import 'package:flutter/services.dart';
import 'utils/asset_path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure asset loading mode
   AssetPath.isPackageMode = true; // Set to true for package mode, false for normal project
  
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
      if (AssetPath.isPackageMode == false) {
         print('❌ Error getting config from platform: $e');
      // Fallback to default values if iOS config fails
          ApiService.configure(
            chatBotId: '1476',
            appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
            licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
            userId: "68af0df36ed4590014c3e518",
            name: 'Chintu',
            timestamp: '2025-07-28T12:30:00Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.LVRINF7EyicK0Y_-6Y4sRjwzvrif_q_JKiEkt_39UJ_6zmaWO6QOmc1Y4D9gQgJ1f6deX2mBr0YSfgaVCvIvF-G6ua8W-7t8SyvhdqAtBASF2i4MEl9lIj_ihythQl0nPAeGyk678rOby8Txsi87qoijgQN1u8-sz66Xki2anM8.OlgSl05L_e0Pmp3j.BEFhTZq_5QH8mHc-7I8hMRZPNKS3dgwt2CQ3kvvKJ3685iiKhrB46g44-Q0v3skHKVWUzLrZMOo9Myyyn0zFzEjxcIN8lETjP8TiYFimKCUzv4OBU8HLHZfCY4j0jydo8ynpCAzGrkAK08GfVBSZhRpuZANDCt5P2z-n_gD-omzUk_mrJ7zrpyaxJ9zRetW-z9gPXqzvr5xysz1CRyUx0xhPRbABtMgieBqyL-5xpa-9dtBpSHX3dQ8dMeSnt-3UX1Q0VStN0rru-Q6nzbb-nE8KqjLvzRxBFLZ66qB2gbAk66r0CsR8uo4AVOaF25uEZv7FbDVnmvRQ6bER4OPzvlxR1Q8Iz7cEW4nsamnz2QPyqGQ2RMMRUgdO6-g7P5A0cQk9LoINMeW_Xv2kqjRKqOcbgPAcu6ew-ng09hpobOrzbKbALG8zXGmMhfF_jze4EukOYjo4XiV804qxDQ40y4Ysgy44iUC6pITHO9EZmnxJHI-sb9cbC-OjDVaS28wg2bwcHc5IScEhBRYW9ofkrnGzpLYVDrD7-W8FTCnmztde5usddQsjuOBN1PLpG9PogDvA-eXFhxAiO0YsW6yCNmuBuk1z1zshJWEnYGA5WJgTEN461wh9yyM4juoMW3nUgWgHk0BV0qHw1BRLzlXE-0z9geOxBmTK0nrnpBHoHLqCYxSO7115kf_emw_auAKRC8gc0amWa1JNpOT46Aw0zAlF26NyPp-Au22GLip1GykcpwxG82mJa4eWV5fgwpfnfCc6yELJpMn_-saLCzdjm0sXg8BGsVOu0M4WX74vAxdtJBJWHtAsT_BR1boi8nJff0LfTNyoNyl2OtqjE5OBCTCoiXIz1IjEXjWzlk6JfhS0mCNjgOknbCTE3VKxE1UgaipNZ9y1WsRZuo9ExzIWsOPUmVbvNTlSSrPwIah3xvUtxrvz71KK5C8uUS5mTrIGJ0fOFQMjXo6vE96D4ElZvfJaBsug_fdBM3b8dgTeKerthp3-Ii0MFf7JU-_IWK3jW_sVZ15dMgS9hdyubBVKG31eKkgXK7Af0zfAJhBtNgN49MMahu4coV9GKjXy0bHWculx0pycRCo4a_pTJ7N_cMzPHgqARtgu7bgGmTBndAwYHvBUmX3P36PV_un02_bjZieD5svcrQVzT2BRjUdYU-eeDnuL8lTQFao357lpZ8DFckfWJKOOKwwULglZ0sC5rMQswl_IzP7vgqtZtOM2slbwH0vAJJkZ60ZmGR_UIbcppULJeCXtpDBA1UpKsK5ZWvb6PaZ0kh1WsYKL96SUAJfHkl1trGs6Lj7xLiwu9C5XFzsScFVMRkGsdJepqLu8PKOJxShfgfM_vDjCoylnEmjQZjqXA7FAV3Y4We1wCu2f-A2BHjKjFrgTPJasGD8rDFjTKOW2O_MgLTgK612vce5-wxKdPQYfiPCtLghV9gmEZO2EyFo7wVhfz0DLkd4nYNSZZAzvSy2PAf_o8Yo_cdq2AafBDj9mGUWBtYtJQRw3hbS9WoWBDDjM1AV1p-Bmo2I_N5GggJ83Qi-RkRHF4xNeq-6Q13Y4ZX_AA-Wtsh4vVa0i29e1cNxWRBJF127u5AWW0ROyDaf1IyhkPD9kS1b1UUFuma-a_PIaDVAbDHS5Iz0kvPMphNt6KrwU70L_za4nkuWwqLwO6rMXtMBk_cW3_gWZEk_uIqThUniiKgsfKVzEk2dGY60YLEK8XOaR-2CTixZNI2AqOfZlcAAMVOLWLBYrXpcJ_ukrYt7ynzrgAE3Z95oVAg.sdgjn_2uhavhoNqLGFUUeg',
            location: 'Dubai Marina',
            isProduction: false,
            latitude: 40.7128,
            longitude: 74.0060,
          );
      }
    }
  }
}
