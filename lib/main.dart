import 'package:chat_bot/view/launch_screen.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/callback_manage.dart';
import 'package:flutter/services.dart';
import 'utils/asset_path.dart';
import 'utils/utility.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure asset loading mode
  // AssetPath.isPackageMode = true; // Set to true for package mode, false for normal project
  
  await PlatformService.initializeFromPlatform();
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void chatMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure for package mode
  AssetPath.isPackageMode = true;
  
  await PlatformService.initializeFromPlatform();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  static const platform = MethodChannel('chat_bot/orders');
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up callbacks when app initializes
    _setupCallbacks();
    
    // Set current context for fallback when navigator key is not available
    Utility.setCurrentContext(context);
    
    return MaterialApp(
      title: 'Chat Bot',
      navigatorKey: kNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home:  LaunchScreen(),//ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
  void _setupCallbacks() {
    OrderService().setProductCallback((Map<String, dynamic> product) {
      _sendEventToiOS(product, 'product');
    });
    
    OrderService().setStoreCallback((Map<String, dynamic> store) {
      _sendEventToiOS(store, 'store');
    });

    // Add dismiss callback
    OrderService().setDismissCallback(() {
      _sendEventToiOS({}, 'dismissChat');
    });
  }
  Future<void> _sendEventToiOS(Map<String, dynamic> data, String type) async {
    try {
      await platform.invokeMethod('handleOrder', {
        'type': type,
        'data': data,
      });
    } catch (e) {
      print('Failed to send $type event to iOS: $e');
    }
  }
}


class PlatformService {
  static const MethodChannel _channel = MethodChannel('chatbot_config');

