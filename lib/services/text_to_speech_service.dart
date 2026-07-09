import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();

  factory TextToSpeechService() => _instance;

  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final ValueNotifier<String?> speakingMessageId = ValueNotifier<String?>(null);
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      speakingMessageId.value = null;
    });

    _flutterTts.setCancelHandler(() {
      speakingMessageId.value = null;
    });

    _isInitialized = true;
  }

  Future<void> speak(String messageId, String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    await _ensureInitialized();

    if (speakingMessageId.value == messageId) {
      await stop();
      return;
    }

    await _flutterTts.stop();
    speakingMessageId.value = messageId;
    await _flutterTts.speak(stripMarkdown(trimmedText));
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    speakingMessageId.value = null;
  }

  bool isSpeakingMessage(String messageId) => speakingMessageId.value == messageId;

  String stripMarkdown(String text) {
    var plainText = text;

    plainText = plainText.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );
    plainText = plainText.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
      (match) => match.group(1) ?? '',
    );
    plainText = plainText.replaceAllMapped(
      RegExp(r'`(.*?)`'),
      (match) => match.group(1) ?? '',
    );
    plainText = plainText.replaceAllMapped(
      RegExp(r'\[([^\]]*)\]\([^\)]*\)'),
      (match) => match.group(1) ?? '',
    );

    return plainText;
  }
}
