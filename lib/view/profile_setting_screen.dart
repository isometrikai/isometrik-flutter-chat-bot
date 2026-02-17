import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/view/chat_history_screen.dart';
import 'package:chat_bot/view/complete_setup/complete_setup_flow_screen.dart';
import 'package:chat_bot/view/popup_overlay_screen.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
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
                            onTap: () {},
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
                            onTap: () {},
                          ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_language.svg'),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'Language',
                            onTap: () {},
                          ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_FAQ.svg'),
                             width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'FAQs',
                            onTap: () {},
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
                            onTap: () {},
                          ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_Privacy.svg'),
                             width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'Privacy Policy',
                            onTap: () {},
                          ),
                          _SettingItem(
                            icon: SvgPicture.asset(
                              AssetPath.get('images/ic_S_About.svg'),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            label: 'About Us',
                            onTap: () {},
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
    );
  }

  Widget _buildProfileCard() {
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
                  'Abram Qureshi',
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
                              'Earn while you spend',
                              style: AppTheme.getTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _sectionLabel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '3452 pts',
                          style: AppTheme.getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _pointsPurple,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Eazy Wallet',
                          style: AppTheme.getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _walletBarBg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'D45,123',
                              style: AppTheme.getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: _walletBarBg,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 12, color: _walletBarBg),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: _walletBarBg,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
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
                      'D45,123',
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
        ],
      ),
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
      // IconButton(
      //                   icon: Opacity(
      //                     opacity: 1.0,
      //                     child: Stack(
      //                       children: [
      //                         SvgPicture.asset(
      //                           AssetPath.get('images/ic_cart.svg'),
      //                           width: 40,
      //                           height: 40,
      //                         ),
      //                         if (cartCount > 0)
      //                           Positioned(
      //                             right: 0,
      //                             top: 0,
      //                             child: Container(
      //                               padding: const EdgeInsets.symmetric(
      //                                 horizontal: 4,
      //                                 vertical: 2,
      //                               ),
      //                               decoration: BoxDecoration(
      //                                 color: AppConstants.appThemeColor,
      //                                 // Purple color
      //                                 borderRadius: BorderRadius.circular(10),
      //                               ),
      //                               constraints: const BoxConstraints(
      //                                 minWidth: 20,
      //                                 minHeight: 20,
      //                               ),
      //                               child: Text(
      //                                 (ccartCount)
      //                                     .toString(),
      //                                 style: const TextStyle(
      //                                   color: Colors.white,
      //                                   fontSize: 12,
      //                                   fontWeight: FontWeight.bold,
      //                                 ),
      //                                 textAlign: TextAlign.center,
      //                               ),
      //                             ),
      //                           ),
      //                       ],
      //                     ),
      //                   ),
      //                   onPressed:() {
      //                     //  Navigator.push(
      //                     //           context,
      //                     //           MaterialPageRoute(
      //                     //             builder:
      //                     //                 (context) => BlocProvider(
      //                     //                   create: (context) => CartBloc(),
      //                     //                   child: CartScreen(
      //                     //                     needToEndThisChat: needToEndThisChat,
      //                     //                     onCheckout: (message, storeCategoryId) {
      //                     //                       onSendMessage(message, null, null, storeCategoryId);
      //                     //                     },
      //                     //                   ),
      //                     //                 ),
      //                     //           ),
      //                     //         );
      //                   },
      //                 )
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
                  onTap: () {},
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
                  onTap: () {},
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
        Navigator.of(context).maybePop();
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
