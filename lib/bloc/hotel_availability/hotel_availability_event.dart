import 'package:equatable/equatable.dart';

abstract class HotelAvailabilityEvent extends Equatable {
  const HotelAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class HotelAvailabilityFetchRequested extends HotelAvailabilityEvent {
  const HotelAvailabilityFetchRequested({
    required this.hotelBooking,
    this.hotelName = '',
    this.hotelImageUrl = '',
  });

  final Map<String, dynamic> hotelBooking;
  final String hotelName;
  final String hotelImageUrl;

  @override
  List<Object?> get props => [hotelBooking, hotelName, hotelImageUrl];
}

class HotelRoomSelected extends HotelAvailabilityEvent {
  const HotelRoomSelected(this.roomId);

  final String roomId;

  @override
  List<Object?> get props => [roomId];
}
