import 'package:equatable/equatable.dart';
import 'package:chat_bot/data/data.dart';

abstract class StoreDetailsState extends Equatable {
  const StoreDetailsState();

  @override
  List<Object?> get props => [];
}

class StoreDetailsInitial extends StoreDetailsState {}

class StoreDetailsLoadInProgress extends StoreDetailsState {
  final String? date; // Track which date is being loaded

  const StoreDetailsLoadInProgress({this.date});

  @override
  List<Object?> get props => [date];
}

class StoreDetailsLoadSuccess extends StoreDetailsState {
  final String date;
  final List<AvailabilitySlot> slots;

  const StoreDetailsLoadSuccess({
    required this.date,
    required this.slots,
  });

  @override
  List<Object?> get props => [date, slots];
}

class StoreDetailsLoadFailure extends StoreDetailsState {
  final String message;
  final String? date; // Track which date failed

  const StoreDetailsLoadFailure(this.message, {this.date});

  @override
  List<Object?> get props => [message, date];
}
