# ChatBot 2.0 - Flutter Package

A comprehensive Flutter chatbot package with restaurant listing, menu management, and order processing capabilities.

## 🚀 Features

- **Restaurant Listing Screen** - Complete UI with search, filters, and restaurant cards
- **Menu System** - Restaurant menus with customization options  
- **Order Management** - Product and store order handling with callbacks
- **Payment Integration** - Stripe payment support
- **Responsive Design** - Modern UI with proper theming
- **Asset Management** - Automatic asset path handling for package mode

## 📦 Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  chat_bot:
    path: ../path/to/isometrik-flutter-chat-bot  # Local path
    # OR if published to pub.dev:
    # chat_bot: ^1.0.0
```

## 🔧 Configuration

Before using the chatbot, configure it with your API credentials:

```dart
import 'package:chat_bot/chat_bot.dart';

void main() {
  ChatBot.configure(
    chatBotId: 'your_chatbot_id',
    appSecret: 'your_app_secret',
    licenseKey: 'your_license_key',
    isProduction: false, // Set to true for production
    userId: 'user_id',
    name: 'User Name',
    timestamp: '2025-01-28T12:30:00Z',
    userToken: 'your_user_token',
    location: 'User Location',
    longitude: 77.562980651855469,
    latitude: 13.040803909301758,
  );
  
  runApp(MyApp());
}
```

## 💻 Usage

### Basic Integration

```dart
import 'package:flutter/material.dart';
import 'package:chat_bot/chat_bot.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              ChatBot.openChatBot(context);
            },
            child: Text('Open Chatbot'),
          ),
        ),
      ),
    );
  }
}
```

### Order Callbacks

Set up callbacks to handle orders and store selections:

```dart
import 'package:chat_bot/services/callback_manage.dart';

// Set up callbacks
OrderService().setProductCallback((Map<String, dynamic> product) {
  // Handle product order
  print('Product ordered: $product');
});

OrderService().setStoreCallback((Map<String, dynamic> store) {
  // Handle store selection
  print('Store selected: $store');
});

OrderService().setDismissCallback(() {
  // Handle chatbot dismissal
  print('Chatbot dismissed');
});
```

## 🎨 Theming

The chatbot uses a custom theme with purple accent colors (`#8E2FFD`). You can customize the appearance by modifying the theme in your main app.

## 📱 Requirements

- Flutter SDK: ^3.7.2
- Dart SDK: ^3.7.2

## 🔗 Dependencies

The package includes these dependencies:
- `http: ^1.1.0`
- `shared_preferences: ^2.2.2`
- `bloc: ^8.1.2`
- `flutter_bloc: ^8.1.3`
- `equatable: ^2.0.5`
- `lottie: ^2.7.0`
- `unique_identifier: ^0.4.0`
- `flutter_svg: ^2.2.0`
- `flutter_stripe: ^10.1.1`
- `flutter_html: ^3.0.0-beta.2`

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
