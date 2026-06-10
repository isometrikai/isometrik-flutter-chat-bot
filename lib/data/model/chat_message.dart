import 'chat_response.dart';
import '../../widgets/choose_address_widget.dart';
import '../../widgets/choose_card_widget.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isBot;
  final bool showAvatar;
  final bool hasQuickReplies;
  final bool hasStoreCards;
  final bool hasProductCards;
  final bool hasCartWidget;
  final bool hasRestaurantSectionsWidget;
  final bool hasHotelDestinationSectionWidget;
  final bool hasCarPickupPlacesSectionWidget;
  final bool hasCarDropoffPlacesSectionWidget;
  final bool hasCarRentalsSearchSectionWidget;
  final bool hasHotelsSectionWidget;
  final bool hasCustomerProfileDetailsSectionWidget;
  final bool hasHotelOrderSummarySectionWidget;
  final bool hasCarOrderSummarySectionWidget;
  final bool hasHotelBookingConfirmedSectionWidget;
  final bool hasServicesDeliveryOptionsWidget;
  final bool hasChooseAddressWidget;
  final bool hasChooseCardWidget;
  final bool hasOrderSummaryWidget;
  final bool hasOrderConfirmedWidget;
  final bool isWelcomeMessage;
  final bool hasOptionButtons;
  final List<String> optionButtons;
  final List<Store> stores;
  final List<Product> products;
  final List<WidgetAction> cartItems;
  final List<WidgetAction> restaurantSectionsItems;
  final List<HotelDestination> hotelDestinationItems;
  final List<CarPickupPlace> carPickupPlacesItems;
  final List<CarPickupPlace> carDropoffPlacesItems;
  final List<CarRentalSearch> carRentalsSearchItems;
  final List<HotelDestination> customerProfileDetailsItems;
  final List<HotelProperty> hotelsItems;
  final List<HotelOrderSummary> hotelOrderSummaryItems;
  final List<CarOrderSummary> carOrderSummaryItems;
  final List<WidgetAction> hotelBookingConfirmedItems;
  final List<WidgetAction> servicesDeliveryOptions;
  final List<AddressOption> addressOptions;
  final List<CardOption> cardOptions;
  final List<WidgetAction> orderSummaryItems;
  final ChatWidget? storesWidget;
  final ChatWidget? productsWidget;
  final ChatWidget? cartWidget;
  final ChatWidget? restaurantSectionsWidget;
  final ChatWidget? servicesDeliveryOptionsWidget;
      final ChatWidget? chooseAddressWidget;
    final ChatWidget? chooseCardWidget;
    final ChatWidget? orderSummaryWidget;
  final ChatWidget? orderConfirmedWidget;
  final ChatWidget? hotelDestinationWidget;
  final ChatWidget? carPickupPlacesWidget;
  final ChatWidget? carDropoffPlacesWidget;
  final ChatWidget? carRentalsSearchWidget;
  final ChatWidget? hotelsWidget;
  final ChatWidget? customerProfileDetailsWidget;
  final ChatWidget? hotelOrderSummaryWidget;
  final ChatWidget? carOrderSummaryWidget;
  final ChatWidget? hotelBookingConfirmedWidget;
  ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    this.showAvatar = false,
    this.hasQuickReplies = false,
    this.hasStoreCards = false,
    this.hasProductCards = false,
    this.hasCartWidget = false,
    this.hasRestaurantSectionsWidget = false,
    this.hasHotelDestinationSectionWidget = false,
    this.hasCarPickupPlacesSectionWidget = false,
    this.hasCarDropoffPlacesSectionWidget = false,
    this.hasCarRentalsSearchSectionWidget = false,
    this.hasHotelsSectionWidget = false,
    this.hasCustomerProfileDetailsSectionWidget = false,
    this.hasHotelOrderSummarySectionWidget = false,
    this.hasCarOrderSummarySectionWidget = false,
    this.hasHotelBookingConfirmedSectionWidget = false,
    this.hasServicesDeliveryOptionsWidget = false,
    this.hasChooseAddressWidget = false,
    this.hasChooseCardWidget = false,
    this.hasOrderSummaryWidget = false,
    this.hasOrderConfirmedWidget = false,
    this.isWelcomeMessage = false,
    this.hasOptionButtons = false,
    this.optionButtons = const [],
    this.stores = const [],
    this.products = const [],
    this.cartItems = const [],
    this.restaurantSectionsItems = const [],
    this.hotelDestinationItems = const [],
    this.carPickupPlacesItems = const [],
    this.carDropoffPlacesItems = const [],
    this.carRentalsSearchItems = const [],
    this.customerProfileDetailsItems = const [],
    this.hotelsItems = const [],
    this.hotelOrderSummaryItems = const [],
    this.carOrderSummaryItems = const [],
    this.hotelBookingConfirmedItems = const [],
    this.servicesDeliveryOptions = const [],
    this.addressOptions = const [],
    this.cardOptions = const [],
    this.orderSummaryItems = const [],
    this.storesWidget,
    this.productsWidget,
    this.cartWidget,
    this.restaurantSectionsWidget,
    this.servicesDeliveryOptionsWidget,
    this.chooseAddressWidget,
    this.chooseCardWidget,
    this.orderSummaryWidget,
    this.orderConfirmedWidget,
    this.hotelDestinationWidget,
    this.carPickupPlacesWidget,
    this.carDropoffPlacesWidget,
    this.carRentalsSearchWidget,
    this.customerProfileDetailsWidget,
    this.hotelsWidget,
    this.hotelOrderSummaryWidget,
    this.carOrderSummaryWidget,
    this.hotelBookingConfirmedWidget,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isBot,
    bool? showAvatar,
    bool? hasQuickReplies,
    bool? hasStoreCards,
    bool? hasProductCards,
    bool? hasCartWidget,
    bool? hasHotelDestinationSectionWidget,
    bool? hasCarPickupPlacesSectionWidget,
    bool? hasCarDropoffPlacesSectionWidget,
    bool? hasCarRentalsSearchSectionWidget,
    bool? hasHotelsSectionWidget,
    bool? hasCustomerProfileDetailsSectionWidget,
    bool? hasHotelOrderSummarySectionWidget,
    bool? hasCarOrderSummarySectionWidget,
    bool? hasHotelBookingConfirmedSectionWidget,
    bool? hasServicesDeliveryOptionsWidget,
    bool? hasChooseAddressWidget,
    bool? hasChooseCardWidget,
    bool? hasOrderSummaryWidget,
    bool? hasOrderConfirmedWidget,
    bool? isWelcomeMessage,
    bool? hasOptionButtons,
    List<String>? optionButtons,
    List<Store>? stores,
    List<Product>? products,
    List<WidgetAction>? cartItems,
    List<WidgetAction>? restaurantSectionsItems,
    List<HotelDestination>? hotelDestinationItems,
    List<CarPickupPlace>? carPickupPlacesItems,
    List<CarPickupPlace>? carDropoffPlacesItems,
    List<CarRentalSearch>? carRentalsSearchItems,
    List<HotelDestination>? customerProfileDetailsItems,
    List<HotelProperty>? hotelsItems,
    List<HotelOrderSummary>? hotelOrderSummaryItems,
    List<CarOrderSummary>? carOrderSummaryItems,
    List<WidgetAction>? hotelBookingConfirmedItems,
    List<WidgetAction>? servicesDeliveryOptions,
    List<AddressOption>? addressOptions,
    List<CardOption>? cardOptions,
    List<WidgetAction>? orderSummaryItems,
    ChatWidget? storesWidget,
    ChatWidget? productsWidget,
    ChatWidget? cartWidget,
    ChatWidget? restaurantSectionsWidget,
    ChatWidget? servicesDeliveryOptionsWidget,
    ChatWidget? chooseAddressWidget,
    ChatWidget? chooseCardWidget,
    ChatWidget? orderSummaryWidget,
    ChatWidget? orderConfirmedWidget,
    ChatWidget? hotelDestinationWidget,
    ChatWidget? carPickupPlacesWidget,
    ChatWidget? carDropoffPlacesWidget,
    ChatWidget? carRentalsSearchWidget,
    ChatWidget? hotelsWidget,
    ChatWidget? customerProfileDetailsWidget,
    ChatWidget? hotelOrderSummaryWidget,
    ChatWidget? carOrderSummaryWidget,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isBot: isBot ?? this.isBot,
      showAvatar: showAvatar ?? this.showAvatar,
      hasQuickReplies: hasQuickReplies ?? this.hasQuickReplies,
      hasStoreCards: hasStoreCards ?? this.hasStoreCards,
      hasProductCards: hasProductCards ?? this.hasProductCards,
      hasCartWidget: hasCartWidget ?? this.hasCartWidget,
      hasRestaurantSectionsWidget: hasRestaurantSectionsWidget ?? this.hasRestaurantSectionsWidget,
      hasHotelDestinationSectionWidget: hasHotelDestinationSectionWidget ?? this.hasHotelDestinationSectionWidget,
      hasCarPickupPlacesSectionWidget: hasCarPickupPlacesSectionWidget ?? this.hasCarPickupPlacesSectionWidget,
      hasCarDropoffPlacesSectionWidget: hasCarDropoffPlacesSectionWidget ?? this.hasCarDropoffPlacesSectionWidget,
      hasCarRentalsSearchSectionWidget: hasCarRentalsSearchSectionWidget ?? this.hasCarRentalsSearchSectionWidget,
      hasHotelsSectionWidget: hasHotelsSectionWidget ?? this.hasHotelsSectionWidget,
      hasCustomerProfileDetailsSectionWidget: hasCustomerProfileDetailsSectionWidget ?? this.hasCustomerProfileDetailsSectionWidget,
      hasHotelOrderSummarySectionWidget: hasHotelOrderSummarySectionWidget ?? this.hasHotelOrderSummarySectionWidget,
      hasCarOrderSummarySectionWidget: hasCarOrderSummarySectionWidget ?? this.hasCarOrderSummarySectionWidget,
      hasHotelBookingConfirmedSectionWidget: hasHotelBookingConfirmedSectionWidget ?? this.hasHotelBookingConfirmedSectionWidget,
      hasServicesDeliveryOptionsWidget: hasServicesDeliveryOptionsWidget ?? this.hasServicesDeliveryOptionsWidget,
      hasChooseAddressWidget: hasChooseAddressWidget ?? this.hasChooseAddressWidget,
      hasChooseCardWidget: hasChooseCardWidget ?? this.hasChooseCardWidget,
              hasOrderSummaryWidget: hasOrderSummaryWidget ?? this.hasOrderSummaryWidget,
        hasOrderConfirmedWidget: hasOrderConfirmedWidget ?? this.hasOrderConfirmedWidget,
      isWelcomeMessage: isWelcomeMessage ?? this.isWelcomeMessage,
      hasOptionButtons: hasOptionButtons ?? this.hasOptionButtons,
      optionButtons: optionButtons ?? this.optionButtons,
      stores: stores ?? this.stores,
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
      restaurantSectionsItems: restaurantSectionsItems ?? this.restaurantSectionsItems,
      hotelDestinationItems: hotelDestinationItems ?? this.hotelDestinationItems,
      carPickupPlacesItems: carPickupPlacesItems ?? this.carPickupPlacesItems,
      carDropoffPlacesItems: carDropoffPlacesItems ?? this.carDropoffPlacesItems,
      carRentalsSearchItems: carRentalsSearchItems ?? this.carRentalsSearchItems,
      customerProfileDetailsItems: customerProfileDetailsItems ?? this.customerProfileDetailsItems,
      hotelsItems: hotelsItems ?? this.hotelsItems,
      hotelOrderSummaryItems: hotelOrderSummaryItems ?? this.hotelOrderSummaryItems,
      carOrderSummaryItems: carOrderSummaryItems ?? this.carOrderSummaryItems,
      hotelBookingConfirmedItems: hotelBookingConfirmedItems ?? this.hotelBookingConfirmedItems,
      servicesDeliveryOptions: servicesDeliveryOptions ?? this.servicesDeliveryOptions,
      addressOptions: addressOptions ?? this.addressOptions,
      cardOptions: cardOptions ?? this.cardOptions,
      orderSummaryItems: orderSummaryItems ?? this.orderSummaryItems,
      storesWidget: storesWidget ?? this.storesWidget,
      productsWidget: productsWidget ?? this.productsWidget,
      cartWidget: cartWidget ?? this.cartWidget,
      servicesDeliveryOptionsWidget: servicesDeliveryOptionsWidget ?? this.servicesDeliveryOptionsWidget,
      chooseAddressWidget: chooseAddressWidget ?? this.chooseAddressWidget,
        chooseCardWidget: chooseCardWidget ?? this.chooseCardWidget,
        orderSummaryWidget: orderSummaryWidget ?? this.orderSummaryWidget,
        orderConfirmedWidget: orderConfirmedWidget ?? this.orderConfirmedWidget,
        hotelDestinationWidget: hotelDestinationWidget ?? this.hotelDestinationWidget,
        carPickupPlacesWidget: carPickupPlacesWidget ?? this.carPickupPlacesWidget,
        carDropoffPlacesWidget: carDropoffPlacesWidget ?? this.carDropoffPlacesWidget,
        carRentalsSearchWidget: carRentalsSearchWidget ?? this.carRentalsSearchWidget,
        hotelsWidget: hotelsWidget ?? this.hotelsWidget,
        customerProfileDetailsWidget: customerProfileDetailsWidget ?? this.customerProfileDetailsWidget,
        hotelOrderSummaryWidget: hotelOrderSummaryWidget ?? this.hotelOrderSummaryWidget,
        carOrderSummaryWidget: carOrderSummaryWidget ?? this.carOrderSummaryWidget,
        hotelBookingConfirmedWidget: hotelBookingConfirmedWidget ?? this.hotelBookingConfirmedWidget,
    );
  }
}