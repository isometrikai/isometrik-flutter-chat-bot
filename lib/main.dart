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
            userId: "68c129ebbdaeb6000f7ed53c",
            name: 'Chintu',
            timestamp: '2026-02-26T12:30:00Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.S4Y82iGkjhSrk74p8kFbsFQ6r8tm9QAJEV2Cgblr4qOtKLVfToQQg_WHIsbxIIfrRfczg_0PEYJfa6LhtXrPQZd-jLVKLfOsQtH2vB1w2BVL2WBoI5bselzR0TSXPlhQbONhrp9kCAYr-1nuVl3FLB8hhzAzmprVdrslGXmUTI0.hajqN5YRYsDPnVP1.OclS8MhxO5F3o524K5vyauY0CE6MSU_GE0Zq2qVxX46Jgaz--hztjU3MxIZZKJxcw9Dz7G4WEg4h_-qXHkA338DbSCmJtHDV4i5SZkTXf3XyYLjrrpFdGXxLJadE4iuAzaCu1095TVsceAsg065bZe-dh-aLwFBiWbA5eRLEn1QFyaAkvR1lHNXyUWEanu09W7Z0kOZPsDHvx6W5VBI4ALKGuobEDzWdLnxHmWRA4DKixzbg8cw3fIziE_b4yIuMTwc1BYHyL6kqyewMoQ0JsabXBorbsybhGcSuZ0TQDFBx2Lt80SWIzHm9YAdzVPf7xEizy_XJiV3Ind33WHHARN5gJTPH3WCVIdn164PEF4AY9x7i5vxJHTlcK30qvNHgwIbNDbZZYv7vBPER3DSCz65Y8OGU0RiPDxv8_xeDPKuvOJwa9JHbDAUQ1DnVHDEOwgWzhnKYBkS31deIazb8_6eTaBGhRB-VrFyzXzOl8wxQT1wBVLvLYlrIIjl5Q_WL-bRiSnPLvD1Dcrka5Jc87fikCXxfh0obajHh2VoMGEhwVi9TEcMyFdOvAlEHRdJ90hvQxLV_6jXaNGwUlqcBHzoN7BwU6znmx9qNDAc1kiFgE5C7Cdirqq37v58QHLsg9QFy4JF-6YhSCkaI36Km38JvUi8XO3f718jOM-SyBoIW-StB4HdP-DOK1xPZATtoVxapzYJkFE8W2P-apxgAxAKkuPVoo7nR2h2UqTX0OMvhWxxMNpVqNgBtQ4wMShcBQbpNl2lkSOHr6267VXddKysj03X4a9zyLX-blp0W1438L_sZ_WVCLptvOTp7I-3yYfmuIB4U46Phg38zONSqIOGIgW5oDmJ87uzccPgZjUTwnZvh8IUaH7q1F_MagwFgCB1GmIFo9UnaluUPx4w2WcC4p6XGRXHVe_uT-cFHmPqiKZag2CSt-m-4bnkVl0ZRtcN2Vv13RL7SpaKN3_44T-w7nkZgkr-011WQi4NAlToryvMLohfH-xoqkJER4t21vDe5ZefiDg0Y2WaG0sNNOzpe95N6qGhYMkbAIDGiWKuZ-XhWZ38jCB4tS1Sg3jj4ToWfgY1-fnq448aylGDXM21_8uxToA3se_rCEkTkTeUoLngtRqDcU70ygyVeP154KaC-UANhPsGvcc8UJJyxGdFZcBrcK2WXZizFbvfBe1KpI8490F5wNbHxOJaLqDsA8h4xIIi87e_grUmrmJqU5XCCjBPctp5cpZR2lUPleY1pMWsGQuW0HVe1F7U1kKS3sCPyO6POSrX6ERHGUL3shBsXd67i8B-cVRi8yLiaq5KdaAPEEVigWNWD-3TroyqGKy2c0sWQ_Smul29GShkt8-_rvilDoMz78Vu5L_AAAUUJel-3U-BkTxUKNlcvhJx9x3x-glkdb4SVfVXKaN-GD_hY6UYWcDi6UL3ODDVBfjdG7X9dEKmOdz3PjlgHq6NjV3hOR7N33_lyqawLUiXKP6pugBgZcWJ-iPlVtgq_kg3kuQgH2wY5UqxdsToaVQhRqfTjYlqwfSP-cSI33d9gbzuM90XHSIiSSuZiqXBoSWnHYgjMJf4jCFFNVUnUh2UzAdV8EbZYWqUW6qHbb5zJ8xhgVE-JaavE-HbnK1e9Xa_BmqHTj92MSBBwWxpQMmTk9RGs5OJRJ2X1XS3alYfs4eZFGV80c4Tv95vWuP-VqvAb8kkLmhoWJYO4ucLBZRF4dXYGSFXrYIZWV77jqB9-_6mGOqeoeFBWdlbRiOv9e6naoLil1A.7Bh6bP1h6_6Sw9vtCtWxcg',
            // location: 'Banglore',
            location: 'Dubai',
            isProduction: false,
            // latitude: 13.02868,
            // longitude: 77.58952,
            latitude: 25.204849243164062,//dubai
            longitude: 55.2704849243164062,//dubai
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
