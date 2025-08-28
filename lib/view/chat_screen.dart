import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/chat_message.dart';
import 'package:chat_bot/view/add_card_sheet.dart';
import 'package:chat_bot/view/address_details_screen.dart';
import 'package:chat_bot/view/restaurant_menu_screen.dart';
import 'package:chat_bot/view/restaurant_screen.dart';
import 'package:chat_bot/view/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../services/callback_manage.dart';
import 'package:chat_bot/widgets/store_card.dart';
import 'package:flutter/services.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/widgets/menu_item_card.dart';
import 'package:chat_bot/widgets/cart_widget.dart';
import 'package:chat_bot/widgets/choose_address_widget.dart';
import 'package:chat_bot/widgets/choose_card_widget.dart';
import '../utils/enum.dart';

// Global variable for cart object
List<WidgetAction>? cartObject = [];

class ChatScreen extends StatefulWidget {
  final MyGPTsResponse chatbotData;
  final GreetingResponse? greetingData;
  const ChatScreen({super.key, required this.chatbotData, this.greetingData});

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

  // Returns index of the last bot message that shows stores, products, cart, choose_address, or choose_card widgets; -1 if none
  int _indexOfLastBotCatalogMessage() {
    for (int i = messages.length - 1; i >= 0; i--) {
      final ChatMessage message = messages[i];
      if (message.isBot && (message.hasStoreCards || message.hasProductCards || message.hasCartWidget || message.hasChooseAddressWidget || message.hasChooseCardWidget)) {
        return i;
      }
    }
    return -1;
  }

  // Produces a hidden version of catalog widgets for a message (non-destructive to data)
  ChatMessage _hideCatalogInMessage(ChatMessage message) {
    if (!(message.hasStoreCards || message.hasProductCards || message.hasCartWidget || message.hasChooseAddressWidget || message.hasChooseCardWidget)) return message;
    return message.copyWith(
      hasStoreCards: false,
      hasProductCards: false,
      hasCartWidget: false,
      hasChooseAddressWidget: false,
      hasChooseCardWidget: false,
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

    setState(() {
      if (catalogIdx >= 0) {
        messages[catalogIdx] = _hideCatalogInMessage(messages[catalogIdx]);
      }
      messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isBot: false
      ));
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
      _totalCartCount = count;
  }

  void _handleChatResponse(ChatResponse response) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    ChatWidget? storesWidget;
    ChatWidget? productsWidget;
    ChatWidget? cartWidget;
    ChatWidget? chooseAddressWidget;
    ChatWidget? chooseCardWidget;
    try {
      storesWidget = response.widgets.firstWhere((widget) => widget.isStoresWidget);
    } catch (e) {
      storesWidget = null;
    }

    try {
      productsWidget = response.widgets.firstWhere((widget) => widget.isProductsWidget);
    } catch (e) {
      productsWidget = null;
    }

    try {
      cartWidget = response.widgets.firstWhere((widget) => widget.isCartWidget);
    } catch (e) {
      cartWidget = null;
    }

    try {
      chooseAddressWidget = response.widgets.firstWhere((widget) => widget.isChooseAddressWidget);
    } catch (e) {
      chooseAddressWidget = null;
    }

    try {
      chooseCardWidget = response.widgets.firstWhere((widget) => widget.isChooseCardWidget);
    } catch (e) {
      chooseCardWidget = null;
    }

    // Check if stores, products, cart, choose_address, or choose_card are present
    bool hasStores = storesWidget != null;
    bool hasProducts = productsWidget != null;
    bool hasCart = cartWidget != null;
    bool hasChooseAddress = chooseAddressWidget != null;
    bool hasChooseCard = chooseCardWidget != null;

    setState(() {
      messages.add(ChatMessage(
        id: messageId,
        text: response.text,
        isBot: true,
        showAvatar: true,
        hasStoreCards: hasStores,
        hasProductCards: hasProducts,
        hasCartWidget: hasCart,
        hasChooseAddressWidget: hasChooseAddress,
        hasChooseCardWidget: hasChooseCard,
        // Don't show option buttons if stores, products, cart, choose_address, or choose_card are present
        hasOptionButtons: !hasStores && !hasProducts && !hasCart && !hasChooseAddress && !hasChooseCard && response.hasWidgets && response.optionsWidgets.isNotEmpty,
        optionButtons: !hasStores && !hasProducts && !hasCart && !hasChooseAddress && !hasChooseCard && response.hasWidgets && response.optionsWidgets.isNotEmpty
            ? response.optionsWidgets.first.options
            : [],
        stores: storesWidget?.stores ?? [],
        products: productsWidget?.products ?? [],
        cartItems: cartWidget?.getCartItems() ?? [],
        addressOptions: chooseAddressWidget?.getAddressOptions() ?? [],
        cardOptions: chooseCardWidget?.getCardOptions() ?? [],
        storesWidget: storesWidget,
        productsWidget: productsWidget,
        cartWidget: cartWidget,
        chooseAddressWidget: chooseAddressWidget,
        chooseCardWidget: chooseCardWidget,
      ));
      
      // Store action widgets for the action buttons
      _latestActionWidgets = response.widgets.where((widget) => 
        widget.type == WidgetEnum.see_more.value ||
        widget.type == WidgetEnum.menu.value ||
        widget.type == WidgetEnum.add_more.value ||
        widget.type == WidgetEnum.proceed_to_checkout.value ||
        widget.type == WidgetEnum.add_address.value ||
        widget.type == WidgetEnum.add_payment.value ||
        widget.type == WidgetEnum.cart.value ||
        widget.type == WidgetEnum.choose_address.value ||
        widget.type == WidgetEnum.choose_card.value ||
        widget.type == WidgetEnum.cash_on_delivery.value
      ).toList();
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
    
    // Add keyboard listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageFocusNode.addListener(_onFocusChange);
    });
  }

