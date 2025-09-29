import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';

class OrderSummaryWidget extends StatelessWidget {
  final List<WidgetAction> orderItems;

  const OrderSummaryWidget({
    super.key,
    required this.orderItems,
  });

  @override
  Widget build(BuildContext context) {
    if (orderItems.isEmpty) return const SizedBox.shrink();

    // Extract store information from the first item
    final storeInfo = orderItems.isNotEmpty ? orderItems.first : WidgetAction(
      buttonText: '',
      title: '',
      subtitle: '',
      storeCategoryId: '',
      keyword: '',
      storeName: 'Restaurant',
      address: 'Address not available',
    );

    // Separate regular items from total
    final regularItems = orderItems.where((item) => 
        item.productName != null && 
        item.productName!.isNotEmpty && 
        item.productName != "Total To Pay" 
        // &&
        // item.quantity != null && 
        // item.quantity!.isNotEmpty
        ).toList();
    
    final totalItem = orderItems.lastWhere(
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
      margin: const EdgeInsets.only(left: 0, right: 24, bottom: 8, top: 8),
            child: IntrinsicHeight(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE9DFFB), width: 1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
                  child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Order summary
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242424),
                ),
              ),
              const SizedBox(height: 10),
              
              // Store information section with light purple background
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF1FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store name with icon
                    Row(
                      children: [
                        Text(
                          storeInfo.storeName ?? '',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF242424),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Address with icon
                    Row(
                      children: [
                        const Text('🏠 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            storeInfo.address ?? 'Address not available',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF242424),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Itemized list
              Column(
                children: regularItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main item
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.quantity?.isNotEmpty ?? false ? '${item.quantity}x ${item.productName}' : item.productName ?? '',
                                // '${item.quantity}x ${item.productName}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF242424),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                _formatCurrency(item.currencySymbol ?? 'د.إ', item.productPrice ?? 0),
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF242424),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        // Add-ons section
                        if(item.addOns != null && item.addOns!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              '${item.addOns}',
                              maxLines: 5,
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF242424),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
              
              // Dotted line
              Container(
                width: double.infinity,
                height: 1,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE9DFFB),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Total and payment method
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Total to pay',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF242424),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 130,
                        child: Text(
                          _formatCurrency(totalItem.currencySymbol ?? '', totalItem.productPrice ?? 0),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF242424),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💳 ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          storeInfo.paymentTypeText ?? '',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF242424),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  String _formatCurrency(String symbol, num value) {
    if (symbol.isNotEmpty) {
      return '$symbol${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return 'د.إ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }
}
