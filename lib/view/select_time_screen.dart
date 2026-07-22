import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/store_details/store_details_bloc.dart';
import '../bloc/store_details/store_details_event.dart';
import '../bloc/store_details/store_details_state.dart';
import '../utils/utils.dart';

class SelectTimeScreen extends StatefulWidget {
  final String userId;
  final String storeCategoryId;
  final String timezone;
  final bool isForTableBooking;
  final Function(String selectedTimeDate,int timestamp)? onConfirm;
  final Function(String selectedDate, String showDate)? onTableBookingConfirm;
  
  const SelectTimeScreen({
    super.key,
    required this.userId,
    required this.storeCategoryId,
    required this.timezone,
    this.onConfirm,
    this.isForTableBooking = false,
    this.onTableBookingConfirm,
  });

  /// Present the SelectTimeScreen as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String userId,
    required String storeCategoryId,
    required String timezone,
    bool isForTableBooking = false,
    Function(String selectedTimeDate,int timestamp)? onConfirm,
    Function(String selectedDate, String showDate)? onTableBookingConfirm,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => BlocProvider(
        create: (context) => StoreDetailsBloc(),
        child: SelectTimeScreen(
          userId: userId,
          storeCategoryId: storeCategoryId,
          timezone: timezone,
          onConfirm: onConfirm,
          isForTableBooking: isForTableBooking,
          onTableBookingConfirm: onTableBookingConfirm,
        ),
      ),
    );
  }

  @override
  State<SelectTimeScreen> createState() => _SelectTimeScreenState();
}

