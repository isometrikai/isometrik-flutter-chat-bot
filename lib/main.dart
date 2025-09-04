import 'package:chat_bot/view/launch_screen.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'package:flutter/services.dart';
import 'utils/asset_path.dart';
import 'utils/utility.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure asset loading mode
  //  AssetPath.isPackageMode = true; // Set to true for package mode, false for normal project
  
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
      navigatorKey: kNavigatorKey,
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
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.da0EBWK_S1gA6urU_A42YWBHMyTzPVkn-W7wiaHS1jJnQty6kddkoq0FY9Jmio1OeBKXG504515zGv4OXCCZ0gzr_LoWB9NerGaUlbRwSpsKkaZNOC5S2ojOrOw5wjJCRN42hs_OFtwTV0eQEkJTbNlVUmoMDhFtBUtNdkLYimA.42TARBLI3b8rPcZA.t7yDZPVjIt45ZZNAo9wMnkOPW5EdCZ9dmdWGcP_FL2AIXC2JgQ9gX-akAAjQFBHiDOVBE9SNF7xC9uVAxW0v2LwYe1DHg1L4AaTSqu5zM2Di6_FtWBUe5oyhWi1ievulyxXPZMS6eLp2t7sviNQn_dBtDUK6VRRmbWeOopGmul5JySKp55J2NQdf2k5mFpDUd5EvXVdD4TNY-C-XKQLYmhc5cnGSl8lWbmYnkB4ZSqcyJAuDuwdnXHohEAo-wFM3MtsM6_WkzVMFcgurhS2jx68jobzpjgwV4_z9xkP_CMCdnscFrK8SYxx3oU1LLmZlOuRkCDT9eoDxwBrWRPmaikChRqbeJ2C9wv-0_YyOac8JmdUfQuLhcUqDTYWepb-UFQaCQjFSuOwgr8DyeymDCiTqJw3YxYHsR2DnOhmrKYpPJlmO4qmWWcsXKFfVT5YyoMwWeI2WVpOlibmR-6w-YeK4HTRf64ixHYZ3CPUqcRZhutf7iybsTQQM_akQL-Pt1zxRsFEkow7gYqm7TdB_g_2XJKkKSpOOBc9y6QquSXVYd5RZFaAPd24xTH7Yc4d3F6sCvJ5QdEfw2EXsW5yyvMmWEBMpnZPLObRk8Jp9BgIqAbs5l9mWL82ho9oT0V5ZDAXaAzvUOLSLuXyXKVEE4THfTi3G6QTyOuicxgJWUxpELv56gLBo1s5ZpgY5mFW7IiPVlEuKHPQQwwYcMvZ6ydsfq6_Xsb9BG9OIxGmJ3qV93VUqh1lUptuOTM0eM16b3oLjHJ24RG8RvzE896f2u_Y8e2eoEWxJhl3gBcSpW2RSWtpX8ulwPkRz63qvCtPuLZtPlLMYDT9Pnzrk8zFXGCB6ESJKbnT2eHCyMq_hv-2L3_ZEjRTBX5tcoWmEA_EpfFaY5eut28jPE2hcMFnYMAv1z04sKUZoIzF1YkkJTUPvtEmMUtylViRLC5gE73zxhZhiMr8cN4xOHZ8-BNbIv0LIprUYigLiZF8NAQnqMMghzsoID4PJSajSNWTH2SKtyhygPzfvjPo6lMK_c_mjH0sDgcaOtMmO4Se4Anjk16RudThNTj4-oJhrx8u2BgaYU0XdhGKsYoN5eNz0EMVzmny2wNEWEvsKpTaxKxm_mvaf7yXRcun5TBXfTHlSKxCULC3yEP5-_bZ_EufRYUnDgolo2iyBA1i9kLO0jF6VcI-sn0lsMIcwg6HYhYovlUek1jBonRQitNLpn3i8V3xgygTdu_R4kjMxQZrZsIPwNZFSq_6BiUemnhSvBx8H_L9d7RlsZdWXWIDm23dmAUW66cXoh7KlRwLoiBIFvr78asjCD49KVIwyMpDoc4pxvlTjufnU9MqGVaZ2Q4ZX4A2tS2nUF4JNjZSFkL4_2qDAaM3Z9RfC3sJlnSSvBLbBpqogPCWB0wEK0zFlUc5QB7kHhdPTGDzYvgiVO8P0ow9YICKc9uUb-NHSZYtN8s6Jrgehvv_VWhO4lES3vvZYtaJQxGONiavsg9gVyrf4UshUNq5H83lt-TRzhklBSzPpaH0osQ9ls3Wbakm0qMaU5QI8D7nGCmstU-ZyCdYwWCsIt62G-IAmIe4qxTtOAxeiaafZlJYdheUP6q5eDn4kM_0sGReG6PoJxhMjlL0_Suvuxf09VoPqQQsYXnMT0sbrbIM8sI9Zyw9KydyC25JY6axo2QBo-jOiy4ENGLpXYEJX7t6ULiX8uk298qdf8HURyEcfdk61tg1WzhIqqL_3rba-QSK0mVcrouFefZaIL1W1TJqcy5Q--5M_LA.B6k7tSRmRvEL_ShK1By5DQ',
            location: 'Dubai Marina',
            isProduction: false,
            latitude: 40.7128,
            longitude: 74.0060,
          );
      }
    }
  }
}
