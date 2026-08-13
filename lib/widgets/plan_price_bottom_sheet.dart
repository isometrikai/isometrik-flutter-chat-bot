import 'package:chat_bot/bloc/subscription/subscription_bloc.dart';
import 'package:chat_bot/bloc/subscription/subscription_event.dart';
import 'package:chat_bot/bloc/subscription/subscription_state.dart';
import 'package:chat_bot/services/in_app_purchase/iap_service.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/app_locale.dart';
import 'package:chat_bot/utils/app_theme.dart';
import 'package:chat_bot/utils/app_translations.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:chat_bot/widgets/pro_plan_success_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Plan & Price subscription full-screen page (In-App Purchase).
class PlanPriceBottomSheet extends StatelessWidget {
  final bool isFromChatScreen;
  final VoidCallback? onPurchaseSuccess;

  const PlanPriceBottomSheet({
    super.key,
    this.isFromChatScreen = false,
    this.onPurchaseSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    bool isFromChatScreen = false,
    VoidCallback? onPurchaseSuccess,
  }) {
    return Navigator.of(context).push<void>(
      AppLocale.materialRoute(
        fullscreenDialog: true,
        builder: (_) => BlocProvider(
          create: (_) => SubscriptionBloc()..add(const SubscriptionStarted()),
          child: PlanPriceBottomSheet(
            isFromChatScreen: isFromChatScreen,
            onPurchaseSuccess: onPurchaseSuccess,
          ),
        ),
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

  String _priceLabelForSuccess(SubscriptionPurchaseSuccess state) {
    final product = state.autoRenew
        ? IapService.instance.autoRenewProduct
        : IapService.instance.manualProduct;
    if (product != null && product.price.isNotEmpty) {
      return product.price;
    }
    return AppTranslations.planPriceAmount;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.viewPadding.top > 0
        ? media.viewPadding.top
        : (media.padding.top > 0 ? media.padding.top : 54.0);
    final bottomInset = media.viewPadding.bottom > 0
        ? media.viewPadding.bottom
        : media.padding.bottom;

    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listenWhen: (prev, next) {
        if (next is SubscriptionFailure) return true;
        if (next is SubscriptionPurchaseSuccess) {
          return prev is! SubscriptionPurchaseSuccess;
        }
        return false;
      },
      listener: (context, state) {
        if (state is SubscriptionPurchaseSuccess) {
          Utility.setIsProPlan(true);
          onPurchaseSuccess?.call();

          final priceLabel = _priceLabelForSuccess(state);
          final navigator = Navigator.of(context);
          // Show on the same navigator as this screen (host navigator in package
          // mode). kNavigatorKey points at the module navigator and fails there.
          ProPlanSuccessBottomSheet.show(context, priceLabel: priceLabel)
              .then((_) {
            if (navigator.mounted) {
              navigator.pop();
            }
          });
        } else if (state is SubscriptionFailure) {
          Utility.showErrorBlackToast(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, bottomInset + 24),
          child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              final ready = state is SubscriptionReady
                  ? state
                  : state is SubscriptionLoadInProgress
                      ? null
                      : SubscriptionReady(
                          storeAvailable: false,
                          autoRenew: false,
                        );

              if (state is SubscriptionLoadInProgress || ready == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(onClose: () => Navigator.of(context).pop()),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PlanCard(priceLabel: ready.displayPrice),
                          const SizedBox(height: 16),
                          _AutoRenewRow(
                            autoRenew: ready.autoRenew,
                            priceLabel: ready.displayPrice,
                            enabled: !ready.purchaseInProgress,
                            onChanged: (value) {
                              context.read<SubscriptionBloc>().add(
                                    SubscriptionAutoRenewToggled(value),
                                  );
                            },
                          ),
                          if (!ready.storeAvailable) ...[
                            const SizedBox(height: 12),
                            Text(
                              AppTranslations.planPriceStoreUnavailable,
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton(
                              onPressed: ready.purchaseInProgress
                                  ? null
                                  : () {
                                      context.read<SubscriptionBloc>().add(
                                            const SubscriptionRestoreRequested(),
                                          );
                                    },
                              child: Text(
                                AppTranslations.planPriceRestore,
                                style: AppTheme.getTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.appThemeColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SubscribeButton(
                    priceLabel: ready.displayPrice,
                    loading: ready.purchaseInProgress,
                    enabled: ready.storeAvailable && !ready.purchaseInProgress,
                    onTap: () {
                      context
                          .read<SubscriptionBloc>()
                          .add(const SubscriptionPurchaseRequested());
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
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
            onTap: onClose,
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
}

class _PlanCard extends StatelessWidget {
  final String priceLabel;

  const _PlanCard({required this.priceLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                priceLabel,
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
          ..._benefits(),
        ],
      ),
    );
  }

  List<Widget> _benefits() {
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
}

class _AutoRenewRow extends StatelessWidget {
  final bool autoRenew;
  final String priceLabel;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _AutoRenewRow({
    required this.autoRenew,
    required this.priceLabel,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                  AppTranslations.planPriceAutoRenewDesc(priceLabel),
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
          IgnorePointer(
            ignoring: !enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: _GradientSwitch(
                value: autoRenew,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  final String priceLabel;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _SubscribeButton({
    required this.priceLabel,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            gradient: enabled ? PlanPriceBottomSheet._primaryGradient : null,
            color: enabled ? null : const Color(0xFFB0B8C9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    AppTranslations.planPriceSubscribeCta(priceLabel),
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
