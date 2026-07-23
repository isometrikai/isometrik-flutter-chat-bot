import 'package:chat_bot/services/callback_manage.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/data.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:chat_bot/utils/asset_path.dart';
import '../utils/utils.dart';

class OrderSummaryWidget extends StatelessWidget {
  final List<WidgetAction> orderItems;
  final bool isFromChatHistory;

  const OrderSummaryWidget({
    super.key,
    required this.orderItems,
    required this.isFromChatHistory,
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
      address: AppTranslations.addressNotAvailable,
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
      margin: const EdgeInsetsDirectional.only(start: 0, end: 24, bottom: 8, top: 8),
            child: IntrinsicHeight(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE9DFFB), width: 1),
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(16),
              topEnd: Radius.circular(16),
              bottomStart: Radius.circular(16),
              bottomEnd: Radius.circular(16),
            ),
          ),
                  child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 15, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Order summary
               Text(
                AppTranslations.orderSummary,
                style: 
                AppTextStyles.restaurantTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242424),
                ),  
              ),
              const SizedBox(height: 10),
              
              if (storeInfo.storeCategoryId == FoodStoreCategoryId.services.value) ...[
                // Service card with light purple background
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
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9DFFB),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          storeInfo.serviceType ?? '',
                          style: AppTextStyles.restaurantTitle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppConstants.appThemeColor,
                          ),
                        ),
                      ),
                      // Content section
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(10, 12, 10, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store name with hammer emoji
                            Row(
                              children: [
                                const Text('🔨 ', style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    storeInfo.storeName ?? '',
                                    style: AppTextStyles.restaurantTitle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF242424),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Address with house emoji
                            if (storeInfo.address != null && storeInfo.address!.isNotEmpty) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🏠 ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      storeInfo.address ?? '',
                                      style: AppTextStyles.restaurantDescription.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF242424),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            // Service time with alarm clock emoji
                            Row(
                              children: [
                                const Text('⏰ ', style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    storeInfo.isScheduled == true 
                                        ? AppTranslations.scheduledFor(_formatServiceTime(storeInfo.serviceRequestedTime)) 
                                        : AppTranslations.bookNow,
                                    style: AppTextStyles.restaurantDescription.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF242424),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
              // Store information section with light purple background
              Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 0, 10),
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
                        Expanded(
                          child: Text(
                            storeInfo.storeName ?? '',
                            style: 
                            AppTextStyles.restaurantTitle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF242424),
                            ),
                          ),
                        ),
                        if(isFromChatHistory == false) ...[
                            GestureDetector(
                              onTap: () {
                                print("storeInfo: ${storeInfo.toJson()}");
                                OrderService().triggerStoreOrder(storeInfo.toJson());
                              },
                              child: Container(
                                // margin: const EdgeInsets.only(right: 15),
                                width: 45,
                                height: 23,
                                // color: Colors.red,
                                alignment: Alignment.center,
                                child:  SvgPicture.asset(
                                  AssetPath.get('images/ic_info_cart.svg'),
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.cover,
                                ),
                                ),
                              ),   
                        ],
                      ],
                    ),
                    if (storeInfo.address != null && storeInfo.address!.isNotEmpty && storeInfo.address != 'N/A') ...[    
                      const SizedBox(height: 10),
                      // Address with icon
                    Row(
                      children: [
                        const Text('🏠 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            storeInfo.address ?? AppTranslations.addressNotAvailable,
                            style: 
                            AppTextStyles.restaurantDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF242424),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ], 
                    if (storeInfo.storeCategoryId == FoodStoreCategoryId.healthCare.value) ...[
                      const SizedBox(height: 10),
                       Row(
                              children: [
                                const Text('⏰ ', style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    storeInfo.isScheduled == true 
                                        ? AppTranslations.scheduledFor(_formatServiceTime(storeInfo.serviceRequestedTime)) 
                                        : AppTranslations.bookNow,
                                    style: AppTextStyles.restaurantDescription.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF242424),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ], 
                    ],
                  ),
                ),
              ],
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
                                style: 
                                AppTextStyles.restaurantDescription.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF242424),
                                ),
                                maxLines: 3,//2
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: Text(
                                _formatCurrency(item.currencySymbol ?? 'د.إ', item.productPrice ?? 0),
                                style: 
                                AppTextStyles.restaurantDescription.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF242424),
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        if(storeInfo.isTableBooking == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            AppTranslations.bookingDateAndTime(
                              storeInfo.bookingDate ?? '',
                              storeInfo.bookingTime ?? '',
                            ),
                            style: AppTextStyles.restaurantDescription.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF242424),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppTranslations.partySize(
                              '${storeInfo.partySize ?? ''}',
                            ),
                            style: AppTextStyles.restaurantDescription.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF242424),
                            ),
                          ),
                        ],
                        // Add-ons section
                        if(item.addOns != null && item.addOns!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 0.0),
                            child: Text(
                              '${item.addOns}',
                              maxLines: 5,
                              style: 
                              AppTextStyles.restaurantDescription.copyWith(
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
                       Expanded(
                        child: Text(
                          AppTranslations.totalToPay,
                          style: 
                          AppTextStyles.restaurantTitle.copyWith(
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
                          style: AppTextStyles.restaurantTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF242424),
                          ),  
                          textAlign: TextAlign.end,
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
                          style: AppTextStyles.restaurantDescription.copyWith(
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

  String _localizedMonth(int month) {
    switch (month) {
      case 1:
        return AppTranslations.monthJanuary;
      case 2:
        return AppTranslations.monthFebruary;
      case 3:
        return AppTranslations.monthMarch;
      case 4:
        return AppTranslations.monthApril;
      case 5:
        return AppTranslations.monthMay;
      case 6:
        return AppTranslations.monthJune;
      case 7:
        return AppTranslations.monthJuly;
      case 8:
        return AppTranslations.monthAugust;
      case 9:
        return AppTranslations.monthSeptember;
      case 10:
        return AppTranslations.monthOctober;
      case 11:
        return AppTranslations.monthNovember;
      case 12:
        return AppTranslations.monthDecember;
      default:
        return '';
    }
  }

  String _formatCurrency(String symbol, num value) {
    if (symbol.isNotEmpty) {
      // return '$symbol${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
      return '$symbol${value.toString()}';
    }
    return 'د.إ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  String _formatServiceTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '';
    }

    try {
      final trimmed = timeString.trim();
      final DateTime dateTime;

      final timestamp = int.tryParse(trimmed);
      if (timestamp != null) {
        final ms = trimmed.length > 10 ? timestamp : timestamp * 1000;
        dateTime = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
      } else {
        dateTime = DateTime.parse(trimmed).toLocal();
      }

      final month = _localizedMonth(dateTime.month);
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year;

      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour >= 12 ? AppTranslations.pm : AppTranslations.am;
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');

      return '$month $day, $year at $displayHour:$displayMinute $period';
    } catch (e) {
      return timeString;
    }
  }
}
