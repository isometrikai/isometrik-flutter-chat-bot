import 'package:flutter/material.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/complete_setup/setup_complete_screen.dart';

/// Tenth (final) screen of Complete Setup flow: "Notification settings".
/// Remind before events, best time to notify, what to remind about.
class NotificationSettingsSetupScreen extends StatefulWidget {
  const NotificationSettingsSetupScreen({super.key});

  @override
  State<NotificationSettingsSetupScreen> createState() =>
      _NotificationSettingsSetupScreenState();
}

class _NotificationSettingsSetupScreenState
    extends State<NotificationSettingsSetupScreen> {
  static const List<String> _remindBeforeLabels = [
    '1 Week before',
    '3 Days before',
    '1 Day before',
  ];

  static const List<String> _bestTimeLabels = [
    'Morning (09:00am)',
    'Afternoon (02:00pm)',
    'Evening (06:00pm)',
  ];

  static const List<String> _remindAboutLabels = [
    'Birthdays 🎂',
    'Deals & Offers 💰',
    'Order Updates 📦',
    'Service Bookings 🔧',
  ];

  int _remindBeforeIndex = 0; // 1 Week before selected by default
  String _bestTime = 'Morning (09:00am)';
  final Set<int> _selectedRemindAbout = {0}; // Birthdays selected by default

  static const Color _blue = Color(0xFF007AFF);
  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _textMuted = Color(0xFF7085AE);
  static const Color _skipBg = Color(0xFFF5F7FF);
  static const Color _sectionLabel = Color(0xFF2F3C70);
  static const Color _borderLight = Color(0xFFE0EBFF);
  static const Color _labelGray = Color(0xFF979797);

  void _toggleRemindAbout(int index) {
    setState(() {
      if (_selectedRemindAbout.contains(index)) {
        _selectedRemindAbout.remove(index);
      } else {
        _selectedRemindAbout.add(index);
      }
    });
  }

  void _onDone() {
    // Push "You're All Set!" screen; from there user taps "Let's get started" to return to chat
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SetupCompleteScreen(),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back | step 10 .10 | Skip
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
                        '10',
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
                      onTap: _onDone,
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
                      'Notification settings',
                      style: AppTextStyles.heading(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'When should I remind you about important events?',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Remind me before events
                    Text(
                      'Remind me before events',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: _sectionLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_remindBeforeLabels.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _RemindRadio(
                          label: _remindBeforeLabels[index],
                          value: index,
                          groupValue: _remindBeforeIndex,
                          onChanged: (v) =>
                              setState(() => _remindBeforeIndex = v!),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    // Best time to notify you
                    Text(
                      'Best time to notify you',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: _sectionLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select range',
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
                          value: _bestTime,
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
                          items: _bestTimeLabels
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _bestTime = v ?? _bestTime),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // What should I remind you about?
                    Text(
                      'What should I remind you about?',
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
                      children: List.generate(_remindAboutLabels.length,
                          (index) {
                        return _RemindAboutChip(
                          label: _remindAboutLabels[index],
                          selected: _selectedRemindAbout.contains(index),
                          onTap: () => _toggleRemindAbout(index),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom bar: step 10 .10 + Done (checkmark) button
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
                        '10',
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
                      onTap: _onDone,
                      borderRadius: BorderRadius.circular(90),
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.check,
                            color: Colors.white, size: 28),
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

class _RemindRadio extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const _RemindRadio({
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

class _RemindAboutChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RemindAboutChip({
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
