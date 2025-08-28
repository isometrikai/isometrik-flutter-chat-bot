import 'package:flutter/material.dart';
import 'asset_helper_svg.dart';
import 'asset_helper_lottie.dart';
import 'chat_bot_config.dart';

/// Utility class to handle asset loading for both package and normal project usage
class AssetHelper {
  /// Determines if the current context is running as a package
  /// You can override this based on your specific needs
  static bool get isPackageMode => ChatBotConfig.isPackageMode;

  /// Gets the appropriate asset path based on the current mode
  /// 
  /// [assetPath] - The relative path to the asset (e.g., 'images/ic_close.svg')
  /// [packageName] - The package name when used as a package (default: 'chat_bot')
  /// 
  /// Returns the asset path that works for both package and normal project usage
  static String getAssetPath(String assetPath, {String? packageName}) {
    final pkgName = packageName ?? ChatBotConfig.packageName;
    
    if (isPackageMode) {
      // When used as a package, prefix with package name
      return '${ChatBotConfig.packageAssetPrefix}$assetPath';
    } else {
      // When used in normal project, use the standard assets path
      return '${ChatBotConfig.normalAssetPrefix}$assetPath';
    }
  }

  /// Loads an image asset with conditional path resolution
  static Image imageAsset(
    String assetPath, {
    String? packageName,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    return Image.asset(
      getAssetPath(assetPath, packageName: packageName),
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }

  /// Loads an SVG asset with conditional path resolution
  /// Note: This requires flutter_svg package to be available
  static Widget svgAsset(
    String assetPath, {
    String? packageName,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    if (!ChatBotConfig.enableSvgSupport) {
      // Fallback to placeholder if SVG support is disabled
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    return AssetHelperSvg.svgAsset(
      assetPath,
      packageName: packageName,
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }

  /// Loads a Lottie animation with conditional path resolution
  /// Note: This requires lottie package to be available
  static Widget lottieAsset(
    String assetPath, {
    String? packageName,
    double? width,
    double? height,
    BoxFit? fit,
    bool repeat = true,
    bool animate = true,
  }) {
    if (!ChatBotConfig.enableLottieSupport) {
      // Fallback to placeholder if Lottie support is disabled
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.animation, color: Colors.grey),
      );
    }

    return AssetHelperLottie.lottieAsset(
      assetPath,
      packageName: packageName,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      animate: animate,
    );
  }
}
