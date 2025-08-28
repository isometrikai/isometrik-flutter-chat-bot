import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'asset_helper.dart';

/// Extension to AssetHelper for Lottie support
extension AssetHelperLottie on AssetHelper {
  /// Loads a Lottie animation with conditional path resolution
  static Widget lottieAsset(
    String assetPath, {
    String? packageName,
    double? width,
    double? height,
    BoxFit? fit,
    bool repeat = true,
    bool animate = true,
  }) {
    return Lottie.asset(
      AssetHelper.getAssetPath(assetPath, packageName: packageName),
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      repeat: repeat,
      animate: animate,
    );
  }
}
