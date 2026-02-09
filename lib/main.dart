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
        platform: config['platform'] ?? 0,
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
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.FT9SXfrlCo6c7FNkTPTFNPkd6Tn9iDZ6yVIjWtSIVqlw9ptF8Bp56XUNRRPYObMyidJiSKL7KURpIKLbP3NnPSdrk-QKf5VqFq04Lfr4K6zk2WNgXD_pXnEaNI254yltNdQBWZuOGnhfNBjsYVOfn2DiOyXmE5zMGq64oN-Fcq4.YuDWHaf7NOhGh775.08mXtVo7FToHIslicBrPKF3gq40R-tYTQTQB88jXzx8wr4PxYDldnr4NhL2yTusNWDwNeUt0Hz3ZcuUAsPA63AA2Hl5cwwQNeEF9LmsJL_Na6tpVUZd-c9lP7Ln5LFt92GOxQMmLEuEzFmK7nWheWufXU6d632GVloeQG5BLLed97QPPdi09LWNNjejwYREKJ3T0EPTpJhpFQ7SOm2KO7DHhNsNIBRnYQs-erUV2cVvWfohX1K1La_fbgt43urnAjF0nS-SKuwqL4HfoztA3-4SEOjsh2QDW_dEy9Tvbub7Ci1FgZ18o0S_D6hCXc_y3xMtRWE7hk97IT3Bs42qVPbKEuE7CF5dexlWyFggb1qQdpocQeEiXmmrYdbi6-0GF1wf6KvbXIZgj6roS_xJIeSxR7YI0Vz1mccQIbTqVaaDKVOFtELNTn9AxP1-D_D8unRaixoXZi6GMVt87BDnhxjwdjGq2CTGPgpp5wH5T_L7Xec6PaZJxjkYPDsbVJbWpHpS72jozzFDIik9z-51ktCr-8nBeayO59j2HoeqdrvfaYjsAsBfClKEYmoBAVbRIUv4L0jmC-S5WZWWRgMySijxq4RAytw33zWA__Z3r8Hhq842FqLYyCcH2A1CLQBjQDmpwc4LTmJECcYXQLw52II3-vVY23iu7ppeKmLbJ_0KNpkvwtOaX6Y0EnMr0r9wvLJPAhRkOtwcvpk-VcrFVexKVTzlX5tbbBOoamp5dZy91dFAgn__eXwhdTR8lfQPZbnqZHJJyto87V6mczrEox6jt0rvKWEKcpb3cF6ZUHPKkUOKzgfA-WGcVxnCxuLwjxsfzZPUZv8NxZYqPh4VwcaH6aShrCGb89ajFHBgkoLy2jFBh3w_7C1RHRT2I36NLx8Bl0Qws3u_XQ5pWwLszsqppzh5OTVu1PAUgmv7QvubPwTyCzc-83sJvvbzypJi-CybMIpubiYCvhEiesTEbHIiyzenLWUuHvG6mQaar8rEQ193fZdpwJmpj_aMBbTtwVW-CC5tQiG8lwaW3j0o4As-H7LhNPQtEhsFmBpm3IyHzSqEk-2cOcGFD7gUZiAL-b_4_zvGqSHPcY-hZLW3cGuQ87-BQEMhJRIuTpsTXAIoF4bV6-ZP178PIvO8s4Pg_MDCt_d53O18R9NyGkfV3uaE_mXOWK8Ran5_kBSoybPQb50CSL7u1iYMNbCxuPObVWVqYevG6enUHTRYJfx-vsu3Rt_JVmvRBddXe8mZUM7v7lNTMz7V1yih5f9pB9lgl14dbKCArOXwgAqtPNN7ZyR_OjCa9g5HwYmsIW6NkcpSe6QeDrIBjXwrqpJpLxGETenx-5hP1FVNYX4llvwRgVvezAlKEqihMt9ANsU16M4tfTVj7YqwktvOnnTFM-D1KUP_qYSNM85Q0zNY_u5yEu_9uR2tFcWwe5QxlFqpujsgmn0JaOYMtPPgvtNrb9GQalG3NVlkH5woRrc2o5kuOloOgY7gERVinnkKQ3TKjI0hIOD0iXE25VKnFEFcfMyE6YtGzO3Ej8Bh_KCSlwckGg7_nV_bMkW2qr6Rw5ZJEtb_-NCQ8XBvB1t8_9uC46i7KKeAK2whvu6BgQjN4jFDlabW5lCa-QnEEzuGFclv_xlrgOSbubbrnQPnS03q6er6Jckqi-2n_mlhSFtXBTDfB_ZYCyGy1NL-zAWx2Tms7IDLyja3WUwyLrrw0s7SqE2oc7KJorJ8ILpNyXV5xcphzXDtmb3uZJoJvkKPwacJkAJj4avndUQ.8Xda9S8IsR926Pm43wu_Vg',
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
            platform: 1,
            // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
            //  currencycode: 'AED',//dubai
            // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          );

          // ApiService.configure(
          //   chatBotId: '1476',
          //   appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
          //   licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
          //   userId: "697c887549ce2251cb66c9e2",
          //   name: 'Chetan',
          //   timestamp: '2026-01-30T11:54:41Z',
          //   userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.NrN5ZjSn5hbFgvan8BbGB7fuJB3BccYl4nm9EzDTKEI-FO0Oq4tuehS5lIO7HGwFc_LnP6VEGlnQhczaoW2aZoo-ElvqnfjpXVDP5HukZm5IUMrcI0v2GxwXCmj_HJFAENOgPsSizkon7igzy-yAPq5OvycdIftBnU9DIaKd7Cw.MjLn8kE307RqfiLu.WXksH3TpeqMRYefj-U1stv4pOLrg8wXWGlwo6zUYreK-94mcj9fKQ8HyWIujWrzBD_ttGo1Rk0t_434huvtpDsNZ38kbvjFD0lg5qdsFACcODRiTwhtS6ke6ej9E_iZIzafp17UGbC8C8ulcBdL1iGakmz3JNfhh6Kcuiqt476EWi7UsDlytwIa1gGE2yrObnd2gSznFZMFX4Qz3metof4bRMuf35xb0_DFV9jsEE3EguZ1r9R6FwHjAS-YBZzQXhnZYRT_9rjaxhDZXgBxA_VAFPMosRjK4dThlYMH7MntjuuoX8UkOfxW3WfYLmh7EdxMU23CZTkPib6fj42-iZpJhlsPK6e0ZcewVBqo-lyFGqG04NSBRMFdsbqgLD-HWXhElWqui78AIKy7BJC17hjjUvhYR8ZE_zf2cEM4CUZjjNvE5Mi1I-tAFf_y79Hch0n8yuzN0KR7c-uzqC9GenNIET83Mi8CzegzMzibwnhD14XRloTilCckcmimn_tTcXVEdRMMNG_Xhsmkn4B4v7odCsjPDgg1q8pqZKZWsnBU1tsJqm3t2Qr97Ix35BgLmZQ6kcvoIk0bs6_eUF0CcSsupo-0OPXr4Jpo04a05R_yCMrYo3cmGZ14zJeXbUF5ss7EpvH9UDKxHkW0ib653HhS4nNhkamFeWeDWWYw5pheCQpqNf2RrQTYpiAz7XmlUBFRS1Ex6GhiD8mRBGIQ0A9Y6DQ-zmW1I9vLnhCAvuC53F60krR5T910_JB_-6U_fFD4Lvz44wC-vTh_S0uJLtgzlooKpS12nLUA7x7Qi8edqXHGUqo_cG7K2ghLaSoe-c8SENDZtMEoyujzUrfUEqpyEM5W5gpaWFi5oAVp-BCY0jsTbPf4mdzkWcbIGkZQpKPRctcNyMvTdWVV_R1NW2WvXeAUXt6m98_Gm3_yV0jV625E0mV14sLuF817OJfaUe1bZFcaa2Y5F15vxH7oh-w6UItmTkdKWJwozXkB2M2s6WmqyM4AL0aPMXqDeGoRbaWLdCownPMA5e0Uk8fObC3_QPRYT3RWRZYs8mR5_FviNOqPJiZ6l8WuLEMxJ2522Imb15qxD2mw_7kYSZG1tJerFT74HG5I8iSozr1cBOnDQ9MvUhUkT95lLL_zrJP7yMzQeNaPZa-6aCL6pmp65tebHBg2vFutiKg75j06RIriuf-9jcpvfMXGTv9AbHroFG1otwXnSCSYa_6gAIh2t3K5HoR0IHQms3yr8meYoGh6ty7jbRoMe6MG39mOEQdMM7RiOD02kEiA2w8zOF9Rcwml7Cj8UiTCsGeXWc4-BBIDWTM6HCCpv3oNnlhikVnjr9Blvs_knavoXlfj3fC6LGw008dN39Pd9tqThtLFkJGzEkkKVq3rRqu2ZTL0NvAiLvuEfERGIMasocBjmzFvzdrQHIejB6m_1XImRhDFwyYiywY335vyDUL9bbA5NyioDeKBqvUulen3NE_arpKbdAUDR4_7niQb4daZZMHxxrYKzw8yulqQdcDDptU75iFjSDR0FZEJx_YYHWVV6r59HaskXWNiMTinvLi-I1P2RKzUeElFcJNP4PCU5gMtO4unhs9MEIazqv2tU0tsuxM9PrN9SGjQhQYw-0AzJ_vs6DNVU__VynhJBJRPM3FKtiX46EpoD7h0jtZCFoSZwwUW8vgWuHiO5BYjhT4qEVeoc7PcH5utL_r6m1WEXtb4YxmD2lKJRarlKwe7ltYIB1RTFTu2NQpHsqyIeiw._YeCh8jOnezWOvj7iwfmdw',
          //   location: 'Bengaluru, Karnataka, India',
          //   isProduction: true,
          //   // latitude: 13.028684616088867,//india
          //   // longitude: 77.58952331542969,//india
          //   latitude: 25.204849243164062,//dubai
          //   longitude: 55.2704849243164062,//dubai
          //   clientGuid: '528a7d439df44f2b9457342b7b865be2',
          //   indexName: 'hitechnology.20250821.105326',
          //   visitId: '01e283c9-841b-4349-9d2d-39863fb3daed',
          //   visitorId: '2b0a8996-a55e-4bdd-b4a7-3f85cae22bd6',
          //   searchApiUrl: 'https://searchapi-dev.hawksearch.net/api/v2',
          //   baseApiUrl: 'https://api-live.eazylife-online.com',
          //   currencycode: 'INR',
          //   currencysymbol: "4oK5",//"د.إ",
          //   zoneId: '634e5da256ad3fd02bd3feb5',
          //   timezone: 'Asia/Kolkata',
          //   // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
          //   //  currencycode: 'AED',//dubai
          //   // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          // );
      }
    }
  }
}
