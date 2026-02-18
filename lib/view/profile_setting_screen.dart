import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:chat_bot/view/chat_history_screen.dart';
import 'package:chat_bot/view/complete_setup/complete_setup_flow_screen.dart';
import 'package:chat_bot/view/popup_overlay_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/asset_path.dart';
import '../utils/app_theme.dart';

/// Profile Setting Screen - matches design spec (Frame 1171284761, etc.)
/// 375px width, white background, sections: profile card, quick actions, My Account, Settings, Legal, Logout.
class ProfileSettingScreen extends StatelessWidget {
  final GreetingResponse? greetingData;
  
  const ProfileSettingScreen({super.key, this.greetingData});

  // Design colors from spec
  static const Color _primaryText = Color(0xFF2F3C70);
  static const Color _sectionLabel = Color(0xFF7085AE);
  static const Color _pointsPurple = Color(0xFF7A36B1);
  static const Color _cardBg = Color(0xFFFCFDFF);
  static const Color _cardBorder = Color(0xFFD8DEF3);
  static const Color _topCardBorder = Color(0xFFE6F1FF);
  static const Color _walletBarBg = Color(0xFF2F3C70);
  static const Color _dividerBorder = Color(0xFFE9DFFB);
  static const Color _chevronColor = Color(0xFFD8DEF3);

  @override
  Widget build(BuildContext context) {
    final userId = ChatApiServices.instance.userId ?? '';
    return BlocProvider(
      create: (context) => WalletBloc()
        ..add(WalletFetchRequested(userId: userId, userType: 'customer')),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: SafeArea(
        child: Container(
          width: double.infinity,
          // constraints: const BoxConstraints(maxWidth: 375),
          margin: EdgeInsets.symmetric(
            horizontal: (MediaQuery.of(context).size.width - 375).clamp(0, double.infinity) / 2,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildSection(
                        context,
                        title: 'MY ACCOUNT',
                        items: [
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_Card.svg'),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'Your Preferences',
                            onTap: () {
                               Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CompleteSetupFlowScreen(onCallback: (data) {
                                    // onRestartGreetingAPI();
                                  }),
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
                            label: 'Debit/Credit Card',
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'debit_credit_card'});
                            },
                          ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_Addres.svg'),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'Manage Addresses',
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'manage_addresses'});
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                      _buildSection(
                        context,
                        title: 'SETTINGS',
                        items: [
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_HelpCenter.svg'),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'Help center',
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'help_center'});
                            },
                          ),
                          // _SettingItem(
                          //   icon: SvgPicture.asset(
                          //     AssetPath.get('images/ic_S_language.svg'),
                          //     width: 20,
                          //     height: 20,
                          //     fit: BoxFit.cover,
                          //   ),
                          //   label: 'Language',
                          //   onTap: () {
                          //     OrderService().triggerSideMenuOption({'action': 'language'});
                          //   },
                          // ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_FAQ.svg'),
                             width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'FAQs',
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'faqs'});
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                      _buildSection(
                        context,
                        title: 'LEGAL',
                        items: [
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_TC.svg'),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'Terms & Conditions',
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'terms_and_conditions'});
                            },
                          ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_Privacy.svg'),
                             width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'Privacy Policy',
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'privacy_policy'});
                            },
                          ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_About.svg'),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'About Us',
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'about_us'});
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildLogoutRow(context),
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

  Widget _buildProfileCard() {
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (prev, next) => prev != next,
      builder: (context, state) {
        final xtraBalance = state is WalletLoadSuccess
            ? (state.availablePoints != null
                ? state.availablePoints.toString()
                : state.response.displayEarningBalance)
            : (state is WalletLoadInProgress ? '---' : '---');
        final walletBalance = state is WalletLoadSuccess
            ? state.response.displayBalance
            : (state is WalletLoadInProgress ? '---' : '—--');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _cardBg,
                  border: Border.all(color: _topCardBorder),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Utility.getName(),
                      style: AppTheme.getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.card_giftcard_outlined, size: 14, color: _pointsPurple),
                                const SizedBox(width: 4),
                                Text(
                                  'Xtra',
                                  style: AppTheme.getTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _pointsPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Earn while you spend',
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _sectionLabel,
                              ),
                            ),
                          ],
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              OrderService().triggerSideMenuOption({'action': 'eazy_Xtra'});
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    xtraBalance == '0' ? '---' : xtraBalance,
                                    style: AppTheme.getTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _pointsPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right, size: 20, color: _pointsPurple),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: _walletBarBg,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: InkWell(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  onTap: () {
                    OrderService().triggerSideMenuOption({'action': 'eazy_wallet'});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 20, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Eazy Wallet',
                              style: AppTheme.getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              walletBalance,
                              style: AppTheme.getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 12, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return  AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      // systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 1,
      leading: IconButton(
                      icon: SvgPicture.asset(
                        AssetPath.get('images/ic_close.svg'),
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
      title: Row(
        children: [
          Container(
            child:
                    SvgPicture.asset(
                      AssetPath.get('images/ic_header_logo.svg'),
                      // width: 75,
                      // height: 23,
                      fit: BoxFit.cover,
                    )
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Add action (e.g. save, done)
                  // Navigator.pop(context);
                  Navigator.pop(context, {
                             'action': 'new_chat_selected',
                            //  'cartCount': widget.cartCount ?? 0,
                           });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 93,
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8AFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'New Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(color: Colors.grey.shade300, height: 0),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: SvgPicture.asset(
                    AssetPath.get('images/ic_S_ChatHistory.svg'),
                    width: 30,
                    height: 30,
                  ),
                  label: 'Past Chats',
                  onTap: () async {
          
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatHistoryScreen()),
                      );

                      // if (result != null && result is Map) {
                      //   final action = result['action'];
                        
                      //   if (action == 'new_chat_selected') {
                      //      onRestartChatAPI();
                      //   }
                      // }
                  },
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: _QuickActionCard(
                  icon: SvgPicture.asset(
                    AssetPath.get('images/ic_S_Persona.svg'),
                    width: 30,
                    height: 30,
                  ),
                  label: 'User Persona',
                  onTap: () {
                    Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (context, animation, secondaryAnimation) => PopupOverlayScreen(greetingData: greetingData),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                    width: 30,
                    height: 30,
                  ),
                  label: 'My Orders',
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
                    width: 30,
                    height: 30,
                  ),
                  label: 'My Profile',
                  onTap: () {
                    OrderService().triggerSideMenuOption({'action': 'my_profile'});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            title,
            style: AppTheme.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _sectionLabel,
            ).copyWith(
              letterSpacing: 0.2 * 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          // decoration: BoxDecoration(
          //   border: Border(bottom: BorderSide(color: _dividerBorder, width: 0.5)),
          // ),
          child: Column(
            children: items.map((item) {
              final isLast = item.isLast;
              return InkWell(
                onTap: item.onTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 12, 16, isLast ? 20 : 12),
                  child: Row(
                    children: [
                      item.icon,
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTheme.getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: _primaryText,
                          ).copyWith(height: 1.4),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 20, color: _chevronColor),
                    ],
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
        // TODO: trigger logout
        OrderService().triggerSideMenuOption({'action': 'logout'});
        // Navigator.of(context).maybePop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
              'Logout',
              style: AppTheme.getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: _primaryText,
              ).copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });
}

class _HeaderIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _HeaderIconButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(54),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(54),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ProfileSettingScreen._cardBg,
            border: Border.all(color: ProfileSettingScreen._cardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 7),
              Text(
                label,
                style: AppTheme.getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ProfileSettingScreen._primaryText,
                ).copyWith(height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
