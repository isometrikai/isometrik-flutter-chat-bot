import 'package:flutter/material.dart';

class AddressDetailsScreen extends StatefulWidget {
  const AddressDetailsScreen({super.key});

  @override
  State<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final TextEditingController _fullAddressController = TextEditingController(text: '');
  final TextEditingController _countryController = TextEditingController(text: '');
  final TextEditingController _areaController = TextEditingController(text: '');
  final TextEditingController _cityController = TextEditingController(text: '');
  final TextEditingController _buildingController = TextEditingController(text: '');
  final TextEditingController _landmarkController = TextEditingController(text: '');

  String _tag = 'Home';
  bool _allFilled = false;

  @override
  void initState() {
    super.initState();
    _countryController.addListener(_updateFilledState);
    _areaController.addListener(_updateFilledState);
    _cityController.addListener(_updateFilledState);
    _buildingController.addListener(_updateFilledState);
    _landmarkController.addListener(_updateFilledState);
    _updateFilledState();
  }

  @override
  void dispose() {
    // _fullAddressController.dispose();
    _countryController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _buildingController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 32),
                    Text(
                      'Please provide your\ncomplete address',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF171212),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // _InputField(controller: _fullAddressController),
                    // const SizedBox(height: 16),
                    _InputField(
                      controller: _countryController,
                      hint: 'Country*',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _areaController,
                      hint: 'Area*',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _cityController,
                      hint: 'City*',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _buildingController,
                      hint: 'Building*',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      controller: _landmarkController,
                      hint: 'Landmark*',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _TagRadio(
                          label: 'Home',
                          groupValue: _tag,
                          onChanged: (v) => setState(() => _tag = v!),
                        ),
                        const SizedBox(width: 16),
                        _TagRadio(
                          label: 'Work',
                          groupValue: _tag,
                          onChanged: (v) => setState(() => _tag = v!),
                        ),
                        const SizedBox(width: 16),
                        _TagRadio(
                          label: 'Others',
                          groupValue: _tag,
                          onChanged: (v) => setState(() => _tag = v!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close, color: Color(0xFF585C77)),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _GradientButton(
                enabled: _allFilled,
                onPressed: _onSubmit,
                child: const Text(
                  'Deliver here',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_allFilled) return;

    final Map<String, String> result = {
      'country': _countryController.text.trim(),
      'area': _areaController.text.trim(),
      'city': _cityController.text.trim(),
      'building': _buildingController.text.trim(),
      'landmark': _landmarkController.text.trim(),
      'tag': _tag,
    };

    Navigator.of(context).pop(result);
  }

  void _updateFilledState() {
    final bool next = _countryController.text.trim().isNotEmpty &&
        _areaController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _buildingController.text.trim().isNotEmpty &&
        _landmarkController.text.trim().isNotEmpty;
    if (next != _allFilled) {
      setState(() {
        _allFilled = next;
      });
    }
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  const _InputField({required this.controller, this.hint, this.validator});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF9AA3B2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD8DEF3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF8E2FFD)),
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          height: 1.4,
          color: Color(0xFF242424),
        ),
      ),
    );
  }
}

class _TagRadio extends StatelessWidget {
  final String label;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _TagRadio({
    required this.label,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = label == groupValue;
    return InkWell(
      onTap: () => onChanged(label),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(color: selected ? const Color(0xFF8E2FFD) : const Color(0xFFE9DFFB), width: 0.8),
              shape: BoxShape.circle,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF8E2FFD) : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF242424),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool enabled;
  const _GradientButton({required this.onPressed, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? const [
                    Color(0xFFD445EC),
                    Color(0xFFB02EFB),
                    Color(0xFF8E2FFD),
                    Color(0xFF5E3DFE),
                    Color(0xFF5186E0),
                  ]
                : const [
                    Color(0xFFE5E7EB),
                    Color(0xFFD1D5DB),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        ),
      ),
    );
  }
}


