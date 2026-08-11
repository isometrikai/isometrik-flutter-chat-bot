import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/model/customer_profile_response.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/chat_history_screen.dart';
import 'package:chat_bot/view/complete_setup/complete_setup_flow_screen.dart';
import 'package:chat_bot/view/personalization_screen.dart';
import 'package:chat_bot/view/popup_overlay_screen.dart';
import 'package:chat_bot/widgets/plan_price_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Profile Setting Screen - matches design spec (Frame 1171284761).
class ProfileSettingScreen extends StatelessWidget {
  final GreetingResponse? greetingData;

  const ProfileSettingScreen({super.key, this.greetingData});

  static const Color _primaryText = Color(0xFF2F3C70);
  static const Color _sectionLabel = Color(0xFF7085AE);
  static const Color _mutedText = Color(0xFF979797);
  static const Color _cardBg = Color(0xFFFCFDFF);
  static const Color _chevronColor = Color(0xFFD8DEF3);
  static const Color _gradientTop = Color(0xFFCEEDFF);
  static const Color _gradientBottom = Color(0xFFF4F6FE);
  static const Color _accentBlue = Color(0xFF007AFF);
  static const Color _personaBlue = Color(0xFF308EFF);
  static const Color _iconTileBg = Color(0xFFEBF3FF);
  static const Color _activeGreen = Color(0xFF00CD4F);
  static const Color _languageHighlight = Color(0xFFF4F8FF);

  static const LinearGradient _pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_gradientTop, _gradientBottom],
  );

  static const LinearGradient _xtraGradient = LinearGradient(
    begin: Alignment(-0.95, 0),
    end: Alignment(0.95, 0),
    colors: [Color(0xFF4BBEFA), Color(0xFF2E8AFF)],
  );

  static const LinearGradient _personaIconGradient = LinearGradient(
    begin: Alignment(-0.7, -0.8),
    end: Alignment(0.8, 0.9),
    colors: [Color(0xFF4FC6F9), Color(0xFF2E8AFF)],
  );

  static const LinearGradient _zainGradient = LinearGradient(
    colors: [
      Color(0xFF5186E0),
      Color(0xFF5E3DFE),
      Color(0xFF8E2FFD),
      Color(0xFFB02EFB),
      Color(0xFFD445EC),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final userId = ChatApiServices.instance.userId ?? '';
    return AppLocale.wrap(
      BlocProvider(
        create: (context) => WalletBloc()
          ..add(WalletFetchRequested(userId: userId, userType: 'customer')),
        child: _ProfileSettingView(greetingData: greetingData),
      ),
    );
  }
}

class _ProfileSettingView extends StatefulWidget {
  final GreetingResponse? greetingData;

  const _ProfileSettingView({this.greetingData});

  @override
  State<_ProfileSettingView> createState() => _ProfileSettingViewState();
}

