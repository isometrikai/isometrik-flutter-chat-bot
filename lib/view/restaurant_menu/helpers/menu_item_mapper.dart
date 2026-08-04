import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/view/restaurant_menu/models/menu_item.dart';

abstract final class MenuItemMapper {
  static MenuItem fromProduct(chat.Product product, {bool storeIsOpen = true}) {
    final String? imageUrl = extractImageUrl(product.images);
    return MenuItem(
      title: product.productName,
      price: formatCurrency(
        product.currency,
        product.finalPriceList.finalPrice,
      ),
      originalPrice: formatCurrency(
        product.currency,
        product.finalPriceList.basePrice,
      ),
      isVeg: !product.containsMeat,
      assetPath: imageUrl ?? '',
      imageUrl: imageUrl,
      productId: product.childProductId,
      centralProductId: product.parentProductId,
      isCustomizable: product.customizable ?? false,
      instock: product.instock ?? true,
      storeIsOpen: storeIsOpen,
    );
  }

  static String formatCurrency(String symbol, double value) {
    final String amount = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 2,
    );
    return '$symbol $amount';
  }

  static String? extractImageUrl(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      return images.isNotEmpty ? images : null;
    }
    if (images is List && images.isNotEmpty) {
      final dynamic first = images.first;
      if (first is String && first.isNotEmpty) return first;
    }
    return null;
  }
}
