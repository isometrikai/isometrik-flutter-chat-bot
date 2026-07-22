import 'package:chat_bot/services/callback_manage.dart';
import 'package:chat_bot/utils/asset_path.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/data.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import '../utils/utils.dart';

class CartWidget extends StatelessWidget {
  final List<WidgetAction> cartItems;
  final bool isFromChatHistory;

  const CartWidget({
    super.key,
    required this.cartItems,
    required this.isFromChatHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) return const SizedBox.shrink();

    final storeNameItem = cartItems.cast<WidgetAction?>().firstWhere(
        (item) => item?.storeName != null && item!.storeName!.isNotEmpty,
        orElse: () => null);

    // Separate regular items from total
    final regularItems = cartItems.where((item) => 
        item.productName != null && 
        item.productName!.isNotEmpty && 
        item.productName != "Total To Pay").toList();
    
    final totalItem = cartItems.lastWhere(
      (item) => item.productName == "Total To Pay",
      orElse: () => WidgetAction(
        buttonText: '',
        title: '',
        subtitle: '',
        storeCategoryId: '',
        keyword: '',
        productName: "Total To Pay",
        currencySymbol: "د.إ",
        productPrice: 0,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(left: 0, right: 24, bottom: 8,top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE6E6FA), // Light purple border
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Store name section
          if (storeNameItem != null) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:
                  isFromChatHistory
                      ? null
                      : () {
                        print("storeNameItem: ${storeNameItem.toJson()}");
                        OrderService().triggerStoreOrder(
                          storeNameItem.toJson(),
                        );
                      },
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AssetPath.get('images/ic_storeCart.svg'),
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeNameItem.storeName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.restaurantTitle.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF242424),
                            ),
                          ),
                          Text(
                            'Visit Store',
                            style: AppTextStyles.bodyText.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppConstants.appThemeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isFromChatHistory == false) ...[
                      Container(
                        width: 45,
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_info_cart.svg'),
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          // Regular items section
          if (regularItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: regularItems.map((item) => _buildCartItem(item)).toList(),
              ),
            ),
            // Dotted line separator
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE6E6FA),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ],
          // Total section
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTotalItem(totalItem),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(WidgetAction item) {
    final quantity = item.quantity ?? '';
    final productName = item.productName ?? '';
    final currencySymbol = item.currencySymbol ?? 'AED';
    final price = item.productPrice ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: quantity.isNotEmpty
                            ? '$quantity× $productName'
                            : productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF242424),
                        ),
                      ),
                      if (item.isDoctorFlow == true && quantity.isEmpty && item.addOns != null && item.addOns!.isNotEmpty)
                        const TextSpan(
                          text: '(Consultation Fee)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF979797),
                          ),
                        ),
                    ],
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$currencySymbol$price',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF242424),
                ),
              ),
            ],
          ),
          if(item.addOns != null && item.addOns!.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.addOns!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF242424),
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );    
  }

  Widget _buildTotalItem(WidgetAction totalItem) {
    final currencySymbol = totalItem.currencySymbol ?? 'د.إ';
    final price = totalItem.productPrice ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          totalItem.productName ?? '',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF242424),
          ),
        ),
        Text(
          '$currencySymbol$price',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }
}


