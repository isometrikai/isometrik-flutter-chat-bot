import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../model/mygpts_model.dart';
import 'chat_screen.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {

  static const platform = MethodChannel('chat_bot_channel');

  final List<String> tagLines = [
    "Building your personalized chat experience...",
    "Loading your smart conversation space...",
    "Tailoring your chat journey just for you...",
    "Configuring the chat that gets you...",
    "Preparing your next-level conversation..."
  ];

  int currentIndex = 0;
  Timer? _timer;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTagLineRotation();
    _loadChatbotData();
  }

  void _startTagLineRotation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % tagLines.length;
      });
    });
  }

  Future<void> _loadChatbotData() async {
    try {
      await ApiService.initialize();
      final chatbotData = await ApiService.getChatbotData();

      if (chatbotData != null && mounted) {
        // Calculate minimum time for one complete tagline cycle
        final minDuration = Duration(milliseconds: tagLines.length * 1500);
        final elapsed = DateTime.now().difference(_startTime);
        
        // Wait for remaining time if needed to complete at least one cycle
        if (elapsed < minDuration) {
          await Future.delayed(minDuration - elapsed);
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ChatScreen(chatbotData: chatbotData),
            ),
          );
        }
      }else {
        print('Failed to load chatbot data');
        _showTimeoutAlert();
      }
    } catch (e) {
      print('Error initializing chatbot: $e');
      if (mounted) {
        // Check if it's a timeout error
        if (e.toString().contains(
            "Something went wrong")) {
          _showTimeoutAlert();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load chatbot data: $e'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => _loadChatbotData(),
              ),
            ),
          );
        }
      }
    }
  }

  void _showTimeoutAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Something went wrong please try again latter'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                // Navigator.of(context).pop(); // Close launch screen
                await platform.invokeMethod('dismissChat');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(27, 27, 27, 1),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Text(
              tagLines[currentIndex],
              key: ValueKey<String>(tagLines[currentIndex]),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
