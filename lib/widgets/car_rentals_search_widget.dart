import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Car rental search listing card (Figma grocery shop / frame 1686554707).
class CarRentalsSearchWidget extends StatelessWidget {
  final List<CarRentalSearch> rentals;
  final bool isFromChatHistory;
  final void Function(CarRentalSearch rental)? onCarRentalSelected;
  final void Function(CarRentalSearch rental)? onOpenInApp;

  const CarRentalsSearchWidget({
    super.key,
    required this.rentals,
    this.isFromChatHistory = false,
    this.onCarRentalSelected,
    this.onOpenInApp,
  });

  static int? daysFromDates(String? pickupDate, String? returnDate) {
    final pickup = Utility.parseHotelBookingDate(pickupDate ?? '');
    final returnDt = Utility.parseHotelBookingDate(returnDate ?? '');
    if (pickup == null || returnDt == null) return null;

    final days = returnDt.difference(pickup).inDays;
    return days > 0 ? days : null;
  }

  @override
  Widget build(BuildContext context) {
    if (rentals.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: rentals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _CarRentalSearchCard(
          rental: rentals[index],
          isFromChatHistory: isFromChatHistory,
          onCarRentalSelected: onCarRentalSelected,
          onOpenInApp: onOpenInApp,
        );
      },
    );
  }
}

class _CarRentalSearchCard extends StatelessWidget {
  final CarRentalSearch rental;
  final bool isFromChatHistory;
  final void Function(CarRentalSearch rental)? onCarRentalSelected;
  final void Function(CarRentalSearch rental)? onOpenInApp;

  const _CarRentalSearchCard({
    required this.rental,
    this.isFromChatHistory = false,
    this.onCarRentalSelected,
    this.onOpenInApp,
  });

  static const Color _cardBackground = Color(0xFFF5F7FF);
  static const Color _cardBorder = Color(0xFFEEF4FF);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _mutedColor = Color(0xFFA2A2A2);
  static const Color _specColor = Color(0xFF979797);
  static const Color _daysLabelColor = Color(0xFF94A0AF);
  static const Color _accentPurple = Color(0xFF8E2FFD);

  @override
  Widget build(BuildContext context) {
    final vehicle = rental.raw.vehicle;
    final days = CarRentalsSearchWidget.daysFromDates(
      rental.pickupDate,
      rental.returnDate,
    );

    final card = Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _cardBackground,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(vehicle.pictureUrl),
          const SizedBox(height: 8),
          _buildNameRow(rental.name),
          const SizedBox(height: 3),
          _buildSpecsRow(vehicle),
          const SizedBox(height: 8),
          _buildPriceRow(days),
          if (!isFromChatHistory) ...[
            const SizedBox(height: 10),
            _buildOpenInAppRow(),
          ],
        ],
      ),
    );

    if (onCarRentalSelected == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onCarRentalSelected?.call(rental),
      child: card,
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7.75),
      child: Container(
        width: double.infinity,
        height: 184,
        color: Colors.white,
        child: _buildVehicleImage(imageUrl),
      ),
    );
  }

  Widget _buildVehicleImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _placeholderImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _placeholderImage();
      },
      errorBuilder: (_, __, ___) => _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: SvgPicture.asset(
          AssetPath.get('images/ic_placeHolder.svg'),
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildNameRow(String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: _titleColor,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Or Similar',
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1.2,
            color: _mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsRow(CarRentalVehicle vehicle) {
    final specs = <String>[
      if (vehicle.passengerQuantity > 0) '${vehicle.passengerQuantity} seat',
      if (vehicle.doorCount > 0) '${vehicle.doorCount} doors',
      if (vehicle.baggageQuantity > 0) '${vehicle.baggageQuantity} bags',
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (var i = 0; i < specs.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(width: 8),
            Text(
              '•',
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: _mutedColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            specs[i],
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: _specColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceRow(int? days) {
    final price = _formatPrice(rental.currency, rental.amount);
    final daysLabel = _daysLabel(days);

    return Row(
      children: [
        Text(
          price,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.3,
            color: _titleColor,
          ),
        ),
        if (daysLabel.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            daysLabel,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: _daysLabelColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOpenInAppRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onOpenInApp?.call(rental),
      child: Row(
        children: [
          SvgPicture.asset(
            AssetPath.get('images/ic_eazy_app.svg'),
            width: 13.8,
            height: 12.96,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              _accentPurple,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Open in Eazy app',
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: _accentPurple,
            ),
          ),
        ],
      ),
    );
  }

  String _daysLabel(int? days) {
    if (days == null || days <= 0) return '';
    return 'for $days day${days == 1 ? '' : 's'}';
  }

  static String _formatPrice(String currency, double value) {
    final code = currency.trim().isEmpty ? 'AED' : currency.trim();
    final formatted = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$code$formatted';
  }
}
