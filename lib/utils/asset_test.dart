import 'package:flutter/material.dart';
import 'asset_helper.dart';
import 'chat_bot_config.dart';

/// Test widget to verify AssetHelper functionality
class AssetTestWidget extends StatelessWidget {
  const AssetTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Helper Test'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuration info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text('Package Mode: ${ChatBotConfig.isPackageMode}'),
                    Text('Package Name: ${ChatBotConfig.packageName}'),
                    Text('SVG Support: ${ChatBotConfig.enableSvgSupport}'),
                    Text('Lottie Support: ${ChatBotConfig.enableLottieSupport}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Asset path examples
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asset Paths:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text('Image: ${AssetHelper.getAssetPath('images/ic_close.svg')}'),
                    Text('SVG: ${AssetHelper.getAssetPath('images/ic_history.svg')}'),
                    Text('Lottie: ${AssetHelper.getAssetPath('lottie/bubble-wave-black.json')}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Asset examples
            const Text(
              'Asset Examples:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            
            // SVG asset
            Row(
              children: [
                const Text('SVG: '),
                AssetHelper.svgAsset(
                  'images/ic_close.svg',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Image asset
            Row(
              children: [
                const Text('Image: '),
                AssetHelper.imageAsset(
                  'images/men.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lottie asset
            Row(
              children: [
                const Text('Lottie: '),
                AssetHelper.lottieAsset(
                  'lottie/bubble-wave-black.json',
                  width: 100,
                  height: 50,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Toggle button
            ElevatedButton(
              onPressed: () {
                ChatBotConfig.isPackageMode = !ChatBotConfig.isPackageMode;
                // Force rebuild
                (context as Element).markNeedsBuild();
              },
              child: Text(
                'Toggle Package Mode (Current: ${ChatBotConfig.isPackageMode ? 'Package' : 'Normal'})',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
