import 'package:chat_bot/model/mygpts_model.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/model/chat_response.dart';
import 'package:chat_bot/model/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../services/callback_manage.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';

class ChatScreen extends StatefulWidget {
  final MyGPTsResponse chatbotData;
  const ChatScreen({super.key, required this.chatbotData});

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
        text: response.response,
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
    _setupWelcomeMessage();
    
    // Add keyboard listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageFocusNode.addListener(_onFocusChange);
    });
  }

  void _initializeSession() {
    _sessionId = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
  }

  void _setupWelcomeMessage() {
    setState(() {
      messages = [
        ChatMessage(
          id: DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),
          text: "Meet ${widget.chatbotData.data.first.name}\n${widget
              .chatbotData.data.first.uiPreferences.launcherWelcomeMessage}",
          isBot: true,
          showAvatar: false,
          hasQuickReplies: false,
          isWelcomeMessage: true,
        ),
      ];
    });
  }
  void _restartChatAPI() {
    setState(() {
      messages = [
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Meet ${widget.chatbotData.data.first.name}\n${widget.chatbotData.data.first.uiPreferences.launcherWelcomeMessage}",
          isBot: true,
          showAvatar: false,
          hasQuickReplies: false,
          isWelcomeMessage: true,
        ),
      ];

      _selectedOptionMessages.clear();
      _sessionId = "${DateTime.now().millisecondsSinceEpoch ~/ 1000}";
      _pendingMessage = null;
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
      ),
    );
  }
}

class _ChatScreenBody extends StatelessWidget {
  static const platform = MethodChannel('chat_bot_channel');
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final ScrollController scrollController;
  final MyGPTsResponse chatbotData;
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

