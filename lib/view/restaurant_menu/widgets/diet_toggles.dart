import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/restaurant_menu/restaurant_menu_colors.dart';

class RestaurantDietToggles extends StatelessWidget {
  const RestaurantDietToggles({
    super.key,
    required this.filterVeg,
    required this.filterNonVeg,
    required this.onVegChanged,
    required this.onNonVegChanged,
  });

  final bool filterVeg;
  final bool filterNonVeg;
  final ValueChanged<bool> onVegChanged;
  final ValueChanged<bool> onNonVegChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _DietToggle(
          assetName: 'images/ic_NonVeg.svg',
          activeColor: RestaurantMenuColors.nonVeg,
          value: filterNonVeg,
          onChanged: onNonVegChanged,
        ),
        const SizedBox(width: 20),
        _DietToggle(
          assetName: 'images/ic_Veg.svg',
          activeColor: RestaurantMenuColors.veg,
          value: filterVeg,
          onChanged: onVegChanged,
        ),
      ],
    );
  }
}

class _DietToggle extends StatelessWidget {
  const _DietToggle({
    required this.assetName,
    required this.activeColor,
    required this.value,
    required this.onChanged,
  });

  final String assetName;
  final Color activeColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SvgPicture.asset(
          AssetPath.get(assetName),
          width: 14,
          height: 14,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: value ? activeColor : RestaurantMenuColors.toggleOff,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: <Widget>[
                AnimatedPositionedDirectional(
                  duration: const Duration(milliseconds: 200),
                  start: value ? 22 : 2,
                  top: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
