/// Response for GET /v1/customer/profile.
class CustomerProfileResponse {
  const CustomerProfileResponse({this.zainPersonalization = false});

  final bool zainPersonalization;

  factory CustomerProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const CustomerProfileResponse();
    }
    return CustomerProfileResponse(
      zainPersonalization: data['zain_personalization'] == true,
    );
  }
}
