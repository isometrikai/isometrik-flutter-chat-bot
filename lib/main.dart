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
        child: const ChatScreen(),//TutorialScreen(currentStep: 1, totalSteps: 6),//const ChatScreen(),
      ),//TutorialScreen(currentStep: 1, totalSteps: 6),//TutorialScreen(),//LaunchScreen(),//ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
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
        currencycode: config['currencycode'] ?? '',
        currencysymbol: config['currencysymbol'] ?? '',
        zoneId: config['zoneId'] ?? '',
        timezone: config['timezone'] ?? '',
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
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.bJn00Q4lZU1xoDuakQ-uIv5VoqxiIlu0d43Bog0vBxul730kRv5wWkiNvDv_NL3AqkJIj_Vnus45j50A3XfqO3mj4gvZ8fBH0sQwnKkt-3T7EpOV36Tln5ihhyQGseJGK3yfnLx2hnd402FzGGkDdDSp7UzOau_CuxMt3EpxHZs.PhuSvYjPYr3eGZ5i.4h72698R1mV5-2sxwbTihZXJOFcFfeThKJU8gab9_AsRuarXZKennUc8k3uN5LrLvVzpHw5_tJ-Ic6otEZtpsKd4YSTnQqvj3oBPzM09F10QFZxlSlctm75KINrTBjjA_Y37G9zCDZwREzCwKg4ONH70WApNPzGBqM7gkm2oCJo2DjP5puO-SHGQ_AUm1gUMFMfpXRwBMHXNq8yLF9saeqyAvJlcrnNn9vGkF2dwzFNE_3ergmNXT9QsWisSTk190Q1r6t-e-984bDHUo67bfugLHQC678QJZM0yqOGjjCPTzz46PqSEzvT2MkYhNYU5F861oC2YRRQN5-CMFxNpVWJwXtgW_y1K8z1W43sHvSy7zv4OGSY8sR-dNe1xbENbiVWgHiP_xpGu8NQ77ACHXucz9WDezQ2o-EgGmGlmBGyOQEc7tYra9zlc8VxPc3i7l_gEnuCSv7civlmtAEDbpyjED--a07TCdtUkFrbCm4qtsTcY409DBaYixxVcW53OCW1NlU9dc_yIhNY5K1MI2DFvykEaIzFMBKcl9AiWcHG0HRaKpKm2Tkd5ofKe-pOsUlain0RvXIrDu1cJXJvUf0lYskLzp-UxVMauZy10aQqMJwSN8UFIm8dKILSvefkFwZfpqgJCs5ykRoxLDu9soZ0wzLFUrkuAYSPClil2hpZngj-ggvqLPzHm3IX1W4Y26DNj-JJGHrgqsa8yTCMRwh8LCzSjkH_VuBViu72WFllYZlbFruX6imXNirLPqiT3Dl6Smr_RooxOZq8mOeapXnA3tbB16fjP5Qt7h3k_BfTk0Bx5haLjs1GJozQ9peQYjhoB_Q5wRJ5pxduThlT3bfFWZfu6xYc5Cp17OVqueSzKl-k1D5WXuWNYN6rhQvKOK8dTJH3qqpAWWWLUCG3f7juxpBPdNnJqHr_C-wcT6fVdjjrw2mt5VLBnCu1-yWRzTGfMRZlYfxL7K4-dPkJWqUfrGiEtRh3F86I2_9cco4m6r8wwRRYccRZKszdXW7OrYpkQ04QUKbsp-pxeXDNx0czdoCb3jUlgXA5sstpbDdiKJNkp7K2quq9dtKPsPdeSGvjeMcqU41m7u-OyRvXsEY3_hD19MKgfeGSZFWw8u7AGDknY-HuTb3dxpjyxFJzLic3Zxn7ZFc0_ReesBMScFHQ2po-XMPkslGEHyUZkqDwK-kpscB7ZDI_AYzQnOJp5CoWAcSKkdC0VilkA08ypaPbjAnnaN8hGIe50G2Om_t8VqAJxXKV4YZgGuNhMpxf3QFXHsIUQJEYYA1-6CX-3Wu07Hxkq-UDgCKxloQHFIWpGS6v4ddC3ohlP-Xz5SXSw4SAdus8ZknrvUpqKlqfETQGSqL2YkjN0iOuC_GHuz0ENWJANCIW0_qBXfobe4rH5a58_ajovdEuLiBKp4FNJ_10X7Qh5RvmHt2I5L-h1NM9fUUjW_0Uxcql1wVsN8IbDtAY0PCSiJl_PKJ7vWkCZgB_3pdgKbf6fphbAA5xze3yoO_oQzDDas71AKah2OUfBK_bJNNOXILP9P7PMbx-ujfJ05HbSuAyRPSO6Nyrgz3tYpkADvF-_FlB3nQKjMgsAb8eB1eKNvkwi1I7MbFtiuI1XvU-srB1MnU_CU9bbH_9HwIlCNJHqCZJmhnlhxpr_a61TUPa21ign8VcpnwtVpC2qjF0WqMEN7ZaTvgMfLBVLR_f_HTegy7SUDNckFzfae620p3s7wqnaba0_iEZLpnrZx72VHdu66g6c03R4aXYolGq9zc0hOv6v1cuQY8ilSb0wj7UkZA_Es0Rk.l6fHNQYyGotFn9WRv6MY5A',
            location: 'Banglore',
            isProduction: false,
            latitude: 13.02868,
            longitude: 77.58952,
            // latitude: 25.204849243164062,//dubai
            // longitude: 55.2704849243164062,//dubai
            clientGuid: '528a7d439df44f2b9457342b7b865be2',
            indexName: 'hitechnology.20250821.105131',
            visitId: '3c6b9339-c602-4af9-b454-0ec0df067181',
            visitorId: '47daf829-b5df-4358-83ea-207aa4eaae15',
            searchApiUrl: 'https://searchapi-dev.hawksearch.net/api/v2',
            baseApiUrl: 'https://api-stage.eazylife-online.com',
            currencycode: 'INR',//'AED',
            currencysymbol: '4oK5',//"2K8u2KU=",//"د.إ",
            zoneId: '634e5da256ad3fd02bd3feb5',
            timezone: 'Asia/Kolkata',
            // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
            //  currencycode: 'AED',//dubai
            // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          );
      }
    }
  }
}
