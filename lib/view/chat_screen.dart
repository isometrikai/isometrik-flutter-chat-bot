import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/cart/cart_event.dart';
import 'package:chat_bot/bloc/cart/cart_state.dart';
import 'package:chat_bot/bloc/launch/launch_bloc.dart';
import 'package:chat_bot/bloc/launch/launch_event.dart';
import 'package:chat_bot/bloc/launch/launch_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/chat_message.dart';
import 'package:chat_bot/data/services/chat_api_services.dart';
import 'package:chat_bot/view/Groceries_menu_screen.dart';
import 'package:chat_bot/view/chat_history_screen.dart';
import 'package:chat_bot/view/popup_overlay_screen.dart';
import 'package:chat_bot/view/customization_summary_screen.dart';
import 'package:chat_bot/view/grocery_customization_screen.dart';
import 'package:chat_bot/view/product_customization_screen.dart';
import 'package:chat_bot/view/restaurant_menu_screen.dart';
import 'package:chat_bot/view/restaurant_screen.dart';
import 'package:chat_bot/view/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:chat_bot/utils/asset_path.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import '../services/callback_manage.dart';
import 'package:chat_bot/widgets/store_card.dart';
import 'package:flutter/services.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/widgets/menu_item_card.dart';
import 'package:chat_bot/utils/text_styles.dart';
import 'package:chat_bot/widgets/cart_widget.dart';
import 'package:chat_bot/widgets/choose_address_widget.dart';
import 'package:chat_bot/widgets/choose_card_widget.dart';
import 'package:chat_bot/widgets/order_summary_widget.dart';
import 'package:chat_bot/widgets/order_confirmed_widget.dart';
import '../utils/enum.dart';
import '../services/speech_service.dart';

class ChatScreen extends StatefulWidget {
  final MyGPTsResponse? chatbotData;
  final GreetingResponse? greetingData;

