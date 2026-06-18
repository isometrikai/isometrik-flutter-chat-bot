import 'package:chat_bot/utils/utils.dart';
import 'package:flutter/material.dart';

abstract final class SearchResultTheme {
  static const Color accentPurple = Color(0xFF8E2FFD);
  static const Color emptyTextColor = Color(0xFF979797);
}

class SearchResultLoading extends StatelessWidget {
  const SearchResultLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: SearchResultTheme.accentPurple,
      ),
    );
  }
}

class SearchResultEmpty extends StatelessWidget {
  final String message;

  const SearchResultEmpty({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyText.copyWith(
          color: SearchResultTheme.emptyTextColor,
        ),
      ),
    );
  }
}
