/// Configuration class for ChatBot package
class ChatBotConfig {
  /// Whether the chatbot is running as a package
  /// Set this to true when using the chatbot as a package
  static bool isPackageMode = false;

  /// The package name when used as a package
  /// Change this if your package name is different
  static String packageName = 'chat_bot';

  /// Whether to enable SVG support
  /// Set to false if flutter_svg is not available
  static bool enableSvgSupport = true;

  /// Whether to enable Lottie support
  /// Set to false if lottie is not available
  static bool enableLottieSupport = true;

  /// Custom asset path prefix for package mode
  /// You can customize this if needed
  static String get packageAssetPrefix => 'packages/$packageName/assets/';

  /// Custom asset path prefix for normal project mode
  static const String normalAssetPrefix = 'assets/';
}