  const _ChatScreenBody({
    required this.messageController,
    required this.messageFocusNode,
    required this.scrollController,
    required this.chatbotData,
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
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
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
      
            return Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      // Handle scroll notifications if needed
                      return false;
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: messages.length + (state is ChatLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show messages
                        if (index < messages.length) {
                          return _buildMessageBubble(messages[index], context);
                        }
      
                        // Show loader as last item when loading
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
                                      color: Color(int.parse(
                                          chatbotData.data.first.uiPreferences
                                              .botBubbleColor.replaceFirst(
                                              '#', '0xFF') ?? '0xFFE5E5FF')),
                                    borderRadius: BorderRadius.only(
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
                                          package: 'chat_bot',
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
                _buildInputArea(context),
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
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () => _showExitChatConfirmation(context),
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
            child: ClipOval(
              child: (chatbotData.data != null &&
                     chatbotData.data.isNotEmpty &&
                     chatbotData.data.first.profileImage != null &&
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
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chatbotData.data.first.name ?? 'Loading...', // Use API data
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'AI Assistant',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            bool isApiLoading = state is ChatLoading;
            return IconButton(
              icon: Icon(
                Icons.refresh,
                color: isApiLoading ? Colors.grey : Colors.black,
              ),
              onPressed: isApiLoading ? null : () => _showNewChatConfirmation(context),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: Colors.grey.shade300,
          height: 0.5,
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
    if (message.isWelcomeMessage) {
      return _buildWelcomeMessage(message);
    }

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
                          ? Color(int.parse(chatbotData.data.first.uiPreferences.botBubbleColor.replaceFirst('#', '0xFF') ?? '0xFFE5E5FF'))
                          : Color(int.parse(chatbotData.data.first.uiPreferences.userBubbleColor.replaceFirst('#', '0xFF') ?? '0xFF007AFF')),
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
                              ? Color(int.parse(chatbotData.data.first.uiPreferences.botBubbleFontColor.replaceFirst('#', '0xFF') ?? '0xFFE5E5FF'))
                              : Color(int.parse(chatbotData.data.first.uiPreferences.userBubbleFontColor.replaceFirst('#', '0xFF') ?? '0xFF007AFF')),
                          fontSize: 14,
                          fontFamily: "Arial"
                        ),
                      ),
                    ),
                    // if (message.hasRestaurantCards) ...[
                    //   const SizedBox(height: 12),
                    //   _buildRestaurantCards(),
                    // ],
                    // if (message.hasFoodCards) ...[
                    //   const SizedBox(height: 12),
                    //   _buildFoodCards(),
                    // ],
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
            // Move store cards outside to avoid padding constraints
            Transform.translate(
              offset: const Offset(-16, 0), // Offset to counteract parent padding
              child: _buildStoreCards(message.stores, message.storesWidget),
            ),
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

  Widget _buildWelcomeMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  bottom: 0,
                  child: Container(
                    width: 120,
                    height: 160,
                    child: Image.asset(
                      'assets/images/men.png',
                      package: 'chat_bot',// Replace with your image
                      width: 120,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if image fails to load
                        return Container(
                          width: 120,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 20,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 220),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.green],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      )
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.1),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Meet ${chatbotData.data.first.name ?? 'Eazy Assistant'}\n",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600, // SemiBold
                            ),
                          ),
                          TextSpan(
                            text: chatbotData.data.first.uiPreferences.launcherWelcomeMessage ?? 'Hi! I am your personal assistant. How can I help you today?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400, // Regular
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
        child: (chatbotData.data != null &&
               chatbotData.data.isNotEmpty &&
               chatbotData.data.first.profileImage != null &&
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
              border: Border.all(color: chatbotData.data.first.uiPreferences.primaryColor != null
                  ? Color(int.parse(chatbotData.data.first.uiPreferences.primaryColor.replaceFirst('#', '0xFF')))
                  : const Color(0xFF000000)),
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
                    color: chatbotData.data.first.uiPreferences.primaryColor != null
                        ? Color(int.parse(chatbotData.data.first.uiPreferences.primaryColor.replaceFirst('#', '0xFF')))
                        : const Color(0xFF000000),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          )).toList(),
    );
  }

  Widget _buildCustomServiceIcon(String imagePath) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          imagePath,
          package: 'chat_bot',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to default icon if image fails to load
            print('Image loading error: $error');
            print('Image path: $imagePath');
            return const Icon(Icons.restaurant, color: Colors.grey, size: 20);
          },
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
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom, // Add keyboard padding
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 0.5),
            )
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 5,
            //     offset: const Offset(0, -2),
            //   ),
            // ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      autofocus: false,
                      controller: messageController,
                      focusNode: messageFocusNode,
                      enabled: !isApiLoading,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Write a message',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: isApiLoading ? null : (text) {
                        onSendMessage(text);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          onScrollToBottom();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isApiLoading ? Colors.grey : Colors.blue, // Change color when disabled
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: isApiLoading ? Colors.grey[600] : Colors.white,
                    ),
                    onPressed: isApiLoading ? null : () {
                      onSendMessage(messageController.text);
                      // Only request focus when manually sending message via button
                      if (messageController.text
                          .trim()
                          .isNotEmpty) {
                        FocusScope.of(context).requestFocus(messageFocusNode);
                      }
                      Future.delayed(const Duration(milliseconds: 100), () {
                        onScrollToBottom();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreCards(List<Store> stores, ChatWidget? storesWidget) {
    return SizedBox(
      height: 290,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 65), // Changed from left: 70
        clipBehavior: Clip.none,
        itemCount: stores.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final store = stores[index];
          return SizedBox(
            width: 280,
            child: _buildStoreCard(store, storesWidget, index),
          );
        },
      ),
    );
  }

  // Add this method to build individual store card
  Widget _buildStoreCard(Store store, ChatWidget? storesWidget, int index) {
    return InkWell(
      onTap: () {
        if (storesWidget != null) {
          String? rawStoreJson = storesWidget.getRawStoreAsJsonString(index);
          print('Raw Store JSON: $rawStoreJson');
          OrderService().triggerStoreOrder(rawStoreJson ?? '');
        }
        print('Store clicked: ${store}');
        // OrderService().triggerStoreOrder(store);
        // Handle store card tap
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          )
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.08),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Image with Rating - Increased height
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    // gradient: const LinearGradient(
                    //   colors: [Color(0xFF4A90E2), Color(0xFF7ED321)],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: store.storeImage.isNotEmpty
                        ? Image.network(
                            store.storeImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultStoreImage(),
                          )
                        : _buildDefaultStoreImage(),
                  ),
                ),
                // Rating badge
                if (store.avgRating > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.black, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            store.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Service icons
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (store.supportedOrderTypes == 3) ...[
                        _buildCustomServiceIcon('assets/images/ic_delivery.png'),
                        const SizedBox(width: 8),
                        _buildCustomServiceIcon('assets/images/ic_pickup.png'),
                      ] else ...[
                        _buildCustomServiceIcon('assets/images/ic_pickup.png'),
                      ],
                      const SizedBox(width: 8),
                      if (store.tableReservations)
                        _buildCustomServiceIcon('assets/images/ic_dinein.png'),
                    ],
                  ),
                ),
              ],
            ),
            // Store Details - Reduced padding to accommodate larger image
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.storename,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${store.address.city} • ${store.distanceKm.toStringAsFixed(1)} km",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price and Status row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${store.currencyCode} ${store.averageCostForMealForTwo} for Two",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Status indicator moved here
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: store.storeIsOpen ? Colors.green[50] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Container(
                            //   width: 6,
                            //   height: 6,
                              // decoration: BoxDecoration(
                              //   color: store.storeIsOpen ? Colors.green : Colors.blue,
                              //   shape: BoxShape.circle,
                              //
                              // ),
                            // ),
                            Icon(
                              Icons.access_time_rounded, // Built-in Material icon
                              size: 12,
                              color: store.storeIsOpen ? Colors.green : Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              store.storeIsOpen ? "Open" : store.storeTag.isNotEmpty ? store.storeTag.replaceAll("Next At", "") : "Closed",
                              style: TextStyle(
                                fontSize: 11,
                                color: store.storeIsOpen ? Colors.green[700] : Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (store.cuisineDetails.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      store.cuisineDetails,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for default store image
  Widget _buildDefaultStoreImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF7ED321)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // _buildServiceIcon(Icons.favorite, Colors.green),
            // _buildServiceIcon(Icons.delivery_dining, Colors.blue),
            // _buildServiceIcon(Icons.restaurant_menu, Colors.orange),
          ],
        ),
      ),
    );
  }

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
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.08),
        //     blurRadius: 8,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
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
                            "${product.currency.toUpperCase()} ${product.finalPrice.toStringAsFixed(2)}",
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
                          String? rawProductJson = productsWidget.getRawProductAsJsonString(index);
                          print('Raw Product JSON: $rawProductJson');
                          OrderService().triggerProductOrder(rawProductJson ?? '');
                        }
                        print('Product URL: ${product.url}');
                        // OrderService().triggerProductOrder(product);
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
