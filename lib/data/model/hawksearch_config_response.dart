class HawkSearchConfigData {
  final String searchApiUrl;
  final String visitorId;
  final String visitId;
  final String clientGuid;
  final String indexName;

  const HawkSearchConfigData({
    required this.searchApiUrl,
    required this.visitorId,
    required this.visitId,
    required this.clientGuid,
    required this.indexName,
  });

  factory HawkSearchConfigData.fromJson(Map<String, dynamic> json) {
    return HawkSearchConfigData(
      searchApiUrl: (json['url'] ?? json['search_api_url'] ?? '').toString(),
      visitorId: (json['visitorId'] ?? json['visitor_id'] ?? '').toString(),
      visitId: (json['visitId'] ?? json['visit_id'] ?? '').toString(),
      clientGuid: (json['ClientGuid'] ??
              json['clientGuid'] ??
              json['client_guid'] ??
              '')
          .toString(),
      indexName: (json['IndexName'] ??
              json['indexName'] ??
              json['index_name'] ??
              '')
          .toString(),
    );
  }
}

class HawkSearchConfigResponse {
  final HawkSearchConfigData? data;
  final String message;

  const HawkSearchConfigResponse({
    required this.data,
    required this.message,
  });

  factory HawkSearchConfigResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return HawkSearchConfigResponse(
      data: rawData is Map<String, dynamic>
          ? HawkSearchConfigData.fromJson(rawData)
          : null,
      message: (json['message'] ?? '').toString(),
    );
  }
}
