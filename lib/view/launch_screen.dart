import 'dart:async';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/launch/launch_bloc.dart';
import 'package:chat_bot/bloc/launch/launch_event.dart';
import 'package:chat_bot/bloc/launch/launch_state.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
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
  late final LaunchBloc _bloc;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTagLineRotation();
    _bloc = LaunchBloc();
    _bloc.add(const LaunchRequested());
  }

  void _startTagLineRotation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % tagLines.length;
      });
    });
  }

  Future<void> _navigateWhenReady(LaunchSuccess success) async {
    final minDuration = Duration(milliseconds: tagLines.length * 1500);
    final elapsed = DateTime.now().difference(_startTime);
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ChatBloc()),
            BlocProvider(create: (context) => CartBloc()),
          ],
          child: ChatScreen(
            chatbotData: success.chatbotData,
            greetingData: success.greetingData,
          ),
        ),
      ),
    );
  }

  void _showTimeoutAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Something went wrong please try again later'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigator.of(context).pop(); // Close launch screen
                // await platform.invokeMethod('dismissChat');
                OrderService().triggerChatDismiss();
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
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<LaunchBloc, LaunchState>(
        listener: (context, state) {
          if (state is LaunchFailure) {
            // Always show the blocking alert for launch failures
            _showTimeoutAlert();
          } else if (state is LaunchSuccess) {
            _navigateWhenReady(state);
          }
        },
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: const Color(0xFF1B1B1B),
            body: Container(
              color: const Color(0xFF1B1B1B),
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
          ),
        ),
      ),
    );
  }
}
