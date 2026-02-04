import 'package:flutter/material.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/complete_setup/health_preferences_setup_screen.dart';

/// Fifth screen of Complete Setup flow: "Shopping habits".
/// Grocery frequency and shopping categories.
class ShoppingHabitsSetupScreen extends StatefulWidget {
  const ShoppingHabitsSetupScreen({super.key});

  @override
  State<ShoppingHabitsSetupScreen> createState() =>
      _ShoppingHabitsSetupScreenState();
}

class _ShoppingHabitsSetupScreenState extends State<ShoppingHabitsSetupScreen> {
  static const List<String> _frequencyOptions = [
    'Daily',
    'Weekly',
    'Bi-weekly',
    'Monthly',
  ];

  static const List<String> _categoryLabels = [
    'Groceries 🛒',
    'Fashion 👕',
    'Electronics 📱',
    'Home & Living 🏠',
    'Beauty 💄',
  ];

  int _frequencyIndex = 1; // Weekly selected by default
  final Set<int> _selectedCategories = {0}; // Groceries selected by default

  static const Color _blue = Color(0xFF007AFF);
  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _textMuted = Color(0xFF7085AE);
  static const Color _skipBg = Color(0xFFF5F7FF);
  static const Color _sectionLabel = Color(0xFF2F3C70);

  void _toggleCategory(int index) {
    setState(() {
      if (_selectedCategories.contains(index)) {
        _selectedCategories.remove(index);
      } else {
        _selectedCategories.add(index);
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
            // Top bar: back | step 05 .10 | Skip
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
                        '05',
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
                      'Shopping habits',
                      style: AppTextStyles.heading(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Help me understand your shopping needs',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // How often do you shop for groceries?
                    Text(
                      'How often do you shop for groceries?',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: _sectionLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        _frequencyOptions.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _FrequencyRadio(
                            label: _frequencyOptions[index],
                            value: index,
                            groupValue: _frequencyIndex,
                            onChanged: (v) =>
                                setState(() => _frequencyIndex = v ?? _frequencyIndex),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Shopping categories
                    Text(
                      'Shopping categories',
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
                      children: List.generate(_categoryLabels.length, (index) {
                        return _ShoppingChip(
                          label: _categoryLabels[index],
                          selected: _selectedCategories.contains(index),
                          onTap: () => _toggleCategory(index),
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
                        '05',
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
                                const HealthPreferencesSetupScreen(),
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

class _FrequencyRadio extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  const _FrequencyRadio({
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

class _ShoppingChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ShoppingChip({
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
