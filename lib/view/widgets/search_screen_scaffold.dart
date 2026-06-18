import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SearchScreenScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;

  const SearchScreenScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              ScreenHeader(
                title: title,
                subtitle: subtitle,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

String searchScreenTitle(WidgetAction action, String fallback) {
  return action.title.isNotEmpty ? action.title : fallback;
}

String? searchScreenSubtitle(WidgetAction action) {
  return action.subtitle.isNotEmpty ? action.subtitle : null;
}
