import 'package:chat_bot/view/chat_screen.dart';
import 'package:chat_bot/view/tutorial_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'package:flutter/services.dart';
import 'utils/asset_path.dart';
import 'utils/app_locale.dart';
import 'utils/utility.dart';
import 'utils/app_theme.dart';
import 'dart:async';

Future<void> _bootstrapAndRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await PlatformService.initializeFromPlatform();

  // Utility.getLanguage() (from platform/config) is the source of truth.
  runApp(
    EasyLocalization(
      supportedLocales: AppLocale.supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: AppLocale.locale,
      useOnlyLangCode: true,
      saveLocale: false,
      child: const MyApp(),
    ),
  );
}

void main() async {
  // AssetPath.isPackageMode = true; // Set to true for package mode, false for normal project
  await _bootstrapAndRun();
}

@pragma('vm:entry-point')
void chatMain() async {
  AssetPath.isPackageMode = true;
  print('STEP 2');
  await _bootstrapAndRun();
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('chat_bot/orders');
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('STEP 1');
    Utility.setCurrentContext(context);

    // Keep EasyLocalization in sync with Utility.getLanguage().
    final appLocale = AppLocale.locale;
    if (context.locale != appLocale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.setLocale(appLocale);
        }
      });
    }

    return MaterialApp(
      title: 'Chat Bot',
      navigatorKey: kNavigatorKey,
      locale: appLocale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // Apply RTL/LTR to the whole app (all routes: chat, profile, cart, …).
      builder: (context, child) {
        return Directionality(
          textDirection: AppLocale.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ChatBloc()),
          BlocProvider(create: (context) => CartBloc()),
        ],
        child: const ChatScreen(), //TutorialScreen(currentStep: 1, totalSteps: 5),//const ChatScreen(),
      ), //TutorialScreen(currentStep: 1, totalSteps: 5),//TutorialScreen(),//LaunchScreen(),//ChatScreen(),
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
        refreshToken: config['refreshToken'] ?? config['refToken'],
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
        phoneNumber: config['phoneNumber'] ?? '',
        countryCode: config['countryCode'] ?? '',
        language: config['language'] ?? 'en',
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
            userId: "6a82ef76ad6b2e0f5fcdd242",
            name: 'Chetan',
            timestamp: '2025-07-28T12:30:00Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.jmJt0eAsceaCID6TU5r1yPx6SNpzsE-SahRKfW1U3dcHioCAaa_Qrdb8oSVoGgcr-0kop7zy1sPF-xY-sjErZ3mz50_yv-cC6DyAXIqp7VSk0fHohT5ynUY-_1LteL-F3jHkYeeL4F9tSYNOZCUSCBqXS1OUyebssgroUdFrBNs.HdgBoPRD7R9NDBoV.XwGMNojeCv3eZ4axGy4e9nuDwi-HHRTOd0zIKAzBqeIzfGkacs5kysQ8Dp0L1CYUPYxUtdJlLc7u61-w-toAbOR0Qw4F0inBNNHDZBF8e-QofJqXvO8Q780FJTX38zw1cyGhNSCQp0XiD6Xu9hkkkjaPoUDVnb7xXoE6QxFhVw0F4pqBu3xH5RqcANsctHSHhQ3RYA2XgTWE-O_yxYfgutbFwBt_iIRt7Lb4LHkKz4iu2yu3toixRDAaFBlrPC6ZGWp0ibn15N-sYTwL4OVkeu9gfIW4ZvRn2VUa4jr7RpA9OYfX3b8LX_bLeC9igYZ6KUOih3K5lMOCqlZR1TMMIamNF25G87e9wGCDQbdwn2-2s4Zbd13hmr-SiWGiuKXP76fUZTd1HAtHoe-ERAUkDeG1kNusbTb_GVY1ecJwKBUFrqtK5kZYeN2A7429bvVaM36KXvMU-gybMknW4r7_tdEqaYZw7vfEBuJt4GlXCjLfzeuPpf620Agz1W6oT3atX_YF9XxoWoLys4cjwc9kaJBGVY2xD1hjqyZ121icqhzLILVcZwoiHWb51Lb93Qjec8opZ0CRkUgomuUXTSU-DZBm9Fr9sTH176EQuNOXQB5_jqegdfd2spo8KXjnn4jLJY4Ua_TDcNDCPJ36dzJnXDi6xlif-erhp8Zq0k876bI55peMpCE4HPU6kR_592kZ0Wt7t9ogMEgkLowcNptYnjdg7a8HUIrc9gU-pTQtxcXH-1yMMR0xKbFj6WrRsy8alCpoPpsJH59sscT5fsTti5S6t7bM7gRCgtSJYbBP9Hwbc6FnG-BsrMH35edPWlhCgMhIrztUCioC8idKEFS2IEuLuXZONLV8__bAIHMYAs_CeFymMUJBLhz-r5cV8zbjcp9GN81aPeMkPKrLWCGKO892G-2W9veiJaPmv3BzVmgntnxp3v_ABLfG3xH2BAliWQ1eOmvNj3i-m_thRS3FJdq4_RSIjvI_JdAo5QGtUiVrm9IDtFJB76U3G13gwgD92cN_xD9WJtV-FKyzDOcf82_JHYn99nSD4t7uK8mnT-Hk1UPxxo-j2cjtSPIELnwBMFsevePim-1B2PEMzpAleTsvRc3uYNwTG_NnwWtnkfBnN7qMQA11m-sYieM5ZwvQ5hB7Ket8lx__3pKdtgmS1rTUUZGLWSym4HdsC5HuOe-bk6aD4vCOYdiYPiUBUl54DNcizRdN8xXlgE5-TaB_9BqsAJ_xd3KDgvqt_J8p9wN6W29OLmw7b6ow6FblZOB0HnChWyBH3bSffUgi4sa336DUWHtVC-MombUf8LNKjKI4VoJCaGrcOl3yJ2YueU0iRqqG4l4TqpGRV0Jc-9pX3OXKnu5OeTDk2obfplwKowgYkgdrbRiXRz8KPHp_F1S0PG_HFo-RKXcK_1f-abofm50CC97n7fcLwb_Z0t9ughpqLsjU1mB0Om9LhwYeA1x57AD_M7Ex7QHQd145p9FIlzO2B-EPOHIhbd38cQAjPru37znoWH_OJWeQmFgd2Eyyirw5Ucse6_fsi24m-GBaaFsps8vJYL_2x_QUiKDhBNOIByw-tCCZ8a7fwOGJkrITiBf2X9CTy1BoCcEMT0bNwpXuEyW82N-mJCXT7wNUAP7HBeByLokkUGd0KnfvV2hRFC4tix7fOSjdavIVnZHKVwBkom1WQ5BHIx-wEXf-jMFYB5FA8kOAyCZmHkk-aCXDdSpl1ofqTcuugO5agp2kKFJeFG7mqkvjsYWRewhCHECa1OefPtpVHaxn5WSrrBVHwiWV4qvNx1ICjKnfGe1AL1j9kYP1ulErGuh3siNN4tnkmaSkl5u2Wj47ueYoRa3xm14jPw0MmM6QkySOcfqRQAL6e6F9fj6ZOj9xi9kxxDmov_V-Z3SGPDmxOt5u_CazbhPkdZHfQe3pQCyG9cJwz87ANl7VwVT7QVHTuRcAdTTK1ia80CZxymyMiP5Sg17W_Qf9O9I85Ib-1cF9dhaSe6sqn0GFXHAtvzKP0gf6OM_3y7p5lyYaRopc_vw76W9SLsip5Z3B90DZemHg7blvPtN5taunz14GJ2nluEv2Ioti3-4V8x2GIy74ycM7sxCl5rx87Q.gacsm-G5kBVa-bgEOQTl-w',
            location: 'Dubai',
            isProduction: false,
            // latitude: 13.02868,
            // longitude: 77.58952,
            latitude: 25.204849243164062,//dubai
            longitude: 55.2704849243164062,//dubai
            clientGuid: '528a7d439df44f2b9457342b7b865be2',
            indexName: 'hitechnology.20260806.044937',
            visitId: '3c6b9339-c602-4af9-b454-0ec0df067181',
            visitorId: '47daf829-b5df-4358-83ea-207aa4eaae15',
            searchApiUrl: 'https://searchapi-dev.hawksearch.net/api/v2',
            baseApiUrl: 'https://api-stage.eazylife-online.com',
            // currencycode: 'INR',//'AED',
            // currencysymbol: '4oK5',//"2K8u2KU=",//"د.إ",
            // zoneId: '634e5da256ad3fd02bd3feb5',
            timezone: 'Asia/Kolkata',
            platform: '1',
            personalization: true,
            emailId: 'chintu@gmail.com',
            phoneNumber: '9988765433',
            countryCode: '91',
            zoneId: '636dfc8c89b6a857b500ccd1',//dubai
             currencycode: 'AED',//dubai
            currencysymbol: "2K8u2KU=",//"د.إ",//dubai
            language: 'en',
          );
          
