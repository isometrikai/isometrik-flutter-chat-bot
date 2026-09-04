class ApiResult {
  bool isSuccess;
  final String? message;
  dynamic data;
  final int? statusCode;

  ApiResult._(this.isSuccess, this.message, this.data, [this.statusCode]);

  factory ApiResult.success(dynamic data) => ApiResult._(true, null, data);

  factory ApiResult.error(String message, [dynamic data, int? statusCode]) =>
      ApiResult._(false, message, data, statusCode);

  /// 406 — the access token expired and can be refreshed, then the request retried.
  bool get isUnauthorized => !isSuccess && statusCode == 406;

  /// 401 — the session is no longer valid and the user must be logged out.
  bool get isTokenExpired => !isSuccess && statusCode == 401;

  /// Any other failure (validation, server or network error).
  bool get isFailure => !isSuccess && !isUnauthorized && !isTokenExpired;
}
