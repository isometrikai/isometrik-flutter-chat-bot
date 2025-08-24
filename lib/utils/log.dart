import 'dart:developer';
import 'dart:convert';


class AppLog {
  ///This Constructor of `AppLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `white` color.
  ///
  ///It can be used for basic logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `AppLog.info()` - for information log
  ///- `AppLog.success()` - for success log
  ///- `AppLog.error()` - for error log
  AppLog(this.message, [this.stackTrace]) {
    log(
      '\x1B[37m[CHATBOT] - $message\x1B[0m',
      stackTrace: stackTrace,
      level: 700,
    );
  }

  ///This Constructor of `AppLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `red` color.
  ///
  ///It can be used for error logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `AppLog()` - for basic log
  ///- `AppLog.info()` - for info log
  ///- `AppLog.success()` - for success log
  AppLog.error(this.message, [this.stackTrace]) {
    log(
      '\x1B[31m[CHATBOT] - $message\x1B[0m',
      stackTrace: stackTrace,
      name: 'Error',
      level: 1200,
    );
  }

  ///This Constructor of `AppLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `green` color.
  ///
  ///It can be used for success logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `AppLog()` - for basic log
  ///- `AppLog.info()` - for info log
  ///- `AppLog.error()` - for error log
  AppLog.success(this.message, [this.stackTrace]) {
    log(
      '\x1B[32m[CHATBOT] - $message\x1B[0m',
      stackTrace: stackTrace,
      name: 'Success',
      level: 500,
    );
  }

  ///This Constructor of `AppLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `yellow` color.
  ///
  ///It can be used for information logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `AppLog()` - for basic log
  ///- `AppLog.success()` - for success log
  ///- `AppLog.error()` - for error log
  AppLog.info(this.message, [this.stackTrace]) {
    log(
      '\x1B[33m[CHATBOT] - $message\x1B[0m',
      stackTrace: stackTrace,
      name: 'Info',
      level: 800,
    );
  }

  ///This Constructor of `AppLog` take 2 parameters
  ///```dart
  ///final dynamic message //This will be displayed in console
  ///final StackTrace? stackTrace //Optional
  ///```
  ///will be used to log the `message` with `cyan` color.
  ///
  ///It can be used for information logs
  ///
  ///You can use other constructors for different type of logs
  ///eg.
  ///- `AppLog()` - for basic log
  ///- `AppLog.success()` - for success log
  ///- `AppLog.error()` - for error log
  AppLog.highlight(this.message, [this.stackTrace]) {
    log(
      '\x1B[36m[CHATBOT] - $message\x1B[0m',
      stackTrace: stackTrace,
      name: 'Highlight',
      level: 400,
    );
  }

  /// Build a copy-pastable cURL command for the given request
  static String buildCurl(
    String method,
    String url,
    Map<String, String> headers, [
    dynamic body,
  ]) {
    String escapeSingleQuotes(String input) => input.replaceAll("'", "'\"'\"'");

    final List<String> parts = [];
    parts.add('curl');
    parts.add('-X');
    parts.add(method.toUpperCase());
    parts.add("'${escapeSingleQuotes(url)}'");

    headers.forEach((key, value) {
      parts.add('-H');
      parts.add("'${escapeSingleQuotes('$key: $value')}'");
    });

    if (body != null) {
      String bodyString;
      if (body is String) {
        bodyString = body;
      } else {
        // Fallback to JSON for map/list bodies
        bodyString = jsonEncode(body);
      }
      parts.add('--data-raw');
      parts.add("'${escapeSingleQuotes(bodyString)}'");
    }

    return parts.join(' ');
  }

  /// Print a cURL command with highlight formatting
  static void curl(
    String method,
    String url,
    Map<String, String> headers, [
    dynamic body,
  ]) {
    final cmd = buildCurl(method, url, headers, body);
    AppLog.highlight('cURL: ' + cmd);
  }

  final dynamic message;
  final StackTrace? stackTrace;
}
