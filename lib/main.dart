import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'view/chat_screen.dart';
import 'model/chat_message.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service to load saved token
  await ApiService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
