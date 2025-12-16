import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_bot/data/data.dart';
import '../utils/utils.dart';

class ServicesDeliveryOptionsWidget extends StatefulWidget {
  final List<WidgetAction> servicesDeliveryOptions;
  final Function(String)? onSendMessage;
  final bool isFromChatHistory;

  const ServicesDeliveryOptionsWidget({
    super.key,
    required this.servicesDeliveryOptions,
    this.onSendMessage,
    this.isFromChatHistory = false,
  });

  @override
  State<ServicesDeliveryOptionsWidget> createState() => _ServicesDeliveryOptionsWidgetState();
}

class _ServicesDeliveryOptionsWidgetState extends State<ServicesDeliveryOptionsWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0, right: 24, bottom: 8, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      constraints: const BoxConstraints(
        minWidth: 320,
        maxWidth: 320,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5F2FF),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.servicesDeliveryOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == index;
            final displayText = option.name ?? option.title;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < widget.servicesDeliveryOptions.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () {
                  if (widget.isFromChatHistory == false) {
                    setState(() {
                      // Toggle selection: if already selected, deselect; otherwise select
                      selectedIndex = isSelected ? null : index;
                    });
                    // Handle option selection - send message with the name text
                    if (selectedIndex != null && displayText.isNotEmpty) {
                      widget.onSendMessage?.call(displayText);
                    }
                  }
                },
                child: Row(
                  children: [
                    Text(
                      option.emoji ?? '',
                      style: AppTextStyles.restaurantDescription.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Text
                    Expanded(
                      child: Text(
                        displayText,
                        style: AppTextStyles.restaurantDescription.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF242424),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (widget.isFromChatHistory == false)
                    // Radio button
                    SvgPicture.asset(
                      AssetPath.get(isSelected 
                        ? 'images/ic_sel_radio.svg' 
                        : 'images/ic_de_sel_radio.svg'),
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

