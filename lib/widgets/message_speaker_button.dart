import 'package:chat_bot/services/text_to_speech_service.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:flutter/material.dart';

class MessageSpeakerButton extends StatelessWidget {
  final String messageId;
  final String text;
  final bool isBot;

  const MessageSpeakerButton({
    super.key,
    required this.messageId,
    required this.text,
    required this.isBot,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final textToSpeechService = TextToSpeechService();

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: ValueListenableBuilder<String?>(
        valueListenable: textToSpeechService.speakingMessageId,
        builder: (context, speakingMessageId, _) {
          final isSpeaking = speakingMessageId == messageId;

          return GestureDetector(
            onTap: () => textToSpeechService.speak(messageId, text),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEDF3FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9DFFB)),
              ),
              child: Icon(
                isSpeaking ? Icons.volume_off : Icons.volume_up,
                size: 18,
                color: AppTheme.chatBotMessageColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
