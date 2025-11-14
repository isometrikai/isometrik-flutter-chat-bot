import 'package:chat_bot/view/chat_screen.dart';
import 'package:chat_bot/view/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'package:flutter/services.dart';
import 'utils/asset_path.dart';
import 'utils/utility.dart';
import 'utils/app_theme.dart';
import 'dart:async';

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
    // _setupCallbacks();
    print('STEP 1');
    // Set current context for fallback when navigator key is not available
    Utility.setCurrentContext(context);
    
    return MaterialApp(
      title: 'Chat Bot',
      navigatorKey: kNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ChatBloc()),
          BlocProvider(create: (context) => CartBloc()),
        ],
        child: TutorialScreen(currentStep: 1, totalSteps: 6),//const ChatScreen(),
      ),//TutorialScreen(currentStep: 1, totalSteps: 6),//TutorialScreen(),//LaunchScreen(),//ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
  // void _setupCallbacks() {
  //   OrderService().setProductCallback((Map<String, dynamic> product) {
  //     _sendEventToiOS(product, 'product');
  //   });
    
  //   OrderService().setStoreCallback((Map<String, dynamic> store) {
  //     _sendEventToiOS(store, 'store');
  //   });

  //   OrderService().setAddCardOpenCallback(() {
  //     _sendEventToiOS({}, 'addCard');
  //   });
    
  //   OrderService().setAddressScreenOpenCallback(() {
  //     _sendEventToiOS({}, 'addressScreen');
  //   });

  //   // Add dismiss callback
  //   OrderService().setDismissCallback(() {
  //     _sendEventToiOS({}, 'dismissChat');
  //   });
  // }
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
        needToShowTutorial: config['needToShowTutorial'],
        clientGuid: config['clientGuid'] ?? '',
        indexName: config['indexName'] ?? '',
        visitId: config['visitId'] ?? '',
        visitorId: config['visitorId'] ?? '',
        searchApiUrl: config['searchApiUrl'] ?? '',
        baseApiUrl: config['baseApiUrl'] ?? '',
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
            userId: "68e8bd01f79a4c0013cab22d",
            name: 'Chintu',
            timestamp: '2025-07-28T12:30:00Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.h4GiSjVO4_JzMV1_65jVxJcsv8uFSfdpIxKR_p2UQe3V4tLxQZOhGf1E48r_d1CehWSxa7usfvP2zOQ9VqEPvrv8Xlobb6JSh38ADXuVd93IZG-VeK7fAagacuKXS9O7wwCyw4rpz-kYEnQgK90nqWWq65bE_zlajuER3DeTdVk.78wh4UHvvTPKL2l5.5HIEF9eQO6Hvq4L31Kcrm8-DnrJPHdHxvTHPL6G67s5UNuc396-Rj5RSE6TTPF2M5hFJUpZdiFVaiFjy-VyQ1Iqsa8ITUF9WErT1vTU5UB3WjdjFvpySSBCJjNNbWAfZiputyAvlQakO6i-bjxd2Jhasj-a7ab0v5vDxwHkoJB_kNUhRR5suor_JXo7Os22_FJTEELg0zCNrmSRVNAoAv0e7KuTKCCohyiVt7hGOhws5FjUNY1LXLOmz3INz66KqdHS7t-g3oiGhmjAU2Bv65ZvXN3bo7KbiHeJ2IblKPkCapa-XZOgZ5vhRyHVVWjxvg4yP73sPGoOVta4mODU0qDktamvND13N1xwRm1DFSGZLyAP6PROfHum_GXJ0C4ne-_QYz1amNNTWNIPBNP5I65r4Y8U_gXGChdTA76Ls4ifUx9yZbXppYTATg3ug36fP9XjJLASosU_aSTeIpRImouhmLZc_jUq8ApJnZuNt1Zqa4kzjWy0BS5pscYVCK0QXhiawE1lm66ETLWQiV4VKN2fDgrQABRgMQ8TLdD2CZmGlSIWna9RyAAjRxWlg8fluVNJ6LJa54fXLdTBo0__SA9ZBNfZwrmtK30osAmwbMr6r9OPCYZB_0TI3ccbCBe-uPsDinjc0Lik2yu5HpMuycHbPCtvS0Xw4-01QWGwQdkM5l2go61lZPkKKsRnb2U4cb4V-Ex2RpCts8Ho3mL7VsXYLYNHUJtB8m6fuaHT2NWwTGY2oex57-Uyy-YqGvuSwoWMU2RtM6z1zT9wC4KCbZ7buEfj4uww6bf40E7TGbwkmMiIiOYqm-wCVR-_EY_ZrZsE28IDpGfezcjVvdwFPB55_EnXvg2i_V9JkBQzqolohTz8VcKO39KYYYaduUqEce8MpgsgS6c2rn_7dTxKK8co7sy25t5HgzBM_5YLzmh_8rGG3hQND468d8BFDK_JETCjB7QVX5lzjd_R83rPgHvBdjI26ldzugeseTQNwJyf1HLWW6qP7X52_OoLwKumuLi-Wca79ywHbL26bYnaYd7s_j43rrp6WUORi1BcF9iHzY_ueIH2Hr_WtGgNMcf7eGabAe7idDoTVuVxMnugBHzhfAZ7X82i2GRErp3CtDntKP_a2AYgF7ojfMDW0HJu7aUx1e7ocwLpvuFrROqAAAiX6yxW8WIgAqPmvzY6_Y0x2dO_ynbmWVtaUEyyGvqgpeIHYGNafUOJQkKDCpXSuL2ZnNDLkrUs2E9xHuM1FRMl8WQddURIP7iTWrTIn8cwvD7tmUxIAiLhKuxViwCF17gwqNCBhPP2kdoYxjsA21ErYsHspLiiKsvaiWoxNs8IXi1vpuWXhpp3vDNjR8puU4PPLg7XZQV_SBbfGqPRgDX5e6ZZ3xHZdrMk0DykOSc4p94Mrgh8IeuDG1al3Td21sZhZnX3a4dEw3-ttuppBWTRvzRuLRr_Lgjy7eVPoiKUNwn0HTa02Trox-IUKmJpCL4T5plJvxw4oyM-iNi1UthId9rYBoMkB-cR912gTmf_usosYbrCDLNpM4M15MfB0ZUqz5Y8wfziNpYoXoqAan58PSOFL2RQKS5SpucOxw0EvfcD4BHDZNYojN7Jn--2OY__n4EPY-h83xZlKmeyV6aPvLFL2flderKDJM26U6h0vLgobGEDeEtRrs625SDsYXyr1wPnhxo3_7t2OO4L8SKW6LmaCAUqzuGS6tZ9ShHhhZrymQP5YUmZezTa2CZFjyexwoj6VfD7RXgu3.D8qXSkDpEC1ewKzA0k2YNA',
            location: 'Dubai Marina',
            isProduction: false,
            latitude: 25.276987,
            longitude: 55.296249,
            clientGuid: '528a7d439df44f2b9457342b7b865be2',
            indexName: 'hitechnology.20250821.105131',
            visitId: '3c6b9339-c602-4af9-b454-0ec0df067181',
            visitorId: '47daf829-b5df-4358-83ea-207aa4eaae15',
            searchApiUrl: 'https://searchapi-dev.hawksearch.net',
            baseApiUrl: 'https://api-stage.eazylife-online.com',
          );
      }
    }
  }
}
