import 'dart:convert';

/// Model for greeting-style responses
class GreetingResponse {
  final String greeting;
  final String subtitle;
  final List<String> options;
  final String weatherText;

  GreetingResponse({
    required this.greeting,
    required this.subtitle,
    required this.options,
    required this.weatherText,
  });

  factory GreetingResponse.fromJson(Map<String, dynamic> json) {
    return GreetingResponse(
      greeting: json['greeting']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      weatherText: json['weatherText']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greeting': greeting,
      'subtitle': subtitle,
      'options': options,
    };
  }

  @override
  String toString() {
    return 'GreetingResponse(greeting: $greeting, subtitle: $subtitle, options: ${options
        .length} items)';
  }
}

/// Helper extension for parsing JSON strings into [GreetingResponse]
extension GreetingParsingExtension on String {
  GreetingResponse toGreetingResponse() {
    final Map<String, dynamic> json = jsonDecode(this) as Map<String, dynamic>;
    return GreetingResponse.fromJson(json);
  }
}
