/// Response for GET /v1/zinrelo/member/points (Zinrelo member points).
class MemberPointsResponse {
  const MemberPointsResponse({this.availablePoints = 0});

  final int availablePoints;

  factory MemberPointsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) return const MemberPointsResponse();
    final points = data['availablePoints'];
    return MemberPointsResponse(
      availablePoints: points is int ? points : (int.tryParse(points?.toString() ?? '0') ?? 0),
    );
  }
}
