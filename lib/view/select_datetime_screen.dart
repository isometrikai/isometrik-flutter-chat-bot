import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import '../utils/utils.dart';
import '../data/repositories/store_details_repository.dart';
import '../data/model/store_details_response.dart';
import '../utils/log.dart';

class SelectDateTimeScreen extends StatefulWidget {
  final DateTime? initialDate;
  final Function(String formattedDateTime, int timestamp)? onConfirm;
  final String? storeId;
  final double? latitude;
  final double? longitude;
  final String timezone;
  
  const SelectDateTimeScreen({
    super.key,
    this.initialDate,
    this.onConfirm,
    this.storeId,
    this.latitude,
    this.longitude,
    this.timezone = 'Asia/Kolkata',
  });

  /// Present the SelectDateTimeScreen as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    DateTime? initialDate,
    Function(String formattedDateTime, int timestamp)? onConfirm,
    String? storeId,
    double? latitude,
    double? longitude,
    String timezone = 'Asia/Kolkata',
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => SelectDateTimeScreen(
        initialDate: initialDate,
        onConfirm: onConfirm,
        storeId: storeId,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      ),
    );
  }

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime? selectedDateTime;
  late DateTime minimumDateTime;
  late DateTime maximumDateTime;
  List<StoreTiming> storeTimings = [];
  bool isLoadingTimings = false;
  final StoreDetailsRepository _repository = const StoreDetailsRepository();
  
  @override
  void initState() {
    super.initState();
    // Use a single DateTime.now() call to ensure consistency
    final now = DateTime.now();
    minimumDateTime = now;
    maximumDateTime = now.add(const Duration(days: 365));
    
    // Ensure initial date is not before minimum
    if (widget.initialDate != null && widget.initialDate!.isBefore(minimumDateTime)) {
      selectedDateTime = minimumDateTime;
    } else {
      selectedDateTime = widget.initialDate ?? minimumDateTime;
    }
    
    // Fetch store timings if storeId is provided
    // Use addPostFrameCallback to ensure widget is fully built before API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.storeId != null && 
          widget.latitude != null && 
          widget.longitude != null) {
        AppLog.info('📅 SelectDateTimeScreen: Fetching store timings for storeId: ${widget.storeId}');
        _fetchStoreTimings();
      } else {
        AppLog.info('📅 SelectDateTimeScreen: Skipping API call - missing parameters. storeId: ${widget.storeId}, lat: ${widget.latitude}, long: ${widget.longitude}');
      }
    });
  }
  
  Future<void> _fetchStoreTimings() async {
    if (widget.storeId == null || 
        widget.latitude == null || 
        widget.longitude == null) {
      AppLog.info('📅 SelectDateTimeScreen: Cannot fetch timings - missing required parameters');
      return;
    }
    
    AppLog.info('📅 SelectDateTimeScreen: Starting API call for store timings');
    AppLog.info('📅 Parameters: storeId=${widget.storeId}, lat=${widget.latitude}, long=${widget.longitude}, timezone=${widget.timezone}');
    
    setState(() {
      isLoadingTimings = true;
    });
    
    try {
      AppLog.info('📅 SelectDateTimeScreen: Calling fetchStoreDetails...');
      final storeDetails = await _repository.fetchStoreDetails(
        storeId: widget.storeId!,
        latitude: widget.latitude!,
        longitude: widget.longitude!,
        timezone: widget.timezone,
      );
      
      AppLog.info('📅 SelectDateTimeScreen: API call successful. Received ${storeDetails.timing.length} timing slots');
      
      // setState(() {
      //   storeTimings = storeDetails.timing;
      //   isLoadingTimings = false;
      // });
    } catch (e, stackTrace) {
      AppLog.error('📅 SelectDateTimeScreen: API call failed: $e');
      AppLog.error('📅 Stack trace: $stackTrace');
      setState(() {
        isLoadingTimings = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load store timings: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  bool _isDateTimeValid(DateTime dateTime) {
    if (storeTimings.isEmpty) {
      // If no timings available, allow any selection
      return true;
    }
    
    // Convert selected datetime to Unix timestamp (seconds)
    final selectedTimestamp = dateTime.millisecondsSinceEpoch ~/ 1000;
    
    // Check if the selected datetime falls within any timing slot
    for (final timing in storeTimings) {
      if (selectedTimestamp >= timing.startDate && 
          selectedTimestamp <= timing.endDate) {
        return true;
      }
    }
    
    return false;
  }
  
  void _handleConfirm() {
    if (selectedDateTime == null) {
       BlackToastView.show(
                      context,
                      'Please select a date and time',
                    );
      return;
    }
    
    // Validate against store timings if available
    // if (storeTimings.isNotEmpty && !_isDateTimeValid(selectedDateTime!)) {

    //   BlackToastView.show(
    //                   context,
    //                   'Selected date and time is not available. Please choose another time slot.',
    //                 );
    //   return;
    // }
    
    // Format the date time and get timestamp
    final formattedDateTime = _formatDateTime(selectedDateTime!);
    final timestamp = selectedDateTime!.millisecondsSinceEpoch ~/ 1000; // Convert to seconds
    
    widget.onConfirm?.call(formattedDateTime, timestamp);
    Navigator.of(context).pop();
  }
  
  String _formatDateTime(DateTime dateTime) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$weekday, $month $day, $year at $displayHour:$minute $period';
  }
  
  String _formatDateShort(DateTime dateTime) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    
    return '$weekday, $month $day';
  }
  
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
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
            child: _buildModalContent(context),
          ),
        ),
      ),
    );
  }
  
  Widget _buildModalContent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final maxModalHeight = screenHeight * 0.85;
    
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
          mainAxisSize: MainAxisSize.min,
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
            
            // Selected date and time display
            if (selectedDateTime != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    border: Border.all(
                      color: const Color(0xFFE5F2FF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.appThemeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatDateShort(selectedDateTime!),
                              style: AppTextStyles.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ).copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.appThemeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatTime(selectedDateTime!),
                              style: AppTextStyles.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ).copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDateTime(selectedDateTime!),
                        style: AppTextStyles.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ).copyWith(
                          color: const Color(0xFF242424),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Calendar and Time Picker
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFEEF4FF),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CupertinoCalendar(
                  mode: CupertinoCalendarMode.dateTime,
                  initialDateTime: selectedDateTime ?? minimumDateTime,
                  minimumDateTime: minimumDateTime,
                  maximumDateTime: maximumDateTime,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      selectedDateTime = newDateTime;
                    });
                  },
                ),
              ),
            ),
            
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
                    onTap: _handleConfirm,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      alignment: Alignment.center,
                      child: isLoadingTimings
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
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
}

