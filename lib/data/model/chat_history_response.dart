import 'chat_response.dart';

// Model for session list
class ChatHistoryResponse {
  final int sessionId;
  final String title;
  final String? timestamp;

  ChatHistoryResponse({
    required this.sessionId,
    required this.title,
    this.timestamp,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      sessionId: json['session_id'] as int,
      title: json['title'] as String? ?? '',
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'title': title,
      'timestamp': timestamp,
    };
  }
}

// Model for detailed chat history of a session
class ChatHistoryDetail {
  final String userMessage;
  final List<ChatHistoryMessageResponse> response;
  final String timestamp;

  ChatHistoryDetail({
    required this.userMessage,
    required this.response,
    required this.timestamp,
  });

  factory ChatHistoryDetail.fromJson(Map<String, dynamic> json) {
    List<ChatHistoryMessageResponse> responseList = [];
    
    if (json['response'] != null && json['response'] is List) {
      responseList = (json['response'] as List)
          .map((item) => ChatHistoryMessageResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ChatHistoryDetail(
      userMessage: json['user_message'] ?? '',
      response: responseList,
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_message': userMessage,
      'response': response.map((r) => r.toJson()).toList(),
      'timestamp': timestamp,
    };
  }
}

// Model for each response in chat history
class ChatHistoryMessageResponse {
  final String text;
  final List<ChatWidget> widgets;

  ChatHistoryMessageResponse({
    required this.text,
    required this.widgets,
  });

  factory ChatHistoryMessageResponse.fromJson(Map<String, dynamic> json) {
    List<ChatWidget> widgetsList = [];
    
    // Handle widgets field - it can be null, a String (error case), or a List
    final widgetsData = json['widgets'];
    if (widgetsData != null) {
      if (widgetsData is List) {
        // Normal case: widgets is a list
        widgetsList = widgetsData
            .map((item) => ChatWidget.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (widgetsData is String) {
        // Edge case: widgets is a string (like error messages)
        // In this case, we don't parse it as widgets and leave the list empty
        widgetsList = [];
      }
    }

    return ChatHistoryMessageResponse(
      text: json['text'] ?? '',
      widgets: widgetsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'widgets': widgets.map((widget) => widget.toJson()).toList(),
    };
  }

  // Helper method to check if response has widgets
  bool get hasWidgets => widgets.isNotEmpty;

  // Helper method to get widgets by type
  List<ChatWidget> getWidgetsByType(String type) {
    return widgets.where((widget) => widget.type == type).toList();
  }

  // Helper methods for specific widget types
  List<ChatWidget> get optionsWidgets => getWidgetsByType('options');
  List<ChatWidget> get storesWidgets => getWidgetsByType('stores');
  List<ChatWidget> get productsWidgets => getWidgetsByType('products');
  List<ChatWidget> get seeMoreWidgets => getWidgetsByType('see_more');
  List<ChatWidget> get cartWidgets => getWidgetsByType('cart');
  List<ChatWidget> get menuWidgets => getWidgetsByType('menu');
  List<ChatWidget> get chooseAddressWidgets => getWidgetsByType('choose_address');
  List<ChatWidget> get chooseCardWidgets => getWidgetsByType('choose_card');
  List<ChatWidget> get orderSummaryWidgets => getWidgetsByType('order_summary');
  List<ChatWidget> get orderConfirmedWidgets => getWidgetsByType('order_confirmed');
  List<ChatWidget> get orderTrackingWidgets => getWidgetsByType('order_tracking');
  List<ChatWidget> get orderDetailsWidgets => getWidgetsByType('order_details');
  List<ChatWidget> get proceedToCheckoutWidgets => getWidgetsByType('proceed_to_checkout');
}

