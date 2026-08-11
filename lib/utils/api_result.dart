class ApiResult {
  bool isSuccess;
  final String? message;
  dynamic data;
  final int? statusCode;

  ApiResult._(this.isSuccess, this.message, this.data, [this.statusCode]);

  factory ApiResult.success(dynamic data) => ApiResult._(true, null, data);

  factory ApiResult.error(String message, [dynamic data, int? statusCode]) =>
      ApiResult._(false, message, data, statusCode);

  /// Whether the request failed due to an expired or invalid token (406 refresh path)
  bool get isUnauthorized => message == "Unauthorized";

  /// Whether the request failed with HTTP/body status 401 (logout path)
  bool get isTokenExpired =>
      statusCode == 401 || message == "TokenExpired";

  /// Whether the request failed and was not unauthorized / token-expired
  bool get isFailure => !isSuccess && !isUnauthorized && !isTokenExpired;
}
