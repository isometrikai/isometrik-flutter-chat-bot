import 'package:chat_bot/data/model/customer_profile_response.dart';
import 'package:chat_bot/data/model/subscription_history_response.dart';
import 'package:chat_bot/data/repositories/subscription_purchase_repository.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/app_locale.dart';
import 'package:chat_bot/utils/app_theme.dart';
import 'package:chat_bot/utils/app_translations.dart';
import 'package:chat_bot/utils/asset_path.dart';
import 'package:chat_bot/utils/external_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Active subscription details screen (opened when plan is Active).
class SubscriptionsScreen extends StatefulWidget {
  final CustomerSubscription? subscription;
  final VoidCallback? onPurchaseSuccess;

  const SubscriptionsScreen({
    super.key,
    this.subscription,
    this.onPurchaseSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    CustomerSubscription? subscription,
    VoidCallback? onPurchaseSuccess,
  }) {
    return Navigator.of(context).push<void>(
      AppLocale.materialRoute(
        builder: (_) => SubscriptionsScreen(
          subscription: subscription,
          onPurchaseSuccess: onPurchaseSuccess,
        ),
      ),
    );
  }

  static const Color _titleColor = Color(0xFF171212);
  static const Color _bodyColor = Color(0xFF242424);
  static const Color _mutedGrey = Color(0xFF979797);
  static const Color _dateRangeGrey = Color(0xFF585C77);
  static const Color _activeGreen = Color(0xFF00CD4F);
  static const Color _activePillBg = Color(0xFFE0FFEC);
  static const Color _pastItemBg = Color(0xFFF3F5F6);
  static const Color _gradientTop = Color(0xFFDFECFC);

  static const LinearGradient _pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_gradientTop, Colors.white],
  );

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  static const int _pageSize =
      SubscriptionPurchaseRepository.defaultHistoryLimit;

  final SubscriptionPurchaseRepository _repository =
      SubscriptionPurchaseRepository();
  final ScrollController _scrollController = ScrollController();

  final List<SubscriptionHistoryItem> _historyItems = [];
  int _total = 0;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _errorMessage;

  bool get _hasMore => _historyItems.length < _total;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadHistory(reset: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_hasMore || _loadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory({bool reset = false}) async {
    if (_loadingMore) return;
    if (!reset && !_hasMore) return;

    setState(() {
      if (reset) {
        _initialLoading = true;
        _errorMessage = null;
      } else {
        _loadingMore = true;
      }
    });

    final skip = reset ? 0 : _historyItems.length;
    final result = await _repository.fetchAppleHistory(
      limit: _pageSize,
      skip: skip,
    );

    if (!mounted) return;

    if (!result.isSuccess || result.data is! SubscriptionHistoryResponse) {
      setState(() {
        _initialLoading = false;
        _loadingMore = false;
        if (reset) {
          _errorMessage =
              result.message ?? AppTranslations.pastSubscriptionsEmpty;
        }
      });
      return;
    }

    final page = result.data as SubscriptionHistoryResponse;
    setState(() {
      if (reset) {
        _historyItems
          ..clear()
          ..addAll(page.items);
      } else {
        _historyItems.addAll(page.items);
      }
      _total = page.total;
      _initialLoading = false;
      _loadingMore = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topInset = media.viewPadding.top > 0
        ? media.viewPadding.top
        : (media.padding.top > 0 ? media.padding.top : 54.0);
    final bottomInset = media.viewPadding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: SubscriptionsScreen._pageGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              topInset + 14,
              16,
              bottomInset + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onClose: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 24),
                Expanded(
                  child: RefreshIndicator(
                    color: AppConstants.appThemeColor,
                    onRefresh: () => _loadHistory(reset: true),
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CurrentPlanCard(
                                subscription: widget.subscription,
                              ),
                              const SizedBox(height: 16),
                              _ManagePlanButton(
                                onTap: () {
                                  openStoreSubscriptions();
                                },
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppTranslations.pastSubscriptions,
                                style: AppTheme.getTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: SubscriptionsScreen._mutedGrey,
                                ).copyWith(height: 1.4),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        ..._buildHistorySlivers(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHistorySlivers() {
    if (_initialLoading) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    if (_errorMessage != null && _historyItems.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _PastEmptyCard(message: _errorMessage!),
        ),
      ];
    }

    if (_historyItems.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: _PastEmptyCard(
            message: AppTranslations.pastSubscriptionsEmpty,
          ),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = _historyItems[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _historyItems.length - 1 && !_loadingMore
                    ? 0
                    : 12,
              ),
              child: _PastSubscriptionTile(item: item),
            );
          },
          childCount: _historyItems.length,
        ),
      ),
      if (_loadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ),
        ),
    ];
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppTranslations.subscriptionsTitle,
            style: AppTheme.getTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: SubscriptionsScreen._titleColor,
            ).copyWith(height: 1.2),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(
                  AssetPath.get('images/ic_close.svg'),
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final CustomerSubscription? subscription;

  const _CurrentPlanCard({this.subscription});

  @override
  Widget build(BuildContext context) {
    final isActive = subscription?.isActive == true;
    final isAutorenew = subscription?.isAutorenew == true;
    final started = _formatDate(subscription?.currentPeriodStart);
    final ends = _formatDate(subscription?.currentPeriodEnd);
    final periodLabel = isAutorenew
        ? AppTranslations.subscriptionsRenewsOn
        : AppTranslations.subscriptionsEndsOn;
    final priceLine = AppTranslations.subscriptionsPriceLine(
      AppTranslations.planPriceAmount,
      isAutorenew
          ? AppTranslations.subscriptionsAutoRenewOn
          : AppTranslations.subscriptionsAutoRenewOff,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A66F3).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AssetPath.get('images/ic_eazy_app_price_logo.svg'),
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        AppConstants.appThemeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        AppTranslations.subscriptionsPlanName,
                        style: AppTheme.getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.appThemeColor,
                        ).copyWith(height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive) const _ActivePill(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            priceLine,
            style: AppTheme.getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: SubscriptionsScreen._mutedGrey,
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateMilestone(
                  label: AppTranslations.subscriptionsStarted,
                  value: started,
                ),
              ),
              Expanded(
                child: _DateMilestone(
                  label: periodLabel,
                  value: ends,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivePill extends StatelessWidget {
  const _ActivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
      decoration: BoxDecoration(
        color: SubscriptionsScreen._activePillBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: SubscriptionsScreen._activeGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            AppTranslations.activeStatus,
            style: AppTheme.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SubscriptionsScreen._activeGreen,
            ).copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _DateMilestone extends StatelessWidget {
  final String label;
  final String value;

  const _DateMilestone({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: SubscriptionsScreen._mutedGrey,
          ).copyWith(height: 1.4),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: SubscriptionsScreen._bodyColor,
          ).copyWith(height: 1.2),
        ),
      ],
    );
  }
}

