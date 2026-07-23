import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Hotel destination picker card (Figma frame 1686554289).
class HotelDestinationWidget extends StatelessWidget {
  final List<HotelDestination> destinations;
  final void Function(HotelDestination obj)? onDestinationSelected;
  final bool isFromChatHistory;

  const HotelDestinationWidget({
    super.key,
    required this.destinations,
    this.onDestinationSelected,
    this.isFromChatHistory = false,
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _rowBackground = Color(0xFFF5F7FF);
  static const Color _labelColor = Color(0xFF8E2FFD);

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: AlignmentDirectional.centerStart,
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
              for (int i = 0; i < destinations.length; i++) ...[
                _DestinationRow(
                  label: destinations[i].fullName,
                  onTap: isFromChatHistory
                      ? null
                      : () {
                          final destination = destinations[i];
                          // final message = destination.fullName.isNotEmpty
                          //     ? destination.fullName
                          //     : destination.name;
                          // if (destination.isNotEmpty) {
                            onDestinationSelected?.call(destination);
                          // }
                        },
                ),
                if (i < destinations.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _DestinationRow({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: HotelDestinationWidget._rowBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: AlignmentDirectional.centerStart,
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
