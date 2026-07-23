import 'package:chat_bot/utils/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();

  factory TextToSpeechService() => _instance;

  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final ValueNotifier<String?> speakingMessageId = ValueNotifier<String?>(null);
  bool _isInitialized = false;
  String? _appliedLanguageCode;

  /// TTS locale from [AppLocale] / [Utility.getLanguage].
  String get _ttsLanguage {
    switch (AppLocale.languageCode) {
      case 'ar':
        return 'ar-SA';
      case 'en':
      default:
        return 'en-US';
    }
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

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

  /// Apply current app language to the engine (supports Arabic when language is `ar`).
  Future<void> _applyLanguage() async {
    final code = AppLocale.languageCode;
    if (_appliedLanguageCode == code) return;

    var locale = _ttsLanguage;
    try {
      final available = await _flutterTts.isLanguageAvailable(locale);
      if (available != true && code == 'ar') {
        // Fallback if ar-SA is missing on device (common on some Android builds).
        for (final candidate in ['ar', 'ar-EG', 'ar-AE']) {
          final ok = await _flutterTts.isLanguageAvailable(candidate);
          if (ok == true) {
            locale = candidate;
            break;
          }
        }
      }
    } catch (_) {
      // Some platforms don't implement isLanguageAvailable; still try setLanguage.
    }

    await _flutterTts.setLanguage(locale);
    _appliedLanguageCode = code;
  }

  Future<void> speak(String messageId, String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    await _ensureInitialized();
    await _applyLanguage();

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
