import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/asset_path.dart';
import 'package:chat_bot/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArchivedChatRow extends StatelessWidget {
  const ArchivedChatRow({
    super.key,
    required this.onOpenChat,
    required this.onUnarchive,
    required this.onDelete,
    required this.dateStyle,
    required this.trailingWidth,
    this.chatName,
    this.dateLabel = 'Jan 4, 2024',
  });

  final VoidCallback onOpenChat;
  final VoidCallback onUnarchive;
  final VoidCallback onDelete;
  final TextStyle dateStyle;
  final double trailingWidth;
  final String? chatName;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final nameStyle = AppTheme.getTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppConstants.appThemeColor,
    );

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onOpenChat,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 24,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AssetPath.get('images/ic_s_message.svg'),
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppConstants.appThemeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatName ?? AppTranslations.chatNameDefault,
                        style: nameStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 14,
                child: Text(
                  dateLabel,
                  style: dateStyle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: trailingWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onUnarchive,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_archive.svg'),
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF424242),
                            BlendMode.srcIn,
                          ),
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
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF424242),
                            BlendMode.srcIn,
                          ),
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
