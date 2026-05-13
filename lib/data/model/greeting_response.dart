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

/// Model for reminder items in greeting responses
class GreetingReminder {
  final String eventType;
  final String emoji;
  final String daysUntil;
  final String title;
  final String subtitle;
  final List<String> buttons;

  GreetingReminder({
    required this.eventType,
    required this.emoji,
    required this.daysUntil,
    required this.title,
    required this.subtitle,
    required this.buttons,
  });

  factory GreetingReminder.fromJson(Map<String, dynamic> json) {
    return GreetingReminder(
      eventType: json['eventType']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      daysUntil: json['daysUntil']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      buttons: (json['buttons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'emoji': emoji,
      'daysUntil': daysUntil,
      'title': title,
      'subtitle': subtitle,
      'buttons': buttons,
    };
  }

  @override
  String toString() {
    return 'GreetingReminder(eventType: $eventType, title: $title, daysUntil: $daysUntil)';
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
  final bool setupUserPreference;
  final List<GreetingReminder> reminders;

  GreetingResponse({
    required this.greeting,
    required this.subtitle,
    required this.options,
    required this.weatherText,
    required this.personaTitle,
    required this.personaDesc,
    required this.setupUserPreference,
    this.reminders = const [],
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
      setupUserPreference: json['setupUserPreference'] ?? false,
      reminders: (json['reminders'] as List<dynamic>?)
          ?.map((item) => GreetingReminder.fromJson(item as Map<String, dynamic>))
          .toList() ??
          <GreetingReminder>[],
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
      'userPreference': setupUserPreference,
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'GreetingResponse(greeting: $greeting, subtitle: $subtitle, options: ${options.length}, reminders: ${reminders.length}, personaTitle: $personaTitle, personaDesc: $personaDesc)';
  }
}

/// Helper extension for parsing JSON strings into [GreetingResponse]
extension GreetingParsingExtension on String {
  GreetingResponse toGreetingResponse() {
    final Map<String, dynamic> json = jsonDecode(this) as Map<String, dynamic>;
    return GreetingResponse.fromJson(json);
  }
}
