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
        personalization: config['personalization'] ?? false,
        emailId: config['emailId'] ?? '',
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
          //   userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.Mc2TdWuyXG2EF1qps_QnLTPpBWtzopsKFKWqYCl2v82uWhmxmVfqoydKfaMIKd8gJ0LIOdL_rKsfs3nSYZBDVL0qtB8JLXXJXfOoFT80N_GDyaomHj0SmKuvn3kUVu5bdOEoV2x9fMJQ-WO1qfa3yqrzRy6wKWCVMhmF94034FE.34xZcD6eKXr9oh_D.JfTfiXWZTFZ2iC6jIkwCVb7dKSsM5u4qe4hTw6h_PoFA9elTBXHY5nuwjhlooT941goc9yTH-Ri68DQbwMG384fd1NV4mxN_Ok19nSn_akv_LvacnIsXqVQNifK-OvmOzcSdXohZnrdOAP9Vbx4nyKs_yiQcjE3zKQnzegUQ5sm9xZTs7amPCJibnzEyiWvtwJIbRqP09t3JwVff3y4ZxWDrX4ivKI32_3rQtrjo3NBIEXuvsJUfaISjvF93a1qet9dx9GFjV88nQ57Z76RULjN53Z4guRjPsmioVavVSoyHqTnw4g9hzYDT6kxphYaygSuvBlLa2qbZ58Jo5afw0Wb-XCSO2K6_9OpdrC6D85uGSB8Vzc83yZk-QcqnkbTxWug61AtbHOLjJf1cStYQMBaXJ0of3KM0y2dMNtU_kmJQ_G_GXwHJvIU0M2su3ZfV2VLpNf9MCjzgtG6QKYDVoKYXrTrTBgfk2gAbBDicL1JV-G2qg0nLIKdAkJR8_e5STP6S1Je5i33Cy51uTPI3rnRSK5dNT7iZc0wK1QgCo1RoGomns1loR_2p_7vzhi6jX0z1BgYJwMYhxCCmSJw4LfV7JIAabh1EFg5HrroiLsHs2znwF6DGcYZzKVwOm0FL_1llVMlH-6YltIGOMvWErJHAE2NrWKLNpIBWlfTfSCw2qNDlaDV-xTuQg8EVFj34btofSmZHq7FlH6hWigYBw17NMFI8ea7Swck5-kJXeq2meOgFlsk5Y_4mYSc54znNASg3oLv33fG5hqoxxr1TV3o6zXMOl3Y1COFSBwokoV8hc7XVxg4hxcnHzzap7x7VT362zd8nnzma9C1keHFqFu-JP8Qcb7DqnRQCRsFfzzeIFwvdke-LT9GUO-eMH4hGYMuTZtIbJpkvIZG7GbBeM7biYqpPAiM-IuAOFv4qkAtHAHnC3B8Yd8saoqoB1lJcWlXQ7if-QQd_07eowZmm14jJdj0I8aUY2QhxyeQ_B1AX71714-8DDawxizkJ_QOfFD2q2uGwooBnlYaUfdVSET28hrqDRUy0-RdXD-GjEtqayOarSaSlTPIOu6T-4kb1DEDL1-yA1BcfPbtUhHdjAQB6RNo5LFNL8sIu7pKVDKprOIrxMdfE8zkjjUhwzciLP63FXAoHc39hlaNt6Mi_WpASXhvEeAIvA5CNKyD1jMbZcMpixZBEf-p-j1S-JVvg9SwyqOzm5182ipoFQZ7hD6fyANu8WqBWqcQzrALo-lD5Y2toUp23XjW552iOs_eRmBMKVSKZPIylEsjgZdiP5SRUvVs-qQRQO7kOObZNBVvGToXO-fKANbwbODucd_2vvB3WjTW9SDo5ndGCq4vQuzgF-NpgJTSYoE1lKZmDtEwQQA534FaSNvUA0SDplvz0US-UlsLJC2I0m-XuNdP9KB9ReOSuTC2qQxY13Q2DjPwdiD7KTcpAXE7_KitX6jZqmUlsIgEcKlmqY7GX9TrEd84s3Aj4B4tm3V3hU3vhlFzl0H-SmdsfiICZBZxFYY5jWaS_kblppmtT0so4P1cpjP5i4T78otinDiBME7VmoVz4D1YmgRDY6qWisJ23VG2iKe5hag1z_8doMCjn3b5ce3BaDyhcwXGEiEbhhWH-xgQDhelGFg5_IgPYztP-xcsAIrTsj2xMwyE4YE7ASF73hNvDR_Cux50EZXQFnnA85t7PrCQUFkdFr-vrLhwAyjq87foU5KpXdYBA9d10lBiYYkVRVCrpfVX8vsWNKy6eJWlf_kjfqIn5.vtfD3y3fAiC4YV9Uf6QyGg',
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
          //   platform: '1',
          //   personalization: true,
          //   emailId: 'chintu@gmail.com',
          //   // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
          //   //  currencycode: 'AED',//dubai
          //   // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          // );
          
