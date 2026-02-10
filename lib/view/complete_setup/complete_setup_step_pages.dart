import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/model/user_preference_request.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:flutter_svg/svg.dart';

/// Builds the body content for each step of the Complete Setup flow.
/// Used by [CompleteSetupFlowScreen]; each step is a StatefulWidget to preserve state.
class CompleteSetupStepPages {
  CompleteSetupStepPages._();

  static Widget buildStep(BuildContext context, int index) {
    switch (index) {
      case 0:
        return const _Step00ServicesPage();
      case 1:
        return const _Step01PersonalDetailsPage();
      case 2:
        return const _Step02ImportantPeoplePage();
      case 3:
        return const _Step03FoodPreferencesPage();
      case 4:
        return const _Step04ShoppingHabitsPage();
      case 5:
        return const _Step05HealthPreferencesPage();
      case 6:
        return const _Step06TravelPreferencesPage();
      case 7:
        return const _Step07HomeServicesPage();
      case 8:
        return const _Step08BudgetDealsPage();
      case 9:
        return const _Step09NotificationSettingsPage();
      default:
        return const _Step00ServicesPage();
    }
  }
}

// --- Shared styling and widgets ---

const Color _kBlue = Color(0xFF007AFF);
const Color _kBlueLight = Color(0xFFE5F2FF);
const Color _kTextDark = Color(0xFF2F3C70);
const Color _kTextMuted = Color(0xFF7085AE);
const Color _kBorderLight = Color(0xFFE0EBFF);
const Color _kSectionLabel = Color(0xFF2F3C70);
const Color _kLabelGray = Color(0xFF979797);