  static Future<void> initializeFromPlatform() async {
    try {
      print('🔄 Attempting to get config from iOS...');
      final Map<dynamic, dynamic> config = await _channel
          .invokeMethod('getConfig')
          .timeout(const Duration(seconds: 5));

      print('✅ Config received from iOS: $config');

      // Handle string to double conversion safely
      double? longitude;
      double? latitude;

      if (config['longitude'] != null) {
        longitude = double.tryParse(config['longitude'].toString());
      }

      if (config['latitude'] != null) {
        latitude = double.tryParse(config['latitude'].toString());
      }

      ApiService.configure(
        chatBotId: config['chatBotId'] ?? '2',
        appSecret: config['appSecret'] ?? '',
        licenseKey: config['licenseKey'] ?? '',
        isProduction: config['isProduction'] ?? false,
        userId: config['userId'] ?? '',
        name: config['name'] ?? '',
        timestamp: config['timestamp'] ?? '',
        userToken: config['userToken'] ?? '',
        location: config['location'],
        longitude: longitude,
        latitude: latitude,
      );

      print('✅ ApiService configured successfully');
    } catch (e) {
      if (AssetPath.isPackageMode == false) {
         print('❌ Error getting config from platform: $e');
      // Fallback to default values if iOS config fails
          ApiService.configure(
            chatBotId: '1476',
            appSecret: "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY2YzQ2YWVhN2E2MDI5Yjk5MTNiMzIxOG0AAAAIa2V5c2V0SWRtAAAAJGFiZGFkNDQyLTA4YzktNDE4Ny1iYjk4LWUwMTAzYmY2YWYzOG0AAAAJcHJvamVjdElkbQAAACQ2Zjg4NzAwMi0yYzQ3LTQ4Y2EtYTQwNS0wZjk2NWVlNDAyNjFkAAZzaWduZWRuBgAUskFvkQE.esNFHT-JxzVtFpxylbJ8ik1lRZ-c75JjuCA0toa4C5M",
            licenseKey: "lic-IMKMqJdO3e2HO+6qDxctvESxA+HkoLIThG9",
            userId: "68af0df36ed4590014c3e518",
            name: 'Chintu',
            timestamp: '2025-07-28T12:30:00Z',
            userToken: 'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.eMnq6dsxpzc2up97I6UWFTvlT_kPAlGp-ivRT5Wn9TbjH_No1w0pPfiy9GUVTsfXu5WsdwUx8aJLdO-yiu5SMWOxb0rfVvtEE7--Lq3eiyd99i3g9rZshtB76SKh9LtSgBY_6psQGDLZw9sb1oPt1PNBFpw45Mf_b0hqQXJLJ94.rPE8OJT2le0ONWek.LhKwbtuiKSz144Yrg80rB9Xq2Z-dqo1gT_UhhJ9CMjGd-NSKGVmAj_bAhWXN-E5B3ml3EFjti4m9YixN7jeev1SThCUHW_zajUTOQs_QRLS56HOTEEIIm2su0ETMLAzd68dSAMDp2T4J8vyLISAxWshVShle8leQFUR0vwBVkODuqmO4CTzS3iES5z_dbbK73xc5p_qNP7yYPaTKASTGPCSlJOolvTcAF3BI4wb1y45wyeICmQTfQJ6fyDJ3kL54FmGfAK-8_GP4aSNs0yI1hd_OtoIbaSKHD6Hrcxv99uKAUPsc5tUoK2KfWHDRPiUq1DuVK3H7siaglBT7iHyhWID34US671y5bf60wnJb2_HUURX8QUyNeuETtuvJVtnXSZKnyamWWTZmrr_d4_Yy8C-UTj5kmCnB8MsiUzbrgoNEem_aiVBwgDutaNoDWxpAkTYOwK2vCmtZlsOxFCZ6LU1lHcrj2cEYtSe18jHtzZyY70FfQIxwglgCTB7DBFfN5MS427LwiHuqyTicd3Sk8jnfdEBRpfwjmR0gsAxzmSIBJtAkqhbRu5__eQRnuhctqEHunFq6rQfhD4m8hr_Iro4Yyjx07fOeGkwge4ihDCLGrYZe_bO6R4jeql-9iUewy3p8WjJ9vELEtK0oEcvSInavgzFn7qXQ6AUv1o_qURZDgoGnvOHZKu4Ecq2LHqFmA5-qyMd8ekkzIt2nj_E3WaNYGJmyk5a-JYuCrdjJbelb2UWVT7pFQFvSSkzsihdQa7--EfvE7ox62ZiZCZCBHtJna4oPHq12-DEvs9MDYDkYwWhtsJ5ooGOcGPr1SkJhhEGILecwcIZUyMuyZFCgkM1sWyV9lC8C8YyrVJKemsJsWajUHbo1LHZkKxISCzr0rNj93eck-1cz5CRKZbwxoYyea1vwIOkILa8tZVQiy0C4PfNMJ2X9Ric-B-I9oKQBneKoDo7wTdVl_426ydSCh9CoQja8wOg0Fg6p1X6QQwCFquA7F1DR-KsQpcF4_Lkt9BDcBNu634KFGZEYXVyQCEI-w3Rvi0g29yS8Yxoeo7A826TJIBROS6TcTqCWcFUpizf7iVwHzV-wboTmo4TcQAtibv0kjuk8_45bNDpn0lyCP13BliKWZ9T6aiSpPDz8W7aCOo9QvmM-cZ0PhckvpTTyMY2zPv7uhETc2GOrDyX9-E8oMN3QLr_jSOm1HoMYjNbd_6fvt_Zl0pZGFp44sizLAWMwegzrb5kZ8gpeLuQ1-NHBQCoPUx55VB5vjA1N-nc5ZZxeTgoyQFGw-0z5oQIH5Te6J3Gl5azOLnkGbr8X2CXIGqwHg_T33WCYrgAsdN2WQZdnhxc2mXlh5ShF9oIcmoWKL1fFSHWoMGztcX-24c6Tf1WzzDlid-JvhxZDgrF9IQuohcNteoYk3Gib80n8e9hGUfTKPH8UXBXzp5Le7vxrlX37a3c-jEEqu5Z3QNaMAYCbqCbsk9gAMjRKB8Nh3akPVm6mX9_MHIfYwC0teyzWTemQDgDXMu2dpTh6eOA7ZmUs6aAb8fY5nFkZV6apLybyhSZIjhaNoxAzMDfeLUnQJNtL5gIs42pzEdNNKT3IFYn1hp6Ea4WeWgXl7pqQSGyetTbhu3nsg8FxZz47nv2BYyGtnJTGnBQp4hFDhDwPR_4wcJJBOfhHmQFDmGZ4Lr8Dke5mZN0BBFwPiNVtazG_-8G7QJF0Qkela4m6bQTcVBl511z8CwaT5uWwyfQHKheWVfWblPKoWJnbKILfyntcK8Oc0U0aVP0oBj0.b4Pi-rEVLccABLbXHKXhyQ',
            location: 'Dubai Marina',
            isProduction: false,
            latitude: 25.276987,
            longitude: 55.296249,
          );
      }
    }
  }
}
