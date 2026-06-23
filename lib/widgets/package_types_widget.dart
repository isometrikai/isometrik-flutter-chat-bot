import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';

class PackageTypesWidget extends StatelessWidget {
  final List<SendPackageType> packageTypes;
  final void Function(SendPackageType packageType)? onPackageTypeSelected;
  final bool isFromChatHistory;
  final String headerText;

  const PackageTypesWidget({
    super.key,
    required this.packageTypes,
    this.onPackageTypeSelected,
    this.isFromChatHistory = false,
    this.headerText = 'Select a category below',
  });

  static const Color _borderColor = Color(0xFFE9DFFB);
  static const Color _rowBackground = Color(0xFFF5F7FF);
  static const Color _labelColor = Color(0xFF8E2FFD);
  static const Color _headerColor = Color(0xFF242424);

  @override
  Widget build(BuildContext context) {
    if (packageTypes.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 294),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                headerText,
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: _headerColor,
                ),
              ),
              for (int i = 0; i < packageTypes.length; i++) ...[
                const SizedBox(height: 10),
                _PackageTypeRow(
                  label: packageTypes[i].sendPackageTypeName,
                  onTap: isFromChatHistory
                      ? null
                      : () => onPackageTypeSelected?.call(packageTypes[i]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageTypeRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PackageTypeRow({
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: PackageTypesWidget._rowBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyText.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: PackageTypesWidget._labelColor,
        ),
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: row,
      ),
    );
  }
}