  void _initializeSession() {
    _sessionId = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
  }

  Future<void> _restartChatAPI() async {
    setState(() {
      messages = [];

      _selectedOptionMessages.clear();
      _sessionId = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
      _pendingMessage = null;
      _latestActionWidgets.clear(); // Clear action widgets when restarting
    });

    // Navigator.push(
    //   context,
    //     MaterialPageRoute(builder: (_) => const AddressDetailsScreen()),
    // ).then((result) {
    //   if (result != null) {
    //     print("Result: $result");
    //   }
    // });
    // final result = await AddCardBottomSheet.show(context);
    //   if (result != null) {
    //     // e.g., update your state or start a payment
    //     debugPrint('PM: ${result['paymentMethodId']} '
    //         '${result['brand']} **** ${result['last4']}');
    //   }
  }

  @override
  void dispose() {
    _messageFocusNode.removeListener(_onFocusChange);
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    // OrderService().clearCallback();
    print("DISPOSE");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(),
      child: _ChatScreenBody(
        messageController: _messageController,
        messageFocusNode: _messageFocusNode,
        scrollController: _scrollController,
        chatbotData: widget.chatbotData,
        greetingData: widget.greetingData,
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
        sessionId: _sessionId, // Pass session ID
        textFieldHeight: _textFieldHeight,
        onUpdateTextFieldHeight: _updateTextFieldHeight,
        latestActionWidgets: _latestActionWidgets,
        onHideStoreCards: _hideStoreCards, // Add the callback
        onUpdateCartCount: _updateCartCount, // Add the callback
        totalCartCount: _totalCartCount, // Pass the cart count
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
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded) {
              List<ChatWidget> cartWidgets = state.messages.cartWidgets;
              if (cartWidgets.isNotEmpty) {
                int cartCount = 0;
                // Get all cart items
                cartObject = cartWidgets.first.getCartItems();
                // Count only items with valid productID (excluding "Total To Pay" and items with empty productID)
                cartCount = cartObject?.where((item) => 
                    item.productID != null && 
                    item.productID!.isNotEmpty).length ?? 0;
                onUpdateCartCount(cartCount);
              }
              //  int cartCount = 0;
              // if (cartObject != null) {
              //   cartCount = cartObject.widget.length;
              // }
              // onUpdateCartCount(cartCount);
              onHandleChatResponse(state.messages);
            } else if (state is ChatError) {
              // Check if it's a timeout error
              if (state.error.contains(
                  "Something went wrong please try again latter")) {
                // Add timeout error message to chat
                final messageId = DateTime
                    .now()
                    .millisecondsSinceEpoch
                    .toString();
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
                BlackToastView.show(context, 'Something went wrong please try again later');
              }
            }
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
      
            final bool showGreetingOverlay = messages.isEmpty && greetingData != null;
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
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: messages.length + (state is ChatLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < messages.length) {
                              return _buildMessageBubble(messages[index], context);
                            }

                            if (state is ChatLoading) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // _buildBotAvatar(),
                                    // const SizedBox(width: 8),
                                    Container(
                                      // decoration: BoxDecoration(
                                      //     color: Color(
                                      //         int.parse(
                                      //             chatbotData
                                      //                 .data
                                      //                 .first
                                      //                 .uiPreferences
                                      //                 .botBubbleColor
                                      //                 .replaceFirst('#', '0xFF'))),
                                      //     borderRadius: BorderRadius.only(
                                      //       topLeft: Radius.circular(8),
                                      //       topRight: Radius.circular(8),
                                      //       bottomLeft: Radius.circular(0),
                                      //       bottomRight: Radius.circular(8),
                                      //     ),
                                      //     border: Border.all(
                                      //       color: Colors.grey.shade300,
                                      //       width: 0.5,
                                      //     )
                                      // ),
                                      child: SizedBox(
                                        width: 80,
                                        height: 40,
                                        child: Transform.scale(
                                          scale: 3.5,
                                          child: Lottie.asset(
                                              'assets/lottie/bubble-wave-black.json',
                                              fit: BoxFit.contain
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
                      if (showGreetingOverlay) Positioned.fill(
                        child: IgnorePointer(
                          ignoring: false,
                          child: _buildGreetingOverlay(context),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(context),
                _buildInputArea(context),
              ],
            );
          },
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
          'assets/images/ic_history.svg',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        onPressed: () {},
      ),
      title: Row(
        children: [
          Container(
            child: (chatbotData.data.isNotEmpty &&
                   chatbotData.data.first.profileImage.isNotEmpty)
                ? SvgPicture.asset(
                    'assets/images/ic_header_logo.svg',
                    width: 80,
                    height: 23,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            bool isApiLoading = state is ChatLoading;
            int cartCount = _getTotalCartCount();
            return Row(
              children: [
                // Only show reload and cart icons if there are messages
                if (messages.isNotEmpty) ...[
                  IconButton(
                    icon: Opacity(
                      opacity: isApiLoading ? 0.4 : 1.0,
                      child: SvgPicture.asset(
                        'assets/images/ic_reload.svg',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    onPressed: isApiLoading ? null : () => _showNewChatConfirmation(context),
                  ),
                  IconButton(
                    icon: Opacity(
                      opacity: isApiLoading ? 0.4 : 1.0,
                      child: Stack(
                        children: [
                          SvgPicture.asset(
                            'assets/images/ic_cart.svg',
                            width: 40,
                            height: 40,
                          ),
                          if (cartCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B46C1), // Purple color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  cartCount.toString(),
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
                    onPressed: isApiLoading ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
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
                ],
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/ic_close.svg',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => _showExitChatConfirmation(context),
                ),
              ],
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: Colors.grey.shade300,
          height: 0,
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start, // Add this for left alignment
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
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onRestartChatAPI();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'YES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
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
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 20),
              const Text(
                'Exit Chat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              const Text(
                'You will lose your current chat context. Are you sure you want to exit?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: ()  {
                        Navigator.of(context).pop(); // Close bottom sheet
                        try {
                          // onRestartChatAPI();
                          OrderService().triggerChatDismiss();
                        } catch (e) {
                          Navigator.of(context).pop(); // Fallback to Flutter navigation
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'EXIT CHAT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
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
                  crossAxisAlignment: message.isBot
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10,bottom: 10,left: message.isBot ? 0 : 14,right: 14),
                      decoration: BoxDecoration(
                        color: message.isBot
                          ? Color(int.parse(chatbotData.data.first.uiPreferences.botBubbleColor.replaceFirst('#', '0xFF')))
                          : Color(int.parse(chatbotData.data.first.uiPreferences.userBubbleColor.replaceFirst('#', '0xFF'))),
                        // borderRadius: BorderRadius.circular(16),
                        borderRadius: (message.isBot == false) ? BorderRadius.only(
                          topLeft:  const Radius.circular(8),
                          topRight: const Radius.circular(8),
                          bottomLeft: message.isBot ? Radius.circular(0) : Radius.circular(8),
                          bottomRight: message.isBot ? Radius.circular(8) : Radius.circular(0),
                        ) : null,
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
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isBot
                              ? Color(int.parse(chatbotData.data.first.uiPreferences.botBubbleFontColor.replaceFirst('#', '0xFF')))
                              : Color(int.parse(chatbotData.data.first.uiPreferences.userBubbleFontColor.replaceFirst('#', '0xFF'))),
                          fontSize: 16,
                          fontFamily: "Plus Jakarta Sans"
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (message.hasOptionButtons) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: _buildOptionButtons(message.optionButtons, message.id, context),
            ),
          ],
          // Store cards outside the row to avoid constraints
          if (message.hasStoreCards) ...[
            const SizedBox(height: 12),
            _buildStoreCards(message.stores, message.storesWidget),
          ],
          if (message.hasProductCards) ...[
            const SizedBox(height: 12),
            Transform.translate(
              offset: const Offset(0, 0),
              child: _buildProductCards(message.products, message.productsWidget),
            ),
          ],
          if (message.hasCartWidget) ...[
            const SizedBox(height: 12),
            _buildCartWidget(message.cartItems),
          ],
          if (message.hasChooseAddressWidget) ...[
            const SizedBox(height: 12),
            _buildChooseAddressWidget(message.addressOptions),
          ],
          if (message.hasChooseCardWidget) ...[
            const SizedBox(height: 12),
            _buildChooseCardWidget(message.cardOptions),
          ],
        ],
      ),
    );
  }

  // Removed welcome message UI

  Widget _buildGreetingOverlay(BuildContext context) {
    final String titleText = greetingData?.greeting.isNotEmpty == true
        ? greetingData!.greeting
        : 'Good evening';
    final String subtitleText = greetingData?.subtitle.isNotEmpty == true
        ? greetingData!.subtitle
        : 'Your intelligent life assistant is ready to help';

    final List<String> opts = (greetingData?.options ?? []).take(4).toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
                          'assets/images/ic_mainImg.svg',
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
                        'assets/images/ic_topStar.svg',
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
                        'assets/images/ic_topStar.svg',
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
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1.2,
                  color: Color(0xFF171212),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 323,
              child: Text(
                subtitleText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF6E4185),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Options grid 2x2
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: opts.map((opt) {
                  return _GreetingOptionTile(
                    text: opt,
                    onTap: () {
                      onSendMessage(opt);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300, // Border color
          width: 0.5, // Border width
        ),
      ),
      child: ClipOval(
        child: (chatbotData.data.isNotEmpty &&
               chatbotData.data.first.profileImage.isNotEmpty)
          ? Image.network(
              chatbotData.data.first.profileImage,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Fallback to default icon if image fails to load
                return const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                );
              },
            )
          : const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
      ),
    );
  }

  Widget _buildOptionButtons(List<String> options, String messageId, BuildContext context) {
    if (selectedOptionMessages.contains(messageId)) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) =>
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Color(
                      int.parse(chatbotData.data.first.uiPreferences.primaryColor.replaceFirst('#', '0xFF')))),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                onUpdateSelectedOptions({...selectedOptionMessages, messageId});
                onSendMessage(option);
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  option,
                  style: TextStyle(
                    color: Color(
                        int.parse(chatbotData.data.first.uiPreferences.primaryColor.replaceFirst('#', '0xFF'))),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )).toList(),
    );
  }

  // Removed unused _buildCustomServiceIcon due to simplified store model

  Widget _buildActionButtons(BuildContext context) {
    if (latestActionWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> actionButtons = [];
    // Handle see_more widgets
    for (final widget in latestActionWidgets.where((w) => w.type == WidgetEnum.see_more.value)) {
      for (final action in widget.seeMore) {
        actionButtons.add(
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              bool isApiLoading = state is ChatLoading;
              return _buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading ? () {} : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantScreen(
                        actionData: action,
                        onCheckout: (List<String> addedProducts) {
                          if (addedProducts.isNotEmpty) {
                            final productsMessage = addedProducts.join(',\n');
                            onSendMessage("I've added these items to my cart:\n\n$productsMessage");
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    }

    for (final widget in latestActionWidgets.where((w) => w.type == WidgetEnum.menu.value)) {
      for (final action in widget.menu) {
        actionButtons.add(
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              bool isApiLoading = state is ChatLoading;
              return _buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading ? () {} : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantMenuScreen(
                        actionData: action,
                        onCheckout: (List<String> addedProducts) {
                          if (addedProducts.isNotEmpty) {
                            final productsMessage = addedProducts.join(',\n');
                            onSendMessage("I've added these items to my cart:\n\n$productsMessage");
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    }

    for (final widget in latestActionWidgets.where((w) => w.type == WidgetEnum.add_address.value)) {
      for (final action in widget.addAddress) {
        actionButtons.add(
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              bool isApiLoading = state is ChatLoading;
              return _buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading ? () {} : () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => RestaurantMenuScreen(
                  //       actionData: action,
                  //     ),
                  //   ),
                  // );
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (_) => const AddressDetailsScreen()),
                ).then((result) {
                  if (result != null) {
                    print("Result: $result");
                  }
             });
                },
              );
            },
          ),
        );
      }
    }

     for (final widget in latestActionWidgets.where((w) => w.type == WidgetEnum.add_payment.value)) {
      for (final action in widget.addPayment) {
        actionButtons.add(
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              bool isApiLoading = state is ChatLoading;
              return _buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading ? () {} : () async {
                  
              final result = await AddCardBottomSheet.show(context);
                if (result != null) {
                  debugPrint('PM: ${result['paymentMethodId']} '
                      '${result['brand']} **** ${result['last4']}');
                }
                },
              );
            },
          ),
        );
      }
    }

    for (final widgetType in [WidgetEnum.add_more.value, WidgetEnum.proceed_to_checkout.value, WidgetEnum.cash_on_delivery.value]) {
      final widgets = latestActionWidgets.where((w) => w.type == widgetType);
      for (final widget in widgets) {
        for (final item in widget.rawItems) {
          final buttonText = item['button_text'] ?? item['title'] ?? 'Action';
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
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8E2FFD),
            height: 1.4,
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
            child: Center(
                              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 64,
                    maxHeight: 570, // Allow up to 550 + 20 padding
                  ),
                child: Container(
                  height: textFieldHeight + 20, // Dynamic height based on text field
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE9DFFB), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: null,
                              minLines: 1,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Color(0xFF242424),
                              ),
                              decoration: const InputDecoration(
                                hintText: 'How can zAIn help you today?',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                                isCollapsed: true,
                              ),
                              onChanged: (text) {
                                // Calculate new height based on text content
                                final textSpan = TextSpan(
                                  text: text.isEmpty ? 'How can zAIn help you today?' : text,
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
                                textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 120);
                                
                                final newHeight = (textPainter.height + 20).clamp(50.0, 550.0);
                                onUpdateTextFieldHeight(newHeight);
                              },
                              onSubmitted: isApiLoading ? null : (text) {
                                onSendMessage(text);
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  onScrollToBottom();
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Opacity(
                          opacity: isApiLoading ? 0.4 : 1.0,
                          child: GestureDetector(
                            onTap: isApiLoading
                                ? null
                                : () {
                                    onSendMessage(messageController.text);
                                    if (messageController.text.trim().isNotEmpty) {
                                      FocusScope.of(context).requestFocus(messageFocusNode);
                                    }
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      onScrollToBottom();
                                    });
                                  },
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: SvgPicture.asset(
                                'assets/images/ic_sendImg.svg',
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
          onAddToCart: (message, product, store) {  
            onSendMessage(message);
          },
          onHide: onHideStoreCards, // Use the callback from parent
        );
      },
    );
  }

  Widget _buildProductCards(List<Product> products, ChatWidget? productsWidget) {
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
            imageUrl: product.productImage.isNotEmpty ? product.productImage : null,
            onClick: () {
              if (productsWidget != null) {
                final Map<String, dynamic>? productJson = productsWidget.getRawProduct(index);
                OrderService().triggerProductOrder(productJson ?? {});
              }
            },
            onAddToCart: (message) {
              onSendMessage(message);
            },
          );
        },
      ),
    );
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
        print('Selected address: ${selectedAddress.name} - ${selectedAddress.address}');
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
}

class _GreetingOptionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GreetingOptionTile({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 162,
        height: 84,
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEF4FF), width: 1),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.4,
              color: Color(0xFF242424),
            ),
          ),
        ),
      ),
    );
  }
}
