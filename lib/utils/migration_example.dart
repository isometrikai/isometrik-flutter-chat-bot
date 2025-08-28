import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'asset_helper.dart';
import 'chat_bot_config.dart';

/// Example showing how to migrate from direct asset loading to AssetHelper
class MigrationExample {
  
  /// Example 1: Before migration (direct asset loading)
  static Widget beforeMigration() {
    return Column(
      children: [
        // Direct asset loading - these won't work when used as a package
        SvgPicture.asset('assets/images/ic_close.svg'),
        Lottie.asset('assets/lottie/bubble-wave-black.json'),
        Image.asset('assets/images/ic_history.svg'),
      ],
    );
  }

  /// Example 2: After migration (using AssetHelper)
  static Widget afterMigration() {
    return Column(
      children: [
        // Using AssetHelper - works in both package and normal project modes
        AssetHelper.svgAsset('images/ic_close.svg'),
        AssetHelper.lottieAsset('lottie/bubble-wave-black.json'),
        AssetHelper.imageAsset('images/ic_history.svg'),
      ],
    );
  }

  /// Example 3: Configuration setup
  static void setupConfiguration() {
    // For normal project usage (default)
    ChatBotConfig.isPackageMode = false;
    
    // For package usage
    // ChatBotConfig.isPackageMode = true;
    // ChatBotConfig.packageName = 'your_package_name';
  }

  /// Example 4: Migration in chat_screen.dart
  static Widget chatScreenMigrationExample() {
    return Row(
      children: [
        // Before:
        // SvgPicture.asset('assets/images/ic_close.svg', width: 24, height: 24),
        
        // After:
        AssetHelper.svgAsset('images/ic_close.svg', width: 24, height: 24),
        
        const SizedBox(width: 8),
        
        // Before:
        // Lottie.asset('assets/lottie/bubble-wave-black.json', width: 100, height: 100),
        
        // After:
        AssetHelper.lottieAsset('lottie/bubble-wave-black.json', width: 100, height: 100),
        
        const SizedBox(width: 8),
        
        // Before:
        // Image.asset('assets/images/ic_history.svg', width: 24, height: 24),
        
        // After:
        AssetHelper.imageAsset('images/ic_history.svg', width: 24, height: 24),
      ],
    );
  }
}

/// Example widget showing the migration
class MigrationExampleWidget extends StatelessWidget {
  const MigrationExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Helper Migration Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Before Migration (Direct Asset Loading):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            MigrationExample.beforeMigration(),
            
            const SizedBox(height: 24),
            
            const Text(
              'After Migration (Using AssetHelper):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            MigrationExample.afterMigration(),
            
            const SizedBox(height: 24),
            
            const Text(
              'Configuration:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Package Mode: ${ChatBotConfig.isPackageMode}'),
            Text('Package Name: ${ChatBotConfig.packageName}'),
            Text('SVG Support: ${ChatBotConfig.enableSvgSupport}'),
            Text('Lottie Support: ${ChatBotConfig.enableLottieSupport}'),
          ],
        ),
      ),
    );
  }
}
