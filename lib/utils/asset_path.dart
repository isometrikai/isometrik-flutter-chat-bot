/// Simple utility for conditional asset paths
class AssetPath {
  /// Set this to true when using as a package
  static bool isPackageMode = false;
  
  /// Get asset path with conditional prefix
  static String get(String assetPath) {
    if (isPackageMode) {
      return 'packages/chat_bot/assets/$assetPath';
    }
    return 'assets/$assetPath';
  }
}
