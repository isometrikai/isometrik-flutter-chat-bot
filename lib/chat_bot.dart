library chat_bot;

import 'package:chat_bot/view/complete_setup/complete_setup_flow_screen.dart';
import 'package:chat_bot/view/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'view/chat_screen.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'utils/utility.dart';

export 'view/launch_screen.dart';
export 'view/chat_screen.dart';
export 'data/model/mygpts_model.dart';
export 'services/api_service.dart';

class ChatBot {
  static bool isTutorialShown = false;
  static bool isCompleteSetupShown = false;

  static void configure({
    required String chatBotId,
    required String appSecret,
    required String licenseKey,
    required bool isProduction,
    required String userId,
    required String name,
    required String timestamp,
    required String userToken,
    required String location,
    required double longitude,
    required double latitude,
    required bool needToShowTutorial,
    required bool needToShowCompleteSetup,
    required String clientGuid,
    required String indexName,
    required String visitId,
    required String visitorId,
    required String searchApiUrl,
    required String baseApiUrl,
    required String currencycode,
    required String currencysymbol,
    required String zoneId,
    required String timezone,
    required String platform,
  }) {
    print('chatBotId: $chatBotId');
    print('appSecret: $appSecret');
    print('licenseKey: $licenseKey');
    print('isProduction: $isProduction');
    print('userId: $userId');
    print('name: $name');
    print('timestamp: $timestamp');
    print('userToken: $userToken');
    print('location: $location');
    print('longitude: $longitude');
    print('latitude: $latitude');
    print('needToShowTutorial: $needToShowTutorial');
    print('needToShowCompleteSetup: $needToShowCompleteSetup');
    print('clientGuid: $clientGuid');
    print('indexName: $indexName');
    print('visitId: $visitId');
    print('visitorId: $visitorId');
    print('searchApiUrl: $searchApiUrl');
    print('baseApiUrl: $baseApiUrl');
    print('currencycode: $currencycode');
    print('currencysymbol: $currencysymbol');
    print('zoneId: $zoneId');
    print('timezone: $timezone');
    print('platform: $platform');
    isTutorialShown = needToShowTutorial;
    isCompleteSetupShown = needToShowCompleteSetup;
    ApiService.configure(
      chatBotId: chatBotId,
      appSecret: appSecret,
      licenseKey: licenseKey,
      isProduction: isProduction,
      userId: userId,
      name: name,
      timestamp: timestamp,
      userToken: userToken,
      location: location,
      longitude: longitude,
      latitude: latitude,
        needToShowTutorial:needToShowTutorial,
        needToShowCompleteSetup:needToShowCompleteSetup,
      clientGuid: clientGuid,
      indexName: indexName,
      visitId: visitId,
      visitorId: visitorId,
      searchApiUrl: searchApiUrl,
      baseApiUrl: baseApiUrl,
      currencycode: currencycode,
      currencysymbol: currencysymbol,
      zoneId: zoneId,
      timezone: timezone,
      platform: platform,
    );
  }

  static void openChatBot(BuildContext context) async {
    // Set current context for fallback when navigator key is not available
    Utility.setCurrentContext(context);
    if (isTutorialShown == true) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const TutorialScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }else if (isCompleteSetupShown == true) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              CompleteSetupFlowScreen(onCallback: (data) {
                print('Data from Complete Setup Flow Screen: $data');
              }),
        ),
      );
    } else {
     Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => ChatBloc()),
              BlocProvider(create: (context) => CartBloc()),
            ],
            child: const ChatScreen(),
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const TutorialScreen()),
    //   );

//  Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MultiBlocProvider(
//             providers: [
//               BlocProvider(create: (context) => ChatBloc()),
//               BlocProvider(create: (context) => CartBloc()),
//             ],
//             child: const ChatScreen(),
//           ),
//         ),
//       );
  static void isCartUpdate(dynamic cartData) {// CHANGE CALLBACK
    print('ChatBot.isCartUpdate called with cartData: $cartData');
    print('Checking callback status before triggering...');
    print('About to call OrderService().triggerCartUpdate(true)');
    OrderService().triggerCartUpdate(true);
    print('OrderService().triggerCartUpdate(true) completed');
    
    // Send message to chat after cart update
    print('Sending message to chat after cart update...');
    OrderService().triggerSendMessage("I have updated the cart");
    print('Message sent to chat');
  }

  static void openStripePayment(String cartNumber) {
    print('openStripePayment: $cartNumber');
    OrderService().triggerStripePayment(cartNumber);
  }

  static void openAddressSummary(String addressSummary) {
    print('openAddressSummary: $addressSummary');
    OrderService().triggerAddressSummary(addressSummary);
  }

  static void openScheduledLaterScreen(Map<String, dynamic> obj) {
    print('openScheduledLaterScreen: $obj');
    OrderService().triggerSelectSchedule(obj);
  }

  static void openSelectStaffScreen(Map<String, dynamic> obj) {
    print('openSelectStaffScreen: $obj');
    OrderService().triggerSelectStaff(obj);
  }

  static void openPrescriptionScreen(Map<String, dynamic> prescription) {
    print('openPrescriptionScreen');
    OrderService().triggerPrescriptionScreen(prescription);
  }

  static void openStripePlaceOrderScreen(Map<String, dynamic> stripePlaceOrder) {
    print('openStripePlaceOrderScreen: $stripePlaceOrder');
    OrderService().triggerStripePlaceOrder(stripePlaceOrder);
  }

  static void openClickManageScreen(Map<String, dynamic> clickManage) {// Data Received 
    print('openClickManageScreen: $clickManage');
    OrderService().triggerClickManageScreen(clickManage);
  }
}
