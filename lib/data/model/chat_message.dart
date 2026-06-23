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
  final bool hasFlightOriginPlacesSectionWidget;
  final bool hasFlightDestinationPlacesSectionWidget;
  final bool hasCarRentalsSearchSectionWidget;
  final bool hasFlightsSearchSectionWidget;
  final bool hasHotelsSectionWidget;
  final bool hasCustomerProfileDetailsSectionWidget;
  final bool hasHotelOrderSummarySectionWidget;
  final bool hasCarOrderSummarySectionWidget;
  final bool hasFlightOrderSummarySectionWidget;
  final bool hasHotelBookingConfirmedSectionWidget;
  final bool hasCarBookingConfirmedSectionWidget;
  final bool hasFlightBookingConfirmedSectionWidget;
  final bool hasPackageTypesSectionWidget;
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
  final List<CarPickupPlace> flightOriginPlacesItems;
  final List<CarPickupPlace> flightDestinationPlacesItems;
  final List<CarRentalSearch> carRentalsSearchItems;
  final List<FlightSearch> flightsSearchItems;
  final List<HotelDestination> customerProfileDetailsItems;
  final List<HotelProperty> hotelsItems;
  final List<HotelOrderSummary> hotelOrderSummaryItems;
  final List<CarOrderSummary> carOrderSummaryItems;
  final List<FlightOrderSummary> flightOrderSummaryItems;
  final List<WidgetAction> hotelBookingConfirmedItems;
  final List<WidgetAction> carBookingConfirmedItems;
  final List<WidgetAction> flightBookingConfirmedItems;
  final List<SendPackageType> packageTypesItems;
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
  final ChatWidget? flightOriginPlacesWidget;
  final ChatWidget? flightDestinationPlacesWidget;
  final ChatWidget? carRentalsSearchWidget;
  final ChatWidget? flightsSearchWidget;
  final ChatWidget? hotelsWidget;
  final ChatWidget? customerProfileDetailsWidget;
  final ChatWidget? hotelOrderSummaryWidget;
  final ChatWidget? carOrderSummaryWidget;
  final ChatWidget? flightOrderSummaryWidget;
  final ChatWidget? hotelBookingConfirmedWidget;
  final ChatWidget? carBookingConfirmedWidget;
  final ChatWidget? flightBookingConfirmedWidget;
  final ChatWidget? packageTypesWidget;
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
    this.hasFlightOriginPlacesSectionWidget = false,
    this.hasFlightDestinationPlacesSectionWidget = false,
    this.hasCarRentalsSearchSectionWidget = false,
    this.hasFlightsSearchSectionWidget = false,
    this.hasHotelsSectionWidget = false,
    this.hasCustomerProfileDetailsSectionWidget = false,
    this.hasHotelOrderSummarySectionWidget = false,
    this.hasCarOrderSummarySectionWidget = false,
    this.hasFlightOrderSummarySectionWidget = false,
    this.hasHotelBookingConfirmedSectionWidget = false,
    this.hasCarBookingConfirmedSectionWidget = false,
    this.hasFlightBookingConfirmedSectionWidget = false,
    this.hasPackageTypesSectionWidget = false,
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
    this.flightOriginPlacesItems = const [],
    this.flightDestinationPlacesItems = const [],
    this.carRentalsSearchItems = const [],
    this.flightsSearchItems = const [],
    this.customerProfileDetailsItems = const [],
    this.hotelsItems = const [],
    this.hotelOrderSummaryItems = const [],
    this.carOrderSummaryItems = const [],
    this.flightOrderSummaryItems = const [],
    this.hotelBookingConfirmedItems = const [],
    this.carBookingConfirmedItems = const [],
    this.flightBookingConfirmedItems = const [],
    this.packageTypesItems = const [],
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
    this.flightOriginPlacesWidget,
    this.flightDestinationPlacesWidget,
    this.carRentalsSearchWidget,
    this.flightsSearchWidget,
    this.customerProfileDetailsWidget,
    this.hotelsWidget,
    this.hotelOrderSummaryWidget,
    this.carOrderSummaryWidget,
    this.flightOrderSummaryWidget,
    this.hotelBookingConfirmedWidget,
    this.carBookingConfirmedWidget,
    this.flightBookingConfirmedWidget,
    this.packageTypesWidget,
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
    bool? hasFlightOriginPlacesSectionWidget,
    bool? hasFlightDestinationPlacesSectionWidget,
    bool? hasCarRentalsSearchSectionWidget,
    bool? hasFlightsSearchSectionWidget,
    bool? hasHotelsSectionWidget,
    bool? hasCustomerProfileDetailsSectionWidget,
    bool? hasHotelOrderSummarySectionWidget,
    bool? hasCarOrderSummarySectionWidget,
    bool? hasFlightOrderSummarySectionWidget,
    bool? hasHotelBookingConfirmedSectionWidget,
    bool? hasCarBookingConfirmedSectionWidget,
    bool? hasFlightBookingConfirmedSectionWidget,
    bool? hasPackageTypesSectionWidget,
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
    List<CarPickupPlace>? flightOriginPlacesItems,
    List<CarPickupPlace>? flightDestinationPlacesItems,
    List<CarRentalSearch>? carRentalsSearchItems,
    List<FlightSearch>? flightsSearchItems,
    List<HotelDestination>? customerProfileDetailsItems,
    List<HotelProperty>? hotelsItems,
    List<HotelOrderSummary>? hotelOrderSummaryItems,
    List<CarOrderSummary>? carOrderSummaryItems,
    List<FlightOrderSummary>? flightOrderSummaryItems,
    List<WidgetAction>? hotelBookingConfirmedItems,
    List<WidgetAction>? carBookingConfirmedItems,
    List<WidgetAction>? flightBookingConfirmedItems,
    List<SendPackageType>? packageTypesItems,
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
    ChatWidget? flightOriginPlacesWidget,
    ChatWidget? flightDestinationPlacesWidget,
    ChatWidget? carRentalsSearchWidget,
    ChatWidget? flightsSearchWidget,
    ChatWidget? hotelsWidget,
    ChatWidget? customerProfileDetailsWidget,
    ChatWidget? hotelOrderSummaryWidget,
    ChatWidget? carOrderSummaryWidget,
    ChatWidget? flightOrderSummaryWidget,
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
      hasFlightOriginPlacesSectionWidget: hasFlightOriginPlacesSectionWidget ?? this.hasFlightOriginPlacesSectionWidget,
      hasFlightDestinationPlacesSectionWidget: hasFlightDestinationPlacesSectionWidget ?? this.hasFlightDestinationPlacesSectionWidget,
      hasCarRentalsSearchSectionWidget: hasCarRentalsSearchSectionWidget ?? this.hasCarRentalsSearchSectionWidget,
      hasFlightsSearchSectionWidget: hasFlightsSearchSectionWidget ?? this.hasFlightsSearchSectionWidget,
      hasHotelsSectionWidget: hasHotelsSectionWidget ?? this.hasHotelsSectionWidget,
      hasCustomerProfileDetailsSectionWidget: hasCustomerProfileDetailsSectionWidget ?? this.hasCustomerProfileDetailsSectionWidget,
      hasHotelOrderSummarySectionWidget: hasHotelOrderSummarySectionWidget ?? this.hasHotelOrderSummarySectionWidget,
      hasCarOrderSummarySectionWidget: hasCarOrderSummarySectionWidget ?? this.hasCarOrderSummarySectionWidget,
      hasFlightOrderSummarySectionWidget: hasFlightOrderSummarySectionWidget ?? this.hasFlightOrderSummarySectionWidget,
      hasHotelBookingConfirmedSectionWidget: hasHotelBookingConfirmedSectionWidget ?? this.hasHotelBookingConfirmedSectionWidget,
      hasCarBookingConfirmedSectionWidget: hasCarBookingConfirmedSectionWidget ?? this.hasCarBookingConfirmedSectionWidget,
      hasFlightBookingConfirmedSectionWidget: hasFlightBookingConfirmedSectionWidget ?? this.hasFlightBookingConfirmedSectionWidget,
      hasPackageTypesSectionWidget: hasPackageTypesSectionWidget ?? this.hasPackageTypesSectionWidget,
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
      flightOriginPlacesItems: flightOriginPlacesItems ?? this.flightOriginPlacesItems,
      flightDestinationPlacesItems: flightDestinationPlacesItems ?? this.flightDestinationPlacesItems,
      carRentalsSearchItems: carRentalsSearchItems ?? this.carRentalsSearchItems,
      flightsSearchItems: flightsSearchItems ?? this.flightsSearchItems,
      customerProfileDetailsItems: customerProfileDetailsItems ?? this.customerProfileDetailsItems,
      hotelsItems: hotelsItems ?? this.hotelsItems,
      hotelOrderSummaryItems: hotelOrderSummaryItems ?? this.hotelOrderSummaryItems,
      carOrderSummaryItems: carOrderSummaryItems ?? this.carOrderSummaryItems,
      flightOrderSummaryItems: flightOrderSummaryItems ?? this.flightOrderSummaryItems,
      hotelBookingConfirmedItems: hotelBookingConfirmedItems ?? this.hotelBookingConfirmedItems,
      carBookingConfirmedItems: carBookingConfirmedItems ?? this.carBookingConfirmedItems,
      flightBookingConfirmedItems: flightBookingConfirmedItems ?? this.flightBookingConfirmedItems,
      packageTypesItems: packageTypesItems ?? this.packageTypesItems,
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
        flightOriginPlacesWidget: flightOriginPlacesWidget ?? this.flightOriginPlacesWidget,
        flightDestinationPlacesWidget: flightDestinationPlacesWidget ?? this.flightDestinationPlacesWidget,
        carRentalsSearchWidget: carRentalsSearchWidget ?? this.carRentalsSearchWidget,
        flightsSearchWidget: flightsSearchWidget ?? this.flightsSearchWidget,
        hotelsWidget: hotelsWidget ?? this.hotelsWidget,
        customerProfileDetailsWidget: customerProfileDetailsWidget ?? this.customerProfileDetailsWidget,
        hotelOrderSummaryWidget: hotelOrderSummaryWidget ?? this.hotelOrderSummaryWidget,
        carOrderSummaryWidget: carOrderSummaryWidget ?? this.carOrderSummaryWidget,
        flightOrderSummaryWidget: flightOrderSummaryWidget ?? this.flightOrderSummaryWidget,
        hotelBookingConfirmedWidget: hotelBookingConfirmedWidget ?? this.hotelBookingConfirmedWidget,
        carBookingConfirmedWidget: carBookingConfirmedWidget ?? this.carBookingConfirmedWidget,
        flightBookingConfirmedWidget: flightBookingConfirmedWidget ?? this.flightBookingConfirmedWidget,
        packageTypesWidget: packageTypesWidget ?? this.packageTypesWidget,
    );
  }
}