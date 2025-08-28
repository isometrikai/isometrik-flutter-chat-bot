# Asset Helper System

This system provides conditional asset loading for both package and normal project usage.

## Overview

The Asset Helper system allows your chatbot to work seamlessly whether it's used as a package or in a normal Flutter project. It automatically handles the correct asset paths based on the configuration.

## Files

- `asset_helper.dart` - Main utility class for asset loading
- `asset_helper_svg.dart` - SVG support extension
- `asset_helper_lottie.dart` - Lottie support extension
- `chat_bot_config.dart` - Configuration class

## Usage

### 1. Configure the Mode

In your main app or where you initialize the chatbot, set the configuration:

```dart
import 'package:chat_bot/utils/chat_bot_config.dart';

// For normal project usage (default)
ChatBotConfig.isPackageMode = false;

// For package usage
ChatBotConfig.isPackageMode = true;
ChatBotConfig.packageName = 'your_package_name'; // if different from 'chat_bot'
```

### 2. Use Asset Helper

Replace your existing asset loading code:

```dart
import 'package:chat_bot/utils/asset_helper.dart';

// Instead of:
// Image.asset('assets/images/ic_close.svg')

// Use:
AssetHelper.imageAsset('images/ic_close.svg')

// For SVG:
AssetHelper.svgAsset('images/ic_close.svg')

// For Lottie:
AssetHelper.lottieAsset('lottie/bubble-wave-black.json')
```

### 3. Migration Example

**Before:**
```dart
// In chat_screen.dart
SvgPicture.asset('assets/images/ic_close.svg')
Lottie.asset('assets/lottie/bubble-wave-black.json')
Image.asset('assets/images/ic_history.svg')
```

**After:**
```dart
// In chat_screen.dart
AssetHelper.svgAsset('images/ic_close.svg')
AssetHelper.lottieAsset('lottie/bubble-wave-black.json')
AssetHelper.imageAsset('images/ic_history.svg')
```

## Configuration Options

### ChatBotConfig Properties

- `isPackageMode` - Set to `true` when using as a package
- `packageName` - Your package name (default: 'chat_bot')
- `enableSvgSupport` - Enable/disable SVG support
- `enableLottieSupport` - Enable/disable Lottie support

### Asset Paths

The system automatically generates the correct paths:

**Normal Project Mode:**
- `assets/images/ic_close.svg`

**Package Mode:**
- `packages/chat_bot/assets/images/ic_close.svg`

## Dependencies

Make sure you have the required dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_svg: ^2.2.0  # For SVG support
  lottie: ^2.7.0       # For Lottie support
```

## Benefits

1. **Single Codebase** - Works in both package and normal project modes
2. **Automatic Path Resolution** - No need to manually change asset paths
3. **Fallback Support** - Graceful degradation when dependencies are missing
4. **Easy Configuration** - Simple boolean flag to switch modes
5. **Type Safety** - Full type safety with null safety support

## Migration Guide

1. Import the asset helper in your files
2. Replace direct asset calls with AssetHelper methods
3. Set the appropriate configuration mode
4. Test in both package and normal project scenarios

## Example Implementation

```dart
// In your main.dart or initialization
void main() {
  // Configure for your use case
  ChatBotConfig.isPackageMode = false; // or true for package mode
  
  runApp(MyApp());
}

// In your widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AssetHelper.svgAsset('images/ic_close.svg', width: 24, height: 24),
        AssetHelper.lottieAsset('lottie/loading.json', width: 100, height: 100),
        AssetHelper.imageAsset('images/logo.png', width: 200, height: 100),
      ],
    );
  }
}
```
