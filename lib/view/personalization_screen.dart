import 'dart:math' as math;

import 'package:chat_bot/bloc/chat_history/chat_history_bloc.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_event.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_state.dart';
import 'package:chat_bot/data/repositories/customer_preference_repository.dart';
import 'package:chat_bot/data/model/shared_session.dart';
import 'package:chat_bot/utils/asset_path.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/app_theme.dart';
import 'package:chat_bot/utils/external_url.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:chat_bot/widgets/archived_chat_row.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Personalization settings — layout and colors from design spec
/// (Frame 2147223814: title + rows with #E0EBFF dividers, pill actions).
class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  static const Color _primaryText = Color(0xFF2F3C70);
  static const Color _divider = Color(0xFFE0EBFF);
  static const Color _pillBorder = Color(0xFFD8DEF3);
  static const Color _pillLabel = Color(0xFF242424);
  static const Color _destructive = Color(0xFFCD0000);
  static const Color _iosBlue = Color(0xFF007AFF);
  static const Color _sheetBodyColor = Color(0xFF4A4A4A);
  static const Color _destructiveConfirmBg = Color(0xFFC5221F);
  /// Same width for every right-side pill (fits “Archive all” / “Delete all”).
  static const double _actionPillWidth = 108;
  static const double _sheetButtonHeight = 52;
  static const double _sheetCornerRadius = 16;
  static const double _sheetButtonRadius = 8;

  late bool _personalizedAiEnabled;
  bool _isSavingPersonalization = false;

  @override
  void initState() {
    super.initState();
    _personalizedAiEnabled = Utility.getPersonalization();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final contentW = math.min(screenW, 375.0);
    final horizontalInset = (screenW - contentW) / 2;

    return BlocProvider(
      create: (context) => ChatHistoryBloc(),
      child: BlocListener<ChatHistoryBloc, ChatHistoryState>(
        listener: (context, state) {
          if (state is ChatHistoryArchiveAllSuccess) {
            BlackToastView.show(context, 'All chats archived successfully');
          } else if (state is ChatHistoryArchiveAllFailure) {
            BlackToastView.show(context, 'Failed to archive all chats: ${state.message}');
          } else if (state is ChatHistoryUnarchiveSuccess) {
            BlackToastView.show(context, 'Chat unarchived successfully');
          } else if (state is ChatHistoryUnarchiveFailure) {
            BlackToastView.show(context, 'Failed to unarchive chat: ${state.message}');
          } else if (state is ChatHistoryDeleteSuccess) {
            BlackToastView.show(context, 'Chat deleted successfully');
          } else if (state is ChatHistoryDeleteFailure) {
            BlackToastView.show(context, 'Failed to delete chat: ${state.message}');
          } else if (state is ChatHistorySharedSessionRevokeSuccess) {
            BlackToastView.show(context, 'Shared link revoked');
          } else if (state is ChatHistorySharedSessionRevokeFailure) {
            BlackToastView.show(context, 'Failed to revoke link: ${state.message}');
          } else if (state is ChatHistoryDeleteAllSuccess) {
            BlackToastView.show(context, 'All chats deleted successfully');
          } else if (state is ChatHistoryDeleteAllFailure) {
            BlackToastView.show(context, 'Failed to delete all chats: ${state.message}');
          }
        },
        child: Builder(
          builder: (innerContext) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Center(
                  child: Container(
                    width: contentW,
                    margin: EdgeInsets.symmetric(horizontal: horizontalInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8, 16, 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                              icon: SvgPicture.asset(
                                AssetPath.get('images/ic_full_black.svg'),
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(Color(0xFF242424), BlendMode.srcIn),
                              ),
                              onPressed: () => Navigator.of(innerContext).maybePop(),
                            ),
                          ),
                        ),
                        _titleHeader(),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            physics: const ClampingScrollPhysics(),
                            children: [
                              _toggleRow(
                                label: 'Personalized AI',
                                value: _personalizedAiEnabled,
                                onChanged: _isSavingPersonalization ? null : _onPersonalizedAiChanged,
                              ),
                              _actionRow(
                                label: 'Shared links',
                                buttonLabel: 'Manage',
                                onPressed: () => _showSharedLinksManage(innerContext),
                              ),
                              _actionRow(
                                label: 'Archived chats',
                                buttonLabel: 'Manage',
                                onPressed: () => _showArchivedChatsManage(innerContext),
                              ),
                              _actionRow(
                                label: 'Archive all chats',
                                buttonLabel: 'Archive all',
                                onPressed: () => _confirmArchiveAll(innerContext),
                              ),
                              _actionRow(
                                label: 'Delete all chats',
                                buttonLabel: 'Delete all',
                                destructive: true,
                                onPressed: () => _confirmDeleteAll(innerContext),
                              ),
                              _actionRow(
                                label: 'Export data',
                                buttonLabel: 'Export',
                                onPressed: () => _showExportRequestSheet(innerContext),
                                showDivider: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _titleHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Personalization',
          style: AppTheme.getTextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: _primaryText,
          ),
        ),
      ),
    );
  }

  TextStyle get _sheetBodyStyle => AppTheme.getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: _sheetBodyColor,
      );

  TextStyle get _sheetTitleStyle => AppTheme.getTextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: Colors.black,
      );

  /// Archive / export: primary blue confirm. Delete: red filled confirm.
  /// Cancel (outlined) first, confirm (filled) second — matches design.
  Future<bool?> _showPersonalizationBottomSheet({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext sheetContext) body,
    required String confirmLabel,
    bool confirmIsDestructive = false,
  }) {
    final confirmColor = confirmIsDestructive ? _destructiveConfirmBg : AppConstants.appThemeColor;

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetCornerRadius)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(title, style: _sheetTitleStyle)),
                      // _SheetCloseButton(onPressed: () => Navigator.pop(sheetContext, false)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  body(sheetContext),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: _sheetButtonHeight,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.appThemeColor,
                        side: const BorderSide(color: AppConstants.appThemeColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_sheetButtonRadius),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTheme.getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.appThemeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: _sheetButtonHeight,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_sheetButtonRadius),
                        ),
                      ),
                      child: Text(
                        confirmLabel,
                        style: AppTheme.getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: _primaryText,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: _iosBlue,
              activeThumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPersonalizedAiChanged(bool v) async {
    final previous = _personalizedAiEnabled;
    setState(() {
      _personalizedAiEnabled = v;
      _isSavingPersonalization = true;
    });

    Utility.showLoader(message: 'Saving...');
    try {
      final res = await CustomerPreferenceRepository().patchZainPersonalization(enabled: v);
      if (!res.isSuccess) {
        throw Exception(res.message ?? 'Failed to update personalization');
      }

      Utility.setPersonalization(v);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _personalizedAiEnabled = previous;
      });
      _showSnack('Failed to update personalization');
    } finally {
      Utility.closeProgressDialog();
      if (mounted) {
        setState(() {
          _isSavingPersonalization = false;
        });
      }
    }
  }

  Widget _actionRow({
    required String label,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool destructive = false,
    bool showDivider = true,
  }) {
    final borderColor = destructive ? _destructive : _pillBorder;
    final textColor = destructive ? _destructive : _pillLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: showDivider ? const Border(bottom: BorderSide(color: _divider)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTheme.getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: _primaryText,
              ),
            ),
          ),
          SizedBox(
            width: _actionPillWidth,
            height: 40,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(_actionPillWidth, 40),
                maximumSize: const Size(_actionPillWidth, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                backgroundColor: Colors.white,
              ),
              child: Text(
                buttonLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    BlackToastView.show(context, message);
  }

  Future<void> _confirmArchiveAll(BuildContext context) async {
    final ok = await _showPersonalizationBottomSheet(
          context: context,
          title: 'Archive your chat history?',
          body: (_) => Text(
            'This will archive all chats, including chats in Projects.',
            style: _sheetBodyStyle,
          ),
          confirmLabel: 'Confirm archive',
        ) ??
        false;
    if (!ok || !mounted) return;
    context.read<ChatHistoryBloc>().add(const ChatHistoryArchiveAllRequested());
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final ok = await _showPersonalizationBottomSheet(
          context: context,
          title: 'Clear your chat history?',
          body: (sheetContext) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will delete all chats, including chats in Projects.',
                style: _sheetBodyStyle,
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 0,
                runSpacing: 4,
                children: [
                  Text('To clear any memories from your chats, visit your ', style: _sheetBodyStyle),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(sheetContext, false);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _showSnack('Open Settings from the profile menu to manage memories.');
                        }
                      });
                    },
                    child: Text(
                      'settings',
                      style: _sheetBodyStyle.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text('.', style: _sheetBodyStyle),
                ],
              ),
            ],
          ),
          confirmLabel: 'Confirm deletion',
          confirmIsDestructive: true,
        ) ??
        false;
    if (!ok || !mounted) return;
    context.read<ChatHistoryBloc>().add(const ChatHistoryDeleteAllRequested());
  }

  Future<void> _showExportRequestSheet(BuildContext context) async {
    const bullets = <String>[
      'Your account details and chats will be included in the export.',
      'The data will be sent to your registered email in a downloadable file.',
      'The download link will expire 24 hours after you receive it.',
      'Processing may take some time. You\'ll be notified when it\'s ready.',
    ];

    final ok = await _showPersonalizationBottomSheet(
          context: context,
          title: 'Request data export',
          body: (_) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < bullets.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: _sheetBodyStyle),
                    Expanded(child: Text(bullets[i], style: _sheetBodyStyle)),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'To proceed, tap “Confirm export” below.',
                style: _sheetBodyStyle,
              ),
            ],
          ),
          confirmLabel: 'Confirm export',
        ) ??
        false;
    if (!ok || !mounted) return;
    _showSnack('Export requested — not wired to backend yet');
  }

  void _showSharedLinksManage(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.58;
    final chatHistoryBloc = context.read<ChatHistoryBloc>();
    chatHistoryBloc.add(const ChatHistorySharedSessionsFetchRequested(isActive: true));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetCornerRadius)),
      ),
      builder: (_) => SizedBox(
        height: h,
        child: BlocProvider.value(
          value: chatHistoryBloc,
          child: _SharedLinksManageSheet(
            onMessage: (msg) {
              if (mounted) _showSnack(msg);
            },
          ),
        ),
      ),
    );
  }

  void _showArchivedChatsManage(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height * 0.58;
    final chatHistoryBloc = context.read<ChatHistoryBloc>();
    chatHistoryBloc.add(const ChatHistoryFetchRequested(isFromArchive: true));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetCornerRadius)),
      ),
      builder: (_) => SizedBox(
        height: h,
        child: BlocProvider.value(
          value: chatHistoryBloc,
          child: _ArchivedChatsManageSheet(
            onMessage: (msg) {
              if (mounted) _showSnack(msg);
            },
          ),
        ),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onPressed});

  static const Color _bg = Color(0xFFECECEC);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.close, size: 20, color: Color(0xFF585C77)),
        ),
      ),
    );
  }
}