// in bottom need to set production data for testing
          // ApiService.configure(
          //   chatBotId: '1476',
          //   appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
          //   licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
          //   userId: "697c887549ce2251cb66c9e2",
          //   name: 'Chetan',
          // timestamp: '2026-01-30T11:54:41Z',
          //   userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.QrzWhV1oB03-Rep444w8DsX_KvsyAZb0W_OoFeJ2D33Lm26ZVafbUB-TNck9EVgBP4C28-qr4vm2y_PnlVIx_oJskwG8pqKWgIl51pENIaAODUuG1UQlSClmg0UH6GX1DpRc9OEaVESSjrnCyChQ5pT7hG44yquRZpd9ZEOv78E.zH1E8QfouB98kAyw.W3Ecbwa235J_pQ2U_2hKsDChtm3DeaA1Y3uT_1cMZltI-me-uXy1zxVIa2_TOU9VxT_UKDC3GGpC20wGjhm8f21pwhJmGQ-fRn23Bk_Up5ZIuXVrjbXX02o_oSqFeD8Yln_Imf97Q_w-ql7oZd3oWfoRN4PouetL_zh_P92rOGR6x5eg-GtXXYsixudIph1Y09__-aIfBHNXGzM2X_05YBW3SfvuNn52vhwa9JdmwqyO6TppoCQ-OJ3q9v9kfRdfWVqIyjjYM4l3h6N1KoB75rNsoCl2fAwN22hltfvzKQKcpbdHSlII5zhOi9sKi_og_gRHkY5UGkCLLpJbarefS7-cIz6qaGO0oQqnf_2I_aRxRYeXS3JgeqZeDlwhn5LbmURSbju8PG6JHRrihVS6vBzHDX7SAKoeOVK6GsF51K2X0XYjEZ3KUuj7s2f4hFNGndcA20y2N_lc_GkEEOcz7TRQ8SkMZnrJBtcIk7Pkt8KW4M7GrvAMW5X_KRkQrpI596geB_Va2usKp5_LlIxDhFfAbnjK3rYDVhIiGxvkordhLKYul0QfSx5V-9uKmn_lX8JyqF5E4hZiFA83_uXnhafKohOfICBrIdbZE0orucdJ2bAp2FEWCczQExyY0qX6gHqkvfewSeFshM3u3SOYwQMrrDEG9Y3xrE283gkKM0PI1OJwv7Y2xAZY0c2krO8OeCPixZalBUY74rCHDCw8AZCUXFJViRSgGZ4sB4Ab6qIhqNZTsN3sypoM_dtN6EU11KGcqQjT0vTYt333ozevbCJ3SV7RbI4pYBIgzTSALk2nOE3-cjUT4GKKmvoniKpziWrKWha250Q_B7_nzwPYqVjqiwAZWPRvtsNMFL795togxhWZhV6-WXptgDpvyxKrWjDf49Yg-yD5j0rNNMS45Cer9SVB0WD5aae-By9zH3fM2Pwbm4Keep9ExFdIilWEZwaWhbpFpmDi1ugz_IGlDCTXMw0kJKdKpRIofGqSL31TbIn_S_7EIYr7pskuwgCSS8GbNcd3p9YJQKFTx6e2nusg1E2JL10V6tGc8JgcAFEIUNQXtvm2f3fOhJbdToLjd9eJ4a0sMxPludTZPqBHJ6xO1wBoXiWUwdtRpvfSyulSSBKGFkaYEV1DXviZqro0XauNBEoSvmQ-nUN_-yn_nPJA4SJ_7v0f3dmvcFBzMU_AX2N5fMzxfBZT1rxNgN01wASbEmOUSO3olbSypkAEB2IS9AMcBXMLb20I6fwRTAZg4wp96IkCS6OWlduuCjKklFxDcEuG6pDdRo5Dw135UWKNP3WvDNgEKi0uf_nHdlGspV-Zhgeu60jU5CTaQvmnX5Oh3k1hmec8-x2TS4IvMJ-HfSygGOapn94-Sz9yooCLyDKaDGU8qpyah0P-Dvpbt9h9s9PsFWw6eMnknQ0W1C-dtHbqlDmjO2g22mRS75Oj_dRem4ZPRkWJBVsnsljoGw3tVrqdurpZ0oXpyk4h5ZEdMfsOxnx_WST9gfxbG54-ya6HKzkUZKrjzZGfUftCK4pX7WHD2wvELteiWGwzdKlffR5WZccBdeW_dvuk7PxfWZu0vacEaadxBQXDb_uNeB_OFjS-UTq1M0xVJmcOe9KEfo2T0M2IQs-wQE7k-_8XKRYPE_mGGkJUBH7H46ghIjAr3emzzN1cSmo3aG51MuV9JgwhjnU9-agQAgL_wFUWeeoJixbfZpZvd9a3SNAz5lm_RwMdemCYB2eP15Vke8wK5Oi1RqwmhkTrRBTE53A2kuaBqzYxBTQ7g1Hkg7pP.zkTn2YLz7GWLoinpq-V5-w',
          //   // location: 'Banglore',
          // location: 'Bengaluru, Karnataka, India',
          //   isProduction: true,
          //   latitude: 13.02868,
          //   longitude: 77.58952,
          //   // latitude: 25.204849243164062,//dubai
          //   // longitude: 55.2704849243164062,//dubai
          //   clientGuid: '528a7d439df44f2b9457342b7b865be2',
          //   indexName: 'hitechnology.20250821.105326',
          //   visitId: '01e283c9-841b-4349-9d2d-39863fb3daed',
          //   visitorId: '2b0a8996-a55e-4bdd-b4a7-3f85cae22bd6',
          //   searchApiUrl: 'https://searchapi-dev.hawksearch.net/api/v2',
          //   baseApiUrl: 'https://api-live.eazylife-online.com',
          //   currencycode: 'INR',
          //   currencysymbol: "NG9LNQ==",//"د.إ",
          //   zoneId: '634e5da256ad3fd02bd3feb5',
          //   timezone: 'Asia/Kolkata',
          //   platform: '1',
          //   personalization: true,
          //   emailId: 'chintu@gmail.com',
          //   // zoneId: '636dfc8c89b6a857b500ccd1',//dubai
          //   //  currencycode: 'AED',//dubai
          //   // currencysymbol: "2K8u2KU=",//"د.إ",//dubai
          // );

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
