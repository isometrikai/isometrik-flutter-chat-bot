import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> kNavigatorKey = GlobalKey<NavigatorState>();

class Utility {
  static bool isLoading = false;
  static String currencySymbol = '';
  static String currencyCode = '';
  static String platform = '';
  static String name = '';
  static String emailId = '';
  static String timezone = '';
  static bool personalization = true;

  /// Fixed UTC offsets for common IANA zones (no DST). Extend as needed.
  static const Map<String, Duration> _ianaUtcOffsets = {
    'Asia/Kolkata': Duration(hours: 5, minutes: 30),
    'Asia/Calcutta': Duration(hours: 5, minutes: 30),
    'Asia/Dubai': Duration(hours: 4),
    'Asia/Riyadh': Duration(hours: 3),
    'Asia/Singapore': Duration(hours: 8),
    'Europe/London': Duration(hours: 0),
    'America/New_York': Duration(hours: -5),
    'America/Los_Angeles': Duration(hours: -8),
  };

  static void showLoader({
    String? message,
  }) async {
    if (isLoading) return; // Prevent multiple loaders
    
    final context = kNavigatorKey.currentContext;
    if (context == null) {
      print('Warning: Navigator context is null, cannot show loader');
      // Try to get context from the current widget tree
      final currentContext = _getCurrentContext();
      if (currentContext == null) {
        print('Error: No valid context available for showing loader');
        return;
      }
      _showLoaderWithContext(currentContext, message);
      return;
    }
    
    _showLoaderWithContext(context, message);
  }

