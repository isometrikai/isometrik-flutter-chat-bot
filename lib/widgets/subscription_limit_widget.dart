import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/utils/app_theme.dart';
import 'package:chat_bot/widgets/plan_price_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Daily free-message limit card shown in chat (subscription widget).
class SubscriptionLimitWidget extends StatelessWidget {
  final List<WidgetAction> items;
  final bool isFromChatHistory;
  final VoidCallback? onPurchaseSuccess;

  const SubscriptionLimitWidget({
    super.key,
    required this.items,
    this.isFromChatHistory = false,
    this.onPurchaseSuccess,
  });

  static const Color _titleColor = Color(0xFF242424);
  static const Color _bodyColor = Color(0xFF6B7280);
  static const Color _footerColor = Color(0xFF9CA3AF);
  static const Color _cardBorder = Color(0xFFC5DCFF);

  static const LinearGradient _cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F3FF),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient _buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2E8AFF),
      Color(0xFF007AFF),
      Color(0xFF5186E0),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final item = items.first;
    final current = item.current_messages?.toInt() ?? 0;
    final max = item.max_messages?.toInt() ?? 0;
    final title = item.title.isNotEmpty
        ? item.title
        : "You've reached today's free limit";
    final subtitle = item.subtitle.isNotEmpty
        ? item.subtitle
        : "You've used all $max free messages with zAIn for today. "
            'Subscribe to zAIn Pro for unlimited chats and priority replies.';
    final buttonText = item.buttonText.isNotEmpty
        ? item.buttonText
        : 'Subscribe to zAIn Pro';
    final footer = (item.footer ?? '').isNotEmpty
        ? item.footer!
        : '';

    return Container(
      margin: const EdgeInsetsDirectional.only(start: 0, end: 24, bottom: 8, top: 8),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 340),
      decoration: BoxDecoration(
        gradient: _cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppConstants.appThemeColor.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UsageRing(current: current, max: max),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _titleColor,
            ).copyWith(height: 1.25),
          ),
          const SizedBox(height: 10),
          _SubtitleText(text: subtitle, boldCount: max),
          const SizedBox(height: 20),
          _SubscribeButton(
            label: buttonText,
            enabled: !isFromChatHistory,
            onTap: () {
              if (isFromChatHistory) return;
              PlanPriceBottomSheet.show(
                context,
                isFromChatScreen: true,
                onPurchaseSuccess: onPurchaseSuccess,
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            footer,
            textAlign: TextAlign.center,
            style: AppTheme.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: _footerColor,
            ).copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _UsageRing extends StatelessWidget {
  final int current;
  final int max;

  const _UsageRing({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: max > 0 ? (current / max).clamp(0.0, 1.0) : 1.0,
              strokeWidth: 6,
              backgroundColor:
                  AppConstants.appThemeColor.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppConstants.appThemeColor,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '$current/$max',
            style: AppTheme.getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConstants.appThemeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  final String text;
  final int boldCount;

  const _SubtitleText({required this.text, required this.boldCount});

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTheme.getTextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: SubscriptionLimitWidget._bodyColor,
    ).copyWith(height: 1.4);

    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: SubscriptionLimitWidget._titleColor,
    );

    // Bold "{n} free messages" when present in API subtitle.
    final pattern = RegExp(
      r'(\d+\s+free messages)',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);

    if (match == null) {
      // Fallback: bold "{max} free messages" if we can find a close phrase.
      final fallback = boldCount > 0
          ? RegExp(
              RegExp.escape('$boldCount free messages'),
              caseSensitive: false,
            ).firstMatch(text)
          : null;
      if (fallback == null) {
        return Text(text, textAlign: TextAlign.center, style: baseStyle);
      }
      return Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: text.substring(0, fallback.start)),
            TextSpan(text: fallback.group(0), style: boldStyle),
            TextSpan(text: text.substring(fallback.end)),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, match.start)),
          TextSpan(text: match.group(0), style: boldStyle),
          TextSpan(text: text.substring(match.end)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SubscribeButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(40),
        child: Ink(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: enabled
                ? SubscriptionLimitWidget._buttonGradient
                : null,
            color: enabled ? null : const Color(0xFFB0B8C9),
            borderRadius: BorderRadius.circular(40),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color:
                          AppConstants.appThemeColor.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.getTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
