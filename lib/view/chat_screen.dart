import 'package:chat_bot/data/model/mygpts_model.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:chat_bot/data/model/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../services/callback_manage.dart';
import 'package:chat_bot/widgets/store_card.dart';
import 'package:flutter/services.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:chat_bot/view/restaurant_menu_screen.dart';

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

  List<ChatMessage> messages = [];

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

    setState(() {
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

  void _handleChatResponse(ChatResponse response) {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    ChatWidget? storesWidget;
    ChatWidget? productsWidget;
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

    // Check if stores or products are present
    bool hasStores = storesWidget != null;
    bool hasProducts = productsWidget != null;

    setState(() {
      messages.add(ChatMessage(
        id: messageId,
        text: response.text,
        isBot: true,
        showAvatar: true,
        hasStoreCards: hasStores,
        hasProductCards: hasProducts,
        // Don't show option buttons if stores or products are present
        hasOptionButtons: !hasStores && !hasProducts && response.hasWidgets && response.optionsWidgets.isNotEmpty,
        optionButtons: !hasStores && !hasProducts && response.hasWidgets && response.optionsWidgets.isNotEmpty
            ? response.optionsWidgets.first.options
            : [],
        stores: storesWidget?.stores ?? [],
        products: productsWidget?.products ?? [],
        storesWidget: storesWidget,
        productsWidget: productsWidget,
      ));
      
      // Store action widgets for the action buttons
      _latestActionWidgets = response.widgets.where((widget) => 
        widget.type == 'see_more' ||
        widget.type == 'menu' ||
        widget.type == 'add_more' ||
        widget.type == 'proceed_to_checkout' ||
        widget.type == 'add_address' ||
        widget.type == 'add_payment'
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

  void _restartChatAPI() {
    setState(() {
      messages = [];

      _selectedOptionMessages.clear();
      _sessionId = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
      _pendingMessage = null;
      _latestActionWidgets.clear(); // Clear action widgets when restarting
    });
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
                // _showErrorToast(context, 'Something went wrong please try again later');
                BlackToastView.show(context, 'Something went wrong please try again later');
              }
            }
          },
          builder: (context, state) {
            // Send pending message if any
            if (pendingMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final event = await ChatLoadEvent.create(
                  message: pendingMessage!,
                  sessionId: sessionId, // Use existing session ID
                );
                context.read<ChatBloc>().add(event);
                onClearPendingMessage();
              });
            }
      
            if (state is ChatLoading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onScrollToBottom();
              });
            }
      
            final bool showGreetingOverlay = messages.isEmpty && greetingData != null;
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
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
                                    _buildBotAvatar(),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Color(
                                              int.parse(
                                                  chatbotData
                                                      .data
                                                      .first
                                                      .uiPreferences
                                                      .botBubbleColor
                                                      .replaceFirst('#', '0xFF'))),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 0.5,
                                          )
                                      ),
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
                    ),
                    _buildActionButtons(context),
                    _buildInputArea(context),
                  ],
                ),
                if (showGreetingOverlay) Positioned.fill(
                  child: IgnorePointer(
                    ignoring: false,
                    child: _buildGreetingOverlay(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
        ),
        onPressed: () {},
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 0.5,
              ),
            ),
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
        ],
      ),
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            bool isApiLoading = state is ChatLoading;
            return Row(
              children: [
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
              if (message.isBot && message.showAvatar) ...[
                _buildBotAvatar(),
                const SizedBox(width: 8),
              ] else if (message.isBot) ...[
                const SizedBox(width: 48),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: message.isBot
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10,bottom: 10,left: 14,right: 14),
                      decoration: BoxDecoration(
                        color: message.isBot
                          ? Color(int.parse(chatbotData.data.first.uiPreferences.botBubbleColor.replaceFirst('#', '0xFF')))
                          : Color(int.parse(chatbotData.data.first.uiPreferences.userBubbleColor.replaceFirst('#', '0xFF'))),
                        // borderRadius: BorderRadius.circular(16),
                        borderRadius: BorderRadius.only(
                          topLeft:  Radius.circular(8),
                          topRight: Radius.circular(8),
                          bottomLeft: message.isBot ? Radius.circular(0) : Radius.circular(8),
                          bottomRight: message.isBot ? Radius.circular(8) : Radius.circular(0),
                        ),
                        border: Border.all(
                          color: Colors.grey.shade300, // light gray
                          width: 0.5,
                        ),
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
                          fontSize: 14,
                          fontFamily: "Arial"
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
              offset: const Offset(-16, 0),
              child: _buildProductCards(message.products, message.productsWidget),
            ),
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

    return ConstrainedBox(
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
                    messageController.text = opt;
                    messageController.selection = TextSelection.collapsed(offset: opt.length);
                    FocusScope.of(context).requestFocus(messageFocusNode);
                  },
                );
              }).toList(),
            ),
          ),
        ],
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
    for (final widget in latestActionWidgets.where((w) => w.type == 'see_more')) {
      for (final action in widget.seeMore) {
        actionButtons.add(
          _buildActionButton(
            text: action.buttonText,
            onTap: () {
              // Navigate to restaurant menu screen for see_more actions
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantMenuScreen(
                    actionData: {
                      'buttonText': action.buttonText,
                      'title': action.title,
                      'subtitle': action.subtitle,
                      'storeCategoryId': action.storeCategoryId,
                      'keyword': action.keyword,
                    },
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    // Handle other action types
    for (final widgetType in ['menu', 'add_more', 'proceed_to_checkout', 'add_address', 'add_payment']) {
      final widgets = latestActionWidgets.where((w) => w.type == widgetType);
      for (final widget in widgets) {
        for (final item in widget.rawItems) {
          final buttonText = item['button_text'] ?? item['title'] ?? 'Action';
          actionButtons.add(
            _buildActionButton(
              text: buttonText,
              onTap: () {
                // Handle other action types - send message for now
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
        );
      },
    );
  }

  // Individual store card moved to `StoreCard` widget.

  // Add product cards method
  // Update _buildProductCards to pass the widget and index
  Widget _buildProductCards(List<Product> products, ChatWidget? productsWidget) {
    return SizedBox(
      height: 305,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 70),
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 200,
            child: _buildProductCard(product, productsWidget, index),
          );
        },
      ),
    );
  }

  // Update _buildProductCard to handle raw JSON  
  Widget _buildProductCard(Product product, ChatWidget? productsWidget, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: product.productImage.isNotEmpty
                  ? Image.network(
                      product.productImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultProductImage(),
                    )
                  : _buildDefaultProductImage(),
            ),
          ),
          // Product Details - Fixed height to prevent overflow
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "${product.currencySymbol}${product.finalPrice.toStringAsFixed(2)}",
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                          if (product.finalPriceList.discountPercentage > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              "${product.currencySymbol}${product.finalPriceList.basePrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {
                        if (productsWidget != null) {
                          // String? rawProductJson = productsWidget.getRawProductAsJsonString(index);
                          final Map<String, dynamic>? productJson = productsWidget.getRawProduct(index);
                          print('Product JSON: $productJson');
                          OrderService().triggerProductOrder(productJson ?? {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        "ORDER NOW",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for default product image
  Widget _buildDefaultProductImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Product Image',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
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
