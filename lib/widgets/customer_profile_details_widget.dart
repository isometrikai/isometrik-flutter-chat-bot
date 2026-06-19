import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Customer profile summary card (Figma frame 1171285000).
class CustomerProfileDetailsWidget extends StatelessWidget {
  final List<HotelDestination> items;

  const CustomerProfileDetailsWidget({
    super.key,
    required this.items,
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _detailsBackground = Color(0xFFFBF1FF);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 294),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _ProfileDetailsCard(details: items[i]),
              if (i < items.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  final HotelDestination details;

  const _ProfileDetailsCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final headerTitle =
        details.title.isNotEmpty ? details.title : 'Your Details';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CustomerProfileDetailsWidget._borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerTitle,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: CustomerProfileDetailsWidget._titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CustomerProfileDetailsWidget._detailsBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (details.name.isNotEmpty) ...[
                  _DetailLine(emoji: '👤', label: 'Name', value: details.name),
                  const SizedBox(height: 10),
                ],
                if (details.contact.isNotEmpty) ...[
                  _DetailLine(
                    emoji: '📞',
                    label: 'Contact',
                    value: details.contact,
                  ),
                  const SizedBox(height: 10),
                ],
                if (details.email.isNotEmpty)
                  _DetailLine(
                    emoji: '📧',
                    label: 'Email',
                    value: details.email,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _DetailLine({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$emoji $label: $value',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyText.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: CustomerProfileDetailsWidget._titleColor,
      ),
    );
  }
}
