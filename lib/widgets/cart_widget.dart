import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';

class CartWidget extends StatelessWidget {
  final List<WidgetAction> cartItems;

  const CartWidget({
    super.key,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) return const SizedBox.shrink();

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
    final currencySymbol = item.currencySymbol ?? 'د.إ';
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
                child: Text(
                  quantity.isNotEmpty ? '$quantity× $productName' : productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF242424),
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


