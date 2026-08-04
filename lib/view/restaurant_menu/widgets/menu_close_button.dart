import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/restaurant_menu/restaurant_menu_colors.dart';

class RestaurantMenuCloseButton extends StatelessWidget {
  const RestaurantMenuCloseButton({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        AssetPath.get('images/ic_close.svg'),
        width: 40,
        height: 40,
      ),
      padding: EdgeInsets.zero,
      onPressed: onClose,
    );
  }
}

class RestaurantMenuCollapsedNavBar extends StatelessWidget {
  const RestaurantMenuCollapsedNavBar({
    super.key,
    required this.storeName,
    required this.onClose,
  });

  final String storeName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey<String>('collapsed-header'),
      color: Colors.white,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                    color: RestaurantMenuColors.collapsedTitle,
                  ),
                ),
              ),
              RestaurantMenuCloseButton(onClose: onClose),
            ],
          ),
        ),
      ),
    );
  }
}
