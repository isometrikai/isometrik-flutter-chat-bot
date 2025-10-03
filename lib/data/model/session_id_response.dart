class SessionIdResponse {
  final int sessionId;
  final String message;

  SessionIdResponse({
    required this.sessionId,
    required this.message,
  });

  factory SessionIdResponse.fromJson(Map<String, dynamic> json) {
    return SessionIdResponse(
      sessionId: json['session_id'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'message': message,
    };
  }
}

