import 'package:flutter/material.dart';

import '../utils/utils.dart';

class AddressOption {
  final String name;
  final String address;
  final bool isPackageDelivery;
  final String addressId;

  AddressOption({
    required this.name,
    required this.address,
    required this.isPackageDelivery,
    required this.addressId,
  });

  factory AddressOption.fromJson(Map<String, dynamic> json) {
    return AddressOption(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      isPackageDelivery: json['is_package_flow'] ?? false,
      addressId: json['addressId'] ?? '',
    );
  }
}

class ChooseAddressWidget extends StatefulWidget {
  final List<AddressOption> addressOptions;
  final Function(AddressOption)? onAddressSelected;
  final Function(String)? onSendMessage;
  final bool isFromChatHistory;

  const ChooseAddressWidget({
    super.key,
    required this.addressOptions,
    this.onAddressSelected,
    this.onSendMessage,
    this.isFromChatHistory = false,
  });

  @override
  State<ChooseAddressWidget> createState() => _ChooseAddressWidgetState();
}

class _ChooseAddressWidgetState extends State<ChooseAddressWidget> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            AppTranslations.chooseAddress,
            style: AppTextStyles.restaurantTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 8),
          // Address options
          ...widget.addressOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final addressOption = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildAddressOption(index, addressOption),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddressOption(int index, AddressOption addressOption) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (widget.isFromChatHistory == false) {
          setState(() {
            selectedIndex = index;
          });
          widget.onAddressSelected?.call(addressOption);
          
          // Automatically send the selected address as a message
          final message = "Use this address\n${addressOption.name}: ${addressOption.address}";
          widget.onSendMessage?.call(message);
        }
      },
      child: Container(
        width: double.infinity,
        height: 54,
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
                  _getIconForAddressType(addressOption.name),
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
            // Address text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    addressOption.address,
                    style: AppTextStyles.restaurantTitle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      color: Color(0xFF242424),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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

  String _getIconForAddressType(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('home') || lowerName.contains('house')) {
      return '🏠';
    } else if (lowerName.contains('work') || lowerName.contains('office')) {
      return '💼';
    } else {
      return '📍'; // Default location icon
    }
  }
}
