import 'package:flutter/material.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/complete_setup/food_preferences_setup_screen.dart';

String _formatMemberDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// Third screen of Complete Setup flow: "Important people".
/// List of family members with add/edit/delete; reminders for birthdays/anniversaries.
class ImportantPeopleSetupScreen extends StatefulWidget {
  const ImportantPeopleSetupScreen({super.key});

  @override
  State<ImportantPeopleSetupScreen> createState() =>
      _ImportantPeopleSetupScreenState();
}

class _FamilyMember {
  final String name;
  final String relationship; // SPOUSE, CHILD, FATHER, MOTHER, etc.
  final String gender; // MALE, FEMALE
  final DateTime? birthday;
  final DateTime? anniversary;

  _FamilyMember({
    required this.name,
    required this.relationship,
    required this.gender,
    this.birthday,
    this.anniversary,
  });
}

class _ImportantPeopleSetupScreenState extends State<ImportantPeopleSetupScreen> {
  final List<_FamilyMember> _members = [
    _FamilyMember(
      name: 'Aisha Al-Noor',
      relationship: 'SPOUSE',
      gender: 'FEMALE',
      birthday: DateTime(1990, 7, 23),
      anniversary: DateTime(2020, 7, 23),
    ),
    _FamilyMember(
      name: 'Zayd Al-Amiri',
      relationship: 'CHILD',
      gender: 'MALE',
      birthday: DateTime(2024, 7, 23),
    ),
    _FamilyMember(
      name: 'Khalid Al-Masri',
      relationship: 'FATHER',
      gender: 'MALE',
      birthday: DateTime(1956, 7, 23),
    ),
  ];

  static const Color _blue = Color(0xFF007AFF);
  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _textMuted = Color(0xFF7085AE);
  static const Color _skipBg = Color(0xFFF5F7FF);
  static const Color _buttonBorder = Color(0xFF2E8AFF);

