import 'package:chat_bot/utils/app_constants.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';

class ProductCustomizationHeader extends StatelessWidget {
  final Product? product;
  final String? productName;
  final String? productImage;
  final bool isFromMenuScreen;

  const ProductCustomizationHeader({
    super.key,
    required this.product,
    required this.productName,
    required this.productImage,
    required this.isFromMenuScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 28,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD8DEF3),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 15),

          // Header content
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9DFFB),
                  borderRadius: BorderRadius.circular(6.22),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.22),
                  // NOTE: preserve original behavior: only look at product?.productImage for deciding.
                  child: (product?.productImage.isNotEmpty ?? false)
                      ? Image.network(
                          isFromMenuScreen ? (productImage ?? '') : (product?.productImage ?? ''),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.restaurant,
                            color: AppConstants.appThemeColor,
                            size: 20,
                          ),
                        )
                      : const Icon(
                          Icons.restaurant,
                          color: AppConstants.appThemeColor,
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isFromMenuScreen ? (productName ?? '') : (product?.productName ?? ''),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF242424),
                  ),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(38.18),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF585C77),
                    size: 9.6,
                  ),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          // Keep space consistent with previous layout.
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}

