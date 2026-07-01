import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Car pickup place picker card (same layout as hotel destination).
class CarPickupPlacesWidget extends StatelessWidget {
  final List<CarPickupPlace> places;
  final void Function(CarPickupPlace place)? onPlaceSelected;
  final bool isFromChatHistory;

  const CarPickupPlacesWidget({
    super.key,
    required this.places,
    this.onPlaceSelected,
    this.isFromChatHistory = false,
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _rowBackground = Color(0xFFF5F7FF);
  // static const Color _labelColor = Color(0xFF8E2FFD);

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 294),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < places.length; i++) ...[
                _PickupPlaceRow(
                  label: places[i].name,
                  onTap: isFromChatHistory
                      ? null
                      : () => onPlaceSelected?.call(places[i]),
                ),
                if (i < places.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PickupPlaceRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PickupPlaceRow({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: CarPickupPlacesWidget._rowBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyText.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppConstants.appThemeColor,
        ),
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: row,
      ),
    );
  }
}
