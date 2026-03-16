import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/utils/utils.dart';

/// Service type option for doctor booking (In-Call, Out-Call, Tele-Call).
enum DoctorServiceType {
  inCall,
  outCall,
  teleCall,
}

extension DoctorServiceTypeX on DoctorServiceType {
  String get label {
    switch (this) {
      case DoctorServiceType.inCall:
        return "Visit at doctor's clinic";
      case DoctorServiceType.outCall:
        return "Doctor's at home";
      case DoctorServiceType.teleCall:
        return "Tele appointment";
    }
  }
}

/// Bottom sheet to select doctor service type (In-Call / Out-Call / Tele-Call)
/// based on [Doctor.pricing] flags. Only options with true flag are shown.
/// First option is selected by default.
class DoctorServiceTypeSheet extends StatefulWidget {
  final Doctor doctor;
  final void Function(DoctorServiceType selectedType)? onConfirm;

  const DoctorServiceTypeSheet({
    super.key,
    required this.doctor,
    this.onConfirm,
  });

  /// Shows the sheet. When the user confirms, [onServiceTypeSelected] is called
  /// with the selected type (and the sheet closes). Optional [onServiceTypeSelected]
  /// callback so you can react to the selection (e.g. add to cart).
  static Future<DoctorServiceType?> show(
    BuildContext context, {
    required Doctor doctor,
    void Function(DoctorServiceType selectedType)? onServiceTypeSelected,
  }) {
    return showModalBottomSheet<DoctorServiceType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DoctorServiceTypeSheet(
        doctor: doctor,
        onConfirm: (type) {
          onServiceTypeSelected?.call(type);
          Navigator.of(context).pop(type);
        },
      ),
    );
  }

  @override
  State<DoctorServiceTypeSheet> createState() => _DoctorServiceTypeSheetState();
}

class _DoctorServiceTypeSheetState extends State<DoctorServiceTypeSheet> {
  DoctorServiceType? _selectedType;

  List<DoctorServiceType> get _availableOptions {
    final pricing = widget.doctor.pricing;
    if (pricing == null) return [DoctorServiceType.inCall];
    final List<DoctorServiceType> options = [];
    if (pricing.isInCallFee) options.add(DoctorServiceType.inCall);
    if (pricing.isOutCallFee) options.add(DoctorServiceType.outCall);
    if (pricing.isTeleCallFee) options.add(DoctorServiceType.teleCall);
    if (options.isEmpty) return [DoctorServiceType.inCall];
    return options;
  }

  int _feeFor(DoctorServiceType type) {
    final pricing = widget.doctor.pricing;
    if (pricing == null) return 0;
    switch (type) {
      case DoctorServiceType.inCall:
        return pricing.inCallFee;
      case DoctorServiceType.outCall:
        return pricing.outCallFee;
      case DoctorServiceType.teleCall:
        return pricing.teleCallFee;
    }
  }

  @override
  void initState() {
    super.initState();
    final options = _availableOptions;
    _selectedType = options.isNotEmpty ? options.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final options = _availableOptions;
    if (options.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Text('No service options available'),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select service type',
              style: AppTextStyles.productTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF242424),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.doctor.fullName,
              style: AppTextStyles.restaurantDescription.copyWith(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((type) {
              final isSelected = _selectedType == type;
              final fee = _feeFor(type);
              final priceText =
                  '${Utility.getCurrencyCode()} ${fee.toString()}';
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          type.label,
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
                      const SizedBox(width: 8),
                      Text(
                        priceText,
                        style: AppTextStyles.body(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ).copyWith(
                          color: const Color(0xFF242424),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildRadioButton(isSelected),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedType == null
                    ? null
                    : () => widget.onConfirm?.call(_selectedType!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.appThemeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirm'),
              ),
            ),
          ],
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
