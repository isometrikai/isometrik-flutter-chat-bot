import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/app_theme.dart';
import 'package:chat_bot/utils/app_translations.dart';
import 'package:chat_bot/utils/asset_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Success bottom sheet shown after a successful Pro plan purchase.
class ProPlanSuccessBottomSheet extends StatelessWidget {
  final String priceLabel;

  const ProPlanSuccessBottomSheet({
    super.key,
    required this.priceLabel,
  });

  static Future<void> show(
    BuildContext context, {
    required String priceLabel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => ProPlanSuccessBottomSheet(priceLabel: priceLabel),
    );
  }

  static const Color _titleColor = Color(0xFF242424);
  static const Color _bodyColor = Color(0xFF6B7280);
  static const Color _footerBg = Color(0xFFF5F9FF);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                SvgPicture.asset(
                  AssetPath.get('images/img_success_pro.svg'),
                  width: 88,
                  height: 88,
                ),
                const SizedBox(height: 20),
                Text(
                  AppTranslations.proPlanSuccessTitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.getTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _titleColor,
                  ).copyWith(height: 1.25),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    style: AppTheme.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _bodyColor,
                    ).copyWith(height: 1.45),
                    children: [
                      TextSpan(text: AppTranslations.proPlanSuccessDescPrefix),
                      TextSpan(
                        text: '$priceLabel/month',
                        style: TextStyle(
                          color: AppConstants.appThemeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: AppTranslations.proPlanSuccessDescSuffix),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: _footerBg,
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppConstants.appThemeColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      AppTranslations.proPlanSuccessContinue,
                      style: AppTheme.getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
