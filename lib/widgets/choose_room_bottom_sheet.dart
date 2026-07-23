import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/hotel_availability/hotel_availability_bloc.dart';
import '../bloc/hotel_availability/hotel_availability_event.dart';
import '../bloc/hotel_availability/hotel_availability_state.dart';
import '../data/model/hotel_availability_response.dart';
import '../utils/utils.dart';

/// Choose Room bottom sheet (Figma frame 1171285017).
class ChooseRoomBottomSheet extends StatelessWidget {
  final String hotelName;
  final String hotelImageUrl;
  final void Function(HotelRoomSelection selection)? onNext;

  const ChooseRoomBottomSheet({
    super.key,
    required this.hotelName,
    required this.hotelImageUrl,
    this.onNext,
  });

  static Future<HotelRoomSelection?> show(
    BuildContext context, {
    required Map<String, dynamic> hotelBooking,
    String hotelName = '',
    String hotelImageUrl = '',
    void Function(HotelRoomSelection selection)? onNext,
  }) {
    return showModalBottomSheet<HotelRoomSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AppLocale.wrap(
          BlocProvider(
            create: (_) => HotelAvailabilityBloc()
              ..add(
                HotelAvailabilityFetchRequested(
                  hotelBooking: hotelBooking,
                  hotelName: hotelName,
                  hotelImageUrl: hotelImageUrl,
                ),
              ),
            child: ChooseRoomBottomSheet(
              hotelName: hotelName,
              hotelImageUrl: hotelImageUrl,
              onNext: (selection) {
                onNext?.call(selection);
                Navigator.of(sheetContext).pop(selection);
              },
            ),
          ),
        );
      },
    );
  }

  static const Color _sheetBackground = Color(0xFFF5F7FF);
  // static const Color _accentPurple = Color(0xFF8E2FFD);
  static const Color _labelPurple = Color(0xFF6E4185);
  static const Color _titleColor = Color(0xFF242424);
  static const Color _mutedGrey = Color(0xFF979797);
  static const Color _featureGrey = Color(0xFF4B4B4B);
  static const Color _recommendGreen = Color(0xFF00CD4F);
  static const Color _cardBorder = Color(0xFFEEF4FF);
  static const Color _radioBorderIdle = Color(0xFFE9DFFB);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: _sheetBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE9DFFB)),
          Flexible(child: _buildBody(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<HotelAvailabilityBloc, HotelAvailabilityState>(
      builder: (context, state) {
        final name = state is HotelAvailabilityLoadSuccess
            ? state.hotelName
            : state is HotelAvailabilityLoadInProgress
                ? state.hotelName
                : hotelName;
        final imageUrl = state is HotelAvailabilityLoadSuccess
            ? state.hotelImageUrl
            : state is HotelAvailabilityLoadInProgress
                ? state.hotelImageUrl
                : hotelImageUrl;
        final summary = state is HotelAvailabilityLoadSuccess
            ? state.bookingSummary
            : state is HotelAvailabilityLoadInProgress
                ? state.bookingSummary
                : '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HotelThumbnail(imageUrl: imageUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name.isNotEmpty ? name : AppTranslations.hotelFallback,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: _titleColor,
                      ),
                    ),
                  ),
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                ],
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      AppTranslations.dateLabel,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 12,
                        height: 1.4,
                        color: _labelPurple,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: 12,
                          height: 1.4,
                          color: _titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<HotelAvailabilityBloc, HotelAvailabilityState>(
      builder: (context, state) {
        if (state is HotelAvailabilityLoadInProgress) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator(
              color: AppConstants.appThemeColor,
            )),
          );
        }

        if (state is HotelAvailabilityLoadFailure) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(color: _titleColor),
            ),
          );
        }

        if (state is! HotelAvailabilityLoadSuccess) {
          return const SizedBox.shrink();
        }

        return ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
          children: [
            const SizedBox(height: 8),
            Text(
              AppTranslations.chooseRoom,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: _titleColor,
              ),
            ),
            const SizedBox(height: 8),
            ...state.rooms.map(
              (room) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RoomCard(
                  room: room,
                  isSelected: room.id == state.selectedRoomId,
                  onSelect: () {
                    context
                        .read<HotelAvailabilityBloc>()
                        .add(HotelRoomSelected(room.id));
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return BlocBuilder<HotelAvailabilityBloc, HotelAvailabilityState>(
      builder: (context, state) {
        final enabled = state is HotelAvailabilityLoadSuccess &&
            state.selection != null;

        return Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
          color: _sheetBackground,
          child: _GradientNextButton(
            enabled: enabled,
            onPressed: enabled
                ? () {
                    final selection = state.selection!;
                    onNext?.call(selection);
                  }
                : null,
          ),
        );
      },
    );
  }
}

class _HotelThumbnail extends StatelessWidget {
  final String imageUrl;

  const _HotelThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.5),
      child: SizedBox(
        width: 35,
        height: 35,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ThumbnailPlaceholder(),
              )
            : const _ThumbnailPlaceholder(),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFD9D9D9),
      child: Icon(Icons.hotel, size: 18, color: Color(0xFF979797)),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(38),
        ),
        child: const Icon(Icons.close, size: 12, color: Color(0xFF585C77)),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final HotelRoom room;
  final bool isSelected;
  final VoidCallback onSelect;

  const _RoomCard({
    required this.room,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final rate = room.lowestRate;
    final priceLabel = rate == null
        ? ''
        : _formatPrice(rate.currency, rate.totalRate);
    final roomsLabel = room.availability > 0
        ? AppTranslations.totalForRooms(room.availability.toString())
        : '';

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: ChooseRoomBottomSheet._cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    room.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: ChooseRoomBottomSheet._titleColor,
                    ),
                  ),
                ),
                _RoomRadio(isSelected: isSelected),
              ],
            ),
            if (room.recommendationLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                room.recommendationLabel,
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 12,
                  height: 1.4,
                  color: ChooseRoomBottomSheet._recommendGreen,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: ChooseRoomBottomSheet._sheetBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < room.featureLines.length; i++) ...[
                    if (i > 0) const SizedBox(height: 2),
                    Text(
                      room.featureLines[i],
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 12,
                        height: 1.4,
                        color: ChooseRoomBottomSheet._featureGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (priceLabel.isNotEmpty)
                  Text(
                    priceLabel,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 14,
                      height: 1.4,
                      color: ChooseRoomBottomSheet._titleColor,
                    ),
                  ),
                if (roomsLabel.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    roomsLabel,
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 14,
                      height: 1.4,
                      color: ChooseRoomBottomSheet._mutedGrey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(String currency, double value) {
    final code = currency.trim().isEmpty ? 'AED' : currency.trim();
    final formatted = value.truncateToDouble() == value
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$code $formatted';
  }
}

class _RoomRadio extends StatelessWidget {
  final bool isSelected;

  const _RoomRadio({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppConstants.appThemeColor
              : ChooseRoomBottomSheet._radioBorderIdle,
          width: 0.83,
        ),
      ),
      child: isSelected
          ? Container(
              decoration: const BoxDecoration(
                color: AppConstants.appThemeColor,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _GradientNextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const _GradientNextButton({
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: enabled
          //       ? [
          //          AppConstants.appThemeColor,
          //         ]
          //       : const [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          // ),
          color: enabled ? AppConstants.appThemeColor : Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            AppTranslations.next,
            style: AppTextStyles.button.copyWith(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
