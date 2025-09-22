import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';

class CartDetailsPriceWidget extends StatelessWidget {
  final List<WidgetAction> cartItems;

  const CartDetailsPriceWidget({
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
        item.productName != "Total To Pay" &&
        item.productName != "Delivery fee" &&
        item.productName != "Service Fee" &&
        !_isTaxItem(item.productName!) &&
        item.quantity != null && 
        item.quantity!.isNotEmpty).toList();
    
    final deliveryFeeItem = cartItems.where((item) => 
        item.productName == "Delivery fee").toList();
    
    final serviceFeeItem = cartItems.where((item) => 
        item.productName == "Service Fee").toList();
    
    final taxItems = cartItems.where((item) => 
        item.productName != null && _isTaxItem(item.productName!)).toList();
    
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
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 8,top: 8),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: regularItems.map((item) => _buildCartItem(item)).toList(),
              ),
            ),
          ],
          
          // Delivery fee section (if exists)
          if (deliveryFeeItem.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDeliveryFeeItem(deliveryFeeItem.first),
            ),
          ],
          
          // Service fee section (if exists)
          if (serviceFeeItem.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildServiceFeeItem(serviceFeeItem.first),
            ),
          ],
          
          // Tax items section (if exists)
          if (taxItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: taxItems.map((taxItem) => _buildTaxItem(taxItem)).toList(),
              ),
            ),
          ],
          
          // Line separator before total
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
    final addOns = item.addOns ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // Main product row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quantity.isNotEmpty ? '$quantity $productName' : productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF242424),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$currencySymbol ${price}',//toStringAsFixed(0)
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF242424),
                ),
              ),
            ],
          ),
          if(addOns.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    addOns,
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

  Widget _buildDeliveryFeeItem(WidgetAction deliveryFeeItem) {
    final currency = deliveryFeeItem.currencySymbol ?? 'د.إ';
    final price = deliveryFeeItem.productPrice ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Delivery fee',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF242424),
          ),
        ),
        Text(
          '$currency ${price}',//toStringAsFixed(0)
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceFeeItem(WidgetAction serviceFeeItem) {
    final currency = serviceFeeItem.currencySymbol ?? 'د.إ';
    final price = serviceFeeItem.productPrice ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Service Fee',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF242424),
          ),
        ),
        Text(
          '$currency ${price}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxItem(WidgetAction taxItem) {
    final currency = taxItem.currencySymbol ?? 'د.إ';
    final price = taxItem.productPrice ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            taxItem.productName ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF242424),
            ),
          ),
          Text(
            '$currency ${price}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF242424),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(WidgetAction totalItem) {
    final currency = totalItem.currencySymbol ?? 'د.إ';
    final price = totalItem.productPrice ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          totalItem.productName ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF242424),
          ),
        ),
        Text(
          '$currency ${price}',//toStringAsFixed(0)
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }

  /// Helper method to identify tax items
  bool _isTaxItem(String productName) {
    // Tax items typically contain "GST", "VAT", "Tax", or have a percentage in the name
    return productName.toLowerCase().contains('gst') ||
           productName.toLowerCase().contains('vat') ||
           productName.toLowerCase().contains('tax') ||
           productName.contains('%');
  }
}


