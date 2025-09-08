import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'asset_helper.dart';

/// Extension to AssetHelper for SVG support
extension AssetHelperSvg on AssetHelper {
  /// Loads an SVG asset with conditional path resolution
  static Widget svgAsset(
    String assetPath, {
    String? packageName,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
  }) {
    return SvgPicture.asset(
      AssetHelper.getAssetPath(assetPath, packageName: packageName),
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
