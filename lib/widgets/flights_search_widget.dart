import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/data.dart';
import '../utils/utils.dart';

/// Flight search listing card.
class FlightsSearchWidget extends StatelessWidget {
  final List<FlightSearch> flights;
  final bool isFromChatHistory;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onFlightSelected;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onOpenInApp;

  const FlightsSearchWidget({
    super.key,
    required this.flights,
    this.isFromChatHistory = false,
    this.onFlightSelected,
    this.onOpenInApp,
  });

  @override
  Widget build(BuildContext context) {
    if (flights.isEmpty) return const SizedBox.shrink();

    final cards = <Widget>[];
    for (final flight in flights) {
      final cabins =
          flight.cabins.isNotEmpty ? flight.cabins : <FlightSearchCabin>[];
      if (cabins.isEmpty) {
        cards.add(
          _FlightSearchCard(
            flight: flight,
            cabin: null,
            isFromChatHistory: isFromChatHistory,
            onFlightSelected: onFlightSelected,
            onOpenInApp: onOpenInApp,
          ),
        );
        continue;
      }
      for (final cabin in cabins) {
        cards.add(
          _FlightSearchCard(
            flight: flight,
            cabin: cabin,
            isFromChatHistory: isFromChatHistory,
            onFlightSelected: onFlightSelected,
            onOpenInApp: onOpenInApp,
          ),
        );
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: cards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class _FlightSearchCard extends StatelessWidget {
  final FlightSearch flight;
  final FlightSearchCabin? cabin;
  final bool isFromChatHistory;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onFlightSelected;
  final void Function(FlightSearch flight, FlightSearchCabin cabin)?
      onOpenInApp;

  const _FlightSearchCard({
    required this.flight,
    required this.cabin,
    this.isFromChatHistory = false,
    this.onFlightSelected,
    this.onOpenInApp,
  });

  static const Color _cardBackground = Color(0xFFF5F7FF);
  static const Color _titleColor = Color(0xFF262626);
  static const Color _airportColor = Color(0xFF6E4185);
  static const Color _mutedColor = Color(0xFF979797);
  static const Color _amenityTextColor = Color(0xFF242424);
  static const Color _amenityIconColor = Color(0xFFA674BF);
  static const Color _perAdultColor = Color(0xFFA2A2A2);
  // static const Color _accentPurple = Color(0xFF8E2FFD);
  static const Color _pathLineColor = Color(0xFFEDE8F4);

  @override
  Widget build(BuildContext context) {
    final segments = flight.segments;
    final isRoundTrip = segments.length > 1;

    final card = Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 343),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (segments.isNotEmpty) ...[
                if (isRoundTrip)
                  ..._buildRoundTripSegments(segments)
                else
                  ..._buildOneWaySegment(segments.first),
                const SizedBox(height: 10),
              ],
              _buildAmenitiesAndPriceRow(),
              if (!isFromChatHistory) ...[
                const SizedBox(height: 10),
                _buildOpenInAppRow(),
              ],
            ],
          ),
        ),
      ),
    );

    if (onFlightSelected == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: cabin == null ? null : () => onFlightSelected?.call(flight, cabin!),
      child: card,
    );
  }

  List<Widget> _buildOneWaySegment(FlightSearchSegment segment) {
    return [
      _buildAirlineRow(segment),
      const SizedBox(height: 12),
      _buildFlightDetailsBox(
        segment,
        departureTime: _segmentDepartureTime(segment),
        arrivalTime: _segmentArrivalTime(segment),
      ),
    ];
  }

  List<Widget> _buildRoundTripSegments(List<FlightSearchSegment> segments) {
    final widgets = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(height: 6));
      }
      widgets.addAll([
        _buildAirlineRow(segments[i]),
        const SizedBox(height: 6),
        _buildFlightDetailsBox(
          segments[i],
          departureTime: _segmentDepartureTime(segments[i]),
          arrivalTime: _segmentArrivalTime(segments[i]),
        ),
      ]);
    }
    return widgets;
  }

  static String _segmentDepartureTime(FlightSearchSegment segment) {
    if (segment.departureTime.trim().isNotEmpty) {
      return segment.departureTime.trim();
    }
    return _formatFlightTime(segment.departureDate);
  }

  static String _segmentArrivalTime(FlightSearchSegment segment) {
    if (segment.arrivalTime.trim().isNotEmpty) {
      return segment.arrivalTime.trim();
    }
    return _formatFlightTime(segment.arrivalDate);
  }

  Widget _buildAirlineRow(FlightSearchSegment segment) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFD),
            borderRadius: BorderRadius.circular(4),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildAirlineLogo(segment.airlineLogo),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            segment.airlineName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: _titleColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAirlineLogo(String logoUrl) {
    if (logoUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Image.network(
      logoUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _buildFlightDetailsBox(
    FlightSearchSegment segment, {
    required String departureTime,
    required String arrivalTime,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildAirportColumn(
            time: departureTime,
            airport: segment.departureAirport,
            alignEnd: false,
          ),
          Expanded(child: _buildFlightPath(segment)),
          _buildAirportColumn(
            time: arrivalTime,
            airport: segment.arrivalAirport,
            alignEnd: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAirportColumn({
    required String time,
    required String airport,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: _titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          airport,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: _airportColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFlightPath(FlightSearchSegment segment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatDuration(segment.duration),
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: _mutedColor,
          ),
        ),
        const SizedBox(height: 1),
        SizedBox(
          height: 12,
          child: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 4,
                  margin: const EdgeInsetsDirectional.only(end: 6),
                  decoration: BoxDecoration(
                    color: _pathLineColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFD445EC),
                    Color(0xFFB02EFB),
                    Color(0xFF8E2FFD),
                    Color(0xFF5E3DFE),
                    Color(0xFF5186E0),
                  ],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.flight,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          _stopsLabel(segment),
          style: AppTextStyles.bodyText.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: _mutedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesAndPriceRow() {
    final selectedCabin = cabin;
    final baggageLabel =
        selectedCabin == null ? '' : _baggageLabel(selectedCabin);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmenityRow(
                icon: Icons.restaurant,
                label: AppTranslations.complimentaryCuisine,
              ),
              if (baggageLabel.isNotEmpty) ...[
                const SizedBox(height: 3),
                _buildAmenityRow(
                  icon: Icons.shopping_bag_outlined,
                  label: baggageLabel,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              selectedCabin == null
                  ? ''
                  : _formatPrice(
                      selectedCabin.currencyCode,
                      selectedCabin.totalRate,
                    ),
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppTranslations.perAdult,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: _perAdultColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityRow({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: _amenityIconColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: _amenityTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOpenInAppRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: cabin == null ? null : () => onOpenInApp?.call(flight, cabin!),
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

  static String _formatFlightTime(String raw) {
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return '';
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _formatDuration(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.replaceAll(':', ' ');
  }

  static String _stopsLabel(FlightSearchSegment segment) {
    if (segment.stops.isEmpty) return AppTranslations.nonStop;
    if (segment.stops.length == 1) return AppTranslations.oneStop;
    return AppTranslations.nStops(segment.stops.length.toString());
  }

  static String _baggageLabel(FlightSearchCabin cabin) {
    for (final detail in cabin.baggageDetails) {
      for (final passengerBaggage in detail.passengerBaggages) {
        String? cabinQty;
        String? checkInQty;

        for (final allowance in passengerBaggage.baggage) {
          final type = allowance.type.toLowerCase();
          if (type.contains('cabin')) {
            cabinQty = allowance.freeQuantity;
          } else if (type.contains('check')) {
            checkInQty = allowance.freeQuantity;
          }
        }

        final checkIn = int.tryParse(checkInQty ?? '0') ?? 0;
        final cabinBag = int.tryParse(cabinQty ?? '0') ?? 0;

        if (checkIn > 0) {
          return AppTranslations.checkInKg(checkIn.toString());
        }
        if (checkIn <= 0 && cabinBag > 0) {
          return AppTranslations.handBagOnly;
        }
        if (cabinBag > 0) {
          return AppTranslations.cabinBagKg(cabinBag.toString());
        }
      }
    }
    return AppTranslations.handBagOnly;
  }

  static String _formatPrice(String currency, double value) {
    final code = currency.trim().isEmpty ? 'AED' : currency.trim();
    final formatted = value.toStringAsFixed(2);
    return '$code$formatted';
  }
}
