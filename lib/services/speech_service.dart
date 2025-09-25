// import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();

  factory SpeechService() => _instance;

  SpeechService._internal();

  // final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isInitialized = false;
  bool _isPreWarmed = false;
  bool _initializationStarted = false;

  /// Get the current recognized text
  String get currentRecognizedText => _currentRecognizedText;

  /// Check if speech recognition is available
  bool get isAvailable => _isAvailable;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if service is pre-warmed for ultra-fast response
  bool get isPreWarmed => _isPreWarmed;

  String _currentRecognizedText = '';

  /// Initialize speech to text service
  Future<bool> initialize() async {
    if (_isInitialized) {
      return _isAvailable;
    }

    if (!_initializationStarted) {
      _initializationStarted = true;
      _initializeInBackground(); // Don't await this
    }

    // Return immediately - don't block the UI
    return _isAvailable;
  }

  /// Initialize speech recognition in background
  void _initializeInBackground() async {
    try {
      debugPrint('Starting speech recognition initialization in background...');

      // _isAvailable = await _speechToText.initialize(
      //   onError: (error) {
      //     debugPrint('Speech recognition error: ${error.errorMsg}');
      //   },
      //   onStatus: (status) {
      //     debugPrint('Speech recognition status: $status');
      //     if (status == 'done' || status == 'notListening') {
      //       _isListening = false;
      //     }
      //   },
      // );

      _isInitialized = true;
      debugPrint('Speech recognition initialized: $_isAvailable');

      // // Pre-warm the service for ultra-fast response
      // if (_isAvailable) {
      //   _preWarmService();
      // }
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      _isInitialized = true;
      _isAvailable = false;
    }
  }

  /// Ultra-fast start listening - instant response
  bool startListening() {
    // If not initialized yet, start initialization and return false
    if (!_isInitialized && !_initializationStarted) {
      initialize();
      return false;
    }

    // If initialization is in progress or not available, return false
    if (!_isAvailable || _isListening) {
      return false;
    }

    _currentRecognizedText = '';
    _isListening = true;

    // Fire-and-forget approach - don't wait for anything
    // _startListeningAsync();

    return true;
  }

  // /// Internal method to start listening asynchronously (fire-and-forget)
  // void _startListeningAsync() {
  //   // Use unawaited to prevent any blocking
  //   _speechToText
  //       .listen(
  //         onResult: (result) {
  //           _currentRecognizedText = result.recognizedWords;
  //           debugPrint('Recognized text: $_currentRecognizedText');
  //         },
  //         listenFor: const Duration(seconds: 60),
  //         pauseFor: const Duration(seconds: 5),
  //         partialResults: true,
  //         localeId: "en_US",
  //         listenMode: ListenMode.confirmation,
  //       )
  //       .catchError((error) {
  //         debugPrint('Error during speech recognition: $error');
  //         _isListening = false;
  //       });
  // }

  // /// Stop listening for speech input
  // Future<void> stopListening() async {
  //   if (_isListening) {
  //     await _speechToText.stop();
  //     _isListening = false;
  //   }
  // }

  // /// Cancel speech recognition
  // Future<void> cancel() async {
  //   if (_isListening) {
  //     await _speechToText.cancel();
  //     _isListening = false;
  //   }
  // }

  // /// Get available locales
  // Future<List<LocaleName>> getAvailableLocales() async {
  //   if (!_isAvailable) return [];
  //   return await _speechToText.locales();
  // }

  // /// Check if speech recognition is supported on this device
  // Future<bool> isSupported() async {
  //   return await _speechToText.hasPermission;
  // }

  // /// Request microphone permission
  // Future<bool> requestPermission() async {
  //   return await _speechToText.initialize();
  // }

  // /// Pre-warm the speech service for instant response
  // Future<void> _preWarmService() async {
  //   if (_isPreWarmed) return;

  //   try {
  //     // Pre-warm by starting and immediately stopping a session
  //     // This prepares the speech recognition engine
  //     await _speechToText.listen(
  //       onResult: (result) {
  //         // Ignore results during pre-warming
  //       },
  //       listenFor: const Duration(milliseconds: 100),
  //       pauseFor: const Duration(milliseconds: 50),
  //       partialResults: true,
  //       localeId: "en_US",
  //       listenMode: ListenMode.confirmation,
  //     );

  //     // Immediately stop the pre-warming session
  //     // await Future.delayed(const Duration(milliseconds: 200));
  //     await _speechToText.stop();

  //     _isPreWarmed = true;
  //     debugPrint('Speech service pre-warmed successfully');
  //   } catch (e) {
  //     debugPrint('Failed to pre-warm speech service: $e');
  //   }
  // }
}
