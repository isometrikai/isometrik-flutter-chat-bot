import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/services/services.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/restaurant_menu/restaurant_menu_colors.dart';

class RestaurantStoreInfoCard extends StatelessWidget {
  const RestaurantStoreInfoCard({
    super.key,
    required this.storeName,
    required this.imageUrl,
    required this.avgRating,
    this.actionData,
  });

  final String storeName;
  final String imageUrl;
  final double avgRating;
  final chat.WidgetAction? actionData;

  @override
  Widget build(BuildContext context) {
    if (storeName.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RestaurantMenuColors.cardBackground,
        border: Border.all(color: RestaurantMenuColors.cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StoreLogo(imageUrl: imageUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.restaurantTitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: RestaurantMenuColors.title,
                  ),
                ),
                if (avgRating > 0) ...<Widget>[
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: AppConstants.appThemeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: AppTextStyles.restaurantDescription.copyWith(
                          color: RestaurantMenuColors.title,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (actionData != null) {
                      OrderService().triggerStoreOrder(actionData!.toJson());
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SvgPicture.asset(
                        AssetPath.get('images/ic_eazy_app.svg'),
                        width: 13.8,
                        height: 12.96,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          AppConstants.appThemeColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AppTranslations.openInEazyApp,
                        style: AppTextStyles.restaurantDescription.copyWith(
                          color: AppConstants.appThemeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static RestaurantStoreInfoCard fromStoreData({
    required StoreData? storeData,
    required chat.WidgetAction? actionData,
    required String storeName,
  }) {
    final String imageUrl =
        storeData?.logoImages?.imageUrl.isNotEmpty == true
            ? storeData!.logoImages!.imageUrl
            : (actionData?.image ?? '');
    return RestaurantStoreInfoCard(
      storeName: storeName,
      imageUrl: imageUrl,
      avgRating: storeData?.avgRating ?? 0,
      actionData: actionData,
    );
  }
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 69,
        height: 69,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) return child;
                  return const _StoreLogoPlaceholder();
                },
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) =>
                    const _StoreLogoPlaceholder(),
              )
            : const _StoreLogoPlaceholder(),
      ),
    );
  }
}

class _StoreLogoPlaceholder extends StatelessWidget {
  const _StoreLogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AssetPath.get('images/ic_placeHolder.svg'),
      width: 69,
      height: 69,
      fit: BoxFit.cover,
    );
  }
}
