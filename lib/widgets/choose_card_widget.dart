import 'package:flutter/material.dart';
import '../utils/utils.dart';

class CardOption {
  final String title;

  CardOption({
    required this.title,
  });

  factory CardOption.fromJson(Map<String, dynamic> json) {
    return CardOption(
      title: json['title'] ?? '',
    );
  }
}

class ChooseCardWidget extends StatefulWidget {
  final List<CardOption> cardOptions;
  final Function(CardOption)? onCardSelected;
  final Function(String)? onSendMessage;
  final bool isFromChatHistory;

  const ChooseCardWidget({
    super.key,
    required this.cardOptions,
    this.onCardSelected,
    this.onSendMessage,
    this.isFromChatHistory = false,
  });

  @override
  State<ChooseCardWidget> createState() => _ChooseCardWidgetState();
}

class _ChooseCardWidgetState extends State<ChooseCardWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 0, end: 24, bottom: 8, top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9DFFB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
           Text(
            AppTranslations.choosePaymentOption,
            style: AppTextStyles.restaurantTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 8),
          // Card options
          ...widget.cardOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final cardOption = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCardOption(index, cardOption),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardOption(int index, CardOption cardOption) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (widget.isFromChatHistory == false) {
          setState(() {
            selectedIndex = index;
          });
          widget.onCardSelected?.call(cardOption);
          
          // Automatically send the selected card as a message
          final message = "Use this card:-\n${cardOption.title}";
          widget.onSendMessage?.call(message);
        }
      },
      child: Container(
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5F2FF),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(44.5),
              ),
              child: Center(
                child: Text(
                  _getIconForCardType(cardOption.title),
                  style: AppTextStyles.restaurantTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Card text
            Expanded(
              child: Text(
                cardOption.title,
                style: AppTextStyles.restaurantTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: Color(0xFF242424),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppConstants.appThemeColor : const Color(0xFFDDE7FA),
                  width: 0.83,
                ),
                color: isSelected ? AppConstants.appThemeColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconForCardType(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('cash') || lowerTitle.contains('delivery')) {
      return '💰';
    } else if (lowerTitle.contains('card') || lowerTitle.contains('ending')) {
      return '💳';
    } else {
      return '💳'; // Default card icon
    }
  }
}