  static void _showLoaderWithContext(BuildContext context, String? message) {
    isLoading = true;
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (_) => AppLoader(
        message: message,
      ),
      barrierDismissible: false,
    );
  }

  static BuildContext? _getCurrentContext() {
    // Try to get context from the current widget tree
    // This is a fallback when navigator key context is not available
    try {
      // This will be set by the app when it initializes
      return _currentContext;
    } catch (e) {
      print('Error getting current context: $e');
      return null;
    }
  }

  // Static variable to store current context as fallback
  static BuildContext? _currentContext;

  /// Set the current context for fallback when navigator key is not available
  /// Call this method in your app's build method to ensure context is available
  static void setCurrentContext(BuildContext context) {
    _currentContext = context;
  }

  static void closeProgressDialog() {
    final context = kNavigatorKey.currentContext ?? _currentContext;
    if (isLoading && context != null && Navigator.of(context).canPop()) {
      isLoading = false;
      Navigator.of(context).pop();
    }
  }

  static void showErrorBlackToast(String message) {
    final context = kNavigatorKey.currentContext ?? _currentContext;
    if (context != null) {
      BlackToastView.show(
                  context,
                  message,
                );
    }
  }

  /// Show a confirmation dialog with two options
  /// Returns true if primary action is selected, false if secondary action is selected
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String primaryButtonText = 'OK',
    String secondaryButtonText = 'Cancel',
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) async {
    final context = kNavigatorKey.currentContext ?? _currentContext;
    if (context == null) {
      print('Warning: Navigator context is null, cannot show dialog');
      return null;
    }

    return await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AppConfirmationDialog(
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryPressed: onPrimaryPressed,
          onSecondaryPressed: onSecondaryPressed,
        );
      },
    );
  }

  static void setCurrencySymbol(String currencySymbol) {
    Utility.currencySymbol = currencySymbol;
  }

  static void setCurrencyCode(String currencyCode) {
    Utility.currencyCode = currencyCode;
  }

  static void setPlatform(String platform) {
    Utility.platform = platform;
  }

  static void setName(String name) {
    Utility.name = name;
  }

  static void setEmailId(String emailId) {
    Utility.emailId = emailId;
  }

  static void setPersonalization(bool personalization) {
    Utility.personalization = personalization;
  }

  static bool getPersonalization() {
    return personalization;
  }

  static String getName() {
    return name;
  }

  static void setTimezone(String value) {
    timezone = value;
  }

  /// Parses offsets like `+05:30`, `UTC+5:30`, or total minutes `330`.
  static Duration? _parseUtcOffset(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final minutesOnly = int.tryParse(trimmed);
    if (minutesOnly != null) {
      return Duration(minutes: minutesOnly);
    }

    final match = RegExp(
      r'^(?:UTC)?\s*([+-])\s*(\d{1,2})(?::(\d{2}))?$',
      caseSensitive: false,
    ).firstMatch(trimmed.replaceAll(' ', ''));
    if (match == null) return null;

    final sign = match.group(1) == '-' ? -1 : 1;
    final hours = int.parse(match.group(2)!);
    final minutes = int.parse(match.group(3) ?? '0');
    return Duration(
      hours: sign * hours,
      minutes: sign * minutes,
    );
  }

  /// Hour of day for [Utility.timezone], or device local time when unknown.
  static int currentHourInTimezone() {
    final tzValue = timezone.trim();
    if (tzValue.isEmpty) {
      return DateTime.now().hour;
    }

    final offset =
        _parseUtcOffset(tzValue) ?? _ianaUtcOffsets[tzValue];
    if (offset != null) {
      return DateTime.now().toUtc().add(offset).hour;
    }

    return DateTime.now().hour;
  }

  /// Returns "Good morning", "Good afternoon", or "Good evening".
  static String getTimeOfDayGreeting() {
    final hour = currentHourInTimezone();
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    }
    if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  static String getEmailId() {
    return emailId;
  }

  static String getCurrencySymbol() {
    return currencySymbol;
  }

  static String getCurrencyCode() {
    return currencyCode;
  }

  static String getPlatform() {
    return platform;
  }

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Parses hotel date strings such as `2026-06-10`.
  static DateTime? parseHotelBookingDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed);
  }

  /// Returns `yyyy-MM-dd` (pass-through when already in that shape).
  static String formatHotelBookingDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;

    final parsed = parseHotelBookingDate(trimmed);
    if (parsed == null) return trimmed;

    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Chat display format: `10th June 2026`.
  static String formatHotelBookingDateForDisplay(String raw) {
    final parsed = parseHotelBookingDate(raw);
    if (parsed == null) return raw.trim();

    final day = parsed.day;
    final suffix = (day >= 11 && day <= 13)
        ? 'th'
        : switch (day % 10) {
            1 => 'st',
            2 => 'nd',
            3 => 'rd',
            _ => 'th',
          };

    return '$day$suffix ${_monthNames[parsed.month - 1]} ${parsed.year}';
  }

  /// Formats hotel occupancy for chat, e.g.:
  /// `Room 1: 3 adults, 1 child (age 2)\nRoom 2: 3 adults`
  static String formatHotelOccupancyForDisplay(dynamic occupancy) {
    if (occupancy == null) return '';

    final List<dynamic> rooms;
    if (occupancy is List) {
      rooms = occupancy;
    } else {
      return occupancy.toString();
    }

    if (rooms.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      if (room is! Map) continue;

      final map = Map<String, dynamic>.from(room);
      final adults = (map['adults'] as num?)?.toInt() ?? 0;
      final children = (map['childs'] as num?)?.toInt() ??
          (map['children'] as num?)?.toInt() ??
          0;
      final childAgesRaw = map['childages'] ?? map['childAges'] ?? [];
      final List<int> childAges = [];
      if (childAgesRaw is List) {
        for (final age in childAgesRaw) {
          final parsed = int.tryParse(age.toString());
          if (parsed != null) childAges.add(parsed);
        }
      }

      if (buffer.isNotEmpty) buffer.writeln();
      buffer.write('Room ${i + 1}: ');

      final parts = <String>[];
      if (adults > 0) {
        parts.add('$adults ${adults == 1 ? 'adult' : 'adults'}');
      }
      if (children > 0) {
        var childPart = '$children ${children == 1 ? 'child' : 'children'}';
        if (childAges.isNotEmpty) {
          childPart += childAges.length == 1
              ? ' (age ${childAges.first})'
              : ' (ages ${childAges.join(', ')})';
        }
        parts.add(childPart);
      }
      if (parts.isEmpty) {
        buffer.write('No guests');
      } else {
        buffer.write(parts.join(', '));
      }
    }

    return buffer.toString();
  }
}


class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppConstants.appThemeColor,
            strokeWidth: 4,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  final String title;
  final String message;
  final String primaryButtonText;
  final String secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  // Custom color scheme
  static const Color lightLavender = Color(0xFFF0DAFE);
  static const Color primaryPurple = Color(0xFF8B5CF6); // Darker purple for contrast

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  height: 1.4,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  // No Button (Secondary)
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.of(context).pop(false);
                            onSecondaryPressed?.call();
                          },
                          child: Center(
                            child: Text(
                              secondaryButtonText,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Yes Button (Primary)
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0DAFE), // Blue color like in the image
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.of(context).pop(true);
                            onPrimaryPressed?.call();
                          },
                          child: Center(
                            child: Text(
                              primaryButtonText,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
