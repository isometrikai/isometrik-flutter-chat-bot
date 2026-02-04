import 'package:flutter/material.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/complete_setup/notification_settings_setup_screen.dart';

/// Ninth screen of Complete Setup flow: "Budget & deals".
/// Deals importance, monthly budget range, causes for donations.
class BudgetDealsSetupScreen extends StatefulWidget {
  const BudgetDealsSetupScreen({super.key});

  @override
  State<BudgetDealsSetupScreen> createState() => _BudgetDealsSetupScreenState();
}

class _BudgetDealsSetupScreenState extends State<BudgetDealsSetupScreen> {
  static const List<String> _dealsImportanceLabels = [
    'Very Important - Always looking for deals',
    'Moderate - Nice to have',
    'Low - Convenience first',
  ];

  static const List<String> _budgetRangeLabels = [
    '₹2,000 - ₹5,000',
    '₹5,000 - ₹10,000',
    '₹10,000 - ₹20,000',
    '₹20,000+',
  ];

  static const List<String> _causeLabels = [
    'Education',
    'Healthcare',
    'Environment',
    'Animals',
  ];

  int _dealsImportanceIndex = 0; // Very Important selected by default
  String _budgetRange = '₹2,000 - ₹5,000';
  final Set<int> _selectedCauses = {0}; // Education selected by default

  static const Color _blue = Color(0xFF007AFF);
  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _textMuted = Color(0xFF7085AE);
  static const Color _skipBg = Color(0xFFF5F7FF);
  static const Color _sectionLabel = Color(0xFF2F3C70);
  static const Color _borderLight = Color(0xFFE0EBFF);
  static const Color _labelGray = Color(0xFF979797);

  void _toggleCause(int index) {
    setState(() {
      if (_selectedCauses.contains(index)) {
        _selectedCauses.remove(index);
      } else {
        _selectedCauses.add(index);
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
            // Top bar: back | step 09 .10 | Skip
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
                        '09',
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
                      'Budget & deals',
                      style: AppTextStyles.heading(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Help me find the best deals for you',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // How important are deals/discounts to you?
                    Text(
                      'How important are deals/discounts to you?',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: _sectionLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_dealsImportanceLabels.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _DealsRadio(
                          label: _dealsImportanceLabels[index],
                          value: index,
                          groupValue: _dealsImportanceIndex,
                          onChanged: (v) =>
                              setState(() => _dealsImportanceIndex = v!),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    // Monthly budget for online services (approx.)
                    Text(
                      'Monthly budget for online services (approx.)',
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
                          value: _budgetRange,
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
                          items: _budgetRangeLabels
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _budgetRange = v ?? _budgetRange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Causes you care about (for donations)
                    Text(
                      'Causes you care about (for donations)',
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
                      children: List.generate(_causeLabels.length, (index) {
                        return _CauseChip(
                          label: _causeLabels[index],
                          selected: _selectedCauses.contains(index),
                          onTap: () => _toggleCause(index),
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
                        '09',
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
                                const NotificationSettingsSetupScreen(),
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

class _DealsRadio extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const _DealsRadio({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
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
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CauseChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CauseChip({
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