class _ManagePlanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ManagePlanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              AppTranslations.subscriptionsManagePlan,
              style: AppTheme.getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SubscriptionsScreen._bodyColor,
              ).copyWith(height: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

class _PastEmptyCard extends StatelessWidget {
  final String message;

  const _PastEmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SubscriptionsScreen._pastItemBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: AppTheme.getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: SubscriptionsScreen._dateRangeGrey,
        ).copyWith(height: 1.4),
      ),
    );
  }
}

class _PastSubscriptionTile extends StatelessWidget {
  final SubscriptionHistoryItem item;

  const _PastSubscriptionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isActive = item.isPeriodActive;
    final title = AppTranslations.subscriptionsPastPlanMonthly;
    final range = AppTranslations.subscriptionsDateRange(
      _formatDate(item.currentPeriodStart),
      _formatDate(item.currentPeriodEnd),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SubscriptionsScreen._pastItemBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: SubscriptionsScreen._bodyColor,
                  ).copyWith(height: 1.2),
                ),
              ),
              Text(
                isActive
                    ? AppTranslations.activeStatus
                    : AppTranslations.endedStatus,
                style: AppTheme.getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? SubscriptionsScreen._activeGreen
                      : SubscriptionsScreen._mutedGrey,
                ).copyWith(height: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            range,
            style: AppTheme.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: SubscriptionsScreen._dateRangeGrey,
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '—';
  final local = date.toLocal();
  final months = [
    AppTranslations.monthJanShort,
    AppTranslations.monthFebShort,
    AppTranslations.monthMarShort,
    AppTranslations.monthAprShort,
    AppTranslations.monthMayShort,
    AppTranslations.monthJunShort,
    AppTranslations.monthJulShort,
    AppTranslations.monthAugShort,
    AppTranslations.monthSepShort,
    AppTranslations.monthOctShort,
    AppTranslations.monthNovShort,
    AppTranslations.monthDecShort,
  ];
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
