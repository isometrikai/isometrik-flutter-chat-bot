import 'package:chat_bot/data/data.dart';

class ChatCatalogUtils {
  static int indexOfLastBotCatalogMessage(List<ChatMessage> messages) {
    for (int i = messages.length - 1; i >= 0; i--) {
      final message = messages[i];
      if (message.isBot && _hasCatalogWidgets(message)) {
        return i;
      }
    }
    return -1;
  }

  static bool _hasCatalogWidgets(ChatMessage message) {
    return message.hasStoreCards ||
        message.hasProductCards ||
        message.hasChooseAddressWidget ||
        message.hasChooseCardWidget ||
        message.hasOrderSummaryWidget ||
        message.hasOrderConfirmedWidget ||
        message.hasServicesDeliveryOptionsWidget ||
        message.hasHotelDestinationSectionWidget ||
        message.hasCarPickupPlacesSectionWidget ||
        message.hasCarDropoffPlacesSectionWidget ||
        message.hasFlightOriginPlacesSectionWidget ||
        message.hasFlightDestinationPlacesSectionWidget ||
        message.hasCarRentalsSearchSectionWidget ||
        message.hasFlightsSearchSectionWidget ||
        message.hasHotelsSectionWidget;
  }

  static ChatMessage hideCatalogInMessage(ChatMessage message) {
    if (!_hasCatalogWidgets(message)) return message;
    return message.copyWith(
      hasStoreCards: false,
      hasProductCards: false,
      hasChooseAddressWidget: false,
      hasChooseCardWidget: false,
      hasOrderSummaryWidget: message.hasOrderSummaryWidget,
      hasOrderConfirmedWidget: false,
      hasCartWidget: message.hasCartWidget,
      hasServicesDeliveryOptionsWidget: false,
      hasHotelDestinationSectionWidget: false,
      hasCarPickupPlacesSectionWidget: false,
      hasCarDropoffPlacesSectionWidget: false,
      hasFlightOriginPlacesSectionWidget: false,
      hasFlightDestinationPlacesSectionWidget: false,
      hasCarRentalsSearchSectionWidget: false,
      hasFlightsSearchSectionWidget: false,
      hasHotelsSectionWidget: false,
    );
  }
}
