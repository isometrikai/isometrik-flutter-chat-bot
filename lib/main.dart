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
        child: const ChatScreen()//TutorialScreen(currentStep: 1, totalSteps: 5),//const ChatScreen(),
      ),//TutorialScreen(currentStep: 1, totalSteps: 5),//TutorialScreen(),//LaunchScreen(),//ChatScreen(),
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
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.c8lPDlPW-3EMPo4KHmTXHqoQ_NPPk6_WH7FggAQT_s5rzbJcAWTvjlBmMQw5kKehc7wco9JqMkgl0V41rdGLf8qgLsQe0Y1q5aX3EwXauBGNjINWg0Dnk_pIqqfet8mMgtcfHHvEs4IGTTadvpIuSb1CtBRsTM9uMwGKoBd42nE.J_9Nj84jqByT8-iN.l1ggGbK1Kcjka5HVF5C6XSdTTi00K0fjBG4vEVEJneSaiYLfhAzzxInwj_1s4S-BvALX5P_MyVk-DsDW6EDg8fc2Aud-2ALXk8tWpdAB_8WL8LoDQGlBJ8JWNvxLRlN7o7jb6AiUgrbyE4Sxu2xzc_Vzt0-wwoTpfeEKf2w5a6G5LEQA-ts5eXKmRYZssy5X5HXeA5SCSlo4vHPetfqXv_wEnCX_TQFq5dPEzkkD4eUd3F5ITKNjmy_KhnWt7ldr4CTVi19Qc-6KJ-KgL29-F3nwzdFdDVYsQrGJvg5_HvVXly5amY1jrws8Ui_PyeuGJULZd6N3i53IPWfewkV8XdE8zEwesW11jBj9noABDxFJ6gOteHcOES7hAtLeh1wH9dufctpcBqtMST4jN3FLpgyBO08HxT0CCEYzxvvXt3lDu6zMeqI6Rc4-33OaGLJKKkqgWCMv_fPM23J4FyimMBJuV524kNaxAre5-ebk4vE7ioUec_7xy4Y1XZKDleJgxKVdPr7K6EbxptKHUP1mu53LV9SBfIISJy_lCnC1oElgTEsJyo9VMKKZx_HDxRL2Pj8QIis2yRzQhyu_1ueMab53R5xnQ9vkV39mCTaYLvL4CUx7Ssr51RDwm6QJH3xjNFBprbxFqcqb7xXcGKRJk3YaAmC0jJqFGC1woYC8jpOLnJrmjMsL9H4_6bK6cIU_lvHNKz89BYuwOLC4JlhdK7Y_VcUiF87XWOjevThcXlzdeZymuN_pD2MXe1x_ovZGvQKUCWpHM3_pG3zXINZEzB2lFIX9aym747pB5BDikKFB9_9IU7oO56m3rc-MoJm8zQI7ZaThm-MWFU4CCrYPYJASciAGkwy5HiNqj5r4wWO1iY1gXAJDSEPYbMtbtGCCofaiJTmT8UGRKv0ht8LDEdIA55Ura3OLtOxL0JkCdaX8lYUQntSxkAhK9dzotY1qzf2szfx74SLQRWF0SuU4MJcjoULprPtvZ0VtdX4CUiLr9LN43wwrWqvBmJR-_0x0g-YdXKLPDj6QPeU4SKF4EKccQqe0wUBdNV3r7_9j0jzS9hFT2L7ZNsVeyM2s7gEA7DyWASYS5SP8GywBvWqeK7YTUJ6WTCw44k1gdF4kAwuaIoRxPScmfBJ8FIJ9fG14v9-_lpjLmnnCjxKFt9pu0uKuqjzfQ6gv7LKbngh6h5bO1IDSzy6009eFXOxB8qLM7gjW2wpdhXJnX5cdM83QB89Kn8vg_AC3YFC3g2LUN7RXDvKjk1hfFK3WOEYKP8pIDY1oRGZDRSN-HbQcsKsfwePyVbR3_3NBQAlUP2r6xe3dDSyVN9DmmlsdXqqaJgdMGwIOpUUdsr1LED3bgbplGH1dvCp6xYh7xsZ5zIZUtHZoTf17tl9fSqK_LJGRXQgfOreysiVBEMNgxPrHZ9RBz9o1KOhCmgzCbC-HTEF1vBf8wQc0-rEqZzIS6xPJg7LFr5qRPYjlUzo71agzjLPhq8tzT3uNLJC_fbTWkmsGVhBuM1dLhfDaKwe7qeWjZ2E_NdfNlIN0OZwpd4K8YyHY5RRijUVGNkK5aBlq1wYI9rArnZ7rfhScXYhvqtdQMszvjje5fDRXgYcj90sEnttoAr_izdEEQ-Ho2DIbw_6YkOBxXTYfzu-X2xauyG4hCa579783ErfDN0NVSRsTM725Pqg-nLwmFaTliE7TpwKDWSftGHd8eTfjtSreJbf88tLHtbLvlSCrXbRjQYSbF8E9CXJ_Qh3UO_P7ei6HRy-y3m6lBcwH-Z66-kIj7EVoMN4.7TPx5QdiNtRYSFNTPyszQg',
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

          // ApiService.configure(
          //   chatBotId: '1476',
          //   appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
          //   licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
          //   userId: "63ff047c83f1c452a11b8d63",
          //   name: 'Vishvesh dg',
          //   timestamp: '2025-07-28T12:30:00Z',
          //   userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.dyMQ2fJbubR8rwZZ6jlzeLdwqTafN8eJeZwVu4N7ZNPT8GfNg2lREhoxDOvW2jA2agROulCUQohjZPRCfK7W8NPCOdRuQzdT6tKb214Iq7zALmTEEyr0GyVkiqGKqn-hAvjg0n71BKxWZWaoirN9J1Lilt4Dkw9NzzJffAVtZKE.2-BqXlr_vdIBeRpe.L-B2IOGLYtlWj5xS1umo9l997Bloah7u0n3wQfAMcDhWYLnWd67kwsi88x5UHk5XxAlQuIFeW3k4CiDUhBhThrPmafsb31I0cHgOZtvvdaHPLv8vYIChn5FK0kCkOWaQy4wyqY-FsQE3ouQOJmU1TYe04oqsClO88hoIcVPnMfFbW9JZJ3zORpzNwJfAJyYVKponkgVJls_LbX8kLkFS652F-RPUafLh6WfLlXhJfacc9-b-0GIeoISZl3bn5hVwT76LyHalkoKG-Fp4ej47RTlfgELraHs8vml3Y69kQBrXzocrJadu4uOHTdXmJ9434Y5Iq1cFH58obbK4jTl29lsZd3k11hvwNfmasw2G32_NPNgazTTG4mGA3C1Pt-nbyx6Qel8Z3watNqlk92AK-yd5AdU-zQJwsyzDttfPeUnl6ur_5f3SPi7WGb_HeA5IQCkrkDyjz-7mKdrFi_cF7fcI7Mr728Onl6ujsOpkLiiGT9cuJTnjtmXW9WB5gjyvobodz7dqwVWECAupAJkdNvhyhT6Mtk2Dg4LxxU8MiA6ACCIPzWzl2jBnkV78P7sqY2AyLJ9b9V1Y_jpxTwW0sZKRmJHwCc0mCqVU-bqTVEx7HUM5Z7kYHJsZ8v3CwhVUE3mJC5eqPvGsGE3To_r_41MIHmanpsuwSMoS2ldxacI9Bas2YrRIuJuWHN8mM7TVn1mh7kzscNUJsYwS2xQd4eZi1fm0PGiqbFCjsutD7DKgz-blqc9d00PZtbJjqaGJRuygIN6rYAumSNcOhT8K5NFLTpge0WF22hgu5Wh192dehsQ0eimncJqGFWSEWLL2godekuLb76_gSOt454abkAsllEpAAxWvrD79MwAuWFVpv1NXj2f_6nOuGQee9ORT7_mDTlI660k9x4IvbGguyY3ytvDt9XXejcv2LyRadIC8XS3RyJnJARInv5Zc0_kZ6lLlWTVS2ETphcdGVHi4Hf8R9PAMnUJ4X6UYiXEe2eoy-A2sRHHCRXftq9vQJF7Nee20zc-bFh5jY_i_tztr9s7P0ggRVWRgPZ2kS0pPBR-mtIbgZfFQiOvo2LpuNUB0jrRa_elIzacdqrbm6CsqL2ZfOM0s6wQSdJZDHUw57PLCfdWIA4my9M9LhsCncsCBX5ZVLribUb7mG74g9vcUpv163bbp9OGkItS_Le2eSarjg1rEPqRAE3avUxvomR3IbUiJ7pSIGvEkX3VZZPnMyULXrNjeyoZVemuHC45LdPs0pEv0dJ8E9MoUNuAyGf_xVHvCSgiCunLPNUfIMyeSdJlcV4bD18zQsG2lYMkswRen6fQAXGmf6UlDCnQRgQnLvVFo4NGYzbkeugAAkVTkFihu9HyWrOz03i9FukZe0MTaTuqbu1H31kaetS_0hN48t6jYcDTEuGJqyjybE__58Ab8M_9av85Ix8JDybPd3itXN2mEpKsvS6h2JNW3nHpQYsxOd9CpSW9aVW29V56gInExRLkVjEoxBWTDYqOZ5SkA8zpeqJTDchMQr8AjnFY0t2PzVH6E1jSte4PBoIHIbHfsAM9ewL478mOV0C3ZGmmVGLoiNWuT5ni7AB5JhLTI1xQTd2XNg06H7y2gNY10KuEKB1XG5udpRvJQiOMF0B2KzeRrfJ8pYsrYEgt9YlzxhliF64FAuQgf_c1RUmkqA7inYAdWdUymmzbqiB_M4RJ_1GJqnHLY6Nm7VewdaSJ_MyygQdkdey40nxOWcXxRtIGJVg-ugeTnk0Hp4m4ekO6chuBFFt7EYgYkzPaRxelmzF-h6Gr71Q.OHlrpNAwn5GKGZZWid4P7A',
          //   location: 'Dubai, Dubai, United Arab Emirates',
          //   isProduction: true,
          //   latitude: 25.204849243164062,
          //   longitude: 55.270782470703125,
          //   // latitude: 25.204849243164062,//dubai
          //   // longitude: 55.2704849243164062,//dubai
          //   clientGuid: '528a7d439df44f2b9457342b7b865be2',
          //   indexName: 'hitechnology.20250821.105326',
          //   visitId: '01e283c9-841b-4349-9d2d-39863fb3daed',
          //   visitorId: '2b0a8996-a55e-4bdd-b4a7-3f85cae22bd6',
          //   searchApiUrl: 'https://searchapi-dev.hawksearch.net/api/v2',
          //   baseApiUrl: 'https://api-live.eazylife-online.com',
          //   currencycode: 'AED',
          //   currencysymbol: "2K8u2KU=",//"د.إ",
          //   zoneId: '63e4cfa10a79635797059f24',
          //   timezone: 'Asia/Kolkata',
          //   // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
          //   //  currencycode: 'AED',//dubai
          //   // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          // );
      }
    }
  }
}