class _SelectTimeScreenState extends State<SelectTimeScreen> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  List<DateTime> availableDates = [];
  Map<String, List<String>> dateTimeSlotsMap = {}; // Key: date string (MM/dd/yyyy), Value: list of time slot strings
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // When booking a table, allow selecting from today up to next 30 days.
    // Otherwise, keep existing behavior (next 7 days).
    final daysToShow = widget.isForTableBooking ? 31 : 7; // includes today
    availableDates = List.generate(
      daysToShow,
      (index) => now.add(Duration(days: index)),
    );
    if (availableDates.isNotEmpty) {
      selectedDate = availableDates[0];
      // Fetch slots for the first date
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchSlotsForDate(availableDates[0]);
      });
    }
  }
  
  String _formatDateForApi(DateTime date) {
    // Format: MM/dd/yyyy
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
  
  void _fetchSlotsForDate(DateTime date) {
    if (widget.isForTableBooking) {
      return;
    }
    final dateStr = _formatDateForApi(date);
    
    // Check if we already have slots for this date
    if (dateTimeSlotsMap.containsKey(dateStr)) {
      return;
    }
    
    context.read<StoreDetailsBloc>().add(
      AvailabilitySlotsRequested(
        date: dateStr,
        userId: widget.userId,
        storeCategoryId: widget.storeCategoryId,
      ),
    );
  }
  
  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      selectedTimeSlot = null;
    });
    _fetchSlotsForDate(date);
  }
  
  String _formatDayAbbreviation(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
  
  String _formatMonthDay(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
  
  List<String> get currentTimeSlots {
    if (selectedDate == null) return [];
    final dateStr = _formatDateForApi(selectedDate!);
    return dateTimeSlotsMap[dateStr] ?? [];
  }
  
  bool _isLoadingDate(StoreDetailsState state, DateTime date) {
    if (state is StoreDetailsLoadInProgress) {
      return state.date == _formatDateForApi(date);
    }
    return false;
  }

  /// Parses a time slot string like "12:05 AM - 12:10 AM" and returns
  /// the start time as (hour24, minute). Returns null if parsing fails.
  (int, int)? _parseTimeSlotStart(String timeSlotStr) {
    final parts = timeSlotStr.split(' - ');
    if (parts.isEmpty) return null;
    final startPart = parts[0].trim(); // e.g. "12:05 AM"
    final spaceIdx = startPart.lastIndexOf(' ');
    if (spaceIdx <= 0) return null;
    final timeStr = startPart.substring(0, spaceIdx).trim(); // "12:05"
    final period = startPart.substring(spaceIdx + 1).trim().toUpperCase(); // "AM" or "PM"
    final timeParts = timeStr.split(':');
    if (timeParts.length < 2) return null;
    final hour12 = int.tryParse(timeParts[0].trim());
    final minute = int.tryParse(timeParts[1].trim());
    if (hour12 == null || minute == null) return null;
    int hour24 = hour12;
    if (period == 'AM') {
      hour24 = hour12 == 12 ? 0 : hour12;
    } else {
      hour24 = hour12 == 12 ? 12 : hour12 + 12;
    }
    return (hour24, minute);
  }

  /// Combines [date] and [timeSlotStr] (e.g. "12:05 AM - 12:10 AM") into a
  /// DateTime in local timezone and returns millisecondsSinceEpoch.
  int? _combinedTimestamp(DateTime date, String timeSlotStr) {
    final parsed = _parseTimeSlotStart(timeSlotStr);
    if (parsed == null) return null;
    final (hour24, minute) = parsed;
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      hour24,
      minute,
      0,
      0,
    );
    return combined.millisecondsSinceEpoch;
  }

  /// Formats [dateTime] (in local timezone) as "Friday, February 27, 2026 at 3:36 PM".
  String _formatDateTimeLocal(DateTime dateTime) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final isPm = hour >= 12;
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    final period = isPm ? 'PM' : 'AM';
    return '$weekday, $month $day, $year at $hour12:$minuteStr $period';
  }

  String _formatIsoDate(DateTime date) {
    // YYYY-MM-DD
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _dayOrdinalSuffix(int day) {
    // Handles 11th/12th/13th correctly.
    if (day % 100 >= 11 && day % 100 <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _formatMonthDayOrdinal(DateTime date) {
    const months = [
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
    final month = months[date.month - 1];
    final suffix = _dayOrdinalSuffix(date.day);
    return '$month ${date.day}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0F0021).withValues(alpha: 0.7),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {
              // Prevent closing when tapping on the popup itself
            },
            child: BlocConsumer<StoreDetailsBloc, StoreDetailsState>(
              listener: (context, state) {
                if (state is StoreDetailsLoadSuccess) {
                  // Store slots for the date
                  setState(() {
                    dateTimeSlotsMap[state.date] = state.slots
                        .map((slot) => '${slot.fromStr} - ${slot.toStr}')
                        .toList();
                  });
                } else if (state is StoreDetailsLoadFailure) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('Failed to load time slots: ${state.message}')),
                  // );
                }
              },
              builder: (context, state) {
                return _buildModalContent(context, state);
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildModalContent(BuildContext context, StoreDetailsState state) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final maxModalHeight = widget.isForTableBooking ? screenHeight * 0.4 : screenHeight * 0.7;
    
    final isLoading = selectedDate != null && _isLoadingDate(state, selectedDate!);
    final timeSlots = currentTimeSlots;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: maxModalHeight,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: safeAreaBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Date & Time',
                          style: AppTextStyles.heading(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ).copyWith(
                            color: const Color(0xFF171212),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select a date and time as per your convenience',
                          style: AppTextStyles.body(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ).copyWith(
                            color: const Color(0xFF6E4185),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Close button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(63.6364),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_close.svg'),
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Date selection row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableDates.length,
                  itemBuilder: (context, index) {
                    final date = availableDates[index];
                    final isSelected = selectedDate?.day == date.day &&
                                      selectedDate?.month == date.month &&
                                      selectedDate?.year == date.year;
                    
                    return Padding(
                      padding: EdgeInsets.only(right: index < availableDates.length - 1 ? 7 : 0),
                      child: GestureDetector(
                        onTap: () => _onDateSelected(date),
                        child: Container(
                          width: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? AppConstants.appThemeColor
                              : const Color(0xFFF5F7FF),
                            border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFFE5F2FF),
                                  width: 1,
                                ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _formatDayAbbreviation(date),
                                style: AppTextStyles.body(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ).copyWith(
                                  color: isSelected 
                                    ? Colors.white
                                    : const Color(0xFF242424),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatMonthDay(date),
                                style: AppTextStyles.body(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ).copyWith(
                                  color: isSelected 
                                    ? Colors.white
                                    : const Color(0xFF242424),
                                  height: 1.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            if (!widget.isForTableBooking) ...[
            // Time slots list
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 0,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFEEF4FF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.appThemeColor,
                          ),
                        )
                      : timeSlots.isEmpty
                          ? Center(
                              child: Text(
                                'No time slots available',
                                style: AppTextStyles.body(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ).copyWith(
                                  color: const Color(0xFF242424),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: timeSlots.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final timeSlot = timeSlots[index];
                                final isSelected = selectedTimeSlot == timeSlot;
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedTimeSlot = timeSlot;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          timeSlot,
                                          style: AppTextStyles.body(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ).copyWith(
                                            color: const Color(0xFF242424),
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      _buildRadioButton(isSelected),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ),
            ],
            const SizedBox(height: 24),
            
            // Confirm button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: AppConstants.appThemeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (selectedDate != null && selectedTimeSlot != null) {
                        print('selectedDate: $selectedDate');
                        print('selectedTimeSlot: $selectedTimeSlot');
                        final timestamp = _combinedTimestamp(selectedDate!, selectedTimeSlot!);
                        final ms = timestamp ?? selectedDate!.millisecondsSinceEpoch;
                        final dateTimeLocal = DateTime.fromMillisecondsSinceEpoch(ms);
                        final formatted = _formatDateTimeLocal(dateTimeLocal);
                        widget.onConfirm?.call(
                          formatted,
                          ms,
                        );
                        print(formatted); // e.g. Friday, February 27, 2026 at 3:36 PM
                        Navigator.of(context).pop();
                      }else if (widget.isForTableBooking) {
                        if (selectedDate != null) {
                          final isoDate = _formatIsoDate(selectedDate!);
                          final showDate = _formatMonthDayOrdinal(selectedDate!);
                          widget.onTableBookingConfirm?.call(isoDate, showDate);
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Confirm',
                        style: AppTextStyles.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ).copyWith(
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
            ? AppConstants.appThemeColor
            : const Color(0xFFEEF4FF),
          width: 0.833333,
        ),
        shape: BoxShape.circle,
      ),
      child: isSelected
        ? Container(
            margin: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppConstants.appThemeColor,
              shape: BoxShape.circle,
            ),
          )
        : null,
    );
  }
}
