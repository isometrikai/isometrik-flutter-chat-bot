import 'package:equatable/equatable.dart';

abstract class StoreDetailsEvent extends Equatable {
  const StoreDetailsEvent();

  @override
  List<Object?> get props => [];
}

class AvailabilitySlotsRequested extends StoreDetailsEvent {
  final String date; // Format: MM/dd/yyyy
  final String userId;
  final String storeCategoryId;
  final String eventType;
  final String timeZone;

  const AvailabilitySlotsRequested({
    required this.date,
    required this.userId,
    required this.storeCategoryId,
    this.eventType = 'teleCallAvgMin',
    this.timeZone = 'Asia/Kolkata',
  });

  @override
  List<Object?> get props => [date, userId, storeCategoryId, eventType, timeZone];
}