// --- Shared links / Archived chats management sheets ---

class _ManageSheetColors {
  static const tableHeaderBg = Color(0xFFF5F5F5);
  static const headerLabel = Color(0xFF424242);
  static const rowText = Color(0xFF171212);
  static const rowDivider = Color(0xFFE8E8E8);
}

/// Width reserved for row actions (matches header “…” column).
const double _kManageTrailingColWidth = 88;

class _SharedLinksManageSheet extends StatelessWidget {
  const _SharedLinksManageSheet({required this.onMessage});

  final void Function(String message) onMessage;

  static TextStyle _titleStyle() => AppTheme.getTextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Colors.black,
      );

  static TextStyle _headerCellStyle() => AppTheme.getTextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _ManageSheetColors.headerLabel,
      );

  static TextStyle _cellStyle() => AppTheme.getTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _ManageSheetColors.rowText,
      );

  static String _formatCreatedAt(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    // API returns "YYYY-MM-DD HH:mm:ss.ffffff+00:00" – best-effort parse.
    final normalized = createdAt.replaceFirst(' ', 'T');
    final dt = DateTime.tryParse(normalized);
    if (dt == null) return '';
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '$m ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text('Shared links', style: _titleStyle())),
              // _SheetCloseButton(onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        Container(
          color: _ManageSheetColors.tableHeaderBg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 22, child: Text('Name', style: _headerCellStyle())),
              // Expanded(flex: 10, child: Center(child: Text('Type', style: _headerCellStyle()))),
              Expanded(
                flex: 16,
                child: Text(
                  'Date shared',
                  style: _headerCellStyle(),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: _kManageTrailingColWidth,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
                  alignment: Alignment.centerRight,
                  icon: const Icon(Icons.more_horiz, color: _ManageSheetColors.headerLabel, size: 22),
                  onPressed: () => onMessage('Shared links — more options'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
            builder: (context, state) {
              if (state is ChatHistorySharedSessionsLoadFailure) {
                return Center(child: Text(state.message));
              }

              if (state is ChatHistorySharedSessionsLoadInProgress ||
                  state is ChatHistoryInitial ||
                  state is ChatHistoryLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ChatHistorySharedSessionsLoadSuccess) {
                final shares = state.shares;
                if (shares.isEmpty) {
                  return Center(
                    child: Text(
                      'No Data Found',
                      style: _cellStyle(),
                    ),
                  );
                }

                return _sharedLinksList(shares, context);
              }

              /// Stale bloc state from another screen (e.g. chat history loaded) — wait for fetch.
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Widget _sharedLinksList(List<SharedSession> shares, BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: shares.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        color: _ManageSheetColors.rowDivider,
      ),
      itemBuilder: (context, index) {
        final s = shares[index];
        return _SharedLinkRow(
          name: s.title ?? s.shareUrl,
          typeLabel: 'Chat',
          dateSharedLabel: _formatCreatedAt(s.createdAt),
          onOpenLink: () async {
            // try {
            //   await openUrl(s.shareUrl);
            // } catch (_) {
            //   onMessage('Could not open link');
            // }
          },
          onChat: () async {
            await Clipboard.setData(ClipboardData(text: s.shareUrl));
            onMessage('Link Copy');
          },
          onDelete: () => context.read<ChatHistoryBloc>().add(
                ChatHistorySharedSessionRevokeRequested(shareId: s.shareId),
              ),
        );
      },
    );
  }
}

class _SharedLinkRow extends StatelessWidget {
  const _SharedLinkRow({
    required this.name,
    required this.typeLabel,
    required this.dateSharedLabel,
    required this.onOpenLink,
    required this.onChat,
    required this.onDelete,
  });

  final String name;
  final String typeLabel;
  final String dateSharedLabel;
  final VoidCallback onOpenLink;
  final VoidCallback onChat;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final linkStyle = AppTheme.getTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppConstants.appThemeColor,
    );
    final cellStyle = _SharedLinksManageSheet._cellStyle();

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onOpenLink,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 22,
                child: Row(
                  children: [
                    Icon(Icons.link, size: 20, color: AppConstants.appThemeColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(name, style: linkStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              // Expanded(
              //   flex: 10,
              //   child: Center(child: Text(typeLabel, style: cellStyle, textAlign: TextAlign.center)),
              // ),
              Expanded(
                flex: 16,
                child: Text(
                  dateSharedLabel,
                  style: cellStyle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: _kManageTrailingColWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onChat,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_copy_link.svg'),
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(Color(0xFF424242), BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: onDelete,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_trash.svg'),
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(Color(0xFF424242), BlendMode.srcIn),
                        ),
                      ),
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
}

class _ArchivedChatsManageSheet extends StatelessWidget {
  const _ArchivedChatsManageSheet({required this.onMessage});

  final void Function(String message) onMessage;

  static String _formatDateLabel(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '$m ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Archived chats',
                  style: AppTheme.getTextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Colors.black,
                  ),
                ),
              ),
              // _SheetCloseButton(onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        Container(
          color: _ManageSheetColors.tableHeaderBg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 24, child: Text('Name', style: _SharedLinksManageSheet._headerCellStyle())),
              Expanded(
                flex: 14,
                child: Text(
                  'Date created',
                  style: _SharedLinksManageSheet._headerCellStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: _kManageTrailingColWidth,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
                  alignment: Alignment.centerRight,
                  icon: const Icon(Icons.more_horiz, color: _ManageSheetColors.headerLabel, size: 22),
                  onPressed: () => onMessage('Archived chats — more options'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
            builder: (context, state) {
              if (state is ChatHistoryLoadInProgress || state is ChatHistoryInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ChatHistoryLoadFailure) {
                return Center(child: Text(state.message));
              }

              if (state is! ChatHistoryLoadSuccess) {
                return const SizedBox.shrink();
              }

              final sessions = state.sessions;
              if (sessions.isEmpty) {
                return const Center(child: Text('No Data Found'));
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: _ManageSheetColors.rowDivider,
                ),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  return ArchivedChatRow(
                    chatName: s.title.isNotEmpty ? s.title : 'Session ${s.sessionId}',
                    dateLabel: _formatDateLabel(s.timestamp),
                    onOpenChat: () => {},//onMessage('Open archived chat ${s.sessionId}'),
                    onUnarchive: () => context.read<ChatHistoryBloc>().add(
                          ChatHistoryUnarchiveRequested(sessionId: s.sessionId.toString()),
                        ),
                    onDelete: () => context.read<ChatHistoryBloc>().add(
                          ChatHistoryDeleteRequested(sessionId: s.sessionId.toString()),
                        ),
                    dateStyle: _SharedLinksManageSheet._cellStyle(),
                    trailingWidth: _kManageTrailingColWidth,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
