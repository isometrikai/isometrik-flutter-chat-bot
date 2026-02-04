import 'package:flutter/material.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/complete_setup/travel_preferences_setup_screen.dart';

/// Sixth screen of Complete Setup flow: "Health preferences".
/// Recurring prescriptions, reminder frequency, health interests.
class HealthPreferencesSetupScreen extends StatefulWidget {
  const HealthPreferencesSetupScreen({super.key});

  @override
  State<HealthPreferencesSetupScreen> createState() =>
      _HealthPreferencesSetupScreenState();
}

class _HealthPreferencesSetupScreenState
    extends State<HealthPreferencesSetupScreen> {
  bool _hasRecurringPrescriptions = true; // Yes, I need reminders
  String _reminderFrequency = 'Weekly';

  static const List<String> _healthInterestLabels = [
    'Fitness 💪',
    'Nutrition 🥗',
    'Yoga 🧘',
    'Wellness ✨',
  ];

  static const List<String> _frequencyOptions = [
    'Daily',
    'Weekly',
    'Bi-weekly',
    'Monthly',
  ];

  final Set<int> _selectedInterests = {0}; // Fitness selected by default

  static const Color _blue = Color(0xFF007AFF);
  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _textMuted = Color(0xFF7085AE);
  static const Color _skipBg = Color(0xFFF5F7FF);
  static const Color _sectionLabel = Color(0xFF2F3C70);
  static const Color _borderLight = Color(0xFFE0EBFF);
  static const Color _labelGray = Color(0xFF979797);

  void _toggleInterest(int index) {
    setState(() {
      if (_selectedInterests.contains(index)) {
        _selectedInterests.remove(index);
      } else {
        _selectedInterests.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back | step 06 .10 | Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(Icons.arrow_back,
                          size: 24, color: Color(0xFF242424)),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '06',
                        style: AppTextStyles.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D8AFF),
                        ),
                      ),
                      Text(
                        ' .10',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF171212),
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(80),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 6),
                        decoration: BoxDecoration(
                          color: _skipBg,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: Text(
                          'Skip',
                          style: AppTextStyles.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF414F85),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Health preferences',
                      style: AppTextStyles.heading(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'For pharmacy and health service recommendations',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Do you have any recurring prescriptions?
                    Text(
                      'Do you have any recurring prescriptions?',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: _sectionLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PrescriptionRadio(
                      label: 'Yes, I need reminders',
                      value: true,
                      groupValue: _hasRecurringPrescriptions,
                      onChanged: (v) =>
                          setState(() => _hasRecurringPrescriptions = v ?? true),
                    ),
                    const SizedBox(height: 16),
                    _PrescriptionRadio(
                      label: 'No prescriptions',
                      value: false,
                      groupValue: _hasRecurringPrescriptions,
                      onChanged: (v) =>
                          setState(() => _hasRecurringPrescriptions = v ?? false),
                    ),
                    if (_hasRecurringPrescriptions) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Reminder frequency',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          color: _labelGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: _borderLight, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _reminderFrequency,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: _textDark,
                            ),
                            style: AppTextStyles.body(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: _textDark,
                            ),
                            items: _frequencyOptions
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(
                                () => _reminderFrequency = v ?? _reminderFrequency),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Health interests
                    Text(
                      'Health interests',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: _sectionLabel,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_healthInterestLabels.length,
                          (index) {
                        return _HealthChip(
                          label: _healthInterestLabels[index],
                          selected: _selectedInterests.contains(index),
                          onTap: () => _toggleInterest(index),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '06',
                        style: AppTextStyles.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D8AFF),
                        ),
                      ),
                      Text(
                        ' .10',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: _blue,
                    borderRadius: BorderRadius.circular(90),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const TravelPreferencesSetupScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(90),
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.arrow_forward,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrescriptionRadio extends StatelessWidget {
  final String label;
  final bool value;
  final bool groupValue;
  final ValueChanged<bool?> onChanged;

  const _PrescriptionRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  static const Color _blue = Color(0xFF007AFF);
  static const Color _borderLight = Color(0xFFE0EBFF);
  static const Color _textDark = Color(0xFF2F3C70);

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _blue : _borderLight,
                width: 0.75,
              ),
              color: selected ? _blue : Colors.white,
            ),
            child: selected
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HealthChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const Color _blue = Color(0xFF007AFF);
  static const Color _blueLight = Color(0xFFE5F2FF);
  static const Color _borderLight = Color(0xFFE0EBFF);
  static const Color _textDark = Color(0xFF2F3C70);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _blueLight : Colors.white,
            border: Border.all(
              color: selected ? _blue : _borderLight,
              width: 0.75,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: selected
                    ? Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF34C363),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.check, size: 12, color: Colors.white),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: _blueLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.circle, size: 9, color: _blue),
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
