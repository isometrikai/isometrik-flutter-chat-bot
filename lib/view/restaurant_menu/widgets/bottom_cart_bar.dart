import 'package:flutter/material.dart';
import 'package:chat_bot/utils/utils.dart';

class RestaurantBottomCartBar extends StatelessWidget {
  const RestaurantBottomCartBar({
    super.key,
    required this.itemCount,
    required this.onViewCart,
  });

  final int itemCount;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context) {
    final String itemLabel = itemCount == 1
        ? AppTranslations.oneItemAdded
        : AppTranslations.itemsAdded(itemCount.toString());
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFD4D4D4).withValues(alpha: 0.25),
            offset: const Offset(0, -4),
            blurRadius: 9,
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.fromSTEB(
        16,
        15,
        16,
        bottomInset > 0 ? 8 : 16,
      ),
      child: GestureDetector(
        onTap: onViewCart,
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppConstants.appThemeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                itemLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.2,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppTranslations.viewCart,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Transform.rotate(
                    angle: -1.5708,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
