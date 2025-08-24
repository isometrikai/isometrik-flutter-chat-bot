import 'dart:convert';

// Main API Response Model
class MyGPTsResponse {
  final String message;
  final List<GPTBot> data;
  final int count;

  MyGPTsResponse({
    required this.message,
    required this.data,
    required this.count,
  });

  factory MyGPTsResponse.fromJson(Map<String, dynamic> json) {
    return MyGPTsResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => GPTBot.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((bot) => bot.toJson()).toList(),
      'count': count,
    };
  }

  @override
  String toString() {
    return 'MyGPTsResponse(message: $message, count: $count, data: $data)';
  }
}

// GPT Bot Model
class GPTBot {
  final int id;
  final String botIdentifier;
  final String accountId;
  final String projectId;
  final String name;
  final String userId;
  final UIPreferences uiPreferences;
  final String timezone;
  final String? templateId;
  final List<String> suggestedReplies;
  final String profileImage;
  final List<BotStatus> status;
  final String createdAt;
  final String botType;
  final List<String> welcomeMessage;
  final int appType;

  GPTBot({
    required this.id,
    required this.botIdentifier,
    required this.accountId,
    required this.projectId,
    required this.name,
    required this.userId,
    required this.uiPreferences,
    required this.timezone,
    this.templateId,
    required this.suggestedReplies,
    required this.profileImage,
    required this.status,
    required this.createdAt,
    required this.botType,
    required this.welcomeMessage,
    required this.appType,
  });

  factory GPTBot.fromJson(Map<String, dynamic> json) {
    return GPTBot(
      id: json['id'] ?? 0,
      botIdentifier: json['bot_identifier'] ?? '',
      accountId: json['account_id'] ?? '',
      projectId: json['project_id'] ?? '',
      name: json['name'] ?? '',
      userId: json['user_id'] ?? '',
      uiPreferences: UIPreferences.fromJson(
          json['ui_preferences'] as Map<String, dynamic>? ?? {}),
      timezone: json['timezone'] ?? '',
      templateId: json['template_id'],
      suggestedReplies: (json['suggested_replies'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
      profileImage: json['profile_image'] ?? '',
      status: (json['status'] as List<dynamic>?)
          ?.map((item) => BotStatus.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      botType: json['bot_type'] ?? '',
      welcomeMessage: (json['welcome_message'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
      appType: json['app_type'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bot_identifier': botIdentifier,
      'account_id': accountId,
      'project_id': projectId,
      'name': name,
      'user_id': userId,
      'ui_preferences': uiPreferences.toJson(),
      'timezone': timezone,
      'template_id': templateId,
      'suggested_replies': suggestedReplies,
      'profile_image': profileImage,
      'status': status.map((s) => s.toJson()).toList(),
      'created_at': createdAt,
      'bot_type': botType,
      'welcome_message': welcomeMessage,
      'app_type': appType,
    };
  }

  @override
  String toString() {
    return 'GPTBot(id: $id, name: $name, botType: $botType, status: ${status.length} items)';
  }
}

// UI Preferences Model
class UIPreferences {
  final int modeTheme;
  final String primaryColor;
  final String botBubbleColor;
  final String userBubbleColor;
  final String fontSize;
  final String fontStyle;
  final String botBubbleFontColor;
  final String userBubbleFontColor;
  final String launcherImage;
  final String launcherWelcomeMessage;
  final int selectedLauncherImageType;

  UIPreferences({
    required this.modeTheme,
    required this.primaryColor,
    required this.botBubbleColor,
    required this.userBubbleColor,
    required this.fontSize,
    required this.fontStyle,
    required this.botBubbleFontColor,
    required this.userBubbleFontColor,
    required this.launcherImage,
    required this.launcherWelcomeMessage,
    required this.selectedLauncherImageType,
  });

  factory UIPreferences.fromJson(Map<String, dynamic> json) {
    return UIPreferences(
      modeTheme: json['mode_theme'] ?? 1,
      primaryColor: json['primary_color'] ?? '#000000',
      botBubbleColor: json['bot_bubble_color'] ?? '#000000',
      userBubbleColor: json['user_bubble_color'] ?? '#000000',
      fontSize: json['font_size'] ?? '12px',
      fontStyle: json['font_style'] ?? 'Arial',
      botBubbleFontColor: json['bot_bubble_font_color'] ?? '#000000',
      userBubbleFontColor: json['user_bubble_font_color'] ?? '#000000',
      launcherImage: json['launcher_image'] ?? '',
      launcherWelcomeMessage: json['launcher_welcome_message'] ?? '',
      selectedLauncherImageType: json['selected_launcher_image_type'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode_theme': modeTheme,
      'primary_color': primaryColor,
      'bot_bubble_color': botBubbleColor,
      'user_bubble_color': userBubbleColor,
      'font_size': fontSize,
      'font_style': fontStyle,
      'bot_bubble_font_color': botBubbleFontColor,
      'user_bubble_font_color': userBubbleFontColor,
      'launcher_image': launcherImage,
      'launcher_welcome_message': launcherWelcomeMessage,
      'selected_launcher_image_type': selectedLauncherImageType,
    };
  }

  @override
  String toString() {
    return 'UIPreferences(theme: $modeTheme, primaryColor: $primaryColor)';
  }
}

// Bot Status Model
class BotStatus {
  final String id;
  final int timestamp;
  final String statusText;

  BotStatus({
    required this.id,
    required this.timestamp,
    required this.statusText,
  });

  factory BotStatus.fromJson(Map<String, dynamic> json) {
    return BotStatus(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      statusText: json['statusText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'statusText': statusText,
    };
  }

  // Helper method to get DateTime from timestamp
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  // Helper method to check if bot is active
  bool get isActive => statusText.toUpperCase() == 'ACTIVE';

  @override
  String toString() {
    return 'BotStatus(id: $id, status: $statusText, timestamp: $timestamp)';
  }
}

// Helper extension for parsing JSON strings
extension JsonParsingExtension on String {
  MyGPTsResponse toMyGPTsResponse() {
    final Map<String, dynamic> json = jsonDecode(this);
    return MyGPTsResponse.fromJson(json);
  }
}