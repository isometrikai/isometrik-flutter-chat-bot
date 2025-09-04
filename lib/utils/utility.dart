import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> kNavigatorKey = GlobalKey<NavigatorState>();

class Utility {
  static bool isLoading = false;

  static void showLoader({
    String? message,
  }) async {
    if (isLoading) return; // Prevent multiple loaders
    
    final context = kNavigatorKey.currentContext;
    if (context == null) {
      print('Warning: Navigator context is null, cannot show loader');
      return;
    }
    
    isLoading = true;
    await showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (_) => AppLoader(
        message: message,
      ),
      barrierDismissible: false,
    );
  }

  static void closeProgressDialog() {
    final context = kNavigatorKey.currentContext;
    if (isLoading && context != null && Navigator.of(context).canPop()) {
      isLoading = false;
      Navigator.of(context).pop();
    }
  }
}


class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
