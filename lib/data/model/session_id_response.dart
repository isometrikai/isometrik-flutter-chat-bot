class SessionIdResponse {
  final int sessionId;
  final String message;
  final Map<String, String> storeCategories;

  SessionIdResponse({
    required this.sessionId,
    required this.message,
    this.storeCategories = const {},
  });

  factory SessionIdResponse.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['store_categories'];
    final Map<String, String> categories = rawCategories is Map
        ? rawCategories.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          )
        : const {};

    return SessionIdResponse(
      sessionId: json['session_id'] as int,
      message: json['message'] as String,
      storeCategories: categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'message': message,
      'store_categories': storeCategories,
    };
  }
}
