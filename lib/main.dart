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
          // ApiService.configure(
          //   chatBotId: '1476',
          //   appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
          //   licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
          //   userId: "68c129ebbdaeb6000f7ed53c",
          //   name: 'Chintu',
          //   timestamp: '2025-07-28T12:30:00Z',
          //   userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.KdvtkDhUck2dofeRP_Qj3bHVlQYmEjyCfo_WhPMpy5hQ8lTwmIrb3WZFfZm3uA1RpYjANOxivVxhXbzo1RMSUu5Nd27c3bDtm6gtkH9Dr6Gx2qYNjpb1alOr_5kRN6c6QBsOIagLKoMYTa6XmdcI-HtLFOHSRH9VUeJwGqVnUAE.o1gZAlsyEAz6LW5g.7beLK1vO7VT9jrRfGRajHKvXjQ6WswnpDcMqDnSrzO6WKj4L6FBFbDq4o6CaX-dpjTZPaXSSc5FFvZgJ0JR19WqLdJx2Cyv4Yx9DRIlYGsVM7Elc7hjfUJginK2lwdrDG6Nkglg7fdYK1tdSY4TBSCmOawBMlAFXAXnfb_jvNBHja-A3Isiw1ofwbT--ufgAWge5hLxibng8mJJlQXZz1VzSjOGXevvBrvcJs1T6XF_G0KZNu0hvqV1XOfMdwVDdkDMbn-gyLjNioUgm6Wk-Gex36ANndigtvtTVe6bQDV8cL_Q2lHuIaELvvwahFiw39zSKYqvqbhEURMUODNTIGNnPUraSjo4QW5PsEzc4LiugtfsWF3-y8YxN5KnyFw9YKAvx6V3d9TTaQvBJJx3DhXeCs69pbwj8uS5I1-wNRXYEX3wo2yWZmz8VMfRKsOPSKqC0sDics_WubFzIBvYc4ROZDvOYwl7BSqyOJBVkF-9LOgaAr15jANiYhWtbvqpq29TgdT6i-DrIQ-fjAh8OBuJqKnDqWuCqxw--YiFda1i00mFsMHd5Cz9eEza3svMUooaM7RZVHZEFse9BU9Ox3lVeQR9naIGLwfCYGYSvuJkXLHvtoBFwQd2ijOOeCqR04JBiUUcOIek9RX8wjPgwts_GcQIn79qf9-FpLb5eyg3vvKV0r31e6nHa-B0djfV-etm03Nurs0IxFcIEVyXOdn_O70hPO39lD9KO09Rtl16pCo8yGVC6M4D4JA4w9kAUVHQXjKffg0GSzWf3pikIFSOZ-BWcneU5kb281nXzVcOWcGevJmpO4dg5CP-STjPgdsJsbVGYgzgg53u6e15X1zduZeZYRzRG_QkvyO6CZaQV8d718ra-JSzB8zZvKDdO7EBF7hJPJpo6P-8jrDo9Ua3jXcpFBZXlliMmkhfJA01lWJ1_hYj4Zi-AGh3CSBvk2oFjdvh1L26EjdYohpgqKP7KM9QbMk3sMrRn11HiA9ijrC5CR5Idjwd2hVNxIOMmyYeTUcMTLl5B8-1v22eCpAdelYjnz9GdDRtWU40S2HCAB4B60_p6mFmOxOYxqUpwLY6zzcJCA063340FBs60uBvQfjnfcjgnA_42jufhgwt-4uMlUI6ykoKEZfbvMDxXeuFPx_zZzj9Y6X8YEX9Vyd1KiK4it5F55F0as6g9u9ctCOFpoSVu6__hd98MnE0r-qfZpbSLXZDprTmzFMBCqm1rjq36sXa101B3Ndo-LLIvGmmDaIbKzdfLPvHHJZlc59W_fS_2Nkh1VivVoHeQdD3MVh1Y5Aq1cU0ZWRmb_q3RVa1-jpe8h4hBzGjL0AKB6luI3LyrSIxzAkirsKmAEo6oeqMBE2wKs1hsJgCSvd9gxoS9fsRjH6INvZHCjuoBUNpkEI9qjp0dDsQQ1nWIpawv6-FpGtzE1E2Byw3jCZaNP0op1TcIxEINApy9EBbScFumMJQAeyKoq6_-l-J_iv6zwRpmSDEPLyBmf1SD521R7gk4ch8qruiMiapNKAeoF8WWYAWvAGP49qNsdqaPn1V-XH2TiGLhD7j7i1Uz0GiEwDkecspp0njeCW8BvCbKexB037M0XSt6E_8X9Gdc_fJId5-2N0FFGvSEU67NOACT-BYHPTzLt35De-mOEe7Gh-7LXrAo97VKX0reJ8oI3MPWG4v0QZJqqKmcolk_e4cSfHzn5Ck-BBI55DPHv6iN2ZZgXbJFCyGpdc0X-wwK0xhcfvnCAvZhi3BYOpe_zg4LlMfW36-iEnGi2xJv_vo.AwXy7Y0Vi8SsiHqpbf_bqQ',
          //   location: 'Banglore',
          //   isProduction: false,
          //   latitude: 13.02868,
          //   longitude: 77.58952,
          //   // latitude: 25.204849243164062,//dubai
          //   // longitude: 55.2704849243164062,//dubai
          //   clientGuid: '528a7d439df44f2b9457342b7b865be2',
          //   indexName: 'hitechnology.20250821.105131',
          //   visitId: '3c6b9339-c602-4af9-b454-0ec0df067181',
          //   visitorId: '47daf829-b5df-4358-83ea-207aa4eaae15',
          //   searchApiUrl: 'https://searchapi-dev.hawksearch.net/api/v2',
          //   baseApiUrl: 'https://api-stage.eazylife-online.com',
          //   currencycode: 'INR',//'AED',
          //   currencysymbol: '4oK5',//"2K8u2KU=",//"د.إ",
          //   zoneId: '634e5da256ad3fd02bd3feb5',
          //   timezone: 'Asia/Kolkata',
          //   // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
          //   //  currencycode: 'AED',//dubai
          //   // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          // );

          ApiService.configure(
            chatBotId: '1476',
            appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
            licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
            userId: "68f895bedfd97e328332805c",
            name: 'Hamza',
            timestamp: '2025-07-28T12:30:00Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.ax2eUfJOmf0bk7GNFD4dkBj-DjFMTlcdEOmXThB-DIuKwC3rSnrhzVNc4eLS_EuezaY2rajYNqzVC8QQAhM8KncBbhlB_PW6UCTZ6SnrYrp4fXA7eFMnSx2MK8TtDLeePsaOLdzpTOxSmnHuT-RQoVef-KwVjVUdcnXoBZiX04E.OK91ZiDzMDq8iFOk.a_QR_lCI7IzKR8blfY9GeQz6NC6GsEfMLVuCh3PmEIQpj082jc4XsOh04lAdoNVbEMVKRSlPRHSfiSD7tHAGKO2Aghq-N8X6OCQ9ahWh1R0FDvo6XUmEI-YS-of3waMXDOvDA8IcFr_1z6wwjiHAl3LwGwzQ24NBVxToIfdjc20JFHy_q7lqQfVAh5WrBxkT7rf0L-oCz2h90bESUoZO4KEqbOoT51dNvdKrK7bs8EXB6LrvV-BD26Mx6d-b2nmkY4G-5Rqsrs1FXnEr-Gp-KyeaptTv6qHpIBzbOcCS3lDwujb3sy-U9kYvn22E20IC__ak3Jy0TDee2RLHpGgDvtFsYlb0aQ0NdRtV_CN7SiJkfRYhMA3HiZhW7_qGPV3h4CnIURcPMyBuBmHAIBMOYeTHETmHukvqDEqINXouc_EM8GPF_JqDR2ZBUX9eCUlKoMFvI25TLwUCaQYbO1QiBNwkMGcFXLYv6YFBnrVMKJxMSeFiRowJC__IAkwfr5zeaQxVK-mddY2TKsRWWk9LI1-ps5sVp6AaAzYHd4XlF86qL_acZJXe2twanVw5oLFQdqOAqli9c_uVuzRbrTDfitd-AiX7k5K0na2qYSeJCNMt1gSOwIgzlM61SgM551xjE3yEgu4kAvxQx0lax2QVBcsXRscoyEv5cLtdR0T9oknIOt5_2z-iNeJhnDOlgEtjSBsIuyFcvHEDtTBzORdP-1iNMu04TV3I98CSGCC6_HtJuqnP4eQjutkC1Zrx4LtdTv4vtIRtjw4EgK9p44baXr3RAbBwLeNQyjtHr1twTQoGXWUF-JxJ2bkNTMKQptZhgu7X5pGMhsDzIuWRVJsLGXuFBee_pHYJb_nl1HuAQAEY-5N2pkUNPbhiC7Y6mRQ4vl7ouA69aOBlNc7QYY5F221fae-QaWzGMwRkgjTvLmFlsXIKFP0kt0VK6JZNWB1kYjk8lVAuinblq_6waA0qpItdTdYZDq220zmqVKR_m9STPBxXTmFDPUkGHyYa-GjFjN-Nz94OB_UgHRB8NcYjM3JwHmSO0ksQzrF7aGBES4Edj3LwArc9MSvSr8vMR5gwTXrsuRh2_1cDKYukCw3etTdR-iO2NAAEI3WYcxxY4W7xZ4PYArt38unCWNbAewZALeMZLxgHNFWCCv_dwF0kItMTbHnyWJqifSeHe7JdFWuXQP7avrZUydRAHoIfXf66IXbWgQncw1QFWUCcGxM3aXafVMpMVr3rf2uDPXesViwWa8BCEeL01HNmdb_1amUILb4epCJk5Ny7adNLHH68e1Zymzz24h8tyxyfJZmHbAsZhbxbRceNxy2sCFaGiLyBCzU8O2SGLrvGXOQNVX3YHvtXAPnXqbrhos03FZ1o_b3aBw7nNPsaqrelyTxC4E46uASKMU4OwS6GnAXaGwcbXQ10SoZRNWMsjEJOVRY8Vc-9OI0FNlj4c8gi44dF56GX-H-iWh1ShWTIuqfhdvk0JIjkP-VpJKPsKHKP40huIVtBL8os3jwbrsTLsGOLruKzXJ6OyrBfj-yz0OnCLvBBiqaHZYvCJIsB-szoiniRZxlKf3aJF6pizTgzX6rzGi48Axfz3UevW1HaRAzdDcSzMKTXsI-iVHYYLtirTMLM2KPOgv-f9tzOAfMSLyArflD4jh_HLbp0C43Lg7_Ly3rN9aDb-8sMp6bMqow2dPILshE_uRPB4Vb7R4AlRRDJ8dl45w.LGMTqUDvnZQK0s1xfbWGqA',
            location: 'Bengaluru',
            isProduction: true,
            latitude: 13.02868,
            longitude: 77.58952,
            // latitude: 25.204849243164062,//dubai
            // longitude: 55.2704849243164062,//dubai
            clientGuid: '528a7d439df44f2b9457342b7b865be2',
            indexName: 'hitechnology.20250821.105326',
            visitId: '01e283c9-841b-4349-9d2d-39863fb3daed',
            visitorId: '2b0a8996-a55e-4bdd-b4a7-3f85cae22bd6',
            searchApiUrl: 'https://searchapi-dev.hawksearch.net/api/v2',
            baseApiUrl: 'https://api-live.eazylife-online.com',
            currencycode: 'INR',
            currencysymbol: "NG9LNQ==",//"د.إ",
            zoneId: '634e5da256ad3fd02bd3feb5',
            timezone: '2026-02-09T11:14:03Z',
            // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
            //  currencycode: 'AED',//dubai
            // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          );
      }
    }
  }
}
