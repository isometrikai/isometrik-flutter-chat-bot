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
      // print('❌ Error getting config from platform: $e');
      // Fallback to default values if iOS config fails
      // ApiService.configure(
      //   chatBotId: '1476',
      //   appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
      //   licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
      //   userId: "685e74aa18024b001256ab41",
      //   name: 'Chintu',
      //   timestamp: '2025-07-28T12:30:00Z',
      //   userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.DGMBaPIicdHunW4AAFPF5bKM_EbhRd_CBVqk_GA9vxmPcvuV3_WsQCNvdfaaVJTCjU99YnAnECAB3AqGCqSvn6_cDXRE5GR8MvwNomllR8bb6yHnvuMKtYrhnFqNUk8ZQCc-s5JN5tQi0riOWJNcaAYW8gZM2Kofz8aSFaWy8K0.s9XVs8jPEioX666Q.baC1N3NcA2gtDw4Wp0wmhDMbW-J-31UPW7FMomoPn1zs1q8uGRK1N6YwJXuvsurN8PIZxeq5eBeSm0WlNMSpU5Ic4gZS7bkyfiNi2Sxs73l-pzLHbaGqAXId0BNWJhJc71CdFIeVHYI_nMCEpXfMKykzjTlpwkHmnI0aQDYrcGW5GE7ZKT9kdIohBK7aEtLnR5iI7-NEj0PuX_Tus_ZBFIAGs__5w4azOO5kiEIdv908hvE4wF8GNI4N_z6oDVtwmT4Rz0Til6r1DX-yGHXpr0T76b7A_F-nGpnFPhWec0NIOqCA5YgA2l3zFT6iSMAcAdbx7Opui7-ZsbXV7o-cYkDU1F_sFdEoZnNgLxr8bILbno3wKsUwFCH7XNJK-6pktvDCEDkSAUOt5u0VGjxt5k14lEIcrDKgTyC20zQ03SzFUmCQxwSSRlaYJbT7INeCr12mf3sbIZQl64Y9g756610LlGyggkbkiDXcAUqcto53qwFdf8D4WR34YynGj2bjBtd5PupzCkbIMqKsFhQpysHl1Tjogmr_6ISlhUo9F68-FR3LP9jLVwDMnlBdytBKcBl92S_oyrCZuwB3bLQN2SIkRjtPVGsPHLFTPrvUmrgkcSw35JjY7jK8CGsH7byBg5OHRLrp066MRUdlWi2r1tjynn_h2gnpZtBATPi6GCEp_0SnjhTpwKp4HTVRAi7YDuQ7jyIDHIiAxL1S71fTWAqkJZdxbdoRPYB3bjW28EiSxKtctNqjPNz6CF3nO1knEHOKtLIPxBJoAYP5N2vt3xyWGSi-PHLhBI6krWNKZLeZVZeC0o3n8CGKNf0jhAg6k_3FOc95rJsHYqFCmkz2oSb-Z7tVPxFhLfsl0VMszRD4vesZsJHu5pSxe4O1G6-hlqHeVjjcea1lARzmjLm-jTcFUWJzowqBqW90CZdQzl-MReqnfvWHoYPmro0MGYB_tppxUlfmNVt0K54_hTmPg8gQilv0pw-OCk-qqyC1DcILt7q3mXaRvYB_uu2rZzkW-A3SrThxokXJp65CP8Su9dMaI_BD8bV5M5jBBf2JDTiY2mrQBs2d36mGzv4ke5i9M17N_Nq7hZE3Js8oI3eovn9-ACPMWxCAS3cSMkZySRW4_HGwuO06go69Fy3VPKhWDNqN0hbTA1YfLIkykYhiucEdP0iTj3fN5tNRxYtabAQSORX1IM78xrDw43tzoBIBOiME6ev7yOsdn6qzf0IQWWVoWA8fueL3OCmGmA6qCnaJ_3zqbT4QtHw7i9n86bXKjfjyRBipvxCSqgqosMKUafKAUFOA2DCnq6ZtuxhZyFV7xpqFYeZjfIPrVgHLNUb_DIsNYX9KHEn0zxP8pd8qa3bVjppmF5i4s1N512X8-tkxjACa3Ehl2RYdLDGFy6vsFe02Zk7LKYOWYoq-Ae37ln1v67LgfQXey5s8tdxgyDijN_XisdHw2uter2lk2sDrddx_Xy_XP7AOYMyT8XOsy8L7UReFTxiRHCtgMCYkwF3-mPkE9w3trn2WTAcklco-topBhUGpFsIcUNtJIMOzBnLlc245HPwqJWjhZ5tkFR5m9J6Wcnn3dbYHY0_fAeyGIaTj5i3ZbFZRocDyyeTH8a9Q8hnxfQyffrn0sxHWLbdBLpVZrwFy1pXPmHr6R-robwwHwbkX623TfHjk_u1FVo1Hd8DxMVmFKHprnYKTzRugDX0oyGG3XbKrCi4lcO8_bZFJsMdudYpbbqhEOqRwLQ4kb6fDDs5xKj_vNoN8uM38D0DY6uUGTdGqkDpcmkQyu0mUD3w6zQ.0IXYVc4ZKGMW1N_TiR-ARg',
      //   location: 'Dubai Marina',
      //   isProduction: false,
      //   latitude: 40.7128,
      //   longitude: 74.0060,
      // );
    }
  }
}
