import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/model/hotel_availability_response.dart';

abstract class HotelAvailabilityState extends Equatable {
  const HotelAvailabilityState();

  @override
  List<Object?> get props => [];
}

class HotelAvailabilityInitial extends HotelAvailabilityState {}

class HotelAvailabilityLoadInProgress extends HotelAvailabilityState {
  const HotelAvailabilityLoadInProgress({
    this.hotelName = '',
    this.hotelImageUrl = '',
    this.bookingSummary = '',
  });

  final String hotelName;
  final String hotelImageUrl;
  final String bookingSummary;

  @override
  List<Object?> get props => [hotelName, hotelImageUrl, bookingSummary];
}

class HotelAvailabilityLoadSuccess extends HotelAvailabilityState {
  const HotelAvailabilityLoadSuccess({
    required this.rooms,
    required this.selectedRoomId,
    required this.hotelName,
    required this.hotelImageUrl,
    required this.bookingSummary,
  });

  final List<HotelRoom> rooms;
  final String selectedRoomId;
  final String hotelName;
  final String hotelImageUrl;
  final String bookingSummary;

  HotelRoom? get selectedRoom {
    if (selectedRoomId.isEmpty) return null;
    for (final room in rooms) {
      if (room.id == selectedRoomId) return room;
    }
    return null;
  }

  HotelRoomSelection? get selection {
    final room = selectedRoom;
    final rate = room?.lowestRate;
    if (room == null || rate == null) return null;
    return HotelRoomSelection(
      room: room,
      rate: rate,
      bed: rate.beds.isNotEmpty ? rate.beds.first : null,
    );
  }

  HotelAvailabilityLoadSuccess copyWith({
    List<HotelRoom>? rooms,
    String? selectedRoomId,
    String? hotelName,
    String? hotelImageUrl,
    String? bookingSummary,
  }) {
    return HotelAvailabilityLoadSuccess(
      rooms: rooms ?? this.rooms,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      hotelName: hotelName ?? this.hotelName,
      hotelImageUrl: hotelImageUrl ?? this.hotelImageUrl,
      bookingSummary: bookingSummary ?? this.bookingSummary,
    );
  }

  @override
  List<Object?> get props => [
        rooms,
        selectedRoomId,
        hotelName,
        hotelImageUrl,
        bookingSummary,
      ];
}

class HotelAvailabilityLoadFailure extends HotelAvailabilityState {
  const HotelAvailabilityLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
