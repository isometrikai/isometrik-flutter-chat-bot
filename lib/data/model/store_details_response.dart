class StoreDetailsResponse {
  final String message;
  final StoreDetailsData data;

  StoreDetailsResponse({
    required this.message,
    required this.data,
  });

  factory StoreDetailsResponse.fromJson(Map<String, dynamic> json) {
    return StoreDetailsResponse(
      message: json['message'] ?? '',
      data: StoreDetailsData.fromJson(json['data'] ?? {}),
    );
  }
}

class StoreDetailsData {
  final List<StoreTiming> timing;

  StoreDetailsData({
    required this.timing,
  });

  factory StoreDetailsData.fromJson(Map<String, dynamic> json) {
    return StoreDetailsData(
      timing: (json['timing'] as List<dynamic>?)
              ?.map((item) => StoreTiming.fromJson(item as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}

class StoreTiming {
  final String day;
  final String time;
  final int startDate;
  final int endDate;

  StoreTiming({
    required this.day,
    required this.time,
    required this.startDate,
    required this.endDate,
  });

  factory StoreTiming.fromJson(Map<String, dynamic> json) {
    return StoreTiming(
      day: json['day'] ?? '',
      time: json['time'] ?? '',
      startDate: json['startDate'] ?? 0,
      endDate: json['endDate'] ?? 0,
    );
  }
}