class _SetupChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SetupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
            color: selected ? _kBlueLight : Colors.white,
            border: Border.all(
              color: selected ? _kBlue : _kBorderLight,
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
                    ? SvgPicture.asset(AssetPath.get('images/ic_correct.svg'),
                    width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                  )
                    : SvgPicture.asset(AssetPath.get('images/ic_select.svg'),
                    width: 18,
                  height: 18,
                  fit: BoxFit.cover,),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  color: _kTextDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupRadio<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const _SetupRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

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
            child: selected
                ? SvgPicture.asset(AssetPath.get('images/ic_radio_select.svg'),
                width: 18,
                height: 18,
                fit: BoxFit.cover,
                )
                : SvgPicture.asset(AssetPath.get('images/ic_radio_de_select.svg'),
                width: 18,
                height: 18,
                fit: BoxFit.cover,),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: _kTextDark,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Step 0: Services you use ---

class _Step00ServicesPage extends StatefulWidget {
  const _Step00ServicesPage();

  @override
  State<_Step00ServicesPage> createState() => _Step00ServicesPageState();
}

class _Step00ServicesPageState extends State<_Step00ServicesPage> {
  static const _labels = [
    'Food 🍕', 'Services 🔧', 'Travel ✈️', 'Education 🎓', 'Groceries 🛒',
    'Package 📦', 'Deals 🎁', 'Tickets 🎫️', 'Pharmacy 💊', 'Shopping 🛍️',
    'Donation ❤️', 'MoneyWiz 💰️',
  ];
  final Set<int> _selected = {}; 

  void _restoreFromBloc() {
    final s = context.read<UserPreferenceBloc>().state.request.services;
    if (s == null) return;
    setState(() {
      _selected.clear();
      if (s.food) _selected.add(0);
      if (s.services) _selected.add(1);
      if (s.travel) _selected.add(2);
      if (s.education) _selected.add(3);
      if (s.groceries) _selected.add(4);
      if (s.package) _selected.add(5);
      if (s.deals) _selected.add(6);
      if (s.tickets) _selected.add(7);
      if (s.pharmacy) _selected.add(8);
      if (s.shopping) _selected.add(9);
      if (s.donation) _selected.add(10);
      if (s.moneywiz) _selected.add(11);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreFromBloc();
      // _selected.add(0); // First option (Food) selected by default
      // _syncToBloc(); // Sync default selection to bloc
    });
  }

  void _syncToBloc() {
    context.read<UserPreferenceBloc>().add(UserPreferenceServicesUpdated(
          UserPreferenceServices(
            food: _selected.contains(0),
            services: _selected.contains(1),
            travel: _selected.contains(2),
            education: _selected.contains(3),
            groceries: _selected.contains(4),
            package: _selected.contains(5),
            deals: _selected.contains(6),
            tickets: _selected.contains(7),
            pharmacy: _selected.contains(8),
            shopping: _selected.contains(9),
            donation: _selected.contains(10),
            moneywiz: _selected.contains(11),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Services you use',
            style: AppTextStyles.heading(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select the services you\'re most interested in. This helps me provide better recommendations.',
            style: AppTextStyles.body(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: _kTextMuted,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_labels.length, (i) => _SetupChip(
              label: _labels[i],
              selected: _selected.contains(i),
              onTap: () {
                setState(() {
                  if (_selected.contains(i)) _selected.remove(i);
                  else _selected.add(i);
                });
                _syncToBloc();
              },
            )),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💡 Tip: Select at least 3 services to help me provide personalized recommendations',
              style: AppTextStyles.body(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: _kTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Step 1: Personal details ---

class _Step01PersonalDetailsPage extends StatefulWidget {
  const _Step01PersonalDetailsPage();

  @override
  State<_Step01PersonalDetailsPage> createState() => _Step01PersonalDetailsPageState();
}

class _Step01PersonalDetailsPageState extends State<_Step01PersonalDetailsPage> {
  DateTime? _dob;
  String _gender = 'Male';
  String _language = 'English';
  static const _languages = ['English', 'Arabic', 'Hindi', 'Urdu'];
  static const _langCodes = ['en', 'ar', 'hi', 'ur'];

  void _restoreFromBloc() {
    final d = context.read<UserPreferenceBloc>().state.request.personalDetails;
    if (d == null) return;
    DateTime? dob;
    if (d.dateOfBirth != null && d.dateOfBirth!.length >= 10) {
      final parts = d.dateOfBirth!.split('-');
      if (parts.length == 3) {
        dob = DateTime.tryParse(d.dateOfBirth!);
      }
    }
    final gender = d.gender.length > 1
        ? '${d.gender[0].toUpperCase()}${d.gender.substring(1)}'
        : (d.gender.isEmpty ? 'Male' : d.gender.toUpperCase());
    final langIdx = _langCodes.indexOf(d.preferredLanguage);
    final language = langIdx >= 0 ? _languages[langIdx] : 'English';
    if (mounted) setState(() {
      _dob = dob;
      _gender = gender;
      _language = language;
    });
  }

  void _syncToBloc() {
    final dobStr = _dob != null
        ? '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}'
        : null;
    final langIndex = _languages.indexOf(_language);
    context.read<UserPreferenceBloc>().add(UserPreferencePersonalDetailsUpdated(
          UserPreferencePersonalDetails(
            dateOfBirth: dobStr,
            gender: _gender.toLowerCase(),
            preferredLanguage: langIndex >= 0 ? _langCodes[langIndex] : 'en',
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreFromBloc();
      _syncToBloc();
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2002, 10, 2),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.appThemeColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _kTextDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) {
      setState(() => _dob = d);
      _syncToBloc();
    }
  }

  String get _dateText {
    if (_dob == null) return '';
    const m = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return '${_dob!.day.toString().padLeft(2, '0')} ${m[_dob!.month - 1]} ${_dob!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Personal details',
            style: AppTextStyles.heading(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: _kTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Basic information to personalize your experience',
            style: AppTextStyles.body(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: _kTextMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Date of birth',
            style: AppTextStyles.body(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _kLabelGray,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: _kBorderLight, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateText.isEmpty ? 'DD Month YYYY' : _dateText,
                      style: AppTextStyles.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: _dateText.isEmpty
                            ? _kTextMuted
                            : _kTextDark,
                      ),
                    ),
                    const Icon(Icons.calendar_today,
                        size: 24, color: _kTextDark),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gender',
            style: AppTextStyles.body(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _kLabelGray,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SetupRadio<String>(
                label: 'Male',
                value: 'Male',
                groupValue: _gender,
                onChanged: (v) {
                  setState(() => _gender = v ?? _gender);
                  _syncToBloc();
                },
              ),
              const SizedBox(width: 24),
              _SetupRadio<String>(
                label: 'Female',
                value: 'Female',
                groupValue: _gender,
                onChanged: (v) {
                  setState(() => _gender = v ?? _gender);
                  _syncToBloc();
                },
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // Text(
          //   'Preferred language',
          //   style: AppTextStyles.body(
          //     fontSize: 12,
          //     fontWeight: FontWeight.w400,
          //     color: _kLabelGray,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // Container(
          //   height: 48,
          //   padding: const EdgeInsets.symmetric(
          //       horizontal: 15, vertical: 12),
          //   decoration: BoxDecoration(
          //     border: Border.all(color: _kBorderLight, width: 1),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: DropdownButtonHideUnderline(
          //     child: DropdownButton<String>(
          //       value: _language,
          //       isExpanded: true,
          //       style: AppTextStyles.body(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w400,
          //         color: _kTextDark,
          //       ),
          //       items: _languages
          //           .map((s) => DropdownMenuItem<String>(
          //                 value: s,
          //                 child: Text(s),
          //               ))
          //           .toList(),
          //       onChanged: (v) =>
          //           setState(() => _language = v ?? _language),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// --- Step 2: Important people (simplified: list + add button; sheet reuses logic from existing screen via showModalBottomSheet with inline form) ---

class _FamilyMemberData {
  final String name, relationship, gender;
  final DateTime? birthday, anniversary;
  _FamilyMemberData({required this.name, required this.relationship, required this.gender, this.birthday, this.anniversary});
}

String _fmtDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

String? _toApiDate(DateTime? d) {
  if (d == null) return null;
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

DateTime? _parseApiDate(String? s) {
  if (s == null || s.length < 10) return null;
  return DateTime.tryParse(s);
}

class _Step02ImportantPeoplePage extends StatefulWidget {
  const _Step02ImportantPeoplePage();

  @override
  State<_Step02ImportantPeoplePage> createState() => _Step02ImportantPeoplePageState();
}

class _Step02ImportantPeoplePageState extends State<_Step02ImportantPeoplePage> {
  final List<_FamilyMemberData> _members = [
  ];

  void _restoreFromBloc() {
    final people = context.read<UserPreferenceBloc>().state.request.importantPeople;
    if (people == null || people.isEmpty) return;
    final list = people.map((p) => _FamilyMemberData(
      name: p.name,
      relationship: p.relation.toUpperCase(),
      gender: p.gender.toUpperCase(),
      birthday: _parseApiDate(p.dateOfBirth),
      anniversary: _parseApiDate(p.anniversary),
    )).toList();
    if (mounted) setState(() {
      _members.clear();
      _members.addAll(list);
    });
  }

  void _syncToBloc() {
    final people = _members
        .map((m) => UserPreferenceImportantPerson(
              relation: m.relationship,
              name: m.name,
              dateOfBirth: _toApiDate(m.birthday),
              anniversary: _toApiDate(m.anniversary),
              gender: m.gender,
            ))
        .toList();
    context.read<UserPreferenceBloc>().add(UserPreferenceImportantPeopleUpdated(people));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreFromBloc();
      _syncToBloc();
    });
  }

  void _addMember() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMemberSheet(
        onSave: (m) {
          setState(() => _members.add(m));
          _syncToBloc();
          Navigator.of(ctx).pop();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Important people', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('Add family members so I can remind you about birthdays and anniversaries.', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 24),
          ...List.generate(_members.length, (i) {
            final m = _members[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _kBorderLight, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Pill(label: m.relationship),
                        const SizedBox(width: 7),
                        _Pill(label: m.gender),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(m.name, style: AppTextStyles.body(fontSize: 16, fontWeight: FontWeight.w400, height: 1.2, color: _kTextDark)),
                    if (m.birthday != null) ...[
                      const SizedBox(height: 4),
                      Text('${m.relationship == 'FATHER' ? 'DOB' : 'Birthday'} : ${_fmtDate(m.birthday!)}', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kTextMuted)),
                    ],
                    if (m.anniversary != null) ...[
                      const SizedBox(height: 4),
                      Text('Anniversary : ${_fmtDate(m.anniversary!)}', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kTextMuted)),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _addMember,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF2E8AFF), width: 0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Member', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, color: _kBlue)),
                    const SizedBox(width: 8),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(color: _kBlueLight, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 14, color: _kBlue),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FF), borderRadius: BorderRadius.circular(80)),
      child: Text(label, style: AppTextStyles.body(fontSize: 10, fontWeight: FontWeight.w400, color: const Color(0xFF414F85))),
    );
  }
}

class _AddMemberSheet extends StatefulWidget {
  final void Function(_FamilyMemberData) onSave;
  final VoidCallback onCancel;

  const _AddMemberSheet({required this.onSave, required this.onCancel});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _nameController = TextEditingController();
  String _relationship = 'SPOUSE';
  String _gender = 'MALE';
  DateTime? _birthday, _anniversary;
  static const _relationships = ['SPOUSE', 'CHILD', 'FATHER', 'MOTHER', 'OTHER'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool ann) async {
    final d = await showDatePicker(
      context: context,
      initialDate: ann ? (_anniversary ?? DateTime.now()) : (_birthday ?? DateTime(1990, 7, 23)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
       builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.appThemeColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _kTextDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) setState(() => ann ? _anniversary = d : _birthday = d);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 30, 16, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Add member', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
                ),
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(64)),
                    child: const Icon(Icons.close, size: 14, color: Color(0xFF242424)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Member name', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide:  BorderSide(color: _kBorderLight)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide:  BorderSide(color: _kBorderLight)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            Text('Relationship', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _kBorderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _relationship,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  items: _relationships.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _relationship = v ?? _relationship),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Gender', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
            const SizedBox(height: 8),
            Row(
              children: [
                _SetupRadio<String>(label: 'Male', value: 'MALE', groupValue: _gender, onChanged: (v) => setState(() => _gender = v ?? _gender)),
                const SizedBox(width: 24),
                _SetupRadio<String>(label: 'Female', value: 'FEMALE', groupValue: _gender, onChanged: (v) => setState(() => _gender = v ?? _gender)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Birthday', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickDate(false),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: _kBorderLight), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_birthday == null ? 'Select' : _fmtDate(_birthday!), style: AppTextStyles.body(fontSize: 16, color: _kTextDark)),
                    const Icon(Icons.calendar_today, size: 24, color: _kTextDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Anniversary', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _pickDate(true),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                decoration: BoxDecoration(border: Border.all(color: _kBorderLight), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_anniversary == null ? 'Select' : _fmtDate(_anniversary!), style: AppTextStyles.body(fontSize: 16, color: _kTextDark)),
                    const Icon(Icons.calendar_today, size: 24, color: _kTextDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  widget.onSave(_FamilyMemberData(name: name, relationship: _relationship, gender: _gender, birthday: _birthday, anniversary: _anniversary));
                },
                style: ElevatedButton.styleFrom(backgroundColor: _kBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Step 3: Food preferences ---

class _Step03FoodPreferencesPage extends StatefulWidget {
  const _Step03FoodPreferencesPage();

  @override
  State<_Step03FoodPreferencesPage> createState() => _Step03FoodPreferencesPageState();
}

class _Step03FoodPreferencesPageState extends State<_Step03FoodPreferencesPage> {
  static const _cuisines = ['Indian 🇮🇳', 'Chinese 🇨🇳', 'Thai 🇹🇭', 'Mexican 🇲🇽', 'Italian 🇮🇹', 'Continental 🍽️', 'Others 🍽️'];
  static const _cuisineApi = ['indian', 'chinese', 'thai', 'mexican', 'italian', 'continental', 'others'];
  static const _dietary = ['Vegetarian 🥗', 'Non-Vegetarian 🍗', 'Vegan 🌱', 'Jain 🙏'];
  static const _dietaryApi = ['vegetarian', 'non-veg', 'vegan', 'jain'];
  final Set<int> _selC = {};
  final Set<int> _selD = {};

  void _restoreFromBloc() {
    final f = context.read<UserPreferenceBloc>().state.request.foodPreferences;
    if (f == null) return;
    final selC = <int>{};
    for (final c in f.favoriteCuisines) {
      final i = _cuisineApi.indexOf(c);
      if (i >= 0) selC.add(i);
    }
    final selD = <int>{};
    for (final d in f.dietaryPreferences) {
      final i = _dietaryApi.indexOf(d);
      if (i >= 0) selD.add(i);
    }
    if (mounted) setState(() {
      _selC.clear();
      _selC.addAll(selC);
      _selD.clear();
      _selD.addAll(selD);
    });
  }

  void _syncToBloc() {
    context.read<UserPreferenceBloc>().add(UserPreferenceFoodUpdated(
          UserPreferenceFoodPreferences(
            favoriteCuisines: _selC.map((i) => _cuisineApi[i]).toList(),
            dietaryPreferences: _selD.map((i) => _dietaryApi[i]).toList(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromBloc());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Food preferences', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('Help me recommend restaurants and meals you\'ll love', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 32),
          Text('Favorite cuisines', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_cuisines.length, (i) => _SetupChip(label: _cuisines[i], selected: _selC.contains(i), onTap: () { setState(() { if (_selC.contains(i)) _selC.remove(i); else _selC.add(i); }); _syncToBloc(); }))),
          const SizedBox(height: 24),
          Text('Dietary preferences', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_dietary.length, (i) => _SetupChip(label: _dietary[i], selected: _selD.contains(i), onTap: () { setState(() { if (_selD.contains(i)) _selD.remove(i); else _selD.add(i); }); _syncToBloc(); }))),
        ],
      ),
    );
  }
}

// --- Step 4: Shopping habits ---

class _Step04ShoppingHabitsPage extends StatefulWidget {
  const _Step04ShoppingHabitsPage();

  @override
  State<_Step04ShoppingHabitsPage> createState() => _Step04ShoppingHabitsPageState();
}

class _Step04ShoppingHabitsPageState extends State<_Step04ShoppingHabitsPage> {
  static const _freq = ['Daily', 'Weekly', 'Bi-weekly', 'Monthly'];
  static const _freqApi = ['daily', 'weekly', 'bi-weekly', 'monthly'];
  static const _cats = ['Groceries 🛒', 'Fashion 👕', 'Electronics 📱', 'Home & Living 🏠', 'Beauty 💄'];
  static const _catsApi = ['groceries', 'fashion', 'electronics', 'home_living', 'beauty'];
  int _freqIndex = 1;
  final Set<int> _sel = {};//{0};

  void _restoreFromBloc() {
    final h = context.read<UserPreferenceBloc>().state.request.shoppingHabits;
    if (h == null) return;
    final idx = _freqApi.indexOf(h.groceryFrequency);
    final sel = <int>{};
    for (final c in h.categories) {
      final i = _catsApi.indexOf(c);
      if (i >= 0) sel.add(i);
    }
    if (mounted) setState(() {
      _freqIndex = idx >= 0 ? idx : 1;
      _sel.clear();
      _sel.addAll(sel);
      // if (_sel.isEmpty) _sel.add(0);
    });
  }

  void _syncToBloc() {
    context.read<UserPreferenceBloc>().add(UserPreferenceShoppingUpdated(
          UserPreferenceShoppingHabits(
            groceryFrequency: _freqApi[_freqIndex],
            categories: _sel.map((i) => _catsApi[i]).toList(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromBloc());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Shopping habits', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('Help me understand your shopping needs', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 32),
          Text('How often do you shop for groceries?', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 16),
          ...List.generate(_freq.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _SetupRadio<int>(label: _freq[i], value: i, groupValue: _freqIndex, onChanged: (v) { setState(() => _freqIndex = v!); _syncToBloc(); }),
          )),
          const SizedBox(height: 24),
          Text('Shopping Interests', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_cats.length, (i) => _SetupChip(label: _cats[i], selected: _sel.contains(i), onTap: () { setState(() { if (_sel.contains(i)) _sel.remove(i); else _sel.add(i); }); _syncToBloc(); }))),
        ],
      ),
    );
  }
}

// --- Step 5: Health preferences ---

class _Step05HealthPreferencesPage extends StatefulWidget {
  const _Step05HealthPreferencesPage();

  @override
  State<_Step05HealthPreferencesPage> createState() => _Step05HealthPreferencesPageState();
}

class _Step05HealthPreferencesPageState extends State<_Step05HealthPreferencesPage> {
  bool _hasPrescriptions = true;
  String _freq = 'Weekly';
  static const _freqOpts = ['Daily', 'Weekly', 'Monthly'];
  static const _freqApi = ['daily', 'weekly', 'monthly'];
  static const _interests = ['Fitness 💪', 'Nutrition 🥗', 'Yoga 🧘', 'Wellness ✨'];
  static const _interestsApi = ['fitness', 'nutrition', 'yoga', 'wellness'];
  final Set<int> _sel = {};//{0};

  void _restoreFromBloc() {
    final h = context.read<UserPreferenceBloc>().state.request.healthPreferences;
    if (h == null) return;
    final freqIdx = _freqApi.indexOf(h.reminderFrequency);
    final sel = <int>{};
    for (final x in h.interests) {
      final i = _interestsApi.indexOf(x);
      if (i >= 0) sel.add(i);
    }
    if (mounted) setState(() {
      _hasPrescriptions = h.hasRecurringPrescriptions;
      _freq = freqIdx >= 0 ? _freqOpts[freqIdx] : 'Weekly';
      _sel.clear();
      _sel.addAll(sel);
      // if (_sel.isEmpty) _sel.add(0);
    });
  }

  void _syncToBloc() {
    context.read<UserPreferenceBloc>().add(UserPreferenceHealthUpdated(
          UserPreferenceHealthPreferences(
            hasRecurringPrescriptions: _hasPrescriptions,
            reminderFrequency: _freqApi[_freqOpts.indexOf(_freq).clamp(0, _freqApi.length - 1)],
            interests: _sel.map((i) => _interestsApi[i]).toList(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromBloc());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Health preferences', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('For pharmacy and health service recommendations', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 32),
          Text('Do you have any recurring prescriptions?', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 16),
          _SetupRadio<bool>(label: 'Yes, I need reminders', value: true, groupValue: _hasPrescriptions, onChanged: (v) { setState(() => _hasPrescriptions = v ?? true); _syncToBloc(); }),
          const SizedBox(height: 16),
          _SetupRadio<bool>(label: 'No prescriptions', value: false, groupValue: _hasPrescriptions, onChanged: (v) { setState(() => _hasPrescriptions = v ?? false); _syncToBloc(); }),
          if (_hasPrescriptions) ...[
            const SizedBox(height: 24),
            Text('Reminder frequency', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _kBorderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _freq,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  items: _freqOpts.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) { setState(() => _freq = v ?? _freq); _syncToBloc(); },
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Health interests', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_interests.length, (i) => _SetupChip(label: _interests[i], selected: _sel.contains(i), onTap: () { setState(() { if (_sel.contains(i)) _sel.remove(i); else _sel.add(i); }); _syncToBloc(); }))),
        ],
      ),
    );
  }
}

// --- Step 6: Travel preferences ---

class _Step06TravelPreferencesPage extends StatefulWidget {
  const _Step06TravelPreferencesPage();

  @override
  State<_Step06TravelPreferencesPage> createState() => _Step06TravelPreferencesPageState();
}

class _Step06TravelPreferencesPageState extends State<_Step06TravelPreferencesPage> {
  static const _freq = ['Frequent (Monthly)', 'Occasional (Few times a year)', 'Rarely'];
  static const _freqApi = ['frequent', 'occasional', 'rarely'];
  static const _purposes = ['Business 💼', 'Vacation 🏖️', 'Family Visits 👨‍👩‍👧', 'Adventure 🏔️'];
  static const _purposesApi = ['business', 'vacation', 'family_visits', 'adventure'];
  static const _entertainment = ['Movies 🎬', 'Concerts 🎵', 'Sports ⚽', 'Events 🎪️'];
  static const _entertainmentApi = ['movies', 'concerts', 'sports', 'events'];
  int _freqIndex = 0;
  final Set<int> _selP = {};//{0};
  final Set<int> _selE = {};//{0};

  void _restoreFromBloc() {
    final t = context.read<UserPreferenceBloc>().state.request.travelPreferences;
    if (t == null) return;
    final idx = _freqApi.indexOf(t.travelFrequency);
    final selP = <int>{};
    for (final x in t.purposes) {
      final i = _purposesApi.indexOf(x);
      if (i >= 0) selP.add(i);
    }
    final selE = <int>{};
    for (final x in t.entertainmentInterests) {
      final i = _entertainmentApi.indexOf(x);
      if (i >= 0) selE.add(i);
    }
    if (mounted) setState(() {
      _freqIndex = idx >= 0 ? idx : 0;
      _selP.clear();
      _selP.addAll(selP);
      // if (_selP.isEmpty) _selP.add(0);
      _selE.clear();
      _selE.addAll(selE);
      // if (_selE.isEmpty) _selE.add(0);
    });
  }

  void _syncToBloc() {
    context.read<UserPreferenceBloc>().add(UserPreferenceTravelUpdated(
          UserPreferenceTravelPreferences(
            travelFrequency: _freqApi[_freqIndex],
            purposes: _selP.map((i) => _purposesApi[i]).toList(),
            entertainmentInterests: _selE.map((i) => _entertainmentApi[i]).toList(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromBloc());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Travel preferences', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('For personalized travel & ticket recommendations', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 32),
          Text('Travel frequency', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 12),
          ...List.generate(_freq.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _SetupRadio<int>(label: _freq[i], value: i, groupValue: _freqIndex, onChanged: (v) { setState(() => _freqIndex = v!); _syncToBloc(); }))),
          const SizedBox(height: 12),
          Text('Travel purposes', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_purposes.length, (i) => _SetupChip(label: _purposes[i], selected: _selP.contains(i), onTap: () { setState(() { if (_selP.contains(i)) _selP.remove(i); else _selP.add(i); }); _syncToBloc(); }))),
          const SizedBox(height: 24),
          Text('Entertainment interests', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_entertainment.length, (i) => _SetupChip(label: _entertainment[i], selected: _selE.contains(i), onTap: () { setState(() { if (_selE.contains(i)) _selE.remove(i); else _selE.add(i); }); _syncToBloc(); }))),
        ],
      ),
    );
  }
}

// --- Step 7: Home services ---

class _Step07HomeServicesPage extends StatefulWidget {
  const _Step07HomeServicesPage();

  @override
  State<_Step07HomeServicesPage> createState() => _Step07HomeServicesPageState();
}

class _Step07HomeServicesPageState extends State<_Step07HomeServicesPage> {
  static const _services = ['Cleaning', 'Plumbing', 'Carpentry', 'Electrical', 'Painting', 'Appliance Repair'];
  static const _servicesApi = ['cleaning', 'plumbing', 'carpentry', 'electrical', 'painting', 'appliance_repair'];
  static const _times = ['Morning (8 AM - 12 PM)', 'Afternoon (12 PM - 5 PM)', 'Evening (5 PM - 8 PM)', 'Flexible - Anytime'];
  static const _timesApi = ['morning', 'afternoon', 'evening', 'flexible'];
  final Set<int> _sel = {0};
  int _timeIndex = 0;

  void _restoreFromBloc() {
    final h = context.read<UserPreferenceBloc>().state.request.homeServices;
    if (h == null) return;
    final sel = <int>{};
    for (final x in h.servicesUsed) {
      final i = _servicesApi.indexOf(x);
      if (i >= 0) sel.add(i);
    }
    final timeIdx = _timesApi.indexOf(h.preferredServiceTime);
    if (mounted) setState(() {
      _sel.clear();
      _sel.addAll(sel);
      // if (_sel.isEmpty) _sel.add(0);
      _timeIndex = timeIdx >= 0 ? timeIdx : 0;
    });
  }

  void _syncToBloc() {
    context.read<UserPreferenceBloc>().add(UserPreferenceHomeServicesUpdated(
          UserPreferenceHomeServices(
            servicesUsed: _sel.map((i) => _servicesApi[i]).toList(),
            preferredServiceTime: _timesApi[_timeIndex],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromBloc());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Home services', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('What services do you typically need?', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 32),
          Text('Select services you use', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_services.length, (i) => _SetupChip(label: _services[i], selected: _sel.contains(i), onTap: () { setState(() { if (_sel.contains(i)) _sel.remove(i); else _sel.add(i); }); _syncToBloc(); }))),
          const SizedBox(height: 24),
          Text('Preferred service time', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 16),
          ...List.generate(_times.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _SetupRadio<int>(label: _times[i], value: i, groupValue: _timeIndex, onChanged: (v) { setState(() => _timeIndex = v!); _syncToBloc(); }))),
        ],
      ),
    );
  }
}

// --- Step 8: Budget & deals ---

class _Step08BudgetDealsPage extends StatefulWidget {
  const _Step08BudgetDealsPage();

  @override
  State<_Step08BudgetDealsPage> createState() => _Step08BudgetDealsPageState();
}

class _Step08BudgetDealsPageState extends State<_Step08BudgetDealsPage> {
  static const _deals = ['Very Important - Always looking for deals', 'Moderate - Nice to have', 'Low - Convenience first'];
  static const _dealsApi = ['very_important', 'moderate', 'low'];
  static const _ranges = ['₹2,000 - ₹5,000', '₹5,000 - ₹10,000', '₹10,000 - ₹20,000', '₹20,000+'];
  static const _rangeMin = [2000, 5000, 10000, 20000];
  static const _rangeMax = [5000, 10000, 20000, 50000];
  static const _causes = ['Education', 'Healthcare', 'Environment', 'Animals'];
  static const _causesApi = ['education', 'healthcare', 'environment', 'animals'];
  int _dealsIndex = 0;
  String _range = _ranges[0];
  final Set<int> _selCauses = {0};

  void _restoreFromBloc() {
    final b = context.read<UserPreferenceBloc>().state.request.budgetAndDeals;
    if (b == null) return;
    final dealIdx = _dealsApi.indexOf(b.dealImportance);
    String range = _ranges[0];
    if (b.monthlyBudgetRange != null) {
      for (int i = 0; i < _rangeMin.length; i++) {
        if (_rangeMin[i] == b.monthlyBudgetRange!.min && _rangeMax[i] == b.monthlyBudgetRange!.max) {
          range = _ranges[i];
          break;
        }
      }
    }
    final selCauses = <int>{};
    for (final x in b.donationCauses) {
      final i = _causesApi.indexOf(x);
      if (i >= 0) selCauses.add(i);
    }
    if (mounted) setState(() {
      _dealsIndex = dealIdx >= 0 ? dealIdx : 0;
      _range = range;
      _selCauses.clear();
      _selCauses.addAll(selCauses);
      // if (_selCauses.isEmpty) _selCauses.add(0);
    });
  }

  void _syncToBloc() {
    final rangeIndex = _ranges.indexOf(_range).clamp(0, _rangeMin.length - 1);
    context.read<UserPreferenceBloc>().add(UserPreferenceBudgetUpdated(
          UserPreferenceBudgetAndDeals(
            dealImportance: _dealsApi[_dealsIndex],
            monthlyBudgetRange: UserPreferenceBudgetRange(min: _rangeMin[rangeIndex], max: _rangeMax[rangeIndex]),
            donationCauses: _selCauses.map((i) => _causesApi[i]).toList(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromBloc());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Budget & deals', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('Help me find the best deals for you', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 32),
          Text('How important are deals/discounts to you?', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 16),
          ...List.generate(_deals.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _SetupRadio<int>(label: _deals[i], value: i, groupValue: _dealsIndex, onChanged: (v) { setState(() => _dealsIndex = v!); _syncToBloc(); }))),
          const SizedBox(height: 24),
          Text('Monthly budget for online services (approx.)', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 8),
          Text('Select range', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _kBorderLight),
                borderRadius: BorderRadius.circular(8),
              ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _range,
                isExpanded: true,
                dropdownColor: Colors.white,
                items: _ranges.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) { setState(() => _range = v ?? _range); _syncToBloc(); },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Causes you care about (for donations)', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_causes.length, (i) => _SetupChip(label: _causes[i], selected: _selCauses.contains(i), onTap: () { setState(() { if (_selCauses.contains(i)) _selCauses.remove(i); else _selCauses.add(i); }); _syncToBloc(); }))),
        ],
      ),
    );
  }
}

// --- Step 9: Notification settings ---

class _Step09NotificationSettingsPage extends StatefulWidget {
  const _Step09NotificationSettingsPage();

  @override
  State<_Step09NotificationSettingsPage> createState() => _Step09NotificationSettingsPageState();
}

class _Step09NotificationSettingsPageState extends State<_Step09NotificationSettingsPage> {
  static const _remind = ['1 Week before', '3 Days before', '1 Day before'];
  static const _remindApi = ['1_week', '3_days', '1_day'];
  static const _times = ['Morning (09:00am)', 'Afternoon (02:00pm)', 'Evening (06:00pm)'];
  static const _timesApi = ['09:00', '14:00', '18:00'];
  static const _about = ['Birthdays 🎂', 'Deals & Offers 💰', 'Order Updates 📦', 'Service Bookings 🔧'];
  static const _aboutApi = ['birthdays', 'deals', 'order_updates', 'service_bookings'];
  int _remindIndex = 0;
  String _time = _times[0];
  final Set<int> _selAbout = {0};

  void _restoreFromBloc() {
    final n = context.read<UserPreferenceBloc>().state.request.notificationSettings;
    if (n == null) return;
    final remindIdx = _remindApi.indexOf(n.reminderBefore);
    int timeIdx = _timesApi.indexOf(n.preferredTime);
    if (timeIdx < 0) timeIdx = 0;
    final selAbout = <int>{};
    for (final x in n.reminderTypes) {
      final i = _aboutApi.indexOf(x);
      if (i >= 0) selAbout.add(i);
    }
    if (mounted) setState(() {
      _remindIndex = remindIdx >= 0 ? remindIdx : 0;
      _time = timeIdx < _times.length ? _times[timeIdx] : _times[0];
      _selAbout.clear();
      _selAbout.addAll(selAbout);
      // if (_selAbout.isEmpty) _selAbout.add(0);
    });
  }

  void _syncToBloc() {
    context.read<UserPreferenceBloc>().add(UserPreferenceNotificationUpdated(
          UserPreferenceNotificationSettings(
            reminderBefore: _remindApi[_remindIndex],
            preferredTime: _timesApi[_times.indexOf(_time).clamp(0, _timesApi.length - 1)],
            reminderTypes: _selAbout.map((i) => _aboutApi[i]).toList(),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreFromBloc());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Notification settings', style: AppTextStyles.heading(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, color: _kTextDark)),
          const SizedBox(height: 12),
          Text('When should I remind you about important events?', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, color: _kTextMuted)),
          const SizedBox(height: 32),
          Text('Remind me before events', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 16),
          ...List.generate(_remind.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _SetupRadio<int>(label: _remind[i], value: i, groupValue: _remindIndex, onChanged: (v) { setState(() => _remindIndex = v!); _syncToBloc(); }))),
          const SizedBox(height: 24),
          Text('Best time to notify you', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 8),
          Text('Select range', style: AppTextStyles.body(fontSize: 12, fontWeight: FontWeight.w400, color: _kLabelGray)),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _kBorderLight),
                borderRadius: BorderRadius.circular(8),
              ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _time,
                isExpanded: true,
                dropdownColor: Colors.white,
                items: _times.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) { setState(() => _time = v ?? _time); _syncToBloc(); },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('What should I remind you about?', style: AppTextStyles.body(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2, color: _kSectionLabel)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(_about.length, (i) => _SetupChip(label: _about[i], selected: _selAbout.contains(i), onTap: () { setState(() { if (_selAbout.contains(i)) _selAbout.remove(i); else _selAbout.add(i); }); _syncToBloc(); }))),
        ],
      ),
    );
  }
}
