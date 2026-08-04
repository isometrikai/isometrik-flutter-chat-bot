import 'package:flutter/material.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/widgets/widgets.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/store_info_card.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/menu_close_button.dart';

class RestaurantMenuAnimatedHeader extends StatefulWidget {
  const RestaurantMenuAnimatedHeader({
    super.key,
    required this.storeData,
    required this.storeName,
    required this.actionData,
    required this.collapseAnimation,
    required this.onClose,
  });

  final StoreData? storeData;
  final String storeName;
  final chat.WidgetAction? actionData;
  final Animation<double> collapseAnimation;
  final VoidCallback onClose;

  @override
  State<RestaurantMenuAnimatedHeader> createState() =>
      _RestaurantMenuAnimatedHeaderState();
}

class _RestaurantMenuAnimatedHeaderState
    extends State<RestaurantMenuAnimatedHeader> {
  final GlobalKey _expandedHeaderKey = GlobalKey();
  double _measuredExpandedHeaderHeight = 0;

  void _scheduleMeasureExpandedHeader() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderBox? box =
          _expandedHeaderKey.currentContext?.findRenderObject() as RenderBox?;
      final double height = box?.size.height ?? 0;
      if (height > 0 && (height - _measuredExpandedHeaderHeight).abs() > 1) {
        setState(() => _measuredExpandedHeaderHeight = height);
      }
    });
  }

  double _fallbackExpandedHeaderHeight() {
    double height = 16 + 56;
    final String subtitle = widget.actionData?.subtitle ?? '';
    if (subtitle.isNotEmpty) {
      height += 12 + 44;
    }
    if (widget.storeName.isNotEmpty) {
      height += 8 + 115 + 8;
    }
    return height;
  }

  Widget _buildExpandedHeader({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
          child: ScreenHeader(
            title: widget.actionData?.title ?? '',
            subtitle: widget.actionData?.subtitle ?? '',
            onClose: widget.onClose,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: RestaurantStoreInfoCard.fromStoreData(
            storeData: widget.storeData,
            actionData: widget.actionData,
            storeName: widget.storeName,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _scheduleMeasureExpandedHeader();

    return AnimatedBuilder(
      animation: widget.collapseAnimation,
      builder: (BuildContext context, Widget? child) {
        final double t = widget.collapseAnimation.value;

        if (t <= 0.001) {
          return _buildExpandedHeader(key: _expandedHeaderKey);
        }

        if (t >= 0.999) {
          return RestaurantMenuCollapsedNavBar(
            storeName: widget.storeName,
            onClose: widget.onClose,
          );
        }

        final double expandedHeight = _measuredExpandedHeaderHeight > 0
            ? _measuredExpandedHeaderHeight
            : _fallbackExpandedHeaderHeight();
        final double height =
            expandedHeight + (kToolbarHeight - expandedHeight) * t;

        return SizedBox(
          height: height,
          width: double.infinity,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.topCenter,
              children: <Widget>[
                IgnorePointer(
                  ignoring: t > 0.5,
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: _buildExpandedHeader(),
                  ),
                ),
                IgnorePointer(
                  ignoring: t < 0.5,
                  child: Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: RestaurantMenuCollapsedNavBar(
                      storeName: widget.storeName,
                      onClose: widget.onClose,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