  void _addMember() {
    // TODO: Open add-member sheet/dialog; for now just pop
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMemberSheet(
        onSave: (m) {
          setState(() => _members.add(m));
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _removeMember(int index) {
    setState(() => _members.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back | step 03 .10 | Skip
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
                        '03',
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
                      'Important people',
                      style: AppTextStyles.heading(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add family members so I can remind you about birthdays and anniversaries.',
                      style: AppTextStyles.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(_members.length, (index) {
                      final m = _members[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MemberCard(
                          member: m,
                          onEdit: () {
                            // TODO: open edit sheet
                          },
                          onDelete: () => _removeMember(index),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    // Add member button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _addMember,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: _buttonBorder, width: 0.75),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+ Member',
                                style: AppTextStyles.body(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: _blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5F2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: _blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                        '03',
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
                                const FoodPreferencesSetupScreen(),
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

class _MemberCard extends StatelessWidget {
  final _FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemberCard({
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _borderLight = Color(0xFFE0EBFF);
  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _textMuted = Color(0xFF7085AE);

  @override
  Widget build(BuildContext context) {
    final hasAnniversary = member.anniversary != null;
    final isFather = member.relationship == 'FATHER';
    final dateLabel = isFather ? 'DOB' : 'Birthday';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderLight, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(label: member.relationship),
              const SizedBox(width: 7),
              _Pill(label: member.gender),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: _textDark,
                      ),
                    ),
                    if (member.birthday != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$dateLabel : ${_formatMemberDate(member.birthday!)}',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: _textMuted,
                        ),
                      ),
                    ],
                    if (hasAnniversary) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Anniversary : ${_formatMemberDate(member.anniversary!)}',
                        style: AppTextStyles.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(onTap: onEdit, icon: Icons.edit_outlined),
                  const SizedBox(width: 10),
                  _ActionButton(onTap: onDelete, icon: Icons.delete_outline),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  static const Color _pillBg = Color(0xFFF5F7FF);
  static const Color _pillText = Color(0xFF414F85);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _pillBg,
        borderRadius: BorderRadius.circular(80),
      ),
      child: Text(
        label,
        style: AppTextStyles.body(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: _pillText,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _ActionButton({required this.onTap, this.icon = Icons.edit_outlined});

  static const Color _bg = Color(0xFFF5F7FF);
  static const Color _iconColor = Color(0xFF414F85);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(80),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(80),
          ),
          child: Icon(icon, size: 14, color: _iconColor),
        ),
      ),
    );
  }
}

// Add member sheet — layout and styles per design (Frame 1171284968)
class _AddMemberSheet extends StatefulWidget {
  final void Function(_FamilyMember) onSave;
  final VoidCallback onCancel;

  const _AddMemberSheet({
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _nameController = TextEditingController();
  String _relationship = 'SPOUSE';
  String _gender = 'MALE';
  DateTime? _birthday;
  DateTime? _anniversary;

  static const _relationships = [
    'SPOUSE',
    'CHILD',
    'FATHER',
    'MOTHER',
    'SIBLING',
    'OTHER',
  ];

  static const Color _textDark = Color(0xFF2F3C70);
  static const Color _blue = Color(0xFF007AFF);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isAnniversary) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isAnniversary
          ? _anniversary ?? DateTime.now()
          : _birthday ?? DateTime(1990, 7, 23),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) {
      setState(() {
        if (isAnniversary) {
          _anniversary = d;
        } else {
          _birthday = d;
        }
      });
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onSave(_FamilyMember(
      name: name,
      relationship: _relationship,
      gender: _gender,
      birthday: _birthday,
      anniversary: _anniversary,
    ));
  }

  String get _birthdayText =>
      _birthday == null ? '' : _formatMemberDate(_birthday!);
  String get _anniversaryText =>
      _anniversary == null ? '' : _formatMemberDate(_anniversary!);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 30, 16, 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: title + close
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add member',
                    style: AppTextStyles.heading(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: _textDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(64),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF242424),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Member name
            _SheetLabel(label: 'Member name'),
            const SizedBox(height: 8),
            _SheetTextField(
              controller: _nameController,
              hint: 'Aisha Al-Noor',
            ),
            const SizedBox(height: 20),
            // Relationship
            _SheetLabel(label: 'Relationship'),
            const SizedBox(height: 8),
            _SheetDropdown<String>(
              value: _relationship,
              items: _relationships
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s == 'SPOUSE'
                              ? 'Spouse'
                              : s[0] + s.substring(1).toLowerCase(),
                          style: AppTextStyles.body(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            color: _textDark,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _relationship = v ?? _relationship),
            ),
            const SizedBox(height: 20),
            // Gender
            _SheetLabel(label: 'Gender'),
            const SizedBox(height: 12),
            Row(
              children: [
                _SheetGenderRadio(
                  label: 'Male',
                  value: 'MALE',
                  groupValue: _gender,
                  onChanged: (v) =>
                      setState(() => _gender = v ?? _gender),
                ),
                const SizedBox(width: 24),
                _SheetGenderRadio(
                  label: 'Female',
                  value: 'FEMALE',
                  groupValue: _gender,
                  onChanged: (v) =>
                      setState(() => _gender = v ?? _gender),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Birthday
            _SheetLabel(label: 'Birthday'),
            const SizedBox(height: 8),
            _SheetDateField(
              value: _birthdayText,
              hint: '23 July 1990',
              onTap: () => _pickDate(false),
            ),
            const SizedBox(height: 20),
            // Anniversary date
            _SheetLabel(label: 'Anniversary date'),
            const SizedBox(height: 8),
            _SheetDateField(
              value: _anniversaryText,
              hint: '23 July 2020',
              onTap: () => _pickDate(true),
            ),
            const SizedBox(height: 20),
            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save',
                  style: AppTextStyles.body(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String label;

  const _SheetLabel({required this.label});

  static const Color _labelColor = Color(0xFF979797);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.body(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: _labelColor,
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SheetTextField({
    required this.controller,
    required this.hint,
  });

  static const Color _borderColor = Color(0xFFE0EBFF);
  static const Color _textDark = Color(0xFF2F3C70);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.left,
        style: AppTextStyles.body(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.2,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _textDark.withOpacity(0.5),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _SheetDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _SheetDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const Color _borderColor = Color(0xFFE0EBFF);
  static const Color _textDark = Color(0xFF2F3C70);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
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
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SheetGenderRadio extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _SheetGenderRadio({
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
        mainAxisSize: MainAxisSize.min,
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

class _SheetDateField extends StatelessWidget {
  final String value;
  final String hint;
  final VoidCallback onTap;

  const _SheetDateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  static const Color _borderColor = Color(0xFFE0EBFF);
  static const Color _textDark = Color(0xFF2F3C70);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value.isEmpty ? hint : value,
                style: AppTextStyles.body(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: value.isEmpty
                      ? _textDark.withOpacity(0.6)
                      : _textDark,
                ),
              ),
              const Icon(
                Icons.calendar_today,
                size: 24,
                color: _textDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

