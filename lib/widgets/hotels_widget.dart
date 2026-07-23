import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Hotel property listing card (Figma grocery shop / frame 1686554707).
class HotelsWidget extends StatelessWidget {
  final List<HotelProperty> properties;
  final int? nights;
  final bool isFromChatHistory;
  final void Function(HotelProperty property)? onHotelSelected;
  final void Function(HotelProperty property)? onOpenInApp;

  const HotelsWidget({
    super.key,
    required this.properties,
    this.nights,
    this.isFromChatHistory = false,
    this.onHotelSelected,
    this.onOpenInApp,
  });

  static int? nightsFromApiData(Map<String, dynamic> apiData) {
    final booking = apiData['hotel_booking'];
    if (booking is! Map) return null;

    return nightsFromDates(
      (booking['checkinDate'] ?? '').toString(),
      (booking['checkoutDate'] ?? '').toString(),
    );
  }

  static int? nightsFromDates(String? checkinDate, String? checkoutDate) {
    final checkin = Utility.parseHotelBookingDate(checkinDate ?? '');
    final checkout = Utility.parseHotelBookingDate(checkoutDate ?? '');
    if (checkin == null || checkout == null) return null;

    final nights = checkout.difference(checkin).inDays;
    return nights > 0 ? nights : null;
  }

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: properties.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _HotelPropertyCard(
          property: properties[index],
          nights: nights,
          isFromChatHistory: isFromChatHistory,
          onHotelSelected: onHotelSelected,
          onOpenInApp: onOpenInApp,
        );
      },
    );
  }
}

class _HotelPropertyCard extends StatelessWidget {
  final HotelProperty property;
  final int? nights;
  final bool isFromChatHistory;
  final void Function(HotelProperty property)? onHotelSelected;
  final void Function(HotelProperty property)? onOpenInApp;

  const _HotelPropertyCard({
    required this.property,
    this.nights,
    this.isFromChatHistory = false,
    this.onHotelSelected,
    this.onOpenInApp,
  });

  static const Color _cardBackground = Color(0xFFF5F7FF);
  static const Color _cardBorder = Color(0xFFEEF4FF);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _locationColor = Color(0xFF979797);
  static const Color _nightsLabelColor = Color(0xFF94A0AF);
  // static const Color _accentPurple = Color(0xFF8E2FFD);
  // static const Color _starColor = Color(0xFFA674BF);

  @override
  Widget build(BuildContext context) {
    final location = _formatLocation(property);
    final ratingLabel = _formatRating(property.ratings);
    final showStrikethrough = property.rate.recommendedSellingPrice >
        property.rate.totalRate;

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
          _buildImageSection(ratingLabel),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: _titleColor,
                ),
              ),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    color: _locationColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _buildPriceRow(showStrikethrough),
          if (!isFromChatHistory) ...[
            const SizedBox(height: 10),
            _buildOpenInAppRow(),
          ],
        ],
      ),
    );

    if (onHotelSelected == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onHotelSelected?.call(property),
      child: card,
    );
  }

  Widget _buildImageSection(String ratingLabel) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7.75),
      child: SizedBox(
        width: double.infinity,
        height: 184,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPropertyImage(),
            if (ratingLabel.isNotEmpty)
              PositionedDirectional(
                end: 8,
                bottom: 8,
                child: _RatingBadge(label: ratingLabel),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage() {
    final imageUrl = property.image.large.isNotEmpty
        ? property.image.large
        : property.image.thumbnail;

    if (imageUrl.isEmpty) {
      return _placeholderImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _placeholderImage();
      },
      errorBuilder: (_, __, ___) => _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return ColoredBox(
      color: const Color(0xFFD9D9D9),
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

  Widget _buildPriceRow(bool showStrikethrough) {
    final currency = property.rate.currency;
    final total = _formatPrice(currency, property.rate.totalRate);
    final original = _formatPrice(
      currency,
      property.rate.recommendedSellingPrice,
    );
    final nightsLabel = _nightsLabel();

    return Row(
      children: [
        Text(
          total,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.3,
            color: _titleColor,
          ),
        ),
        if (showStrikethrough) ...[
          const SizedBox(width: 4),
          Text(
            original,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: _titleColor,
              decoration: TextDecoration.lineThrough,
              decorationColor: _titleColor,
            ),
          ),
        ],
        if (nightsLabel.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            nightsLabel,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: _nightsLabelColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOpenInAppRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onOpenInApp?.call(property),
      child: Row(
        children: [
          SvgPicture.asset(
            AssetPath.get('images/ic_eazy_app.svg'),
            width: 13.8,
            height: 12.96,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppConstants.appThemeColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            AppTranslations.openInEazyApp,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: AppConstants.appThemeColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLocation(HotelProperty property) {
    final address = property.contact.address;
    final city = address.city.trim();
    final state = address.state.trim();

    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    }
    if (city.isNotEmpty) return city;
    if (state.isNotEmpty) return state;
    return address.line1.trim();
  }

  String _formatRating(HotelPropertyRatings ratings) {
    if (ratings.starRating <= 0) return '';
    final value = ratings.starRating.toStringAsFixed(1);
    if (ratings.userRating > 0) {
      return '$value (${ratings.userRating.toStringAsFixed(0)} reviews)';
    }
    return value;
  }

  String _nightsLabel() {
    if (nights == null || nights! <= 0) return '';
    final n = nights!;
    return AppTranslations.forNNights(n.toString());
  }

  static String _formatPrice(String currency, double value) {
    final code = currency.trim().isEmpty ? 'AED' : currency.trim();
    final formatted = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$code$formatted';
  }
}

class _RatingBadge extends StatelessWidget {
  final String label;

  const _RatingBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            size: 12,
            color: AppConstants.appThemeColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: const Color(0xFF242424),
            ),
          ),
        ],
      ),
    );
  }
}