  const ChatScreen({super.key, this.chatbotData, this.greetingData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  Set<String> _selectedOptionMessages = {};
  String? _pendingMessage;
  String _sessionId = "";
  double _textFieldHeight = 50.0; // Add height state variable
  List<ChatWidget> _latestActionWidgets = []; // Track latest action widgets
  int _totalCartCount = 0; // Track total cart count
  List<ChatMessage> messages = [];

  late final CartBloc _cartBloc;
  final SpeechService _speechService = SpeechService();
  bool _isSpeechAvailable = false;
  bool _isRecording = false;

  // LaunchBloc related variables
  late final LaunchBloc _launchBloc;
  MyGPTsResponse? _chatbotData;
  GreetingResponse? _greetingData;
  bool _isDataLoaded = false;
  

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
              message.hasOrderConfirmedWidget)) {
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
        message.hasOrderConfirmedWidget))
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

  void _sendMessage(String text) {
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
      _textFieldHeight = 50.0; // Reset to default height when sending message
    });

    _messageController.clear();
    // Remove automatic focus request to prevent keyboard from opening when clicking options
    // _messageFocusNode.requestFocus();
    // _scrollToBottom();
  }

  void _clearPendingMessage() {
    setState(() {
      _pendingMessage = null;
    });
  }

  void _updateTextFieldHeight(double newHeight) {
    setState(() {
      _textFieldHeight = newHeight;
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

  void _handleChatResponse(ChatResponse response) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    ChatWidget? storesWidget;
    ChatWidget? productsWidget;
    ChatWidget? cartWidget;
    ChatWidget? chooseAddressWidget;
    ChatWidget? chooseCardWidget;
    ChatWidget? orderSummaryWidget;
    ChatWidget? orderConfirmedWidget;
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
    bool hasChooseAddress = chooseAddressWidget != null;
    bool hasChooseCard = chooseCardWidget != null;
    bool hasOrderSummary = orderSummaryWidget != null;
    bool hasOrderConfirmed = orderConfirmedWidget != null;

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
          hasChooseAddressWidget: hasChooseAddress,
          hasChooseCardWidget: hasChooseCard,
          hasOrderSummaryWidget: hasOrderSummary,
          hasOrderConfirmedWidget: hasOrderConfirmed,
          // Don't show option buttons if stores, products, cart, choose_address, choose_card, order_summary, or order_confirmed are present
          hasOptionButtons:
              !hasStores &&
              !hasProducts &&
              !hasCart &&
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
                    widget.type == WidgetEnum.order_summary.value ||
                    widget.type == WidgetEnum.choose_address.value ||
                    widget.type == WidgetEnum.choose_card.value ||
                    widget.type == WidgetEnum.cash_on_delivery.value ||
                    widget.type == WidgetEnum.order_tracking.value ||
                    widget.type == WidgetEnum.order_details.value,
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

  @override
  void initState() {
    super.initState();
    _initializeSession();

    // Initialize LaunchBloc
    _launchBloc = LaunchBloc();

    // Check if data is already provided via parameters
    if (widget.chatbotData != null) {
      _chatbotData = widget.chatbotData;
      _greetingData = widget.greetingData;
      _isDataLoaded = true;
    } else {
      // Fetch data using LaunchBloc
      _launchBloc.add(const LaunchRequested());
    }

    // Initialize cartBloc directly since it's provided by parent MultiBlocProvider
    _cartBloc = context.read<CartBloc>();

    // Set up cart update callback - the mounted check handles if screen is active
    // OrderService().setCartUpdateCallback((bool isCartUpdate) {
    //   print(
    //     'ChatScreen: Cart update received 0 - $isCartUpdate, mounted: $mounted',
    //   );
    //   if (mounted && isCartUpdate) {
    //     print('ChatScreen: Cart update received - $isCartUpdate');
    //     Future.delayed(const Duration(seconds: 1), () {
    //       _sendMessage("I have updated the cart");
    //     });
    //   }
    // });
    OrderService().setSendMessageCallback((String message) {// CHANGE CALLBACK
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

    // Add keyboard listener
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

  void _initializeSession() {
    _sessionId = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
  }

  Future<void> _initializeSpeechService() async {
    // Start initialization in background - don't block UI
    try {
      _isSpeechAvailable = await _speechService.initialize();
      if (!_isSpeechAvailable) {
        debugPrint('Speech recognition not available');
      } else {
        debugPrint('Speech service initialized successfully');
      }
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

      if (recognizedText.trim().isNotEmpty) {
        // Set the recognized text to the text field
        _messageController.text = recognizedText.trim();
        // ADDED For Text Field Height
         final textSpan = TextSpan(
                                      text:
                                          _messageController.text.isEmpty
                                              ? 'How can zAIn help you today?'
                                              : _messageController.text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                        color: Color(0xFF242424),
                                      ),
                                    );
                                    final textPainter = TextPainter(
                                      text: textSpan,
                                      textDirection: TextDirection.ltr,
                                      maxLines: null,
                                    );
                                    textPainter.layout(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                          160,
                                    );

                                    final newHeight = (textPainter.height + 20)
                                        .clamp(50.0, 550.0);
                                    _updateTextFieldHeight(newHeight);
      } else {
        BlackToastView.show(context, 'No speech detected. Please try again.');
      }
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
      messages = [];

      _selectedOptionMessages.clear();
      _sessionId = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
      _pendingMessage = null;
      _latestActionWidgets.clear(); // Clear action widgets when restarting
      _cartBloc.add(CartFetchRequested(needToShowLoader: false));
    });
  }

  @override
  void dispose() {
    _messageFocusNode.removeListener(_onFocusChange);
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _launchBloc.close();

    // OrderService().clearCallback();
    print("DISPOSE");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If data is not loaded yet, show loading or handle LaunchBloc states
    if (!_isDataLoaded) {
      return BlocProvider.value(
        value: _launchBloc,
        child: BlocListener<LaunchBloc, LaunchState>(
          listener: (context, state) {
            if (state is LaunchSuccess) {
              setState(() {
                _chatbotData = state.chatbotData;
                _greetingData = state.greetingData;
                _isDataLoaded = true;
              });
            } else if (state is LaunchFailure) {
              // Handle error - show error dialog or retry
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error'),
                    content: const Text(
                      'Something went wrong please try again later',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          OrderService().triggerChatDismiss();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: BlocBuilder<LaunchBloc, LaunchState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(child: _buildShimmerGreetingOverlay(context)),
                ),
              );
            },
          ),
        ),
      );
    }

    // Data is loaded, show the chat screen
    return _ChatScreenBody(
      messageController: _messageController,
      messageFocusNode: _messageFocusNode,
      scrollController: _scrollController,
      chatbotData: _chatbotData!,
      greetingData: _greetingData,
      selectedOptionMessages: _selectedOptionMessages,
      messages: messages,
      onSendMessage: _sendMessage,
      onHandleChatResponse: _handleChatResponse,
      onScrollToBottom: _scrollToBottom,
      onLoadChatbotData: () {},
      onRestartChatAPI: _restartChatAPI,
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
      onClearPendingMessage: _clearPendingMessage,
      sessionId: _sessionId,
      // Pass session ID
      textFieldHeight: _textFieldHeight,
      onUpdateTextFieldHeight: _updateTextFieldHeight,
      latestActionWidgets: _latestActionWidgets,
      onHideStoreCards: _hideStoreCards,
      // Add the callback
      onUpdateCartCount: _updateCartCount,
      // Add the callback
      totalCartCount: _totalCartCount,
      // Pass the cart count
      cartBloc: _cartBloc,
      // Pass the cart bloc
      onStartSpeechRecording: _startSpeechRecording,
      // Add start speech handler
      onStopSpeechRecording: _stopSpeechRecording,
      // Add stop speech handler
      onCancelSpeechRecording: _cancelSpeechRecording,
      // Add cancel speech handler
      isRecording: _isRecording, // Pass recording state
    );
  }

  Widget _buildShimmerGreetingOverlay(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top graphic group with shimmer
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Outer glow circle
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(110),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x1AD445EC),
                            Color(0x1AB02EFB),
                            Color(0x1A8E2FFD),
                            Color(0x1A5E3DFE),
                            Color(0x1A5186E0),
                          ],
                        ),
                      ),
                    ),
                    // Center asset
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFD445EC),
                              Color(0xFFB02EFB),
                              Color(0xFF8E2FFD),
                              Color(0xFF5E3DFE),
                              Color(0xFF5186E0),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            AssetPath.get('images/ic_mainImg.svg'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Opacity(
                        opacity: 0.4,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_topStar.svg'),
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -10,
                      bottom: -8,
                      child: Opacity(
                        opacity: 0.4,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_topStar.svg'),
                          width: 61,
                          height: 61,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Title shimmer
              SizedBox(
                width: double.infinity,
                height: 60,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 280,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle shimmer
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 250,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Weather information shimmer
              Container(
                width: double.infinity,
                height: 130,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                // decoration: BoxDecoration(
                //   color: Colors.grey[300]!,
                //   borderRadius: BorderRadius.circular(12),
                //   border: Border.all(color: Colors.grey[300]!, width: 1),
                // ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Options grid shimmer 2x2
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  children: List.generate(3, (index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 70,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatScreenBody extends StatelessWidget {
  // static const platform = MethodChannel('chat_bot_channel');
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final ScrollController scrollController;
  final MyGPTsResponse chatbotData;
  final GreetingResponse? greetingData;
  final Set<String> selectedOptionMessages;
  final List<ChatMessage> messages;
  final Function(String) onSendMessage;
  final Function(ChatResponse) onHandleChatResponse;
  final VoidCallback onScrollToBottom;
  final VoidCallback onLoadChatbotData;
  final VoidCallback onRestartChatAPI;
  final Function(Set<String>) onUpdateSelectedOptions;
  final Function(List<ChatMessage>) onUpdateMessages;
  final String? pendingMessage;
  final VoidCallback onClearPendingMessage;
  final String sessionId;
  final double textFieldHeight;
  final Function(double) onUpdateTextFieldHeight;
  final List<ChatWidget> latestActionWidgets;
  final VoidCallback onHideStoreCards; // Add callback to hide store cards
  final Function(int) onUpdateCartCount; // Add callback to update cart count
  final int totalCartCount; // Add cart count parameter
  final CartBloc cartBloc; // Add cart bloc parameter
  final Future<void> Function()
  onStartSpeechRecording; // Add start speech handler
  final Future<void> Function()
  onStopSpeechRecording; // Add stop speech handler
  final Future<void> Function()
  onCancelSpeechRecording; // Add cancel speech handler
  final bool isRecording; // Add recording state

  const _ChatScreenBody({
    required this.messageController,
    required this.messageFocusNode,
    required this.scrollController,
    required this.chatbotData,
    required this.greetingData,
    // required this.isLoadingData,
    required this.selectedOptionMessages,
    required this.messages,
    required this.onSendMessage,
    required this.onHandleChatResponse,
    required this.onScrollToBottom,
    required this.onLoadChatbotData,
    required this.onRestartChatAPI,
    required this.onUpdateSelectedOptions,
    required this.onUpdateMessages,
    required this.pendingMessage,
    required this.onClearPendingMessage,
    required this.sessionId,
    required this.textFieldHeight,
    required this.onUpdateTextFieldHeight,
    required this.latestActionWidgets,
    required this.onHideStoreCards, // Add the callback parameter
    required this.onUpdateCartCount, // Add the callback parameter
    required this.totalCartCount, // Add the cart count parameter
    required this.cartBloc, // Add the cart bloc parameter
    required this.onStartSpeechRecording, // Add the start speech handler parameter
    required this.onStopSpeechRecording, // Add the stop speech handler parameter
    required this.onCancelSpeechRecording, // Add the cancel speech handler parameter
    required this.isRecording, // Add the recording state parameter
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  int cartCount = cartBloc.getTotalProductCount;
                  onUpdateCartCount(cartCount);
                  onHandleChatResponse(state.messages);
                  if (state.messages.orderConfirmedWidgets.isNotEmpty) {
                    context.read<CartBloc>().add(
                      CartFetchRequested(needToShowLoader: false),
                    );
                  }
                  if (state.messages.cartCount != null &&
                      state.messages.cartCount == 0) {
                    context.read<CartBloc>().add(
                      CartFetchRequested(needToShowLoader: false),
                    );
                  }
                } else if (state is ChatError) {
                  // Check if it's a timeout error
                  if (state.error.contains(
                    "Something went wrong please try again latter",
                  )) {
                    // Add timeout error message to chat
                    final messageId =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    final errorMessage = ChatMessage(
                      id: messageId,
                      text: "Something went wrong please try again latter",
                      isBot: true,
                      showAvatar: true,
                    );

                    final updatedMessages = [...messages, errorMessage];
                    onUpdateMessages(updatedMessages);
                    onScrollToBottom();
                  } else {
                    BlackToastView.show(
                      context,
                      'Something went wrong please try again later',
                    );
                  }
                }
              },
            ),
            BlocListener<CartBloc, CartState>(
              listener: (context, state) {
                if (state is CartProductAdded) {
                  // onHideStoreCards();
                  // Product added to cart successfully
                  onSendMessage("I have updated the cart");
                } else if (state is CartLoaded) {
                  int cartCount = cartBloc.getTotalProductCount;
                  onUpdateCartCount(cartCount);
                } else if (state is CartEmpty) {
                  // Cart is empty, set count to 0
                  print('CartBloc CartEmpty: Setting cart count to 0');
                  onUpdateCartCount(0);
                }
              },
            ),
          ],
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              // This listener is now handled by the MultiBlocListener above
            },
            builder: (context, state) {
              // Send pending message if any (schedule after build; avoid async directly in builder)
              if (pendingMessage != null) {
                final bloc = context.read<ChatBloc>();
                final String msg = pendingMessage!;
                final String sid = sessionId;
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final event = await ChatLoadEvent.create(
                    message: msg.trim(),
                    sessionId: sid,
                  );
                  bloc.add(event);
                  onClearPendingMessage();
                });
              }

              if (state is ChatLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onScrollToBottom();
                });
              }

              final bool showGreetingOverlay =
                  messages.isEmpty && greetingData != null;
              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            return false;
                          },
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount:
                                messages.length +
                                (state is ChatLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < messages.length) {
                                return _buildMessageBubble(
                                  messages[index],
                                  context,
                                );
                              }

                              if (state is ChatLoading) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: Transform.scale(
                                            scale: 3.5,
                                            child: Lottie.asset(
                                              AssetPath.get(
                                                'lottie/bubble-wave-black.json',
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        if (showGreetingOverlay)
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: false,
                              child: _buildGreetingOverlay(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildActionButtons(context),
                  Stack(
                    children: [
                      _buildInputArea(context),
                      if (isRecording) _buildInputRecordingArea(context),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Calculate total cart count from all messages
  int _getTotalCartCount() {
    return totalCartCount;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 1,
      leading: IconButton(
        icon: SvgPicture.asset(
          AssetPath.get('images/ic_history.svg'),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatHistoryScreen(),
            ),
          );
        },
      ),
      title: Row(
        children: [
          if (messages.isNotEmpty) ...[
          Container(
            child:
                (chatbotData.data.isNotEmpty &&
                        chatbotData.data.first.profileImage.isNotEmpty)
                    ? SvgPicture.asset(
                      AssetPath.get('images/ic_header_logo.svg'),
                      width: 75,
                      height: 23,
                      fit: BoxFit.cover,
                    )
                    : const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 20,
                    ),
          ),
          ]
        ],
      ),
      actions: [
        BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            return BlocBuilder<ChatBloc, ChatState>(
              builder: (context, chatState) {
                bool isApiLoading = chatState is ChatLoading;
                int cartCount = _getTotalCartCount();
                int directCartCount = cartBloc.getTotalProductCount;

                if (directCartCount != cartCount) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onUpdateCartCount(directCartCount);
                  });
                }
                return Row(
                  children: [
                    // Only show reload and cart icons if there are messages
                    if (messages.isNotEmpty) ...[
                      IconButton(
                        icon: Opacity(
                          opacity: 1.0,
                          child: SvgPicture.asset(
                            AssetPath.get('images/ic_reload.svg'),
                            width: 40,
                            height: 40,
                          ),
                        ),
                        onPressed:
                            isApiLoading
                                ? null
                                : () => _showNewChatConfirmation(context),
                      ),
                    ],
                    if (greetingData?.personaTitle.isNotEmpty ?? false) ...[
                      IconButton(
                        icon: SvgPicture.asset(
                        AssetPath.get('images/ic_chat_profile.svg'),
                        width: 40,
                        height: 40,
                      ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (context, animation, secondaryAnimation) => PopupOverlayScreen(greetingData: greetingData),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                    IconButton(
                        icon: Opacity(
                          opacity: 1.0,
                          child: Stack(
                            children: [
                              SvgPicture.asset(
                                AssetPath.get('images/ic_cart.svg'),
                                width: 40,
                                height: 40,
                              ),
                              if (cartCount > 0 || directCartCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6B46C1),
                                      // Purple color
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      (cartCount > 0
                                              ? cartCount
                                              : directCartCount)
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        onPressed:
                            isApiLoading
                                ? null
                                : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => BlocProvider(
                                            create: (context) => CartBloc(),
                                            child: CartScreen(
                                              onCheckout: (message) {
                                                onSendMessage(message);
                                              },
                                            ),
                                          ),
                                    ),
                                  );
                                },
                      ),
                    IconButton(
                      icon: SvgPicture.asset(
                        AssetPath.get('images/ic_close.svg'),
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () => _showExitChatConfirmation(context),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(color: Colors.grey.shade300, height: 0),
      ),
    );
  }

  void _showNewChatConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            // Add this for left alignment
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Are you sure want to start new chat?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 62,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF8E2FFD),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8E2FFD),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Spacing between buttons
                  const SizedBox(width: 16),

                  // Right button - "Repeat last" (Gradient)
                  Expanded(
                    child: SizedBox(
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRestartChatAPI();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF5186E0),
                                Color(0xFF5E3DFE),
                                Color(0xFF8E2FFD),
                                Color(0xFFB02EFB),
                                Color(0xFFD445EC),
                              ],
                              stops: [0.0, 0.24, 0.52, 0.73, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            height: 62,
                            alignment: Alignment.center,
                            child: const Text(
                              "YES",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showExitChatConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar - center this one
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
               Text(
                'Exit zAIn?',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
               Text(
                'Are you sure you want to leave the chat? Your conversation history will be saved, but you will lose your current context.',
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 14, 
                  color: Color(0xFF242424), 
                  fontWeight: FontWeight.w400
                  ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 62,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF8E2FFD),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Color(0xFF8E2FFD),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Stay in chat',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8E2FFD),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 62,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close bottom sheet
                          try {
                            // onRestartChatAPI();
                            OrderService().triggerChatDismiss();
                          } catch (e) {
                            Navigator.of(
                              context,
                            ).pop(); // Fallback to Flutter navigation
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF5186E0),
                                Color(0xFF5E3DFE),
                                Color(0xFF8E2FFD),
                                Color(0xFFB02EFB),
                                Color(0xFFD445EC),
                              ],
                              stops: [0.0, 0.24, 0.52, 0.73, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Continue to app',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat bubble content
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // if (message.isBot && message.showAvatar) ...[
              //   _buildBotAvatar(),
              //   const SizedBox(width: 8),
              // ] else if (message.isBot) ...[
              //   const SizedBox(width: 48),
              // ],
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      message.isBot
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: message.isBot ? 0 : 14,
                        right: 14,
                      ),
                      decoration: BoxDecoration(
                        color:
                            message.isBot
                                ? Color(
                                  int.parse(
                                    chatbotData
                                        .data
                                        .first
                                        .uiPreferences
                                        .botBubbleColor
                                        .replaceFirst('#', '0xFF'),
                                  ),
                                )
                                : Color(
                                  int.parse(
                                    chatbotData
                                        .data
                                        .first
                                        .uiPreferences
                                        .userBubbleColor
                                        .replaceFirst('#', '0xFF'),
                                  ),
                                ),
                        // borderRadius: BorderRadius.circular(16),
                        borderRadius:
                            (message.isBot == false)
                                ? BorderRadius.only(
                                  topLeft: const Radius.circular(8),
                                  topRight: const Radius.circular(8),
                                  bottomLeft:
                                      message.isBot
                                          ? Radius.circular(0)
                                          : Radius.circular(8),
                                  bottomRight:
                                      message.isBot
                                          ? Radius.circular(8)
                                          : Radius.circular(0),
                                )
                                : null,
                        // border: Border.all(
                        //   color: Colors.grey.shade300, // light gray
                        //   width: 0.5,
                        // ),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black.withOpacity(0.05),
                        //     blurRadius: 5,
                        //     offset: const Offset(0, 2),
                        //   ),
                        // ],
                      ),
                      child:
                          _hasMarkdownSyntax(message.text)
                              ? Html(
                                data: _markdownToHtml(message.text),
                                style: {
                                  "body": Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    fontSize: FontSize(16),
                                    fontFamily: "Plus Jakarta Sans",
                                    color:
                                        message.isBot
                                            ? Color(
                                              int.parse(
                                                chatbotData
                                                    .data
                                                    .first
                                                    .uiPreferences
                                                    .botBubbleFontColor
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            )
                                            : Color(
                                              int.parse(
                                                chatbotData
                                                    .data
                                                    .first
                                                    .uiPreferences
                                                    .userBubbleFontColor
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            ),
                                  ),
                                  "strong": Style(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        message.isBot
                                            ? Color(
                                              int.parse(
                                                chatbotData
                                                    .data
                                                    .first
                                                    .uiPreferences
                                                    .botBubbleFontColor
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            )
                                            : Color(
                                              int.parse(
                                                chatbotData
                                                    .data
                                                    .first
                                                    .uiPreferences
                                                    .userBubbleFontColor
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            ),
                                  ),
                                  "em": Style(
                                    fontStyle: FontStyle.italic,
                                    color:
                                        message.isBot
                                            ? Color(
                                              int.parse(
                                                chatbotData
                                                    .data
                                                    .first
                                                    .uiPreferences
                                                    .botBubbleFontColor
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            )
                                            : Color(
                                              int.parse(
                                                chatbotData
                                                    .data
                                                    .first
                                                    .uiPreferences
                                                    .userBubbleFontColor
                                                    .replaceFirst('#', '0xFF'),
                                              ),
                                            ),
                                  ),
                                  "code": Style(
                                    backgroundColor: Colors.grey.shade200,
                                    padding: HtmlPaddings.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    fontFamily: "monospace",
                                  ),
                                },
                              )
                              : Text(
                                message.text,
                                style: AppTextStyles.chatMessage.copyWith(
                                  color:
                                      message.isBot
                                          ? Color(
                                            int.parse(
                                              chatbotData
                                                  .data
                                                  .first
                                                  .uiPreferences
                                                  .botBubbleFontColor
                                                  .replaceFirst('#', '0xFF'),
                                            ),
                                          )
                                          : Color(
                                            int.parse(
                                              chatbotData
                                                  .data
                                                  .first
                                                  .uiPreferences
                                                  .userBubbleFontColor
                                                  .replaceFirst('#', '0xFF'),
                                            ),
                                          ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (message.hasOptionButtons) ...[
            const SizedBox(height: 4), //12
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: _buildOptionButtons(
                message.optionButtons,
                message.id,
                context,
              ),
            ),
          ],
          // Store cards outside the row to avoid constraints
          if (message.hasStoreCards) ...[
            const SizedBox(height: 4), //12
            _buildStoreCards(message.stores, message.storesWidget),
          ],
          if (message.hasProductCards) ...[
            const SizedBox(height: 4), //12
            Transform.translate(
              offset: const Offset(0, 0),
              child: _buildProductCards(
                message.products,
                message.productsWidget,
              ),
            ),
          ],
          if (message.hasCartWidget) ...[
            const SizedBox(height: 4), //12
            _buildCartWidget(message.cartItems),
          ],
          if (message.hasChooseAddressWidget) ...[
            const SizedBox(height: 4), //12
            _buildChooseAddressWidget(message.addressOptions),
          ],
          if (message.hasChooseCardWidget) ...[
            const SizedBox(height: 4), //12
            _buildChooseCardWidget(message.cardOptions),
          ],
          if (message.hasOrderSummaryWidget) ...[
            const SizedBox(height: 4), //12
            _buildOrderSummaryWidget(message.orderSummaryItems),
          ],
          if (message.hasOrderConfirmedWidget) ...[
            const SizedBox(height: 4), //12
            _buildOrderConfirmedWidget(message.orderConfirmedWidget!),
          ],
        ],
      ),
    );
  }

  // Helper method to check if text contains markdown syntax
  bool _hasMarkdownSyntax(String text) {
    // Check for common markdown patterns
    return text.contains('**') || // Bold text
        text.contains('*') || // Italic text
        text.contains('`') || // Code
        text.contains('#') || // Headers
        text.contains('- ') || // Lists
        text.contains('1. ') || // Numbered lists
        text.contains('[') || // Links
        text.contains(']('); // Links
  }

  // Helper method to convert markdown to HTML
  String _markdownToHtml(String text) {
    String html = text;

    // Convert bold text **text** to <strong>text</strong>
    html = html.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => '<strong>${match.group(1)}</strong>',
    );

    // Convert italic text *text* to <em>text</em>
    html = html.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
      (match) => '<em>${match.group(1)}</em>',
    );

    // Convert code `text` to <code>text</code>
    html = html.replaceAllMapped(
      RegExp(r'`(.*?)`'),
      (match) => '<code>${match.group(1)}</code>',
    );

    // Convert line breaks \n to <br>
    html = html.replaceAll('\n', '<br>');

    return html;
  }

  Widget _buildGreetingOverlay(BuildContext context) {
    final String titleText =
        greetingData?.greeting.isNotEmpty == true
            ? greetingData!.greeting
            : 'Good evening';
    final String subtitleText =
        greetingData?.subtitle.isNotEmpty == true
            ? greetingData!.subtitle
            : 'Your intelligent life assistant is ready to help';
    final String weatherText =
        greetingData?.weatherText.isNotEmpty == true
            ? greetingData!.weatherText
            : 'dsada';

    final List<GreetingOption> opts = (greetingData?.options ?? []).toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top graphic group
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Outer glow circle
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(110),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x1AD445EC),
                            Color(0x1AB02EFB),
                            Color(0x1A8E2FFD),
                            Color(0x1A5E3DFE),
                            Color(0x1A5186E0),
                          ],
                        ),
                      ),
                    ),
                    // Center asset
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFD445EC),
                              Color(0xFFB02EFB),
                              Color(0xFF8E2FFD),
                              Color(0xFF5E3DFE),
                              Color(0xFF5186E0),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            AssetPath.get('images/ic_mainImg.svg'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Opacity(
                        opacity: 0.4,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_topStar.svg'),
                          width: 34,
                          height: 34,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -10,
                      bottom: -8,
                      child: Opacity(
                        opacity: 0.4,
                        child: SvgPicture.asset(
                          AssetPath.get('images/ic_topStar.svg'),
                          width: 51,
                          height: 51,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 304,
                child: Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.launchTitle.copyWith(
                    color: const Color(0xFF171212),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 323,
                child: Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.launchSubtitle.copyWith(
                    color: const Color(0xFF6E4185),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Weather information view
              Container(
                width: 340,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0FF), // Light purple background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8D5FF), width: 1),
                ),
                child: Text(
                  weatherText,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.launchWeather.copyWith(
                    color: const Color(0xFF6E4185), // Darker purple text
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Options grid 1x1
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  children:
                      opts.map((opt) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _GreetingOptionTile(
                            option: opt,
                            onTap: () {
                              onSendMessage(opt.title);
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButtons(
    List<String> options,
    String messageId,
    BuildContext context,
  ) {
    if (selectedOptionMessages.contains(messageId)) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children:
          options
              .map(
                (option) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(
                        int.parse(
                          chatbotData.data.first.uiPreferences.primaryColor
                              .replaceFirst('#', '0xFF'),
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () {
                      onUpdateSelectedOptions({
                        ...selectedOptionMessages,
                        messageId,
                      });
                      onSendMessage(option);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: Color(
                            int.parse(
                              chatbotData.data.first.uiPreferences.primaryColor
                                  .replaceFirst('#', '0xFF'),
                            ),
                          ),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  // Removed unused _buildCustomServiceIcon due to simplified store model

  Widget _buildActionButtons(BuildContext context) {
    if (latestActionWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        bool isApiLoading = state is ChatLoading;
        if (isApiLoading == true) {
          return const SizedBox.shrink();
        }

        List<Widget> actionButtons = [];
        // Handle see_more widgets
        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.see_more.value,
        )) {
          for (final action in widget.seeMore) {
            actionButtons.add(
              _buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return RestaurantScreen(
                                  actionData: action,
                                  onCheckout: (value) {
                                    if (isCartAPICalled == true) {
                                      onUpdateCartCount(
                                        cartBloc.getTotalProductCount,
                                      );
                                      onSendMessage("I have updated the cart");
                                      isCartAPICalled = false;
                                      needToCallChatScreenSendMessageAPI = true;
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.order_tracking.value,
        )) {
          for (final action in widget.orderTracking) {
            actionButtons.add(
              _buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {
                          print("Order Tracking: ${action.orderId}");

                          // Call the order details API
                          final orderDetails = await ChatApiServices.instance
                              .getOrderDetails(
                                orderId: action.orderId ?? '',
                                type: 'masterOrder',
                              );

                          if (orderDetails != null) {
                            OrderService().triggerOrderTracking(orderDetails);
                          } else {
                            print("Failed to fetch order details");
                          }
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.order_details.value,
        )) {
          for (final action in widget.orderDetails) {
            actionButtons.add(
              _buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {
                          print("Order Details: ${action.orderId}");
                          // Call the order details API
                          final orderDetails = await ChatApiServices.instance
                              .getOrderDetails(
                                orderId: action.orderId ?? '',
                                type: 'masterOrder',
                              );

                          if (orderDetails != null) {
                            OrderService().triggerOrderDetails(orderDetails);
                          } else {
                            print("Failed to fetch order details");
                          }
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.menu.value,
        )) {
          for (final action in widget.menu) {
            actionButtons.add(
              _buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          if (action.storeTypeId ==
                                  FoodCategory.grocery.value ||
                              action.storeTypeId ==
                                  FoodCategory.pharmacy.value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => GroceriesMenuScreen(
                                      actionData: action,
                                      onCheckout: (value) {
                                        if (isCartAPICalled == true) {
                                          onUpdateCartCount(
                                            cartBloc.getTotalProductCount,
                                          );
                                          onSendMessage(
                                            "I have updated the cart",
                                          );
                                          isCartAPICalled = false;
                                          needToCallChatScreenSendMessageAPI = true;
                                        }
                                      },
                                    ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RestaurantMenuScreen(
                                      actionData: action,
                                      onCheckout: (value) {
                                        if (isCartAPICalled == true) {
                                          onUpdateCartCount(
                                            cartBloc.getTotalProductCount,
                                          );
                                          onSendMessage(
                                            "I have updated the cart",
                                          );
                                          isCartAPICalled = false;
                                          needToCallChatScreenSendMessageAPI = true;
                                        }
                                      },
                                    ),
                              ),
                            );
                          }
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.add_address.value,
        )) {
          for (final action in widget.addAddress) {
            actionButtons.add(
              _buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          OrderService().triggerAddressScreenOpen();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const AddressDetailsScreen(),
                          //   ),
                          // ).then((result) {
                          //   if (result != null) {
                          //     print("Result: $result");

                          //     // Create a formatted address string
                          //     final String building = result['building'] ?? '';
                          //     final String landmark = result['landmark'] ?? '';
                          //     final String area = result['area'] ?? '';
                          //     final String city = result['city'] ?? '';
                          //     final String country = result['country'] ?? '';
                          //     final String tag = result['tag'] ?? '';

                          //     // Build the full address string
                          //     final List<String> addressParts = [];
                          //     if (country.isNotEmpty) addressParts.add(country);
                          //     if (area.isNotEmpty) addressParts.add(area);
                          //     if (city.isNotEmpty) addressParts.add(city);
                          //     if (building.isNotEmpty)
                          //       addressParts.add(building);
                          //     if (landmark.isNotEmpty)
                          //       addressParts.add(landmark);

                          //     final String fullAddress = addressParts.join(
                          //       ', ',
                          //     );
                          //     final String addressMessage =
                          //         "I have added a new address.\nMy $tag address is:\n$fullAddress";

                          //     onSendMessage(addressMessage);
                          //   }
                          // });
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.add_payment.value,
        )) {
          for (final action in widget.addPayment) {
            actionButtons.add(
              _buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {
                          OrderService().triggerAddCardOpen();
                          // final result = await AddCardBottomSheet.show(context);
                          // if (result != null) {
                          //   debugPrint(
                          //     'PM: ${result['paymentMethodId']} '
                          //     '${result['brand']} **** ${result['last4']}',
                          //   );
                          //   onSendMessage(
                          //     'Card added successfully last 4 digits: ${result['last4']}',
                          //   );
                          // }
                        },
              ),
            );
          }
        }

        for (final widgetType in [
          WidgetEnum.add_more.value,
          WidgetEnum.proceed_to_checkout.value,
          WidgetEnum.cash_on_delivery.value,
        ]) {
          final widgets = latestActionWidgets.where(
            (w) => w.type == widgetType,
          );
          for (final widget in widgets) {
            for (final item in widget.rawItems) {
              final buttonText =
                  item['button_text'] ?? item['title'] ?? 'Action';
              actionButtons.add(
                _buildActionButton(
                  text: buttonText,
                  onTap: () {
                    onSendMessage(buttonText);
                  },
                ),
              );
            }
          }
        }

        if (actionButtons.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: actionButtons,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF8E2FFD), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8E2FFD),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        bool isApiLoading = state is ChatLoading;

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Input field container
                // Stack(
                //   children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 64,
                      maxHeight: 570, // Allow up to 550 + 20 padding
                    ),
                    child: Container(
                      height: textFieldHeight + 20,
                      // Dynamic height based on text field
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isRecording
                                  ? Colors.transparent
                                  : Color(0xFFE9DFFB),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        // padding: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 20),// ADDED For Text Field Height
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: textFieldHeight,
                                child: TextField(
                                  autofocus: false,
                                  controller: messageController,
                                  focusNode: messageFocusNode,
                                  enabled: !isApiLoading,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: null,
                                  minLines: 1,
                                  style: AppTextStyles.chatInput.copyWith(
                                    color: const Color(0xFF242424),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'How can zAIn help you today?',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintStyle: AppTextStyles.chatInput.copyWith(
                                      color: Colors.grey,
                                    ),
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (text) {
                                    // Calculate new height based on text content
                                    final textSpan = TextSpan(
                                      text:
                                          text.isEmpty
                                              ? 'How can zAIn help you today?'
                                              : text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                        color: Color(0xFF242424),
                                      ),
                                    );
                                    final textPainter = TextPainter(
                                      text: textSpan,
                                      textDirection: TextDirection.ltr,
                                      maxLines: null,
                                    );
                                    textPainter.layout(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                          160,
                                    );

                                    final newHeight = (textPainter.height + 20)
                                        .clamp(50.0, 550.0);
                                    onUpdateTextFieldHeight(newHeight);
                                  },
                                  onSubmitted:
                                      isApiLoading
                                          ? null
                                          : (text) {
                                            onSendMessage(text);
                                            Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                                onScrollToBottom();
                                              },
                                            );
                                          },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Speech button - Single tap to start/stop recording
                            Opacity(
                              opacity: isApiLoading ? 0.4 : 1.0,
                              child: GestureDetector(
                                onTap:
                                    isApiLoading
                                        ? null
                                        : () async {
                                          if (isRecording) {
                                            // Stop recording if currently recording
                                            //  await onStopSpeechRecording();
                                          } else {
                                            // Start recording if not recording
                                            await onStartSpeechRecording();
                                          }
                                        },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  child: SvgPicture.asset(
                                    AssetPath.get('images/ic_mic.svg'),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Send button
                            Opacity(
                              opacity: isApiLoading ? 0.4 : 1.0,
                              child: GestureDetector(
                                onTap:
                                    isApiLoading
                                        ? null
                                        : () {
                                          onSendMessage(messageController.text);
                                          if (messageController.text
                                              .trim()
                                              .isNotEmpty) {
                                            FocusScope.of(
                                              context,
                                            ).requestFocus(messageFocusNode);
                                          }
                                          Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                              onScrollToBottom();
                                            },
                                          );
                                        },
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: SvgPicture.asset(
                                    AssetPath.get('images/ic_sendImg.svg'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputRecordingArea(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        bool isApiLoading = state is ChatLoading;

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Input field container
                Stack(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 64,
                          maxHeight: 570, // Allow up to 550 + 20 padding
                        ),
                        child: Container(
                          height: textFieldHeight + 20,
                          // Dynamic height based on text field
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFFE9DFFB),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Opacity(
                                  opacity: isApiLoading ? 0.4 : 1.0,
                                  child: GestureDetector(
                                    onTap:
                                        isApiLoading
                                            ? null
                                            : () async {
                                              await onCancelSpeechRecording();
                                            },
                                    child: SizedBox(
                                      width: 34,
                                      height: 34,
                                      child: SvgPicture.asset(
                                        AssetPath.get('images/ic_RecClose.svg'),
                                      ),
                                    ),
                                  ),
                                ),
                                SvgPicture.asset(
                                  AssetPath.get('images/ic_Listening.svg'),
                                ),
                                Opacity(
                                  opacity: isApiLoading ? 0.4 : 1.0,
                                  child: GestureDetector(
                                    onTap:
                                        isApiLoading
                                            ? null
                                            : () async {
                                              await onStopSpeechRecording();
                                              // onSendMessage(
                                              //   messageController.text,
                                              // );
                                              // if (messageController.text
                                              //     .trim()
                                              //     .isNotEmpty) {
                                              //   FocusScope.of(
                                              //     context,
                                              //   ).requestFocus(
                                              //     messageFocusNode,
                                              //   );
                                              // }
                                              // Future.delayed(
                                              //   const Duration(
                                              //     milliseconds: 100,
                                              //   ),
                                              //   () {
                                              //     onScrollToBottom();
                                              //   },
                                              // );
                                            },
                                    child: SizedBox(
                                      width: 34,
                                      height: 34,
                                      child: SvgPicture.asset(
                                        AssetPath.get('images/ic_sendImg.svg'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreCards(List<Store> stores, ChatWidget? storesWidget) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      itemCount: stores.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final store = stores[index];
        return StoreCard(
          store: store,
          storesWidget: storesWidget,
          index: index,
          cartData: cartBloc.cartData,
          onAddToCart: (message, product, store, quantity) {
            onSendMessage(message);
          },
          // onHide: onHideStoreCards,
          onQuantityChanged: (product, store, newQuantity, isIncrease) {
            if (store.storeTypeId == FoodCategory.grocery.value ||
                store.storeTypeId == FoodCategory.pharmacy.value) {
              _onQuantityChangedForGrocery(
                context,
                product.parentProductId,
                product.childProductId,
                product.unitId,
                store.storeId,
                store.storeCategoryId,
                store.storeTypeId ?? -111,
                product.variantsCount,
                newQuantity,
                isIncrease,
                product.productName,
                product.productImage,
              );
            } else {
              _onQuantityChanged(
                context,
                product,
                store,
                newQuantity,
                isIncrease,
              );
            }
          },
          onAddToCartRequested: (product, store) {
            if ((product.variantsCount > 1 &&
                    store.storeTypeId == FoodCategory.food.value) ||
                (product.variantsCount > 0 &&
                    (store.storeTypeId == FoodCategory.grocery.value ||
                        store.storeTypeId == FoodCategory.pharmacy.value))) {
              if (store.storeTypeId == FoodCategory.grocery.value ||
                  store.storeTypeId == FoodCategory.pharmacy.value) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => GroceryCustomizationScreen(
                        parentProductId: product.parentProductId,
                        productId: product.childProductId,
                        storeId: store.storeId,
                        productName: product.productName,
                        productImage: product.productImage,
                        onAddToCart: (parentProductId, productId, unitId) {
                          _onAddToCartForGrocery(
                            parentProductId,
                            productId,
                            unitId,
                            store.storeId,
                            store.storeCategoryId,
                            store.storeTypeId ?? -111,
                            null,
                          );
                        },
                      ),
                );
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => ProductCustomizationScreen(
                        product: product,
                        store: store,
                        onAddToCartWithAddOns: _onAddToCartWithAddOns,
                      ),
                );
              }
            } else {
              //TODO:- Add Quantity
              cartBloc.add(
                CartAddItemRequested(
                  storeId: store.storeId,
                  cartType:
                      store.storeTypeId == FoodCategory.food.value ? 1 : 2,
                  // Default cart type
                  action: 1,
                  // Add action
                  storeCategoryId: store.storeCategoryId,
                  newQuantity: 1,
                  // Add 1 item
                  storeTypeId: store.storeTypeId ?? -111,
                  productId: product.childProductId,
                  centralProductId: product.parentProductId,
                  unitId: product.unitId,
                  needToShowLoaderForCartFetch: false,
                ),
              );
            }
          },
        );
      },
    );
  }

  /// Handle adding products with addons to cart
  void _onAddToCartWithAddOns(
    Product? product,
    Store? store,
    dynamic variant,
    List<Map<String, dynamic>> addOns,
    String selectedProductId,
  ) {
    try {
      //TODO:- Add Quantity
      cartBloc.add(
        CartAddItemRequested(
          storeId: store?.storeId ?? '',
          cartType: 1,
          // Default cart type
          action: 1,
          // Add action
          storeCategoryId: store?.storeCategoryId ?? '',
          newQuantity: 1,
          storeTypeId: store?.storeTypeId ?? -111,
          productId: selectedProductId,
          centralProductId: product?.parentProductId ?? '',
          unitId: variant.unitId,
          newAddOns: addOns,
          needToShowLoaderForCartFetch: false,
        ),
      );

      print("Added product with addons to cart: ${product?.productName ?? ''}");
    } catch (e) {
      print(
        'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
      );
    }
  }

  void _onAddToCartForGrocery(
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int? addToCartOnId,
  ) {
    try {
      //TODO:- Add Quantity
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          // Default cart type
          action: 1,
          // Add action
          storeCategoryId: storeCategoryId,
          newQuantity: 1,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartOnId,
          needToShowLoaderForCartFetch: false,
        ),
      );

      print("Added product to cart: ${productId}");
    } catch (e) {
      print(
        'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
      );
    }
  }

  void _onQuantityChangedForGrocery(
    BuildContext context,
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int variantsCount,
    int newQuantity,
    bool isIncrease,
    String productName,
    String productImage,
  ) {
    if (isIncrease == false && newQuantity == 1) {
      //TODO:- 0 Quantity
      int? addToCartOnId;
      if (variantsCount > 0) {
        addToCartOnId = _getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
      }

      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 2,
          action: 3,
          // Add/Update action
          storeCategoryId: storeCategoryId,
          newQuantity: 0,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartOnId,
          needToShowLoaderForCartFetch: false,
        ),
      );
    } else if (newQuantity > 0 && isIncrease == true) {
      if (variantsCount > 0) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => CustomizationSummaryScreen(
                // store: store,
                // product: product,
                onChooseClicked: () {
                  _openGroceryCustomization(
                    context,
                    parentProductId,
                    productId,
                    unitId,
                    storeId,
                    storeCategoryId,
                    storeTypeId,
                    productName,
                    productImage,
                  );
                },
                onRepeatClicked: () {
                  //TODO:- Add Quantity
                  final addToCartOnId = _getAddToCartOnId(productId);
                  print("addCartOnID: $addToCartOnId");

                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: storeId,
                      cartType: 1,
                      action: 2,
                      // Add action
                      storeCategoryId: storeCategoryId,
                      newQuantity: newQuantity + 1,
                      storeTypeId: storeTypeId,
                      productId: productId,
                      centralProductId: parentProductId,
                      unitId: unitId,
                      addToCartOnId: addToCartOnId,
                      needToShowLoaderForCartFetch: false,
                    ),
                  );
                },
              ),
        );
      } else {
        //TODO:- Add Quantity
        final addToCartOnId = _getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
        cartBloc.add(
          CartAddItemRequested(
            storeId: storeId,
            cartType: 1,
            action: 2,
            // Add action
            storeCategoryId: storeCategoryId,
            newQuantity: newQuantity + 1,
            storeTypeId: storeTypeId,
            productId: productId,
            centralProductId: parentProductId,
            unitId: unitId,
            addToCartOnId: addToCartOnId,
            needToShowLoaderForCartFetch: false,
          ),
        );
      }
    } else {
      //TODO:- Remove Quantity
      int? addToCartOnId;
      if (variantsCount > 0) {
        addToCartOnId = _getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
      }
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 2,
          action: 2,
          // Add/Update action
          storeCategoryId: storeCategoryId,
          newQuantity: newQuantity - 1,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartOnId,
          needToShowLoaderForCartFetch: false,
        ),
      );
    }
  }

  void _openGroceryCustomization(
    BuildContext context,
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    String productName,
    String productImage,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GroceryCustomizationScreen(
            parentProductId: parentProductId,
            productId: productId,
            storeId: storeId,
            productName: productName,
            productImage: productImage,
            onAddToCart: (parentProductId, productId, unitId) {
              _onAddToCartForGrocery(
                parentProductId,
                productId,
                unitId,
                storeId,
                storeCategoryId,
                storeTypeId,
                null,
              );
            },
          ),
    );
  }

  void _onQuantityChanged(
    BuildContext context,
    Product product,
    Store store,
    int newQuantity,
    bool isIncrease,
  ) {
    if (isIncrease == false && newQuantity == 1) {
      //TODO:- 0 Quantity
      int? addToCartOnId;
      if (product.variantsCount > 1) {
        addToCartOnId = _getAddToCartOnId(product.childProductId);
        print("addCartOnID: $addToCartOnId");
      }
      cartBloc.add(
        CartAddItemRequested(
          storeId: store.storeId,
          cartType: 2,
          action: 3,
          // Add/Update action
          storeCategoryId: store.storeCategoryId,
          newQuantity: 0,
          storeTypeId: store.storeTypeId ?? -111,
          productId: product.childProductId,
          centralProductId: product.parentProductId,
          unitId: product.unitId,
          addToCartOnId: addToCartOnId,
          needToShowLoaderForCartFetch: false,
        ),
      );
    } else if (newQuantity > 0 && isIncrease == true) {
      if (product.variantsCount > 1) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => CustomizationSummaryScreen(
                store: store,
                product: product,
                onChooseClicked: () {
                  // When "I'll choose" is clicked, open ProductCustomizationScreen
                  _openProductCustomization(context, product, store);
                },
                onRepeatClicked: () {
                  //TODO:- Add Quantity
                  final addToCartOnId = _getAddToCartOnId(
                    product.childProductId,
                  );
                  print("addCartOnID: $addToCartOnId");

                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: store.storeId,
                      cartType: 1,
                      action: 2,
                      // Add action
                      storeCategoryId: store.storeCategoryId,
                      newQuantity: newQuantity + 1,
                      storeTypeId: store.storeTypeId ?? -111,
                      productId: product.childProductId,
                      centralProductId: product.parentProductId,
                      unitId: product.unitId,
                      addToCartOnId: addToCartOnId,
                      needToShowLoaderForCartFetch: false,
                    ),
                  );
                },
              ),
        );
      } else {
        //TODO:- Add Quantity
        cartBloc.add(
          CartAddItemRequested(
            storeId: store.storeId,
            cartType: 1,
            action: 2,
            // Add action
            storeCategoryId: store.storeCategoryId,
            newQuantity: newQuantity + 1,
            storeTypeId: store.storeTypeId ?? -111,
            productId: product.childProductId,
            centralProductId: product.parentProductId,
            unitId: product.unitId,
            needToShowLoaderForCartFetch: false,
          ),
        );
      }
    } else {
      //TODO:- Remove Quantity
      int? addToCartOnId;
      if (product.variantsCount > 1) {
        addToCartOnId = _getAddToCartOnId(product.childProductId);
        print("addCartOnID: $addToCartOnId");
      }
      cartBloc.add(
        CartAddItemRequested(
          storeId: store.storeId,
          cartType: 2,
          action: 2,
          // Add/Update action
          storeCategoryId: store.storeCategoryId,
          newQuantity: newQuantity - 1,
          storeTypeId: store.storeTypeId ?? -111,
          productId: product.childProductId,
          centralProductId: product.parentProductId,
          unitId: product.unitId,
          addToCartOnId: addToCartOnId,
          needToShowLoaderForCartFetch: false,
        ),
      );
    }

    // Update cart totals
    // _updateCartTotals();
  }

  /// Get addToCartOnId from cart data for a specific product
  dynamic _getAddToCartOnId(String productId) {
    try {
      // Use filter to find the product with matching ID
      final cartData =
          cartBloc.cartData
              .expand((cart) => cart.sellers)
              .expand((seller) => seller.products)
              .where((product) => product.id == productId)
              .firstOrNull;

      return cartData?.addToCartOnId;
    } catch (e) {
      print('Error getting addToCartOnId: $e');
      return null;
    }
  }

  /// Open ProductCustomizationScreen with proper callbacks
  void _openProductCustomization(
    BuildContext context,
    Product product,
    Store store,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ProductCustomizationScreen(
            product: product,
            store: store,
            onAddToCartWithAddOns: _onAddToCartWithAddOns,
          ),
    );
  }

  Widget _buildProductCards(
    List<Product> products,
    ChatWidget? productsWidget,
  ) {
    return Container(
      height: 222,
      // color: Colors.red,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 6),
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final product = products[index];
          final String priceText = _formatCurrency(
            product.currencySymbol,
            product.finalPriceList.finalPrice,
          );
          final String basePriceText = _formatCurrency(
            product.currencySymbol,
            product.finalPriceList.basePrice,
          );
          return MenuItemCard(
            title: product.productName,
            price: priceText,
            originalPrice: basePriceText,
            isVeg: !product.containsMeat,
            imageUrl:
                product.productImage.isNotEmpty ? product.productImage : null,
            productId: product.childProductId,
            centralProductId: product.parentProductId,
            isCustomizable:
                (product.variantsCount > 1 &&
                    product.storeTypeId == FoodCategory.food.value) ||
                (product.variantsCount > 0 &&
                    (product.storeTypeId == FoodCategory.grocery.value ||
                        product.storeTypeId == FoodCategory.pharmacy.value)),
            cartData: cartBloc.cartData,
            instock: product.instock ?? true,
            storeIsOpen: product.storeIsOpen ?? true,
            storeType: product.storeTypeId ?? -111,
            onClick: () {
              if (productsWidget != null) {
                final Map<String, dynamic>? productJson = productsWidget
                    .getRawProduct(index);
                    print("productJson: $productJson");
                OrderService().triggerProductOrder(productJson ?? {});
              }
            },
            onQuantityChanged: (
              productId,
              centralProductId,
              quantity,
              isIncrease,
              isCustomizable,
            ) {
              if (product.storeTypeId == FoodCategory.grocery.value ||
                  product.storeTypeId == FoodCategory.pharmacy.value) {
                _onQuantityChangedForGrocery(
                  context,
                  centralProductId,
                  productId,
                  product.unitId,
                  product.storeId ?? '',
                  product.storeCategoryId ?? '',
                  product.storeTypeId ?? -111,
                  product.variantsCount,
                  quantity,
                  isIncrease,
                  product.productName,
                  product.productImage,
                );
              } else {
                _onQuantityChangedMenuItem(
                  productId,
                  centralProductId,
                  quantity,
                  isIncrease,
                  isCustomizable,
                  product.storeId ?? '',
                  product.storeCategoryId ?? '',
                  product.storeTypeId ?? -111,
                  context,
                  product.productName,
                  product.productImage,
                );
              }
            },
            onAddToCart: (
              productId,
              centralProductId,
              quantity,
              isCustomizable,
            ) {
              if (product.storeIsOpen == false &&
                  product.storeTypeId != FoodCategory.pharmacy.value) {
                print('STORE CLSOSED');
                BlackToastView.show(
                  context,
                  'Store is closed. Please try again later',
                );
                return;
              } else if (product.instock == false &&
                  (product.storeTypeId == FoodCategory.grocery.value ||
                      product.storeTypeId == FoodCategory.pharmacy.value)) {
                print('Product is not in stock');
                BlackToastView.show(
                  context,
                  'Product is not in stock. Please try again later',
                );
                return;
              }
              if (product.storeTypeId == FoodCategory.grocery.value ||
                  product.storeTypeId == FoodCategory.pharmacy.value) {
                if (isCustomizable) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder:
                        (context) => GroceryCustomizationScreen(
                          parentProductId: product.parentProductId,
                          productId: product.childProductId,
                          storeId: product.storeId ?? '',
                          productName: product.productName,
                          productImage: product.productImage,
                          onAddToCart: (parentProductId, productId, unitId) {
                            _onAddToCartForGrocery(
                              parentProductId,
                              productId,
                              unitId,
                              product.storeId ?? '',
                              product.storeCategoryId ?? '',
                              product.storeTypeId ?? -111,
                              null,
                            );
                          },
                        ),
                  );
                } else {
                  //TODO:- Add Quantity
                  final addToCartOnId = _getAddToCartOnId(productId);
                  print("addCartOnID: $addToCartOnId");
                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: product.storeId ?? '',
                      cartType: 1,
                      action: 2,
                      // Add action
                      storeCategoryId: product.storeCategoryId ?? '',
                      newQuantity: quantity + 1,
                      storeTypeId: product.storeTypeId ?? -111,
                      productId: productId,
                      centralProductId: product.parentProductId,
                      unitId: product.unitId,
                      addToCartOnId: addToCartOnId,
                      needToShowLoaderForCartFetch: false,
                    ),
                  );
                }
              } else {
                if (isCustomizable) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder:
                        (context) => ProductCustomizationScreen(
                          productId: productId,
                          centralProductId: centralProductId,
                          storeId: product.storeId,
                          productName: product.productName,
                          productImage:
                              product.productImage.isNotEmpty
                                  ? product.productImage
                                  : null,
                          isFromMenuScreen: true,
                          onAddToCartWithAddOns: (
                            prdt,
                            store,
                            variant,
                            addOns,
                            selectedProductId,
                          ) {
                            //TODO:- Add Quantity
                            cartBloc.add(
                              CartAddItemRequested(
                                storeId: product.storeId ?? '',
                                cartType: 1,
                                // Default cart type
                                action: 1,
                                // Add action
                                storeCategoryId: product.storeCategoryId ?? '',
                                newQuantity: quantity,
                                // Add 1 item
                                storeTypeId: product.storeTypeId ?? -111,
                                productId: selectedProductId,
                                centralProductId: centralProductId,
                                unitId: variant?.unitId ?? '',
                                newAddOns: addOns,
                                needToShowLoaderForCartFetch: false,
                              ),
                            );
                          },
                        ),
                  );
                } else {
                  //TODO:- Add Quantity
                  print("product.storeId: ${product.productName}");
                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: product.storeId ?? '',
                      cartType: 1,
                      // Default cart type
                      action: 1,
                      // Add action
                      storeCategoryId: product.storeCategoryId ?? '',
                      newQuantity: quantity,
                      // Add 1 item
                      storeTypeId: product.storeTypeId ?? -111,
                      productId: productId,
                      centralProductId: centralProductId,
                      unitId: '',
                      needToShowLoaderForCartFetch: false,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }

  void _onQuantityChangedMenuItem(
    String productId,
    String centralProductId,
    int currentQuantity,
    bool isIncrease,
    bool isCustomizable,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    BuildContext context,
    String productName,
    String productImage,
  ) {
    try {
      if (isIncrease == false && currentQuantity == 1) {
        //TODO:- 0 Quantity
        int? addToCartOnId;
        if (isCustomizable == true) {
          addToCartOnId = _getAddToCartOnId(productId);
          print("addCartOnID: $addToCartOnId");
        }

        cartBloc.add(
          CartAddItemRequested(
            storeId: storeId,
            cartType: 2,
            action: 3,
            // Add action
            storeCategoryId: storeCategoryId,
            newQuantity: 0,
            storeTypeId: storeTypeId,
            productId: productId,
            centralProductId: centralProductId,
            unitId: '',
            addToCartOnId: addToCartOnId,
            needToShowLoaderForCartFetch: false,
          ),
        );
      } else if (currentQuantity > 0 && isIncrease == true) {
        if (isCustomizable) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (context) => CustomizationSummaryScreen(
                  onChooseClicked: () {
                    // When "I'll choose" is clicked, open ProductCustomizationScreen
                    _openProductCustomizationMenuItem(
                      productId,
                      centralProductId,
                      storeId,
                      storeCategoryId,
                      storeTypeId,
                      context,
                      productName,
                      productImage,
                    );
                  },
                  onRepeatClicked: () {
                    //TODO:- Add Quantity
                    final addToCartOnId = _getAddToCartOnId(productId);
                    print("addCartOnID: $addToCartOnId");

                    cartBloc.add(
                      CartAddItemRequested(
                        storeId: storeId,
                        cartType: 1,
                        action: 2,
                        // Add action
                        storeCategoryId: storeCategoryId,
                        newQuantity: currentQuantity + 1,
                        storeTypeId: storeTypeId,
                        productId: productId,
                        centralProductId: centralProductId,
                        unitId: '',
                        addToCartOnId: addToCartOnId,
                        needToShowLoaderForCartFetch: false,
                      ),
                    );
                  },
                ),
          );
        } else {
          //TODO:- Add Quantity
          cartBloc.add(
            CartAddItemRequested(
              storeId: storeId,
              cartType: 1,
              action: 2,
              // Remove action
              storeCategoryId: storeCategoryId,
              newQuantity: currentQuantity + 1,
              storeTypeId: storeTypeId,
              productId: productId,
              centralProductId: centralProductId,
              unitId: '',
              needToShowLoaderForCartFetch: false,
            ),
          );
        }
      } else {
        //TODO:- Remove Quantity
        int? addToCartOnId;
        if (isCustomizable == true) {
          addToCartOnId = _getAddToCartOnId(productId);
          print("addCartOnID: $addToCartOnId");
        }
        cartBloc.add(
          CartAddItemRequested(
            storeId: storeId,
            cartType: 2,
            action: 2,
            // Add action
            storeCategoryId: storeCategoryId,
            newQuantity: currentQuantity - 1,
            storeTypeId: storeTypeId,
            productId: productId,
            centralProductId: centralProductId,
            unitId: '',
            addToCartOnId: addToCartOnId,
            needToShowLoaderForCartFetch: false,
          ),
        );
      }
    } catch (e) {
      print('Error changing quantity: $e');
    }
  }

  void _openProductCustomizationMenuItem(
    String productId,
    String centralProductId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    BuildContext context,
    String productName,
    String productImage,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ProductCustomizationScreen(
            productId: productId,
            centralProductId: centralProductId,
            storeId: storeId,
            productName: productName,
            productImage: productImage,
            isFromMenuScreen: true,
            onAddToCartWithAddOns:
                (product, store, variant, addOns, selectedProductId) =>
                    _onAddToCartWithAddOnsMenuItem(
                      productId,
                      centralProductId,
                      storeId,
                      storeCategoryId,
                      storeTypeId,
                      context,
                      variant,
                      addOns,
                      selectedProductId,
                    ),
          ),
    );
  }

  /// Handle adding products with addons to cart
  void _onAddToCartWithAddOnsMenuItem(
    String productId,
    String centralProductId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    BuildContext context,
    dynamic variant,
    List<Map<String, dynamic>> addOns,
    String selectedProductId,
  ) {
    try {
      //TODO:- Add Quantity
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          // Default cart type
          action: 1,
          // Add action
          storeCategoryId: storeCategoryId,
          newQuantity: 1,
          storeTypeId: storeTypeId,
          productId: selectedProductId,
          centralProductId: centralProductId,
          unitId: variant.unitId,
          newAddOns: addOns,
          needToShowLoaderForCartFetch: false,
        ),
      );

      // print("Added product with addons to cart: ${product.productName}");
    } catch (e) {
      print(
        'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
      );
    }
  }

  String _formatCurrency(String symbol, double value) {
    if (symbol.isNotEmpty && symbol != 'AED') {
      return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return 'AED${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  Widget _buildCartWidget(List<WidgetAction> cartItems) {
    return CartWidget(cartItems: cartItems);
  }

  Widget _buildChooseAddressWidget(List<AddressOption> addressOptions) {
    return ChooseAddressWidget(
      addressOptions: addressOptions,
      onAddressSelected: (selectedAddress) {
        // Handle address selection
        print(
          'Selected address: ${selectedAddress.name} - ${selectedAddress.address}',
        );
      },
      onSendMessage: (message) {
        // Automatically send the selected address message
        onSendMessage(message);
      },
    );
  }

  Widget _buildChooseCardWidget(List<CardOption> cardOptions) {
    return ChooseCardWidget(
      cardOptions: cardOptions,
      onCardSelected: (selectedCard) {
        // Handle card selection
        print('Selected card: ${selectedCard.title}');
      },
      onSendMessage: (message) {
        // Automatically send the selected card message
        onSendMessage(message);
      },
    );
  }

  Widget _buildOrderSummaryWidget(List<WidgetAction> orderSummaryItems) {
    return OrderSummaryWidget(orderItems: orderSummaryItems);
  }

  Widget _buildOrderConfirmedWidget(ChatWidget orderConfirmedWidget) {
    final orderData = orderConfirmedWidget.getOrderConfirmedData();
    if (orderData != null) {
      final title = orderData['title'] as String? ?? '';

      return OrderConfirmedWidget(title: title);
    }
    return const SizedBox.shrink();
  }
}

class _GreetingOptionTile extends StatelessWidget {
  final GreetingOption option;
  final VoidCallback onTap;

  const _GreetingOptionTile({required this.option, required this.onTap});

  // List<TextSpan> _buildTextWithLargeEmojis(String text) {
  //   List<TextSpan> spans = [];
  //   // Comprehensive emoji regex covering all major emoji ranges
  //   RegExp emojiRegex = RegExp(
  //     r'[\u{1F600}-\u{1F64F}]|' // Emoticons
  //     r'[\u{1F300}-\u{1F5FF}]|' // Misc Symbols and Pictographs
  //     r'[\u{1F680}-\u{1F6FF}]|' // Transport and Map
  //     r'[\u{1F1E0}-\u{1F1FF}]|' // Regional indicator symbols
  //     r'[\u{2600}-\u{26FF}]|'   // Misc symbols
  //     r'[\u{2700}-\u{27BF}]|'   // Dingbats
  //     r'[\u{1F900}-\u{1F9FF}]|' // Supplemental Symbols and Pictographs
  //     r'[\u{1FA70}-\u{1FAFF}]|' // Symbols and Pictographs Extended-A
  //     r'[\u{1F018}-\u{1F0F5}]|' // Playing cards
  //     r'[\u{1F200}-\u{1F2FF}]|' // Enclosed CJK Letters and Months
  //     r'[\u{1F964}]', // Cup with straw emoji (🥤)
  //     unicode: true
  //   );
    
  //   int lastIndex = 0;
  //   for (Match match in emojiRegex.allMatches(text)) {
     
  //     // Add emoji with larger font size
  //     spans.add(TextSpan(
  //       text: match.group(0),
  //       style: const TextStyle(fontSize: 24), // Larger emoji size
  //     ));


  //     // Add space after emoji
  //     spans.add(const TextSpan(text: '  '));

  //      // Add text before emoji
  //     if (match.start > lastIndex) {
  //       spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
  //     }
      
  //     lastIndex = match.end;
  //   }
    
  //   // Add remaining text
  //   if (lastIndex < text.length) {
  //     spans.add(TextSpan(text: text.substring(lastIndex)));
  //   }
    
  //   return spans;
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),//20,16
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Emoji and text content
            Expanded(
              child: Row(
                children: [
                  // Emoji in circular background
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(63.6364),
                    ),
                    child: Center(
                      child: Text(
                        option.emoji,
                        style: const TextStyle(
                          fontSize: 26,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option.title,
                          maxLines: 2,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                            color: Color(0xFF242424),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          option.subTitle,
                          maxLines: 2,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            color: Color(0xFF585C77),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 14,
              height: 14,
              child: Center(
                child: SvgPicture.asset(
                  AssetPath.get('images/ic_side_arrow.svg'),
                  width: 14,
                  height: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}