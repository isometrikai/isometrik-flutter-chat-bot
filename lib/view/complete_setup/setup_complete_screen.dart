import 'package:chat_bot/chat_bot.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/utils/utils.dart';

/// Shown after completing the 10-step setup: "You're All Set!".
/// User taps "Let's get started" to return to ChatScreen.
class SetupCompleteScreen extends StatelessWidget {
  final Function(String) onCallback;
  const SetupCompleteScreen({super.key, required this.onCallback});

  static const Color _green = Color(0xFF34C363);
  static const Color _blue = Color(0xFF007AFF);
  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _textMuted = Color(0xFF7085AE);
  static const Color _cardBg = Color(0xFFF5F7FF);

  static const List<String> _capabilities = [
    'Remind you about birthdays & events',
    'Suggest restaurants you\'ll love',
    'Find the best deals for you',
    'Book services at your preferred times',
    'Recommend entertainment options',
    'Help with groceries & shopping',
  ];

  void _onLetsGetStarted(BuildContext context) {
    if (ChatBot.isCompleteSetupShown == true) {
      OrderService().triggerChatDismiss();
    } else {
      onCallback("Data from Screen Complete Setup");
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Centered: checkmark, title, subtitle
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'You\'re All Set!',
                  style: AppTextStyles.heading(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: _textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'I now understand your preferences and I\'m ready to assist you with personalised recommendations!!',
                    style: AppTextStyles.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: _textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Card: What I can do for you
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What I can do for you:',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._capabilities.map(
                      (text) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: _textDark,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                text,
                                style: AppTextStyles.body(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                  color: _textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 1),
            // Let's get started button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Material(
                  color: _blue,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _onLetsGetStarted(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        'Let\'s get started',
                        style: AppTextStyles.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
