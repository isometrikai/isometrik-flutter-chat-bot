class AvailabilitySlotsResponse {
  final String status;
  final String message;
  final List<AvailabilitySlot> data;

  AvailabilitySlotsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AvailabilitySlotsResponse.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlotsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => AvailabilitySlot.fromJson(item as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}

class AvailabilitySlot {
  final int from;
  final String fromStr;
  final int to;
  final String toStr;
  final int duration;
  final bool isAvailable;

  AvailabilitySlot({
    required this.from,
    required this.fromStr,
    required this.to,
    required this.toStr,
    required this.duration,
    required this.isAvailable,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      from: json['from'] ?? 0,
      fromStr: json['fromStr'] ?? '',
      to: json['to'] ?? 0,
      toStr: json['toStr'] ?? '',
      duration: json['duration'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}

