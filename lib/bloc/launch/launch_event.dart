import 'package:equatable/equatable.dart';

abstract class LaunchEvent extends Equatable {
  const LaunchEvent();

  @override
  List<Object?> get props => [];
}

class LaunchRequested extends LaunchEvent {
  const LaunchRequested();
}

class LaunchRetried extends LaunchEvent {
  const LaunchRetried();
}


