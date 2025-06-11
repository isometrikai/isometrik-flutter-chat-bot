import 'package:chat_bot/view/launch_screen.dart';
import 'package:flutter/material.dart';
import 'model/chat_response.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'view/chat_screen.dart';
import 'model/chat_message.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('chat_bot/orders');
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up callbacks when app initializes
    _setupCallbacks();
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  LaunchScreen(),//ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
  void _setupCallbacks() {
    OrderService().setProductCallback((Product product) {
      _sendEventToiOS(product.toJson(), 'product');
    });
    
    OrderService().setStoreCallback((Store store) {
      _sendEventToiOS(store.toJson(), 'store');
    });
  }
  Future<void> _sendEventToiOS(Map<String, dynamic> orderData, String type) async {
    try {
      await platform.invokeMethod('handleOrder', {
        'type': type,
        'data': orderData,
      });
    } catch (e) {
      print('Failed to send order to iOS: $e');
    }
  }
}