// in bottom need to set production data for testing
          ApiService.configure(
            chatBotId: '1476',
            appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
            licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
            userId: "697c887549ce2251cb66c9e2",
            name: 'Chetan',
          timestamp: '2026-01-30T11:54:41Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.QrzWhV1oB03-Rep444w8DsX_KvsyAZb0W_OoFeJ2D33Lm26ZVafbUB-TNck9EVgBP4C28-qr4vm2y_PnlVIx_oJskwG8pqKWgIl51pENIaAODUuG1UQlSClmg0UH6GX1DpRc9OEaVESSjrnCyChQ5pT7hG44yquRZpd9ZEOv78E.zH1E8QfouB98kAyw.W3Ecbwa235J_pQ2U_2hKsDChtm3DeaA1Y3uT_1cMZltI-me-uXy1zxVIa2_TOU9VxT_UKDC3GGpC20wGjhm8f21pwhJmGQ-fRn23Bk_Up5ZIuXVrjbXX02o_oSqFeD8Yln_Imf97Q_w-ql7oZd3oWfoRN4PouetL_zh_P92rOGR6x5eg-GtXXYsixudIph1Y09__-aIfBHNXGzM2X_05YBW3SfvuNn52vhwa9JdmwqyO6TppoCQ-OJ3q9v9kfRdfWVqIyjjYM4l3h6N1KoB75rNsoCl2fAwN22hltfvzKQKcpbdHSlII5zhOi9sKi_og_gRHkY5UGkCLLpJbarefS7-cIz6qaGO0oQqnf_2I_aRxRYeXS3JgeqZeDlwhn5LbmURSbju8PG6JHRrihVS6vBzHDX7SAKoeOVK6GsF51K2X0XYjEZ3KUuj7s2f4hFNGndcA20y2N_lc_GkEEOcz7TRQ8SkMZnrJBtcIk7Pkt8KW4M7GrvAMW5X_KRkQrpI596geB_Va2usKp5_LlIxDhFfAbnjK3rYDVhIiGxvkordhLKYul0QfSx5V-9uKmn_lX8JyqF5E4hZiFA83_uXnhafKohOfICBrIdbZE0orucdJ2bAp2FEWCczQExyY0qX6gHqkvfewSeFshM3u3SOYwQMrrDEG9Y3xrE283gkKM0PI1OJwv7Y2xAZY0c2krO8OeCPixZalBUY74rCHDCw8AZCUXFJViRSgGZ4sB4Ab6qIhqNZTsN3sypoM_dtN6EU11KGcqQjT0vTYt333ozevbCJ3SV7RbI4pYBIgzTSALk2nOE3-cjUT4GKKmvoniKpziWrKWha250Q_B7_nzwPYqVjqiwAZWPRvtsNMFL795togxhWZhV6-WXptgDpvyxKrWjDf49Yg-yD5j0rNNMS45Cer9SVB0WD5aae-By9zH3fM2Pwbm4Keep9ExFdIilWEZwaWhbpFpmDi1ugz_IGlDCTXMw0kJKdKpRIofGqSL31TbIn_S_7EIYr7pskuwgCSS8GbNcd3p9YJQKFTx6e2nusg1E2JL10V6tGc8JgcAFEIUNQXtvm2f3fOhJbdToLjd9eJ4a0sMxPludTZPqBHJ6xO1wBoXiWUwdtRpvfSyulSSBKGFkaYEV1DXviZqro0XauNBEoSvmQ-nUN_-yn_nPJA4SJ_7v0f3dmvcFBzMU_AX2N5fMzxfBZT1rxNgN01wASbEmOUSO3olbSypkAEB2IS9AMcBXMLb20I6fwRTAZg4wp96IkCS6OWlduuCjKklFxDcEuG6pDdRo5Dw135UWKNP3WvDNgEKi0uf_nHdlGspV-Zhgeu60jU5CTaQvmnX5Oh3k1hmec8-x2TS4IvMJ-HfSygGOapn94-Sz9yooCLyDKaDGU8qpyah0P-Dvpbt9h9s9PsFWw6eMnknQ0W1C-dtHbqlDmjO2g22mRS75Oj_dRem4ZPRkWJBVsnsljoGw3tVrqdurpZ0oXpyk4h5ZEdMfsOxnx_WST9gfxbG54-ya6HKzkUZKrjzZGfUftCK4pX7WHD2wvELteiWGwzdKlffR5WZccBdeW_dvuk7PxfWZu0vacEaadxBQXDb_uNeB_OFjS-UTq1M0xVJmcOe9KEfo2T0M2IQs-wQE7k-_8XKRYPE_mGGkJUBH7H46ghIjAr3emzzN1cSmo3aG51MuV9JgwhjnU9-agQAgL_wFUWeeoJixbfZpZvd9a3SNAz5lm_RwMdemCYB2eP15Vke8wK5Oi1RqwmhkTrRBTE53A2kuaBqzYxBTQ7g1Hkg7pP.zkTn2YLz7GWLoinpq-V5-w',
            // location: 'Banglore',
          location: 'Bengaluru, Karnataka, India',
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
            timezone: 'Asia/Kolkata',
            platform: '1',
            personalization: true,
            emailId: 'chintu@gmail.com',
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
