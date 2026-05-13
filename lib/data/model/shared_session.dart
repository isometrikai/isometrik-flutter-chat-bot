class SharedSession {
  final String shareId;
  final String shareUrl;
  final int sessionId;
  final bool isActive;
  final String? createdAt;
  final String? revokedAt;
  final String? title;

  const SharedSession({
    required this.shareId,
    required this.shareUrl,
    required this.sessionId,
    required this.isActive,
    this.createdAt,
    this.revokedAt,
    this.title,
  });

  factory SharedSession.fromJson(Map<String, dynamic> json) {
    return SharedSession(
      shareId: json['share_id'] as String? ?? '',
      shareUrl: json['share_url'] as String? ?? '',
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      revokedAt: json['revoked_at'] as String?,
      title: json['title'] as String?,
    );
  }
}

