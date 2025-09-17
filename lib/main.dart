import 'package:chat_bot/view/launch_screen.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'package:flutter/services.dart';
import 'utils/asset_path.dart';
import 'utils/utility.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure asset loading mode
  // AssetPath.isPackageMode = true; // Set to true for package mode, false for normal project
  
  await PlatformService.initializeFromPlatform();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void chatMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure for package mode
  AssetPath.isPackageMode = true;
  print('STEP 2');
  await PlatformService.initializeFromPlatform();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  static const platform = MethodChannel('chat_bot/orders');
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up callbacks when app initializes
    _setupCallbacks();
    print('STEP 1');
    // Set current context for fallback when navigator key is not available
    Utility.setCurrentContext(context);
    
    return MaterialApp(
      title: 'Chat Bot',
      navigatorKey: kNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
            userId: "68c129ebbdaeb6000f7ed53c",
            name: 'Chintu',
            timestamp: '2025-07-28T12:30:00Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.QJA2s5lyqVrBDWROAVE3i8lNY5ktoVhezWBgXhbBoH2MxQ8xaSBEerlsd169io0LM8VVXYjRa3bvA0n-GFVvopTK2UNOvrZ0zPaS0JcmduTgn3U1oAm-GCGL52p-ikyFWZ6exTbdKLYVQHmoAeeynFfVZ_XkJ-f5heMRL3qm5qE.1bbVFV3keuReUZcg.s6if4-aB356mRncR0PNM6DlZ1G-y-QgJraG76QD3XTxUVbUarYAewh47-LyWAY_mVMwk5blG9IqddnsbcayJPlO556rw387IEQs3QHGZ-ogEvuAJTri-VpM0a-EFBYg-q2_RFMiumN2ptxyJP6Ofa2lrNIhfdkks1wK6qqzxUq2kato8p-oi5zJ7dsWzhX6Nn9VMiDkks9UNzCGrDLASznxapqV_K3IJvX6U66LMbSRguscQvK03X8AquPHIJio5G8E8_RbZl3AmujfzqAbF17Lp1hZyJvYqaGxzC14dBm7O-GedzNZQzxZZwGR2vZU49x7xWuvpc6sou3mu8NlyP2ODOe3cYOuyLSggkLZ-xKOBvADvJBe1NM9clfj7kBRiGJZwLvUq5IIjbkBldYOrM2kebAVxGoXnwzlygiw_pL-Tv3NDHAqrcvq7JdSIGHKDjnamP01PS_8PsTZG5_u9Yn7jpyF3LXpLNZDMJqCp7wlK2_iB8SuvImm01nD1KbAfCVlZO-VLt5eOhPhrxfmd0EW3-6aev8vpGyJaFWjccunNxe2ZIbyItRWhhwshidWqu115O0bZMP55ch9v3kctc30GX7YoYNLNAU000O7BTb8mco1dfTpx6RHYBSSpLNHbrrLMbBLooHz23ziO41MEU3A16eSk632vla-JbD3dB0G_enhQ5SBqRXydiGt0NUyJn5ZFuJL7-qTvvV5S2_vQeioyHVBBrGRJRpzaoRPgbFJXrRVlS1-1lhknyTfWeoOuE9VSc1P0O3cPd-nVRtgXQ-kEkSDbbNR_3q98NGy0eU2siZOJ6xSe1uewdtODcWKjw2v9m7QdJOyuWrbGWpee9x9CzL_wItapW0mLK0tsWBH1ReAoL--nPRMbgDXN2IRgFNT2e7SByspEbX21Ch_fELIavZsGR2BTJs6zbhV1DaZL9mNTXO8ELVtoLdJ4SGMngTHonIYQMG8XSEiR4slVerEnTSrcSPYZZDzUCudYj3cusZhnSJX4McoqGQCR9q_fDeWYwXxAowGJP-2bM9PAZEp2fmJ1r45ozoTg2uOJTgBVDY1sME6eFcWfvIjSofalQFjJHEqjf6q3Q3-bZe0R_wMM0c2iHTP7I7jE5O8kdMveD6Nx1qFV9Gxllxkr_AcTul1v54LC47yzDaeAxsCxbRUwCOxYPrH18UpRVsCp2Ax-Mno54jYZKq9ym6hKYGNo7H1riVPlUr6GTdVgKtrPXsoPr2fbGfgv0H9ykGpT3Wkf_0j4xHdaOEmYFozbhJRQKD7W4fBpAzCYGII6-0yUadreZEkI3Lpk2hhR00rih7OngNNAv2hbwc-GzNd1X7XCzW8hMGv85eR1ZmHYPxT3hH_MKqXPVqE-k-X8pNYSfFE-eFRvKvAcRO9NhxmvNtgQD1z6TFscTWwBbYBj9bw0IbYOlfxnzn4s1VIOwZSUrMzvQB2qI92xYSU6y5pRWmvR2JW7KMfx9IyRyZ5bOqtSMcbBVPsUZQD7iNxOZUSeqv9jn05ibqfzukb9jqF0fR_qo1AabubMgBozfs4Agr1nV14Ug59LCv3RgA1cWlB07A0ATAobO9SUf1zHGZrltCk6qnw8ywF_pWl9g5iCsz17eI56EBKtf6cxkMpo4hPwJGXg56Vv15DgBvNQOZq_ns5nSYJ0Ka2KGrfHcleOMgolonOrcDPq1WCLvjO7X7tC4_kD1mELgq0eyNEXmHD9FaJqaT9YIx0qhM-W4OcCm85pmRx7VsRJrJ4xGEBLi8irI56z84_6kxABDm8iLYPgqvM-1_WAVK0OJ4zFTfs.ZgQl50MvmqDci7fK3d4XAw',
            location: 'Dubai Marina',
            isProduction: false,
            latitude: 25.276987,
            longitude: 55.296249,
          );
      }
    }
  }
}
