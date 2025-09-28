import 'dart:convert';

/// Model for option items in greeting responses
class GreetingOption {
  final String title;
  final String subTitle;
  final String emoji;

  GreetingOption({
    required this.title,
    required this.subTitle,
    required this.emoji,
  });

  factory GreetingOption.fromJson(Map<String, dynamic> json) {
    return GreetingOption(
      title: json['title']?.toString() ?? '',
      subTitle: json['subTitle']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subTitle': subTitle,
      'emoji': emoji,
    };
  }

  @override
  String toString() {
    return 'GreetingOption(title: $title, subTitle: $subTitle, emoji: $emoji)';
  }
}

/// Model for greeting-style responses
class GreetingResponse {
  final String greeting;
  final String subtitle;
  final List<GreetingOption> options;
  final String weatherText;
  final String personaTitle;
  final String personaDesc;

  GreetingResponse({
    required this.greeting,
    required this.subtitle,
    required this.options,
    required this.weatherText,
    required this.personaTitle,
    required this.personaDesc,
  });

  factory GreetingResponse.fromJson(Map<String, dynamic> json) {
    return GreetingResponse(
      greeting: json['greeting']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      weatherText: json['weatherText']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((item) => GreetingOption.fromJson(item as Map<String, dynamic>))
          .toList() ??
          <GreetingOption>[],
      personaTitle: json['personaTitle']?.toString() ?? '',
      personaDesc: json['personaDesc']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'greeting': greeting,
      'subtitle': subtitle,
      'weatherText': weatherText,
      'options': options.map((option) => option.toJson()).toList(),
      'personaTitle': personaTitle,
      'personaDesc': personaDesc,
    };
  }

  @override
  String toString() {
    return 'GreetingResponse(greeting: $greeting, subtitle: $subtitle, options: ${options.length}, personaTitle: $personaTitle, personaDesc: $personaDesc)';
  }
}

/// Helper extension for parsing JSON strings into [GreetingResponse]
extension GreetingParsingExtension on String {
  GreetingResponse toGreetingResponse() {
    final Map<String, dynamic> json = jsonDecode(this) as Map<String, dynamic>;
    return GreetingResponse.fromJson(json);
  }
}
