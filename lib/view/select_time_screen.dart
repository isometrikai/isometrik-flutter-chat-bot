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
  final Function(DateTime selectedDate, String selectedTime)? onConfirm;
  
  const SelectTimeScreen({
    super.key,
    required this.userId,
    required this.storeCategoryId,
    this.onConfirm,
  });

  /// Present the SelectTimeScreen as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String userId,
    required String storeCategoryId,
    Function(DateTime selectedDate, String selectedTime)? onConfirm,
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
          onConfirm: onConfirm,
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
    // Initialize with next 7 days
    final now = DateTime.now();
    availableDates = List.generate(7, (index) => now.add(Duration(days: index)));
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
    return '$month/$day/$year';
  }
  
  void _fetchSlotsForDate(DateTime date) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load time slots: ${state.message}')),
                  );
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
    final maxModalHeight = screenHeight * 0.7;
    
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
                          'Select a Time',
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
                          'Select a Time as per your convenience',
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
                height: 52,
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
                          width: isSelected ? 47 : 51,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? const Color(0xFF8E2FFD)
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
                              ),
                              const SizedBox(height: 0),
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
                            color: Color(0xFF8E2FFD),
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
            
            const SizedBox(height: 24),
            
            // Confirm button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD445EC),
                      Color(0xFFB02EFB),
                      Color(0xFF8E2FFD),
                      Color(0xFF5E3DFE),
                      Color(0xFF5186E0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (selectedDate != null && selectedTimeSlot != null) {
                        widget.onConfirm?.call(selectedDate!, selectedTimeSlot!);
                        Navigator.of(context).pop();
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
            ? const Color(0xFF8E2FFD)
            : const Color(0xFFEEF4FF),
          width: 0.833333,
        ),
        shape: BoxShape.circle,
      ),
      child: isSelected
        ? Container(
            margin: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Color(0xFF8E2FFD),
              shape: BoxShape.circle,
            ),
          )
        : null,
    );
  }
}