class _ProfileSettingViewState extends State<_ProfileSettingView> {
  CustomerSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ChatApiServices.instance.fetchCustomerProfile();
    if (!mounted) return;
    if (profile == null) return;
    final subscription = profile.subscription;
    if (subscription != null) {
      Utility.setIsProPlan(subscription.isActive);
    }
    setState(() => _subscription = subscription);
  }

  bool get _showSetupBanner =>
      widget.greetingData?.setupUserPreference == true;

  bool get _isPlanActive =>
      _subscription?.isActive == true || Utility.getIsProPlan();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: ProfileSettingScreen._pageGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: IgnorePointer(
              child: Image.asset(
                AssetPath.get('images/img_profile_bg.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(context),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showSetupBanner) ...[
                    _buildFinishSetupBanner(context),
                    const SizedBox(height: 16),
                  ],
                  _buildUserCard(),
                  const SizedBox(height: 16),
                  _buildXtraCard(),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: AppTranslations.myAccount,
                    items: [
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/img_plan.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.planAndPrice,
                        subtitle: _planRenewsLabel(),
                        badge: _isPlanActive
                            ? AppTranslations.activeStatus
                            : null,
                        onTap: () => PlanPriceBottomSheet.show(
                          context,
                          onPurchaseSuccess: _loadProfile,
                        ),
                      ),
                      _SettingItem(
                        icon: const Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: ProfileSettingScreen._primaryText,
                        ),
                        label: AppTranslations.yourPreferences,
                        onTap: () {
                          Navigator.of(context).push(
                            AppLocale.materialRoute(
                              builder: (context) =>
                                  CompleteSetupFlowScreen(onCallback: (data) {}),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_S_Card.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.debitCreditCard,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'debit_credit_card'},
                          );
                        },
                      ),
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_S_Addres.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.manageAddresses,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'manage_addresses'},
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: AppTranslations.settingsSection,
                    items: [
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_personalization.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.dataControl,
                        onTap: () {
                          Navigator.of(context).push(
                            AppLocale.materialRoute<void>(
                              builder: (context) =>
                                  const PersonalizationScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_S_HelpCenter.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.helpCenter,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'help_center'},
                          );
                        },
                      ),
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_S_FAQ.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.faqs,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'faqs'},
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: AppTranslations.legalSection,
                    items: [
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_S_TC.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.termsAndConditions,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'terms_and_conditions'},
                          );
                        },
                      ),
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_S_Privacy.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.privacyPolicy,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'privacy_policy'},
                          );
                        },
                      ),
                      _SettingItem(
                        icon: SvgPicture.asset(
                          AssetPath.get('images/ic_S_About.svg'),
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                        label: AppTranslations.aboutUs,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'about_us'},
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildLogoutRow(context),
                  const SizedBox(height: 8),
                  // _buildPoweredBy(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: SvgPicture.asset(
          AssetPath.get('images/ic_close.svg'),
          width: 40,
          height: 40,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AssetPath.get('images/ic_header_logo.svg'),
              height: 24,
              fit: BoxFit.contain,
            ),
            if (Utility.getIsProPlan()) ...[
              const SizedBox(width: 5),
              SvgPicture.asset(
                AssetPath.get('images/img_pro.svg'),
                width: 25,
                height: 25,
              ),
            ],
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, {
                    'action': 'new_chat_selected',
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8AFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+ ${AppTranslations.newChat}',
                        style: AppTheme.getTextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishSetupBanner(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            AppLocale.materialRoute(
              builder: (context) => CompleteSetupFlowScreen(
                onCallback: (data) {},
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ProfileSettingScreen._accentBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.finishYourSetup,
                      style: AppTheme.getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ).copyWith(height: 1.2),
                    ),
                    // const SizedBox(height: 2),
                    // Text(
                    //   AppTranslations.setupStepsLeft('2'),
                    //   style: AppTheme.getTextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w400,
                    //     color: Colors.white.withValues(alpha: 0.8),
                    //   ).copyWith(height: 1.4),
                    // ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      AppTranslations.continueLabel,
                      style: AppTheme.getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ProfileSettingScreen._accentBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: ProfileSettingScreen._accentBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    final userId = ChatApiServices.instance.userId ?? '';
    final handle = userId.isEmpty
        ? ''
        : '@${userId.length > 12 ? userId.substring(0, 12) : userId}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFBAE7FE), Color(0xFF92F4FE)],
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 22,
              color: Color(0xFF1EB4EB),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Utility.getName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ProfileSettingScreen._primaryText,
                  ).copyWith(height: 1.2),
                ),
                // if (handle.isNotEmpty) ...[
                //   const SizedBox(height: 2),
                //   Text(
                //     handle,
                //     maxLines: 1,
                //     overflow: TextOverflow.ellipsis,
                //     style: AppTheme.getTextStyle(
                //       fontSize: 10,
                //       fontWeight: FontWeight.w500,
                //       color: ProfileSettingScreen._accentBlue,
                //     ).copyWith(height: 1.2),
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXtraCard() {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (prev, next) => prev != next,
      builder: (context, state) {
        final xtraBalance = state is WalletLoadSuccess
            ? (state.availablePoints != null
                ? state.availablePoints.toString()
                : state.response.displayEarningBalance)
            : '---';
        final walletBalance = state is WalletLoadSuccess
            ? state.response.displayBalance
            : '---';
        final ptsLabel = xtraBalance == '0' || xtraBalance == '---'
            ? '---'
            : AppTranslations.ptsSuffix(xtraBalance);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: ProfileSettingScreen._xtraGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0458B4).withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _EazyCoin(size: 22),
                    const SizedBox(width: 4),
                    Text(
                      AppTranslations.eazyXtra,
                      style: AppTheme.getTextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _XtraMetric(
                        icon: const _EazyCoin(size: 20, light: true),
                        label: AppTranslations.rewards,
                        value: ptsLabel,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'eazy_Xtra'},
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Expanded(
                      child: _XtraMetric(
                        icon: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        label: AppTranslations.wallet,
                        value: walletBalance,
                        valueSize: 16,
                        onTap: () {
                          OrderService().triggerSideMenuOption(
                            {'action': 'eazy_wallet'},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: SvgPicture.asset(
                  AssetPath.get('images/ic_S_ChatHistory.svg'),
                  width: 26,
                  height: 26,
                ),
                label: AppTranslations.pastChats,
                subtitle: AppTranslations.pastChatsSubtitle,
                onTap: () async {
                  await Navigator.push(
                    context,
                    AppLocale.materialRoute(
                      builder: (context) => ChatHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: _QuickActionCard(
                icon: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: SvgPicture.asset(
                    AssetPath.get('images/ic_S_Persona.svg'),
                    width: 26,
                    height: 26,
                  ),
                ),
                label: AppTranslations.userPersona,
                subtitle: AppTranslations.userPersonaSubtitle,
                highlighted: true,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AppLocale.wrap(
                        PopupOverlayScreen(greetingData: widget.greetingData),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: SvgPicture.asset(
                  AssetPath.get('images/ic_S_OrderHistory.svg'),
                  width: 26,
                  height: 26,
                ),
                label: AppTranslations.myOrders,
                subtitle: AppTranslations.myOrdersSubtitle,
                onTap: () {
                  OrderService().triggerSideMenuOption({'action': 'my_orders'});
                },
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: _QuickActionCard(
                icon: SvgPicture.asset(
                  AssetPath.get('images/ic_S_Profile.svg'),
                  width: 26,
                  height: 26,
                ),
                label: AppTranslations.myProfile,
                subtitle: AppTranslations.myProfileSubtitle,
                onTap: () {
                  OrderService().triggerSideMenuOption({'action': 'my_profile'});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: AppTheme.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ProfileSettingScreen._sectionLabel,
            ).copyWith(
              letterSpacing: 0.2 * 12,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00356F).withValues(alpha: 0.1),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isFirst = index == 0;
              return InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? const Radius.circular(20) : Radius.zero,
                  bottom: item.isLast ? const Radius.circular(20) : Radius.zero,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    item.highlighted ? 8 : 16,
                    isFirst ? (item.highlighted ? 12 : 20) : (item.highlighted ? 4 : 12),
                    item.highlighted ? 8 : 16,
                    item.isLast
                        ? (item.highlighted ? 12 : 20)
                        : (item.highlighted ? 4 : 12),
                  ),
                  child: Container(
                    padding: item.highlighted
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
                        : EdgeInsets.zero,
                    decoration: item.highlighted
                        ? BoxDecoration(
                            color: ProfileSettingScreen._languageHighlight,
                            borderRadius: BorderRadius.circular(10),
                          )
                        : null,
                    child: Row(
                      children: [
                        item.icon,
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: AppTheme.getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: ProfileSettingScreen._primaryText,
                                ).copyWith(height: 1.4),
                              ),
                              if (item.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle!,
                                  style: AppTheme.getTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: ProfileSettingScreen._mutedText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (item.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: ProfileSettingScreen._activeGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.badge!,
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: item.highlighted
                              ? ProfileSettingScreen._accentBlue
                              : ProfileSettingScreen._chevronColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutRow(BuildContext context) {
    return InkWell(
      onTap: () {
        OrderService().triggerSideMenuOption({'action': 'logout'});
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Row(
          children: [
            SvgPicture.asset(
              AssetPath.get('images/ic_S_Logout.svg'),
              width: 20,
              height: 20,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Text(
              AppTranslations.logout,
              style: AppTheme.getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ProfileSettingScreen._primaryText,
              ).copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoweredBy() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppTranslations.poweredBy,
          style: AppTheme.getTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ProfileSettingScreen._sectionLabel,
          ).copyWith(height: 1.2),
        ),
        const SizedBox(width: 5),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              ProfileSettingScreen._zainGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'zAIn',
            style: AppTheme.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ).copyWith(height: 1.2),
          ),
        ),
      ],
    );
  }

  String? _planRenewsLabel() {
    final end = _subscription?.currentPeriodEnd?.toLocal();
    if (end == null) return null;
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
    final month = months[end.month - 1];
    return AppTranslations.planRenews('${end.day} $month ${end.year}');
  }
}

class _SettingItem {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final bool highlighted;
  final String? subtitle;
  final String? badge;

  _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.highlighted = false,
    this.subtitle,
    this.badge,
  });
}

class _EazyCoin extends StatelessWidget {
  final double size;
  final bool light;

  const _EazyCoin({this.size = 22, this.light = false});

  @override
  Widget build(BuildContext context) {
    final outer =
        light ? Colors.white.withValues(alpha: 0.6) : const Color(0xFFD5A2FF);
    final inner = light ? const Color(0xFF5EC2FF) : const Color(0xFF7A36B1);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: outer),
      padding: EdgeInsets.all(size * 0.12),
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: inner),
        child: Icon(
          Icons.sentiment_satisfied_alt_rounded,
          size: size * 0.48,
          color: outer,
        ),
      ),
    );
  }
}

class _XtraMetric extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final double valueSize;

  const _XtraMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.valueSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                  ).copyWith(
                    height: 1.2,
                    letterSpacing: 0.14 * 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getTextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ).copyWith(height: 1.2),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ProfileSettingScreen._cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: highlighted
                          ? null
                          : ProfileSettingScreen._iconTileBg,
                      gradient: highlighted
                          ? ProfileSettingScreen._personaIconGradient
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: highlighted
                          ? [
                              BoxShadow(
                                color: const Color(0xFF379BFE)
                                    .withValues(alpha: 0.44),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: icon,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: highlighted
                          ? ProfileSettingScreen._personaBlue
                          : ProfileSettingScreen._primaryText,
                    ).copyWith(height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: ProfileSettingScreen._mutedText,
                    ).copyWith(height: 1.4),
                  ),
                ],
              ),
              if (highlighted)
                const PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFF2E8AFF),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
