import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:chat_bot/widgets/chat_screen_body.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/services/services.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chatScreen';

  final MyGPTsResponse? chatbotData;
  final GreetingResponse? greetingData;
  final bool isFromHistory;
  final String? historySessionId;
  final String? chatHistoryTitle;
  const ChatScreen({super.key, this.chatbotData, this.greetingData, this.isFromHistory = false, this.historySessionId, this.chatHistoryTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  Set<String> _selectedOptionMessages = {};
  String? _pendingMessage;
  Map<String, dynamic> _apiData = {};
  List<ChatWidget> _latestActionWidgets = []; // Track latest action widgets
  int _totalCartCount = 0; // Track total cart count
  List<ChatMessage> messages = [];
  bool _needToEndThisChat = false; // Track if chat should be ended
  bool _gotStripePaymentCallback = false;
  late final CartBloc _cartBloc;
  final SpeechService _speechService = SpeechService();
  bool _isSpeechAvailable = false;
  bool _isRecording = false;

  // LaunchBloc related variables
  late final LaunchBloc _launchBloc;
  MyGPTsResponse? _chatbotData;
  GreetingResponse? _greetingData;

  @override
  void initState() {
    super.initState();

    if (widget.isFromHistory == true && widget.historySessionId != null) {
      _initializeHistoryMode();
    } else {
      _initializeNormalMode();
      _setupOrderServiceCallbacks();
      _setupPostInitializationTasks();
    }
  }

  /// Initializes the screen in history mode
  void _initializeHistoryMode() {
    print('ChatScreen: isFromHistory - ${widget.isFromHistory}');
    print('ChatScreen: historySessionId - ${widget.historySessionId}');
    
    // Don't initialize new session, just fetch history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(ChatHistorySessionIdEvent(sessionId: widget.historySessionId!));
    });
    
    _cartBloc = context.read<CartBloc>();
    _launchBloc = LaunchBloc();
    _cartBloc.add(CartFetchRequested(needToShowLoader: false));
  }

  /// Initializes the screen in normal mode
  void _initializeNormalMode() {
    // Initialize cartBloc directly since it's provided by parent MultiBlocProvider
    _cartBloc = context.read<CartBloc>();

    // Always initialize LaunchBloc to fetch chatbot data
    _launchBloc = LaunchBloc();

    // Check if data is already provided via parameters
    if (widget.chatbotData != null) {
      _chatbotData = widget.chatbotData;
      _greetingData = widget.greetingData;
    } else {
      // Fetch data using LaunchBloc
      _launchBloc.add(const LaunchRequested());
    }
    
    // Normal mode initialization
    _initializeSession(false);
  }

  /// Sets up all OrderService callbacks
  void _setupOrderServiceCallbacks() {
    OrderService().setSendMessageCallback((String message) {
      if (mounted && needToCallChatScreenSendMessageAPI) {
        print('ChatScreen: External message received - $message');
        _sendMessage(message);
      }
    });

    OrderService().setStripePaymentCallback((String cartNumber) {
      if (mounted) {
        print('ChatScreen: Stripe payment received - $cartNumber');
        _sendMessage('Card added successfully last 4 digits: ${cartNumber}');
      }
    });

    OrderService().setAddressSummaryCallback((String addressSummary) {
      if (mounted) {
        print('ChatScreen: Address summary received - $addressSummary');
        _sendMessage('I have added a new address.\n$addressSummary');
      }
    });

    OrderService().setSelectScheduleCallback((Map<String, dynamic> schedule) {
      if (mounted) {
        print('ChatScreen: Select schedule received - $schedule');
         _apiData = {
            ..._apiData,
            'serviceRequestedTime': schedule['serviceRequestedTime'],
          };
        _sendMessage('I have selected a schedule: \n${schedule['dateTimeStr']}', schedule['scheduleLaterStaffId'], schedule['serviceRequestedTime']);
      }
    });

    OrderService().setSelectStaffCallback((Map<String, dynamic> staff) {
      if (mounted) {
        print('ChatScreen: Select staff received - $staff');
         _apiData = {
            ..._apiData,
            'scheduleLaterStaffId': staff['scheduleLaterStaffId'],
          };
        _sendMessage('I have selected a staff member: ${staff['staffName']}', staff['scheduleLaterStaffId'], staff['serviceRequestedTime']);
      }
    });

    OrderService().setPrescriptionCallback((Map<String, dynamic> prescription) {
      if (mounted) {
        print('ChatScreen: Prescription screen received');
        print('ChatScreen: Prescription screen received - $prescription');
        _apiData = {
            ..._apiData,
            // 'prescription_image_urls': (prescription['imagesurls'] as List?)?.join(',') ?? '',
            'prescription_image_urls': prescription['imagesurls'] ?? '',
          };
        _sendMessage('I have uploaded the prescription. Please proceed with the order', null, null, null);
      }
    });

    OrderService().setStripePlaceOrderCallback((Map<String, dynamic> stripePlaceOrder) {
      if (mounted) {
        print('ChatScreen: Stripe place order received - $stripePlaceOrder');
        if (stripePlaceOrder['isPaymentSuccess'] == true) {
          _needToEndThisChat = true;
          _gotStripePaymentCallback = true;
          BlackToastView.show(context, 'Payment completed successfully');
           context.read<CartBloc>().add(
              CartFetchRequested(needToShowLoader: false),
            );
        }else if (stripePlaceOrder['isPaymentFailed'] == true) {
          _gotStripePaymentCallback = true;
          // BlackToastView.show(context, stripePlaceOrder['message']);
          _sendMessage(stripePlaceOrder['message'], null, null, null);
        }
        // _sendMessage('Order placed successfully', null, null, null);
      }
    });

    OrderService().setSelectClickManageCallback((
      Map<String, dynamic> clickManage,
    ) {
      if (mounted) {
        print('ChatScreen: Click manage received - $clickManage');
        if (clickManage['flow'] == 'HotelBooking') {
          if (clickManage['screenName'] == 'HotelBookingDates') {
            final checkinDate = Utility.formatHotelBookingDate(
              (clickManage['checkIn'] ?? '').toString(),
            );
            final checkoutDate = Utility.formatHotelBookingDate(
              (clickManage['checkOut'] ?? '').toString(),
            );
            final existing = _apiData['hotel_booking'];
            final Map<String, dynamic> hotelBooking;
            if (existing is Map) {
              hotelBooking = Map<String, dynamic>.from(existing);
              hotelBooking['checkinDate'] = checkinDate;
              hotelBooking['checkoutDate'] = checkoutDate;
            } else {
              hotelBooking = {
                'checkinDate': checkinDate,
                'checkoutDate': checkoutDate,
                'countryOfResidence': 'AE',
              };
            }
            _apiData = {..._apiData, 'hotel_booking': hotelBooking};
            _sendMessage(
              'I have selected the checkin and checkout dates: \n'
              '${Utility.formatHotelBookingDateForDisplay((clickManage['checkIn'] ?? '').toString())} '
              'to ${Utility.formatHotelBookingDateForDisplay((clickManage['checkOut'] ?? '').toString())}',
            );
          } else if (clickManage['screenName'] == 'HotelBookingGuests') {
            final existing = _apiData['hotel_booking'];
            final Map<String, dynamic> hotelBooking;
            if (existing is Map) {
              hotelBooking = Map<String, dynamic>.from(existing);
              hotelBooking['occupancy'] = clickManage['occupancy'];
            } else {
              hotelBooking = {
                'occupancy': clickManage['occupancy'],
                'countryOfResidence': 'AE',
              };
            }
            _apiData = {..._apiData, 'hotel_booking': hotelBooking};
            _sendMessage(
              'I have selected the number of guests:\n'
              '${Utility.formatHotelOccupancyForDisplay(clickManage['occupancy'])}',
            );
          }else if (clickManage['screenName'] == 'HotelBookingUserDetails') {
            final existing = _apiData['hotel_booking'];
            final Map<String, dynamic> hotelBooking;
            if (existing is Map) {
              hotelBooking = Map<String, dynamic>.from(existing);
              hotelBooking['hotel_booking'] = clickManage['hotel_booking'];
            }else {
              hotelBooking = {
                'hotel_booking': clickManage['hotel_booking'],
              };
            }
            _apiData = {..._apiData, 'hotel_booking': hotelBooking};
            _sendMessage(
              'I have added the customer details.',
            );
          }
        } else {
          _apiData = {
            ..._apiData,
            "dependent_id": clickManage['dependentId'] ?? '',
          };
          _sendMessage(
            'I have selected a dependent:\n${clickManage['firstName'] ?? ''} ${clickManage['lastName'] ?? ''}',
            null,
            null,
            null,
          );
        }
      }
    });
  }

  /// Sets up post-initialization tasks (keyboard listener, cart fetch, speech service)
  void _setupPostInitializationTasks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _messageFocusNode.addListener(_onFocusChange);
      // Fetch cart data after cartBloc is initialized
      _fetchCartData();
      Future.delayed(const Duration(seconds: 1), () {
        // Speech service is already initialized at app startup for ultra-fast response
        // Just check availability
        _initializeSpeechService();
      });
    });
  }

  void _initializeSession(bool needToShowLoader) {
    sessionId = "";
    StoreCategoryRegistry.clear();
    context.read<ChatBloc>().add(ChatSessionIdEvent(needToShowLoader: needToShowLoader));
  }

  // Returns index of the last bot message that shows stores, products, choose_address, choose_card, order_summary, or order_confirmed widgets; -1 if none
  // Cart widget is not considered for hiding
  int _indexOfLastBotCatalogMessage() {
    for (int i = messages.length - 1; i >= 0; i--) {
      final ChatMessage message = messages[i];
      if (message.isBot &&
          (message.hasStoreCards ||
              message.hasProductCards ||
              message.hasChooseAddressWidget ||
              message.hasChooseCardWidget ||
              message.hasOrderSummaryWidget ||
              message.hasOrderConfirmedWidget ||
              message.hasServicesDeliveryOptionsWidget ||
              message.hasHotelDestinationSectionWidget ||
              message.hasHotelsSectionWidget)) {
        return i;
      }
    }
    return -1;
  }

  // Produces a hidden version of catalog widgets for a message (non-destructive to data)
  // Only hides stores, products, and order confirmed, keeps cart widget visible
  ChatMessage _hideCatalogInMessage(ChatMessage message) {
    if (!(message.hasStoreCards ||
        message.hasProductCards ||
        message.hasChooseAddressWidget ||
        message.hasChooseCardWidget ||
        message.hasOrderSummaryWidget ||
        message.hasOrderConfirmedWidget ||
        message.hasServicesDeliveryOptionsWidget ||
        message.hasHotelDestinationSectionWidget ||
        message.hasHotelsSectionWidget))
      return message;
    return message.copyWith(
      hasStoreCards: false,
      hasProductCards: false,
      hasChooseAddressWidget: false,
      hasChooseCardWidget: false,
      hasOrderSummaryWidget: message.hasOrderSummaryWidget,
      hasOrderConfirmedWidget: false,
      // Keep cart widget visible
      hasCartWidget: message.hasCartWidget,
      hasServicesDeliveryOptionsWidget: false,
      hasHotelDestinationSectionWidget: false,
      hasHotelsSectionWidget: false,
    );
  }

  void _onFocusChange() {
    if (_messageFocusNode.hasFocus) {
      // Scroll to bottom when keyboard opens
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    }
  }

  void _sendMessage(String text, [String? scheduleLaterStaffId, String? serviceRequestedTime, String? storeCategoryId, Map<String, dynamic>? dict]) {
    if (text.trim().isEmpty) return;

    // Prepare: hide stores/products from the last bot message if present
    final int catalogIdx = _indexOfLastBotCatalogMessage();
    _hideStoreCards();

    setState(() {
      if (catalogIdx >= 0) {
        messages[catalogIdx] = _hideCatalogInMessage(messages[catalogIdx]);
      }
      messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isBot: false,
        ),
      );
      _pendingMessage = text;
      if (serviceRequestedTime != null) {
        _apiData = {
            ..._apiData,
            'serviceRequestedTime': serviceRequestedTime,
          };
      }else {
        _apiData = {
          ..._apiData,
          ...dict ?? {},
          'storeCategoryId': storeCategoryId,
        };
      }

      print('CHINTU: _apiData: $_apiData');
    });

    _messageController.clear();
    // Remove automatic focus request to prevent keyboard from opening when clicking options
    // _messageFocusNode.requestFocus();
    // _scrollToBottom();
  }

  void _clearPendingMessage() {
    setState(() {
      _pendingMessage = null;
      // _apiData = {};
    });
  }

  void _updateCartCount(int count) {
    setState(() {
      _totalCartCount = count;
    });
  }

  void _fetchCartData() {
    if (!mounted) return;

    _cartBloc.add(CartFetchRequested(needToShowLoader: false));
    // Cart count will be updated via the CartBloc listener
    print('Cart data fetch requested');

    // Also update cart count directly from cart bloc after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final directCount = _cartBloc.getTotalProductCount;
        print('Direct cart count after fetch: $directCount');
        _updateCartCount(directCount);
      }
    });
  }

  void _handleChatHistoryResponse(List<ChatHistoryDetail> historyList) {
    List<ChatMessage> historyMessages = [];
    
    for (var historyDetail in historyList) {
      // Add user message
      historyMessages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_user',
          text: historyDetail.userMessage,
          isBot: false,
        ),
      );
      
      // Add bot responses
      for (var botResponse in historyDetail.response) {
        // Extract widgets similar to _handleChatResponse
        ChatWidget? storesWidget;
        ChatWidget? productsWidget;
        ChatWidget? cartWidget;
        ChatWidget? restaurantSectionsWidget;
        ChatWidget? servicesDeliveryOptionsWidget;
        ChatWidget? chooseAddressWidget;
        ChatWidget? chooseCardWidget;
        ChatWidget? orderSummaryWidget;
        ChatWidget? orderConfirmedWidget;
        ChatWidget? hotelDestinationWidget;
        ChatWidget? hotelsWidget;
        ChatWidget? customerProfileDetailsWidget;
        ChatWidget? hotelOrderSummaryWidget;
        ChatWidget? hotelBookingConfirmedWidget;
        try {
          storesWidget = botResponse.widgets.firstWhere(
            (widget) => widget.isStoresWidget,
          );
        } catch (e) {
          storesWidget = null;
        }

        try {
          productsWidget = botResponse.widgets.firstWhere(
            (widget) => widget.isProductsWidget,
          );
        } catch (e) {
          productsWidget = null;
        }

        try {
          cartWidget = botResponse.widgets.firstWhere((widget) => widget.isCartWidget);
        } catch (e) {
          cartWidget = null;
        }

        try {
          restaurantSectionsWidget = botResponse.widgets.firstWhere((widget) => widget.isRestaurantSectionsWidget);
        } catch (e) {
          restaurantSectionsWidget = null;
        }

        try {
          hotelDestinationWidget = botResponse.widgets.firstWhere((widget) => widget.isHotelDestinationWidget);
        } catch (e) {
          hotelDestinationWidget = null;
        }

        try {
          customerProfileDetailsWidget = botResponse.widgets.firstWhere((widget) => widget.isCustomerProfileDetailsWidget);
        } catch (e) {
          customerProfileDetailsWidget = null;
        }

        try {
          hotelOrderSummaryWidget = botResponse.widgets.firstWhere((widget) => widget.isHotelOrderSummaryWidget);
        } catch (e) {
          hotelOrderSummaryWidget = null;
        }

        try {
          hotelBookingConfirmedWidget = botResponse.widgets.firstWhere((widget) => widget.isHotelBookingConfirmedWidget);
        } catch (e) {
          hotelBookingConfirmedWidget = null;
        }

        try {
          hotelsWidget = botResponse.widgets.firstWhere((widget) => widget.isHotelsWidget);
        } catch (e) {
          hotelsWidget = null;
        }

        try {
          servicesDeliveryOptionsWidget = botResponse.widgets.firstWhere((widget) => widget.isServicesDeliveryOptionsWidget);
        } catch (e) {
          servicesDeliveryOptionsWidget = null;
        }

        try {
          chooseAddressWidget = botResponse.widgets.firstWhere(
            (widget) => widget.isChooseAddressWidget,
          );
        } catch (e) {
          chooseAddressWidget = null;
        }

        try {
          chooseCardWidget = botResponse.widgets.firstWhere(
            (widget) => widget.isChooseCardWidget,
          );
        } catch (e) {
          chooseCardWidget = null;
        }

        try {
          orderSummaryWidget = botResponse.widgets.firstWhere(
            (widget) => widget.isOrderSummaryWidget,
          );
        } catch (e) {
          orderSummaryWidget = null;
        }

        try {
          orderConfirmedWidget = botResponse.widgets.firstWhere(
            (widget) => widget.isOrderConfirmedWidget,
          );
        } catch (e) {
          orderConfirmedWidget = null;
        }

        // Check if stores, products, cart, etc. are present
        bool hasStores = storesWidget != null;
        bool hasProducts = productsWidget != null;
        bool hasCart = cartWidget != null;
        bool hasRestaurantSections = restaurantSectionsWidget != null;
        bool hasHotelDestinationSection = hotelDestinationWidget != null;
        bool hasCustomerProfileDetailsSection = customerProfileDetailsWidget != null;
        bool hasHotelOrderSummarySection = hotelOrderSummaryWidget != null;
        bool hasHotelBookingConfirmedSection = hotelBookingConfirmedWidget != null;
        bool hasHotelsSection = hotelsWidget != null;
        bool hasServicesDeliveryOptions = servicesDeliveryOptionsWidget != null;
        bool hasChooseAddress = chooseAddressWidget != null;
        bool hasChooseCard = chooseCardWidget != null;
        bool hasOrderSummary = orderSummaryWidget != null;
        bool hasOrderConfirmed = orderConfirmedWidget != null;

        historyMessages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_bot',
            text: botResponse.text,
            isBot: true,
            showAvatar: true,
            hasStoreCards: hasStores,
            hasProductCards: hasProducts,
            hasCartWidget: hasCart,
            hasRestaurantSectionsWidget: hasRestaurantSections,
            hasHotelDestinationSectionWidget: hasHotelDestinationSection,
            hasHotelsSectionWidget: hasHotelsSection,
            hasCustomerProfileDetailsSectionWidget: hasCustomerProfileDetailsSection,
            hasHotelOrderSummarySectionWidget: hasHotelOrderSummarySection,
            hasHotelBookingConfirmedSectionWidget: hasHotelBookingConfirmedSection,
            hasServicesDeliveryOptionsWidget: hasServicesDeliveryOptions,
            hasChooseAddressWidget: hasChooseAddress,
            hasChooseCardWidget: hasChooseCard,
            hasOrderSummaryWidget: hasOrderSummary,
            hasOrderConfirmedWidget: hasOrderConfirmed,
            // Don't show option buttons if stores, products, cart, etc. are present
            hasOptionButtons:
                !hasStores &&
                !hasProducts &&
                !hasCart &&
                !hasChooseAddress &&
                !hasChooseCard &&
                !hasOrderSummary &&
                !hasOrderConfirmed &&
                botResponse.hasWidgets &&
                botResponse.optionsWidgets.isNotEmpty,
            optionButtons:
                !hasStores &&
                        !hasProducts &&
                        !hasCart &&
                        !hasRestaurantSections &&
                        !hasHotelDestinationSection &&
                        !hasCustomerProfileDetailsSection &&
                        !hasHotelsSection &&
                        !hasHotelOrderSummarySection &&
                        !hasHotelBookingConfirmedSection &&
                        !hasChooseAddress &&
                        !hasChooseCard &&
                        !hasOrderSummary &&
                        !hasOrderConfirmed &&
                        botResponse.hasWidgets &&
                        botResponse.optionsWidgets.isNotEmpty
                    ? botResponse.optionsWidgets.first.options
                    : [],
            stores: storesWidget?.stores ?? [],
            products: productsWidget?.products ?? [],
            cartItems: cartWidget?.getCartItems() ?? [],
            restaurantSectionsItems: restaurantSectionsWidget?.getRestaurantSectionsItems() ?? [],
            hotelDestinationItems: hotelDestinationWidget?.getHotelDestinationItems() ?? [],
            customerProfileDetailsItems: customerProfileDetailsWidget?.getCustomerProfileDetailsItems() ?? [],
            hotelsItems: hotelsWidget?.getHotelsItems() ?? [],
            hotelOrderSummaryItems: hotelOrderSummaryWidget?.getHotelOrderSummaryItems() ?? [],
            hotelBookingConfirmedItems: hotelBookingConfirmedWidget?.getHotelBookingConfirmedItems() ?? [],
            servicesDeliveryOptions: servicesDeliveryOptionsWidget?.getServicesDeliveryOptions() ?? [],
            addressOptions: chooseAddressWidget?.getAddressOptions() ?? [],
            cardOptions: chooseCardWidget?.getCardOptions() ?? [],
            orderSummaryItems: orderSummaryWidget?.getOrderSummaryItems() ?? [],
            storesWidget: storesWidget,
            productsWidget: productsWidget,
            cartWidget: cartWidget,
            chooseAddressWidget: chooseAddressWidget,
            chooseCardWidget: chooseCardWidget,
            orderSummaryWidget: orderSummaryWidget,
            orderConfirmedWidget: orderConfirmedWidget,
          ),
        );
        
        // Store action widgets for the action buttons (from the last bot response)
        if (historyDetail == historyList.last && botResponse == historyDetail.response.last) {
          _latestActionWidgets =
              botResponse.widgets
                  .where(
                    (widget) =>
                        // widget.type == WidgetEnum.see_more.value ||
                        // widget.type == WidgetEnum.menu.value ||
                        // widget.type == WidgetEnum.add_more.value ||
                        // widget.type == WidgetEnum.proceed_to_checkout.value ||
                        // widget.type == WidgetEnum.add_address.value ||
                        // widget.type == WidgetEnum.add_payment.value ||
                        // widget.type == WidgetEnum.cart.value ||
                        // widget.type == WidgetEnum.restaurant_sections.value ||
                        // widget.type == WidgetEnum.order_summary.value ||
                        // widget.type == WidgetEnum.choose_address.value ||
                        // widget.type == WidgetEnum.choose_card.value ||
                        // widget.type == WidgetEnum.cash_on_delivery.value ||
                        widget.type == WidgetEnum.order_tracking.value ||
                        widget.type == WidgetEnum.order_details.value,
                  )
                  .toList();
        }
      }
    }
    
    setState(() {
      messages.addAll(historyMessages);
    });
    // _scrollToBottom();
  }

  void _handleChatResponse(ChatResponse response) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    ChatWidget? storesWidget;
    ChatWidget? productsWidget;
    ChatWidget? cartWidget;
    ChatWidget? restaurantSectionsWidget;
    ChatWidget? servicesDeliveryOptionsWidget;
    ChatWidget? chooseAddressWidget;
    ChatWidget? chooseCardWidget;
    ChatWidget? orderSummaryWidget;
    ChatWidget? orderConfirmedWidget;
    ChatWidget? hotelDestinationWidget;
    ChatWidget? hotelsWidget;
    ChatWidget? customerProfileDetailsWidget;
    ChatWidget? hotelOrderSummaryWidget;
    ChatWidget? hotelBookingConfirmedWidget;
    // Capture needToEndThisChat from API response
    _needToEndThisChat = response.needToEndThisChat;
    try {
      storesWidget = response.widgets.firstWhere(
        (widget) => widget.isStoresWidget,
      );
    } catch (e) {
      storesWidget = null;
    }

    try {
      productsWidget = response.widgets.firstWhere(
        (widget) => widget.isProductsWidget,
      );
    } catch (e) {
      productsWidget = null;
    }

    try {
      cartWidget = response.widgets.firstWhere((widget) => widget.isCartWidget);
    } catch (e) {
      cartWidget = null;
    }

    try {
      restaurantSectionsWidget = response.widgets.firstWhere((widget) => widget.isRestaurantSectionsWidget);
    } catch (e) {
      restaurantSectionsWidget = null;
    }

    try {
      hotelDestinationWidget = response.widgets.firstWhere((widget) => widget.isHotelDestinationWidget);
    } catch (e) {
      hotelDestinationWidget = null;
    }

    try {
      customerProfileDetailsWidget = response.widgets.firstWhere((widget) => widget.isCustomerProfileDetailsWidget);
    } catch (e) {
      customerProfileDetailsWidget = null;
    }

    try {
      hotelOrderSummaryWidget = response.widgets.firstWhere((widget) => widget.isHotelOrderSummaryWidget);
    } catch (e) {
      hotelOrderSummaryWidget = null;
    }

    try {
      hotelBookingConfirmedWidget = response.widgets.firstWhere((widget) => widget.isHotelBookingConfirmedWidget);
    } catch (e) {
      hotelBookingConfirmedWidget = null;
    }

    try {
      hotelsWidget = response.widgets.firstWhere((widget) => widget.isHotelsWidget);
    } catch (e) {
      hotelsWidget = null;
    }

     try {
      servicesDeliveryOptionsWidget = response.widgets.firstWhere((widget) => widget.isServicesDeliveryOptionsWidget);
    } catch (e) {
      servicesDeliveryOptionsWidget = null;
    }

    try {
      chooseAddressWidget = response.widgets.firstWhere(
        (widget) => widget.isChooseAddressWidget,
      );
    } catch (e) {
      chooseAddressWidget = null;
    }

    try {
      chooseCardWidget = response.widgets.firstWhere(
        (widget) => widget.isChooseCardWidget,
      );
    } catch (e) {
      chooseCardWidget = null;
    }

    try {
      orderSummaryWidget = response.widgets.firstWhere(
        (widget) => widget.isOrderSummaryWidget,
      );
    } catch (e) {
      orderSummaryWidget = null;
    }

    try {
      orderConfirmedWidget = response.widgets.firstWhere(
        (widget) => widget.isOrderConfirmedWidget,
      );
    } catch (e) {
      orderConfirmedWidget = null;
    }

    // Check if stores, products, cart, choose_address, choose_card, order_summary, or order_confirmed are present
    bool hasStores = storesWidget != null;
    bool hasProducts = productsWidget != null;
    bool hasCart = cartWidget != null;
    bool hasRestaurantSections = restaurantSectionsWidget != null;
    bool hasServicesDeliveryOptions = servicesDeliveryOptionsWidget != null;
    bool hasChooseAddress = chooseAddressWidget != null;
    bool hasChooseCard = chooseCardWidget != null;
    bool hasOrderSummary = orderSummaryWidget != null;
    bool hasOrderConfirmed = orderConfirmedWidget != null;
    bool hasHotelDestinationSections = hotelDestinationWidget != null;
    bool hasHotelsSection = hotelsWidget != null;
    bool hasCustomerProfileDetailsSection = customerProfileDetailsWidget != null;
    bool hasHotelOrderSummarySection = hotelOrderSummaryWidget != null;
    bool hasHotelBookingConfirmedSection = hotelBookingConfirmedWidget != null;
    setState(() {
      messages.add(
        ChatMessage(
          id: messageId,
          text: response.text,
          isBot: true,
          showAvatar: true,
          hasStoreCards: hasStores,
          hasProductCards: hasProducts,
          hasCartWidget: hasCart,
          hasRestaurantSectionsWidget: hasRestaurantSections,
          hasHotelDestinationSectionWidget: hasHotelDestinationSections,
          hasCustomerProfileDetailsSectionWidget: hasCustomerProfileDetailsSection,
          hasHotelOrderSummarySectionWidget: hasHotelOrderSummarySection,
          hasHotelBookingConfirmedSectionWidget: hasHotelBookingConfirmedSection,
          hasHotelsSectionWidget: hasHotelsSection,
          hasServicesDeliveryOptionsWidget: hasServicesDeliveryOptions,
          hasChooseAddressWidget: hasChooseAddress,
          hasChooseCardWidget: hasChooseCard,
          hasOrderSummaryWidget: hasOrderSummary,
          hasOrderConfirmedWidget: hasOrderConfirmed,
          // Don't show option buttons if stores, products, cart, choose_address, choose_card, order_summary, or order_confirmed are present
          hasOptionButtons:
              !hasStores &&
              !hasProducts &&
              !hasCart &&
              !hasRestaurantSections &&
              !hasHotelDestinationSections &&
              !hasCustomerProfileDetailsSection &&
              !hasHotelsSection &&
              !hasHotelOrderSummarySection &&
              !hasHotelBookingConfirmedSection &&
              !hasServicesDeliveryOptions &&
              !hasChooseAddress &&
              !hasChooseCard &&
              !hasOrderSummary &&
              !hasOrderConfirmed &&
              response.hasWidgets &&
              response.optionsWidgets.isNotEmpty,
          optionButtons:
              !hasStores &&
                      !hasProducts &&
                      !hasCart &&
                      !hasRestaurantSections &&
                      !hasHotelDestinationSections &&
                      !hasCustomerProfileDetailsSection &&
                      !hasHotelsSection &&
                      !hasHotelOrderSummarySection &&
                      !hasHotelBookingConfirmedSection &&
                      !hasServicesDeliveryOptions &&
                      !hasChooseAddress &&
                      !hasChooseCard &&
                      !hasOrderSummary &&
                      !hasOrderConfirmed &&
                      response.hasWidgets &&
                      response.optionsWidgets.isNotEmpty
                  ? response.optionsWidgets.first.options
                  : [],
          stores: storesWidget?.stores ?? [],
          products: productsWidget?.products ?? [],
          cartItems: cartWidget?.getCartItems() ?? [],
          restaurantSectionsItems: restaurantSectionsWidget?.getRestaurantSectionsItems() ?? [],
          hotelDestinationItems: hotelDestinationWidget?.getHotelDestinationItems() ?? [],
          customerProfileDetailsItems: customerProfileDetailsWidget?.getCustomerProfileDetailsItems() ?? [],
          hotelsItems: hotelsWidget?.getHotelsItems() ?? [],
          hotelOrderSummaryItems: hotelOrderSummaryWidget?.getHotelOrderSummaryItems() ?? [],
          hotelBookingConfirmedItems: hotelBookingConfirmedWidget?.getHotelBookingConfirmedItems() ?? [],
          servicesDeliveryOptions: servicesDeliveryOptionsWidget?.getServicesDeliveryOptions() ?? [],
          addressOptions: chooseAddressWidget?.getAddressOptions() ?? [],
          cardOptions: chooseCardWidget?.getCardOptions() ?? [],
          orderSummaryItems: orderSummaryWidget?.getOrderSummaryItems() ?? [],
          storesWidget: storesWidget,
          productsWidget: productsWidget,
          cartWidget: cartWidget,
          restaurantSectionsWidget: restaurantSectionsWidget,
          hotelDestinationWidget: hotelDestinationWidget,
          customerProfileDetailsWidget: customerProfileDetailsWidget,
          hotelsWidget: hotelsWidget,
          hotelOrderSummaryWidget: hotelOrderSummaryWidget,
          hotelBookingConfirmedWidget: hotelBookingConfirmedWidget,
          servicesDeliveryOptionsWidget: servicesDeliveryOptionsWidget,
          chooseAddressWidget: chooseAddressWidget,
          chooseCardWidget: chooseCardWidget,
          orderSummaryWidget: orderSummaryWidget,
          orderConfirmedWidget: orderConfirmedWidget,
        ),
      );

      // Store action widgets for the action buttons
      _latestActionWidgets =
          response.widgets
              .where(
                (widget) =>
                    widget.type == WidgetEnum.see_more.value ||
                    widget.type == WidgetEnum.menu.value ||
                    widget.type == WidgetEnum.add_more.value ||
                    widget.type == WidgetEnum.proceed_to_checkout.value ||
                    widget.type == WidgetEnum.add_address.value ||
                    widget.type == WidgetEnum.add_payment.value ||
                    widget.type == WidgetEnum.cart.value ||
                    widget.type == WidgetEnum.restaurant_sections.value ||
                    widget.type == WidgetEnum.hotel_booking_dates.value ||
                    widget.type == WidgetEnum.hotel_guests_rooms.value ||
                    widget.type == WidgetEnum.hotel_booking_for_me.value ||
                    widget.type == WidgetEnum.hotel_booking_for_other.value ||
                    widget.type == WidgetEnum.see_more_hotels.value ||
                    widget.type == WidgetEnum.hotel_confirm_booking.value ||
                    widget.type == WidgetEnum.see_available_rooms.value ||
                    widget.type == WidgetEnum.service_types.value ||
                    widget.type == WidgetEnum.order_summary.value ||
                    widget.type == WidgetEnum.choose_address.value ||
                    widget.type == WidgetEnum.choose_card.value ||
                    widget.type == WidgetEnum.cash_on_delivery.value ||
                    widget.type == WidgetEnum.order_tracking.value ||
                    widget.type == WidgetEnum.order_details.value ||
                    widget.type == WidgetEnum.schedule_later.value ||
                    widget.type == WidgetEnum.staff_selection.value ||
                    widget.type == WidgetEnum.prescription_screen.value ||
                    widget.type == WidgetEnum.online_payment_confirm_order.value ||
                    widget.type == WidgetEnum.add_dependent.value ||
                    widget.type == WidgetEnum.choose_date.value,
              )
              .toList();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Method to hide store cards when Add button is clicked
  void _hideStoreCards() {
    setState(() {
      // Find the last bot message with store cards and hide them
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].isBot && messages[i].hasStoreCards) {
          messages[i] = messages[i].copyWith(hasStoreCards: false);
          break;
        }
      }
    });
  }

  Future<void> _initializeSpeechService() async {
    // Start initialization in background - don't block UI
    try {
      _isSpeechAvailable = await _speechService.initialize();
      // if (!_isSpeechAvailable) {
      //   debugPrint('Speech recognition not available');
      // } else {
        debugPrint('Speech service initialized successfully');
        
        // Set up real-time text update callback
        _speechService.setOnTextUpdateCallback((String recognizedText) {
          if (mounted) {
            setState(() {
              print("recognizedText: $_isRecording");
              _messageController.text = recognizedText;
              if (_isRecording == false && recognizedText.isNotEmpty) {
                _messageController.clear();
              }
            });
          }
        });
      // }
    } catch (e) {
      debugPrint('Failed to initialize speech service: $e');
      _isSpeechAvailable = false;
    }
  }

  Future<void> _startSpeechRecording() async {
    if (_isRecording) {
      return;
    }

    // Haptic feedback for stop
    HapticFeedback.lightImpact();

    // IMMEDIATE response - no async operations blocking UI
    setState(() {
      _isRecording = true;
      _messageController.clear(); // Clear text field when starting recording
    });

    // Ultra-fast start - fire and forget approach
    final bool started = _speechService.startListening();
    if (!started) {
      // If fast start failed, reset the UI state
      setState(() {
        _isRecording = false;
      });

      // Update availability status
      _isSpeechAvailable = _speechService.isAvailable;

      // Show user feedback if service is not available
      if (!_isSpeechAvailable) {
        BlackToastView.show(context, 'Speech recognition is not available');
      }
    }
  }

  Future<void> _stopSpeechRecording() async {
    if (!_isRecording) {
      return;
    }

    // Haptic feedback for stop
    HapticFeedback.lightImpact();

    try {
      await _speechService.stopListening();

      setState(() {
        _isRecording = false;
      });

      final String recognizedText = _speechService.currentRecognizedText;

      if (recognizedText.trim().isEmpty) {
        BlackToastView.show(context, 'No speech detected. Please try again.');
      }
      // Text is already set in real-time via callback, no need to set it again here
    } catch (e) {
      debugPrint('Failed to stop speech recording: $e');
      setState(() {
        _isRecording = false;
      });
      BlackToastView.show(context, 'Recording failed. Please try again.');
    }
  }

  Future<void> _cancelSpeechRecording() async {
    if (!_isRecording) {
      return;
    }

    // Haptic feedback for cancel
    HapticFeedback.lightImpact();

    try {
      await _speechService.cancel();

      setState(() {
        _isRecording = false;
         _messageController.clear(); // Clear text field when starting recording
      });
    } catch (e) {
      debugPrint('Failed to cancel speech recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _restartChatAPI() async {
    setState(() {
      _needToEndThisChat = false;
      messages = [];

      _selectedOptionMessages.clear();
      _initializeSession(true);
      _pendingMessage = null;
      _apiData = {};
      _latestActionWidgets.clear(); // Clear action widgets when restarting
      _cartBloc.add(CartFetchRequested(needToShowLoader: false));
    });
  }

  Future<void> _restartGreetingAPI() async {
    setState(() {
      _greetingData = null;
    });
    _launchBloc.add(const LaunchRequested());
  }

  void _onLaunchState(BuildContext context, LaunchState state) {
    if (state is LaunchSuccess) {
      setState(() {
        _chatbotData = state.chatbotData;
        _greetingData = state.greetingData;
      });
    } else if (state is LaunchFailure) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Something went wrong please try again later',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  OrderService().triggerChatDismiss();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildChatScreenBody() {
    return ChatScreenBody(
      messageController: _messageController,
      messageFocusNode: _messageFocusNode,
      scrollController: _scrollController,
      chatbotData: _chatbotData,
      greetingData: _greetingData,
      selectedOptionMessages: _selectedOptionMessages,
      messages: messages,
      onSendMessage: _sendMessage,
      onHandleChatResponse: _handleChatResponse,
      onHandleChatHistoryResponse: _handleChatHistoryResponse,
      onScrollToBottom: _scrollToBottom,
      onLoadChatbotData: () {},
      onRestartChatAPI: _restartChatAPI,
      onRestartGreetingAPI: _restartGreetingAPI,
      onUpdateSelectedOptions: (Set<String> newSet) {
        setState(() {
          _selectedOptionMessages = newSet;
        });
      },
      onUpdateMessages: (List<ChatMessage> newMessages) {
        setState(() {
          messages = newMessages;
        });
      },
      pendingMessage: _pendingMessage,
      apiData: _apiData,
      onClearPendingMessage: _clearPendingMessage,
      sessionId: sessionId,
      latestActionWidgets: _latestActionWidgets,
      onHideStoreCards: _hideStoreCards,
      onUpdateCartCount: _updateCartCount,
      totalCartCount: _totalCartCount,
      cartBloc: _cartBloc,
      onStartSpeechRecording: _startSpeechRecording,
      onStopSpeechRecording: _stopSpeechRecording,
      onCancelSpeechRecording: _cancelSpeechRecording,
      isRecording: _isRecording,
      needToEndThisChat: _needToEndThisChat,
      gotStripePaymentCallback: _gotStripePaymentCallback,
      onUpdateGotStripePaymentCallback: (bool value) {
        if (_gotStripePaymentCallback == true) {
          Timer(Duration(seconds: 2), () {
            _gotStripePaymentCallback = value;
          });
        }
      },
      isFromHistory: widget.isFromHistory,
      chatHistoryTitle: widget.chatHistoryTitle,
    );
  }

  @override
  void dispose() {
    if (widget.isFromHistory == false) {
      _messageFocusNode.removeListener(_onFocusChange);
      _messageController.dispose();
      _scrollController.dispose();
      _messageFocusNode.dispose();
      _launchBloc.close();
      
      // Clear speech service callback
      _speechService.clearOnTextUpdateCallback();
    }

    // OrderService().clearCallback();
    print("DISPOSE");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFromHistory) {
      return _buildChatScreenBody();
    }

    return BlocProvider.value(
      value: _launchBloc,
      child: BlocListener<LaunchBloc, LaunchState>(
        listener: _onLaunchState,
        child: _buildChatScreenBody(),
      ),
    );
  }
}
// // TODO: Get userId from ChatApiServices.instance.userId or UserPreferences.getUserId()
//   // TODO: Get storeCategoryId from the store or action data
//   SelectTimeScreen.show(
//     context,
//     userId: '66a26937fc6559000d18a6a2', // TODO: Replace with actual userId
//     storeCategoryId: '6507f939c2630000b000458d', // TODO: Replace with actual storeCategoryId
//     onConfirm: (selectedDate, selectedTimeSlot) {
//       // Handle confirmation
//       print('Selected date: $selectedDate, time: $selectedTimeSlot');
//     },
//   );