import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/app_locale.dart';
import 'package:chat_bot/utils/app_theme.dart';
import 'package:chat_bot/utils/app_translations.dart';
import 'package:flutter/material.dart';

/// Plan & Price subscription full-screen page.
class PlanPriceBottomSheet extends StatefulWidget {
  const PlanPriceBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      AppLocale.materialRoute(
        fullscreenDialog: true,
        builder: (_) => const PlanPriceBottomSheet(),
      ),
    );
  }

  static const Color _titleColor = Color(0xFF242424);
  static const Color _mutedGrey = Color(0xFF979797);
  static const Color _priceColor = Color(0xFF1E1B4B);
  static const Color _periodColor = Color(0xFF9CA3AF);
  static const Color _dividerColor = Color(0xFFE5E7EB);
  static const Color _toggleBorder = Color(0xFFD8DEF3);
  static const Color _closeIcon = Color(0xFF585C77);
  static const Color _cardBorder = Color(0xFFC5DCFF);
  static const Color _checkBg = Color(0xFFE5F2FF);

  static const LinearGradient _primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2E8AFF),
      Color(0xFF007AFF),
      Color(0xFF5186E0),
    ],
  );

  static const LinearGradient _cardGradient = LinearGradient(
    begin: Alignment(-0.7, -0.8),
    end: Alignment(0.8, 0.9),
    colors: [
      Color(0xFFE8F3FF),
      Color(0xFFFFFFFF),
    ],
  );

  @override
  State<PlanPriceBottomSheet> createState() => _PlanPriceBottomSheetState();
}

class _PlanPriceBottomSheetState extends State<PlanPriceBottomSheet> {
  bool _autoRenew = true;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Prefer viewPadding; fall back when host/embed reports 0 (common in package mode).
    final topInset = media.viewPadding.top > 0
        ? media.viewPadding.top
        : (media.padding.top > 0 ? media.padding.top : 54.0);
    final bottomInset = media.viewPadding.bottom > 0
        ? media.viewPadding.bottom
        : media.padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, bottomInset + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPlanCard(),
                    const SizedBox(height: 16),
                    _buildAutoRenewRow(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSubscribeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: AppTheme.getTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: PlanPriceBottomSheet._titleColor,
                  ).copyWith(height: 1.2),
                  children: [
                    TextSpan(text: AppTranslations.planPriceTitlePrefix),
                    TextSpan(
                      text: AppTranslations.planPriceTitleHighlight,
                      style: TextStyle(color: AppConstants.appThemeColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppTranslations.planPriceSubtitle,
                style: AppTheme.getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: PlanPriceBottomSheet._mutedGrey,
                ).copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(64),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: PlanPriceBottomSheet._closeIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: PlanPriceBottomSheet._cardGradient,
            border: Border.all(
              color: PlanPriceBottomSheet._cardBorder,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppConstants.appThemeColor.withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.planPricePlanName,
                style: AppTheme.getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.appThemeColor,
                ).copyWith(height: 1.2),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppTranslations.planPriceAmount,
                    style: AppTheme.getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: PlanPriceBottomSheet._priceColor,
                    ).copyWith(height: 1.2),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppTranslations.planPricePeriod,
                    style: AppTheme.getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: PlanPriceBottomSheet._periodColor,
                    ).copyWith(height: 1.4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(
                height: 1,
                thickness: 1,
                color: PlanPriceBottomSheet._dividerColor,
              ),
              const SizedBox(height: 16),
              ..._buildBenefits(),
            ],
          ),
        ),
        // PositionedDirectional(
        //   top: 20,
        //   end: 0,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //     decoration: const BoxDecoration(
        //       gradient: PlanPriceBottomSheet._primaryGradient,
        //       borderRadius: BorderRadiusDirectional.only(
        //         topStart: Radius.circular(12),
        //         bottomStart: Radius.circular(12),
        //       ),
        //     ),
        //     child: Text(
        //       AppTranslations.planPriceSaveBadge,
        //       style: AppTheme.getTextStyle(
        //         fontSize: 11,
        //         fontWeight: FontWeight.w700,
        //         color: Colors.white,
        //       ).copyWith(
        //         height: 1.27,
        //         letterSpacing: 0.2,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  List<Widget> _buildBenefits() {
    final benefits = [
      AppTranslations.planPriceBenefit1,
      AppTranslations.planPriceBenefit2,
      AppTranslations.planPriceBenefit3,
      AppTranslations.planPriceBenefit4,
    ];
    return [
      for (var i = 0; i < benefits.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == benefits.length - 1 ? 0 : 12),
          child: _BenefitRow(text: benefits[i]),
        ),
    ];
  }

  Widget _buildAutoRenewRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PlanPriceBottomSheet._toggleBorder),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.012),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.planPriceAutoRenewTitle,
                  style: AppTheme.getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: PlanPriceBottomSheet._titleColor,
                  ).copyWith(height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  AppTranslations.planPriceAutoRenewDesc,
                  style: AppTheme.getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: PlanPriceBottomSheet._mutedGrey,
                  ).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _GradientSwitch(
            value: _autoRenew,
            onChanged: (value) => setState(() => _autoRenew = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Subscription flow can be wired later.
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            gradient: PlanPriceBottomSheet._primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              AppTranslations.planPriceSubscribeCta,
              style: AppTheme.getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ).copyWith(height: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: PlanPriceBottomSheet._checkBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 12,
            color: AppConstants.appThemeColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTheme.getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: PlanPriceBottomSheet._titleColor,
            ).copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _GradientSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GradientSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 39,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: value ? PlanPriceBottomSheet._primaryGradient : null,
          color: value ? null : const Color(0xFFD1D5DB),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
