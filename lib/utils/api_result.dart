class ApiResult {
  bool isSuccess;
  final String? message;
  dynamic data;

  ApiResult._(this.isSuccess, this.message, this.data);

  factory ApiResult.success(dynamic data) => ApiResult._(true, null, data);

  factory ApiResult.error(String message, [dynamic data]) =>
      ApiResult._(false, message, data);

  /// Whether the request failed due to an expired or invalid token
  bool get isUnauthorized => message == "Unauthorized";

  /// Whether the request failed and was not unauthorized
  bool get isFailure => !isSuccess && !isUnauthorized;
}


