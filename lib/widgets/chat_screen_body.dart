import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:chat_bot/widgets/message_speaker_button.dart';
import 'package:chat_bot/view/views.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/services/services.dart';

class ChatScreenBody extends StatelessWidget {
  // static const platform = MethodChannel('chat_bot_channel');
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final ScrollController scrollController;
  final MyGPTsResponse? chatbotData;
  final GreetingResponse? greetingData;
  final Set<String> selectedOptionMessages;
  final List<ChatMessage> messages;
  final Function(String, [String?, String?, String?, Map<String, dynamic>?]) onSendMessage;
  final Function(ChatResponse) onHandleChatResponse;
  final Function(List<ChatHistoryDetail>) onHandleChatHistoryResponse;
  final VoidCallback onScrollToBottom;
  final VoidCallback onLoadChatbotData;
  final VoidCallback onRestartChatAPI;
  final VoidCallback onRestartGreetingAPI;
  final Function(Set<String>) onUpdateSelectedOptions;
  final Function(List<ChatMessage>) onUpdateMessages;
  final String? pendingMessage;
  final Map<String, dynamic> apiData;
  final VoidCallback onClearPendingMessage;
  final String sessionId;
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
  final bool needToEndThisChat; // Add needToEndThisChat parameter
  final bool gotStripePaymentCallback; // Add gotStripePaymentCallback parameter
  final Function(bool) onUpdateGotStripePaymentCallback; // Add callback to update gotStripePaymentCallback
  final bool isFromHistory; // Add isFromHistory parameter
  final String? chatHistoryTitle; // Add chatHistoryTitle parameter

  const ChatScreenBody({
    required this.messageController,
    required this.messageFocusNode,
    required this.scrollController,
    this.chatbotData,
    this.greetingData,
    // required this.isLoadingData,
    required this.selectedOptionMessages,
    required this.messages,
    required this.onSendMessage,
    required this.onHandleChatResponse,
    required this.onHandleChatHistoryResponse,
    required this.onScrollToBottom,
    required this.onLoadChatbotData,
    required this.onRestartChatAPI,
    required this.onRestartGreetingAPI,
    required this.onUpdateSelectedOptions,
    required this.onUpdateMessages,
    required this.pendingMessage,
    required this.apiData,
    required this.onClearPendingMessage,
    required this.sessionId,
    required this.latestActionWidgets,
    required this.onHideStoreCards, // Add the callback parameter
    required this.onUpdateCartCount, // Add the callback parameter
    required this.totalCartCount, // Add the cart count parameter
    required this.cartBloc, // Add the cart bloc parameter
    required this.onStartSpeechRecording, // Add the start speech handler parameter
    required this.onStopSpeechRecording, // Add the stop speech handler parameter
    required this.onCancelSpeechRecording, // Add the cancel speech handler parameter
    required this.isRecording, // Add the recording state parameter
    required this.needToEndThisChat, // Add the needToEndThisChat parameter
    required this.gotStripePaymentCallback, // Add gotStripePaymentCallback parameter
    required this.onUpdateGotStripePaymentCallback, // Add callback to update gotStripePaymentCallback
    required this.isFromHistory, // Add the isFromHistory parameter
    required this.chatHistoryTitle, // Add the chatHistoryTitle parameter
  });

  String _to24HourWithSeconds(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return raw;

    // Already 24-hour time? Normalize seconds to ":00" if missing.
    final already24 = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(raw);
    if (already24 != null) {
      final h = int.tryParse(already24.group(1)!) ?? 0;
      final m = int.tryParse(already24.group(2)!) ?? 0;
      final s = already24.group(3);
      final hh = h.clamp(0, 23).toString().padLeft(2, '0');
      final mm = m.clamp(0, 59).toString().padLeft(2, '0');
      final ss = (s == null || s.isEmpty) ? '00' : (int.tryParse(s) ?? 0).clamp(0, 59).toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }

    // 12-hour format like "06:05 pm" or "12:05 am".
    final match12 = RegExp(r'^(\d{1,2}):(\d{2})\s*([ap]m)$', caseSensitive: false).firstMatch(raw);
    if (match12 == null) return raw;

    var hour = int.tryParse(match12.group(1)!) ?? 0;
    final minute = int.tryParse(match12.group(2)!) ?? 0;
    final suffix = match12.group(3)!.toLowerCase();

    hour = hour % 12; // 12 -> 0 before applying pm rule
    if (suffix == 'pm') hour += 12;

    final hh = hour.clamp(0, 23).toString().padLeft(2, '0');
    final mm = minute.clamp(0, 59).toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: isFromHistory ? buildAppBarForHistory(context) : buildAppBar(context),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  int cartCount = cartBloc.getTotalProductCount;
                  onUpdateCartCount(cartCount);
                  onHandleChatResponse(state.messages);
                  if (state.messages.orderConfirmedWidgets.isNotEmpty) {
                    if (state.messages.isOnlinePayment == false) {
                      context.read<CartBloc>().add(
                        CartFetchRequested(needToShowLoader: false),
                      );
                    }
                  }
                  if (state.messages.cartCount != null &&
                      state.messages.cartCount == 0) {
                    context.read<CartBloc>().add(
                      CartFetchRequested(needToShowLoader: false),
                    );
                  }
                } else if (state is ChatLoadedWithHistorySessionId) {
                  // Handle chat history response
                  print('ChatScreen: Chat history loaded with ${state.history.length} items');
                  onHandleChatHistoryResponse(state.history);
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
                      text: AppTranslations.somethingWentWrongTryLatter,
                      isBot: true,
                      showAvatar: true,
                    );

                    final updatedMessages = [...messages, errorMessage];
                    onUpdateMessages(updatedMessages);
                    onScrollToBottom();
                  } else {
                    BlackToastView.show(
                      context,
                      AppTranslations.somethingWentWrongTryLater,
                    );
                  }
                }
              },
            ),
            BlocListener<CartBloc, CartState>(
              listener: (context, state) {
                if (state is CartProductAdded) {
                  if (state.needToSendMessage) {
                    // onHideStoreCards();
                    // Product added to cart successfully
                    onSendMessage("I have updated the cart", null, null, state.storeCategoryId);
                  }
                } else if (state is CartLoaded) {
                  int cartCount = cartBloc.getTotalProductCount;
                  onUpdateCartCount(cartCount);
                  onUpdateGotStripePaymentCallback(false);
                } else if (state is CartEmpty) {
                  // Cart is empty, set count to 0
                  print('CartBloc CartEmpty: Setting cart count to 0');
                  onUpdateCartCount(0);
                  onUpdateGotStripePaymentCallback(false);
                }else if (state is CartError) {
                  BlackToastView.show(
                    context,
                    state.message,
                  );
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
                    staffId: apiData['scheduleLaterStaffId'] ?? "",
                    serviceRequestedTime: apiData['serviceRequestedTime'] ?? "",
                    storeCategoryId: apiData['storeCategoryId'] ?? "",
                    prescriptionImageUrls: apiData['prescription_image_urls'] != null
                        ? (apiData['prescription_image_urls'] as List)
                            .map((e) => e.toString())
                            .toList()
                        : null,
                    tableBookingData: apiData['table_booking'] ?? {},
                    hotelDestinationData: apiData['hotel_booking'] ?? {},
                    carPickupData: apiData['car_booking'] ?? {},
                    flightBookingData: apiData['flight_booking'] ?? {},
                    packageDeliveryData: apiData['package_delivery'] ?? {},
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

              final bool showGreetingOverlay = messages.isEmpty;
              return Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Dismiss keyboard when tapping outside input area
                        FocusScope.of(context).unfocus();
                      },
                      behavior: HitTestBehavior.translucent,
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
                                  return buildMessageBubble(
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
                                child: buildGreetingOverlay(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  buildActionButtons(context),
                  if (isFromHistory == false) ...[
                  Stack(
                    children: [
                      if (needToEndThisChat == true)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F0FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppTranslations.sessionEnded,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  color: const Color(0xFF242424),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                        width: 190,
                                        height: 47,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: AppConstants.appThemeColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: state is ChatLoading
                                                ? null
                                                : () => showNewChatConfirmation(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12, // reduced from 38 so text fits
                                                vertical: 14,
                                              ),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                AppTranslations.startNewChat,
                                                style: AppTextStyles.button.copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                            ],
                          ),
                        )
                         
                      else ...[
                        Column(
                          children: [
                            if (showGreetingOverlay == true) ...[
                              _buildGreetingOptions(),
                            ],
                             buildInputArea(context),
                          ],
                        ),
                        // if (isRecording) _buildInputRecordingArea(context),
                      ]
                    ],
                  ),
                  ]else ...[
                    const SizedBox(height: 50),
                  ]
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Calculate total cart count from all messages
  int getTotalCartCount() {
    return totalCartCount;
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return  AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 1,
      // toolbarHeight: 64,
      leadingWidth: 48,
      titleSpacing: 0,
      centerTitle: false,
      leading: IconButton(
        icon: SvgPicture.asset(
          AssetPath.get('images/ic_sideMeu.svg'),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
        onPressed: () async {
         final result = await Navigator.push(
            context,
            AppLocale.materialRoute(
              builder: (context) => ProfileSettingScreen(greetingData: greetingData),
            ),
          );

                if (result != null && result is Map) {
            final action = result['action'];
            
            if (action == 'new_chat_selected') {
              onRestartChatAPI();
            }
          }
        },
      ),
      //  IconButton(
      //   icon: SvgPicture.asset(
      //     AssetPath.get('images/ic_history.svg'),
      //     width: 40,
      //     height: 40,
      //     fit: BoxFit.cover,
      //   ),
      //   onPressed: () async {
      //     Navigator.push(
      //       context,
      //       AppLocale.materialRoute(
      //         builder: (context) => const ProfileSettingScreen(),
      //       ),
      //     );
      //     // print('ChatScreen: $totalCartCount');
      //     // final result = await Navigator.push(
      //     //   context,
      //     //   MaterialPageRoute(builder: (context) => ChatHistoryScreen()),
      //     // );

      //     // if (result != null && result is Map) {
      //     //   final action = result['action'];
            
      //     //   if (action == 'new_chat_selected') {
      //     //     onRestartChatAPI();
      //     //   }
      //     // }
      //   },
      // ),
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AssetPath.get('images/ic_header_logo.svg'),
              width: 55,
              height: 24,
              fit: BoxFit.cover,
            ),
            ValueListenableBuilder<String>(
              valueListenable: Utility.locationNotifier,
              builder: (context, locationValue, _) {
                final displayLocation = locationValue.trim().isNotEmpty
                    ? locationValue.trim()
                    : AppTranslations.selectLocation;
                return GestureDetector(
                  onTap: () {
                    OrderService().triggerClickManageScreenOpen({
                      'flow': 'ChangeCountry',
                      'screenName': 'ChangeCountryScreen',
                      'action': 'ChangeCountryScreen',
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          displayLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF8E2FFD),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF8E2FFD),
                        size: 25,
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            return BlocBuilder<ChatBloc, ChatState>(
              builder: (context, chatState) {
                bool isApiLoading = chatState is ChatLoading;
                int cartCount = getTotalCartCount();
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
                                : () => showNewChatConfirmation(context),
                      ),
                    ],
                    // if (greetingData?.personaTitle.isNotEmpty ?? false) ...[
                    //   IconButton(
                    //     icon: SvgPicture.asset(
                    //     AssetPath.get('images/ic_chat_profile.svg'),
                    //     width: 40,
                    //     height: 40,
                    //   ),
                    //     onPressed: () {
                    //       // OrderService().triggerPrescriptionScreenOpen({});
                    //       Navigator.push(
                    //         context,
                    //         PageRouteBuilder(
                    //           opaque: false,
                    //           pageBuilder: (context, animation, secondaryAnimation) => PopupOverlayScreen(greetingData: greetingData),
                    //           transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    //             return FadeTransition(
                    //               opacity: animation,
                    //               child: child,
                    //             );
                    //           },
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ],
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
                                PositionedDirectional(
                                  end: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppConstants.appThemeColor,
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
                                  if (isFromHistory == true) {
                                    Navigator.push(
                                    context,
                                    AppLocale.materialRoute(
                                      builder:
                                          (context) => BlocProvider(
                                            create: (context) => CartBloc(),
                                            child: CartScreen(
                                              needToEndThisChat: isFromHistory,
                                              onCheckout: (message, storeCategoryId) {
                                                onSendMessage(message, null, null, storeCategoryId);
                                              },
                                            ),
                                          ),
                                    ),
                                  );
                                  }else {
                                    Navigator.push(
                                    context,
                                    AppLocale.materialRoute(
                                      builder:
                                          (context) => BlocProvider(
                                            create: (context) => CartBloc(),
                                            child: CartScreen(
                                              needToEndThisChat: needToEndThisChat,
                                              onCheckout: (message, storeCategoryId) {
                                                onSendMessage(message, null, null, storeCategoryId);
                                              },
                                            ),
                                          ),
                                    ),
                                  );
                                  }
                                },
                      ),
                    IconButton(
                      icon: SvgPicture.asset(
                        AssetPath.get('images/ic_close.svg'),
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () => showExitChatConfirmation(context),
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

  PreferredSizeWidget buildAppBarForHistory(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 1,
      leadingWidth: 0,
      leading: const SizedBox.shrink(), // Remove leading widget
      title:  Text(
        chatHistoryTitle ?? '',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    // height: 1.2,
                    color: Color(0xFF171212),
                  ),
      ),
      centerTitle: false, // Align title to the left
      titleSpacing: 16, // Add left padding for proper alignment
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            AssetPath.get('images/ic_close.svg'),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(color: Colors.grey.shade300, height: 0),
      ),
    );
  }

  void showNewChatConfirmation(BuildContext context) {
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
              Text(
                AppTranslations.confirmStartNewChat,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
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
                            color: AppConstants.appThemeColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          AppTranslations.cancelUpper,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.appThemeColor,
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
                            color: AppConstants.appThemeColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            height: 62,
                            alignment: Alignment.center,
                            child: Text(
                              AppTranslations.yesUpper,
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

  void showExitChatConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 16),
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
                AppTranslations.leaveChat,
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20),
               Text(
                AppTranslations.leaveChatBody,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 14, 
                  color: Color(0xFF242424), 
                  fontWeight: FontWeight.w400
                  ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 40),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
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
                           backgroundColor: Colors.white,
                          foregroundColor: AppConstants.appThemeColor,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppConstants.appThemeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              AppTranslations.yesGoToEazyApp,
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
                 const SizedBox(height: 16),
                   SizedBox(
                    width: double.infinity,
                    child: SizedBox(
                      height: 62,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: AppConstants.appThemeColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppTranslations.stayInChat,
                          style: AppTextStyles.button.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.appThemeColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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

  Widget buildMessageBubble(ChatMessage message, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat bubble content
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      message.isBot
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.only(
                        top: 10,
                        bottom: 10,
                        start: message.isBot ? 0 : 14,
                        end: 14,
                      ),
                      decoration: BoxDecoration(
                        color:
                            message.isBot
                                ? Color(int.parse('0xFFFFFFFF'))
                                : Color(int.parse('0xFFEDF3FF')),
                        border: message.isBot == false
                            ? Border.all(
                                color: const Color(0xFFE9DFFB),
                                width: 1,
                              )
                            : null,
                        // borderRadius: BorderRadius.circular(16),
                        borderRadius:
                            (message.isBot == false)
                                ? const BorderRadiusDirectional.only(
                                  topStart: Radius.circular(8),
                                  topEnd: Radius.circular(8),
                                  bottomStart: Radius.circular(8),
                                  bottomEnd: Radius.circular(0),
                                )
                                : null,
                      ),
                      child:
                          hasMarkdownSyntax(message.text)
                              ? Html(
                                data: markdownToHtml(message.text),
                                style: {
                                  "body": Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    fontSize: FontSize(16),
                                    fontFamily: "Plus Jakarta Sans",
                                    color:
                                        message.isBot
                                            ? AppTheme.chatBotMessageColor
                                            : AppTheme.chatUserMessageColor,
                                  ),
                                  "strong": Style(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        message.isBot
                                            ? AppTheme.chatBotMessageColor
                                            : AppTheme.chatUserMessageColor,
                                  ),
                                  "em": Style(
                                    fontStyle: FontStyle.italic,
                                    color:
                                        message.isBot
                                            ? AppTheme.chatBotMessageColor
                                            : AppTheme.chatUserMessageColor,
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
                                          ? AppTheme.chatBotMessageColor
                                          : AppTheme.chatUserMessageColor,
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
              padding: const EdgeInsetsDirectional.only(start: 50.0),
              child: buildOptionButtons(
                message.optionButtons,
                message.id,
                context,
              ),
            ),
          ],
          // Store cards outside the row to avoid constraints
          if (message.hasStoreCards) ...[
            const SizedBox(height: 4), //12
            buildStoreCards(message.stores, message.storesWidget),
          ],
          if (message.hasProductCards) ...[
            const SizedBox(height: 4), //12
            Transform.translate(
              offset: const Offset(0, 0),
              child: buildProductCards(
                message.products,
                message.productsWidget,
              ),
            ),
          ],
          if (message.hasCartWidget) ...[
            const SizedBox(height: 4), //12
            buildCartWidget(message.cartItems),
          ],
          if (message.hasRestaurantSectionsWidget) ...[
            const SizedBox(height: 4), //12
            buildRestaurantSectionsWidget(context, message.restaurantSectionsItems),
          ],
          if (message.hasHotelDestinationSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildHotelDestinationWidget(message.hotelDestinationItems),
          ],
          if (message.hasCarPickupPlacesSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildCarPickupPlacesWidget(message.carPickupPlacesItems),
          ],
          if (message.hasCarDropoffPlacesSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildCarDropoffPlacesWidget(message.carDropoffPlacesItems),
          ],
          if (message.hasFlightOriginPlacesSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildFlightOriginPlacesWidget(message.flightOriginPlacesItems),
          ],
          if (message.hasFlightDestinationPlacesSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildFlightDestinationPlacesWidget(message.flightDestinationPlacesItems),
          ],
          if (message.hasHotelsSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildHotelsWidget(message.hotelsItems),
          ],
          if (message.hasCarRentalsSearchSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildCarRentalsSearchWidget(message.carRentalsSearchItems),
          ],
          if (message.hasFlightsSearchSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildFlightsSearchWidget(message.flightsSearchItems),
          ],
          if (message.hasHotelOrderSummarySectionWidget) ...[
            const SizedBox(height: 4), //12
            buildHotelOrderSummaryWidget(message.hotelOrderSummaryItems),
          ],
          if (message.hasCarOrderSummarySectionWidget) ...[
            const SizedBox(height: 4), //12
            buildCarOrderSummaryWidget(message.carOrderSummaryItems),
          ],
          if (message.hasFlightOrderSummarySectionWidget) ...[
            const SizedBox(height: 4), //12
            buildFlightOrderSummaryWidget(message.flightOrderSummaryItems),
          ],
          if (message.hasHotelBookingConfirmedSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildHotelBookingConfirmedWidget(message.hotelBookingConfirmedItems),
          ],
          if (message.hasCarBookingConfirmedSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildCarBookingConfirmedWidget(message.carBookingConfirmedItems),
          ],
          if (message.hasFlightBookingConfirmedSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildFlightBookingConfirmedWidget(message.flightBookingConfirmedItems),
          ],
          if (message.hasCustomerProfileDetailsSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildCustomerProfileDetailsWidget(message.customerProfileDetailsItems),
          ],
          if (message.hasServicesDeliveryOptionsWidget) ...[
            const SizedBox(height: 4), //12
            buildServicesDeliveryOptionsWidget(message.servicesDeliveryOptions),
          ],
          if (message.hasChooseAddressWidget) ...[
            const SizedBox(height: 4), //12
            buildChooseAddressWidget(message.addressOptions),
          ],
          if (message.hasChooseCardWidget) ...[
            const SizedBox(height: 4), //12
            buildChooseCardWidget(message.cardOptions),
          ],
          if (message.hasOrderSummaryWidget) ...[
            const SizedBox(height: 4), //12
            buildOrderSummaryWidget(message.orderSummaryItems),
          ],
          if (message.hasOrderConfirmedWidget) ...[
            const SizedBox(height: 4), //12
            buildOrderConfirmedWidget(message.orderConfirmedWidget!),
          ],
          if (message.hasPackageTypesSectionWidget) ...[
            const SizedBox(height: 4), //12
            buildPackageTypesWidget(message.packageTypesItems),
          ],
          if (message.text.trim().isNotEmpty && message.isBot) ...[
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: message.isBot ? 0 : 50,
                end: message.isBot ? 50 : 0,
              ),
              child: MessageSpeakerButton(
                messageId: message.id,
                text: message.text,
                isBot: message.isBot,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to check if text contains markdown syntax
  bool hasMarkdownSyntax(String text) {
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
  String markdownToHtml(String text) {
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

  Widget _buildWeatherTextSection(double contentWidth) {
    final String? weatherText = greetingData?.weatherText;
    final bool hasWeatherText =
        weatherText != null && weatherText.isNotEmpty;

    if (hasWeatherText) {
      return SizedBox(
        width: contentWidth,
        child: Text(
          weatherText,
          textAlign: TextAlign.center,
          style: AppTextStyles.launchSubtitle.copyWith(
            color: const Color(0xFF7085AE),
          ),
        ),
      );
    }

    return SizedBox(
      width: contentWidth,
      height: 56,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: contentWidth * 0.9,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: contentWidth * 0.8,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: contentWidth * 0.7,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGreetingOverlay(BuildContext context) {
    // Get device width and calculate dynamic width with 20 spacing on each side
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double contentWidth = deviceWidth - 40; // 20 on left + 20 on right

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 20, end: 20, top: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 75,
                  width: 75,
                  child: SvgPicture.asset(
                        AssetPath.get('images/ic_LogoTutorial.svg'),
                        fit: BoxFit.contain,
                      ),
                ),
                SizedBox(
                  width: contentWidth,
                  child: _buildTitleWithHighlightedName(_greetingTitleText()),
                ),
                const SizedBox(height: 20),
                _buildWeatherTextSection(contentWidth),
                if (greetingData?.setupUserPreference == true) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            AppLocale.materialRoute(
                              builder: (context) => CompleteSetupFlowScreen(onCallback: (data) {
                                onRestartGreetingAPI();
                              }),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 313,
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F7FF),
                            border: Border.all(color: AppConstants.appThemeColor, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppTranslations.completeSetupCta,
                                style: AppTextStyles.launchSubtitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  height: 1.2,
                                  color: AppConstants.appThemeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (greetingData?.reminders.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _BirthdayReminderCard(
                    greetingReminder: greetingData?.reminders.first,
                    onBookRestaurant: () {
                      onSendMessage(
                        greetingData?.reminders.first.buttons.first ?? '',
                      );
                    },
                    onBrowseGifts: () {
                      onSendMessage(greetingData?.reminders.first.buttons.last ?? '');
                    },
                  ),
                ],
                // const SizedBox(height: 16),
                // // Weather information view
                // Container(
                //   width: contentWidth,
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 20,
                //     vertical: 16,
                //   ),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFF5F7FF),// Light purple background
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Text(
                //     weatherText,
                //     textAlign: TextAlign.center,
                //     style: AppTextStyles.launchWeather.copyWith(
                //       color: const Color(0xFF2F3C70), // Darker purple text
                //     ),
                //   ),
                // ),
                const SizedBox(height: 40),
                //Explore Our Services
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE0EBFF),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        AppTranslations.exploreOurServices,
                        style: AppTextStyles.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7085AE),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE0EBFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                //SET EXPLORE OPTIONS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryItem(
                        iconPath: 'ic_H_food.svg',
                        label: AppTranslations.labelFood,
                      ),
                      const SizedBox(width: 15),
                      _buildCategoryItem(
                        iconPath: 'ic_H_services.svg',
                        label: AppTranslations.labelServices,
                      ),
                      const SizedBox(width: 15),
                      _buildCategoryItem(
                        iconPath: 'ic_H_groceries.svg',
                        label: AppTranslations.labelGroceries,
                      ),
                      const SizedBox(width: 15),
                      _buildCategoryItem(
                        iconPath: 'ic_H_education.svg',
                        label: AppTranslations.labelEducation,
                      ),
                      const SizedBox(width: 15),
                      _buildCategoryItem(
                        iconPath: 'ic_H_travel.svg',
                        label: AppTranslations.labelTravel,
                      ),
                      const SizedBox(width: 15),
                      _buildCategoryItem(
                        iconPath: 'ic_H_pharmacy.svg',
                        label: AppTranslations.labelPharmacy,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                //Switch to Classic View
                Container(
                  width: contentWidth,
                  height: 138,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    border: Border.all(color: const Color(0xFFEEF4FF), width: 1),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text Block
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppTranslations.switchToClassicView,
                              style: AppTextStyles.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2F3C70),
                              ).copyWith(height: 1.2),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: 313,
                              child: Text(
                                AppTranslations.preferBrowsing,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8294B8),
                                ).copyWith(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Button
                      SizedBox(
                        width: 313,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Handle button tap
                            OrderService().triggerChatDismiss();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.appThemeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(313, 56),
                            maximumSize: const Size(313, 56),
                            fixedSize: const Size(313, 56),
                            elevation: 0,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppTranslations.goToEazyApp,
                                  style: AppTextStyles.body(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ).copyWith(height: 1.2),
                                ),
                                const SizedBox(width: 8),
                                Transform.rotate(
                                  angle: 3.14159, // 180 degrees in radians
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 14,
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
                
                // Options grid 1x1
                // ConstrainedBox(
                //   constraints: BoxConstraints(maxWidth: contentWidth),
                //   child: Column(
                //     children:
                //         opts.map((opt) {
                //           return Padding(
                //             padding: const EdgeInsets.only(bottom: 10),
                //             child: GreetingOptionTile(
                //               option: opt,
                //               onTap: () {
                //                 onSendMessage(opt.title);
                //               },
                //             ),
                //           );
                //         }).toList(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greetingTitleText() {
    final hour = Utility.currentHourInTimezone();
    final String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = AppTranslations.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      timeGreeting = AppTranslations.goodAfternoon;
    } else {
      timeGreeting = AppTranslations.goodEvening;
    }
    final userName = Utility.getName().trim();
    if (userName.isEmpty) {
      return AppTranslations.greetingWithHelp(timeGreeting);
    }
    return AppTranslations.greetingNamedWithHelp(timeGreeting, userName);
  }

  Widget _buildTitleWithHighlightedName(String text) {
    // Parse text to find name between quotes (handles both \"name\" and "name")
    final baseStyle = AppTextStyles.launchTitle.copyWith(
      color: const Color(0xFF171212),
    );
    final highlightedStyle = AppTextStyles.launchTitle.copyWith(
      color: AppConstants.appThemeColor,
    );

    final List<TextSpan> spans = [];
    // Pattern matches both escaped quotes (\") and regular quotes (")
    final RegExp quotePattern = RegExp(r'(?:\\"|")([^"]+)(?:\\"|")');

    int lastEnd = 0;
    final matches = quotePattern.allMatches(text);

    if (matches.isEmpty) {
      // No matches found, return regular text
      return Text(
        text,
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    }

    for (final match in matches) {
      // Add text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      // Add the highlighted name (without quotes)
      spans.add(TextSpan(
        text: match.group(1) ?? '',
        style: highlightedStyle,
      ));

      lastEnd = match.end;
    }

    // Add remaining text after the last match
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGreetingOptions() {
    final List<GreetingOption> opts = (greetingData?.options ?? []).toList();
    print('Options count: ${opts.length}');
    if (opts.isEmpty) {
      print('Options list is empty');
      return const SizedBox.shrink();
    }
    print('Rendering ${opts.length} options');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: opts.length,
          itemBuilder: (context, index) {
            final option = opts[index];
            print('Rendering option $index: ${option.title}');
            final displayText = option.emoji.isNotEmpty
                ? '${option.emoji} ${option.title}'
                : option.title;
            return GestureDetector(
              onTap: () {
                print('Selected option title: ${option.title}');
                onSendMessage(option.title);
              },
              child: Container(
                margin: EdgeInsetsDirectional.only(end: index < opts.length - 1 ? 12 : 0),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE0EBFF),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    displayText,
                    style: AppTextStyles.restaurantDescription.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF2F3C70),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildCategoryItem({
    String? iconPath,
    required String label,
  }) {
    assert(iconPath != null,
        'Either icon or iconPath must be provided');
    return GestureDetector(
      onTap: () {
        // Handle category tap
        // onSendMessage(label);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: SvgPicture.asset(
                    AssetPath.get('images/$iconPath'),
                    // width: 24,
                    // height: 24,
                    fit: BoxFit.contain,
                  )
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF2F3C70),
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget buildOptionButtons(
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
                      color: Color(int.parse('0xFF3F51B5')),
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
                          color: Color(int.parse('0xFF3F51B5')),
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

  Widget buildActionButtons(BuildContext context) {
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
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          Navigator.push(
                            context,
                            AppLocale.materialRoute(
                              builder: (context) {
                                return RestaurantScreen(
                                  actionData: action,
                                  isTableBookingFlow: widget.isTableBookingFlow,
                                  onTableBookingTap: (store) {
                                    onSendMessage('I want to book a table for ${store.storename}');
                                  },
                                  onDonationTap: (store, product) {
                                    onSendMessage('I want to donate for ${product?.productName ?? ''} from ${store.storename}');
                                  },
                                  onCheckout: (value) {
                                    if (isCartAPICalled == true) {
                                      onUpdateCartCount(
                                        cartBloc.getTotalProductCount,
                                      );
                                      onSendMessage("I have updated the cart", null, null, action.storeCategoryId);
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
              buildActionButton(
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
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {
                          print("widget: ${widget.toJson()}");
                          if (action.isTableBooking == true) {
                            OrderService().triggerOrderDetails(action.toJson());
                          }else if (widget.isCarBookingFlow == true) {
                            OrderService().triggerOrderDetails(widget.toJson());
                          }else if (widget.isHotelBookingFlow == true) {
                            OrderService().triggerOrderDetails(widget.toJson());
                          }else if (widget.isFlightBookingFlow == true) {
                            OrderService().triggerOrderDetails(widget.toJson());
                          } else {
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
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          if (action.storeCategoryId == FoodStoreCategoryId.healthCare.value) {
                             print("action: ${action.toJson()}");
                            OrderService().triggerStoreOrder(action.toJson());
                          }else if (action.storeTypeId ==
                                  FoodCategory.grocery.value ||
                              action.storeTypeId ==
                                  FoodCategory.pharmacy.value ||
                              action.storeTypeId ==
                                  FoodCategory.services.value) {
                            Navigator.push(
                              context,
                              AppLocale.materialRoute(
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
                                            null,
                                            null,
                                            action.storeCategoryId,
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
                              AppLocale.materialRoute(
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
                                            null,
                                            null,
                                            action.storeCategoryId,
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
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          OrderService().triggerAddressScreenOpen();
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
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {
                          OrderService().triggerAddCardOpen();
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.choose_date.value,
        )) {
          for (final action in widget.chooseDate) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap: () {
                  // OrderService().triggerChooseDateScreenOpen();
                   SelectTimeScreen.show(
                    context,
                    userId:
                        action.storeId ??
                        '', // TODO: Replace with actual userId
                    storeCategoryId:
                        action
                            .storeCategoryId, // TODO: Replace with actual storeCategoryId
                    timezone: ChatApiServices.instance.timezone ?? '',
                    isForTableBooking: true,
                    onTableBookingConfirm: (String selectedDateIso, String showDate) {
                      final Map<String, dynamic>? dict = {
                       "table_booking": {
                            "booking_date": selectedDateIso,
                            "booking_time": ""
                        },
                      };
                      onSendMessage(
                        'I want to book for $showDate',
                        null,
                        null,
                        null,
                        dict,
                      );
                    },
                  );
                },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.schedule_later.value,
        )) {
          for (final action in widget.scheduledLater) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {
                          if (action.storeCategoryId == FoodStoreCategoryId.services.value) {
                             //   Map<String, dynamic> obj = {
                              //   'storeId': action.storeId,
                              //   'storeIsOpen': action.storeIsOpen ?? true
                              // };
                         SelectDateTimeScreen.show(
                                    context,
                                    initialDate: DateTime.now(),
                                    storeId: action.storeId ?? '',
                                    latitude: Utility.getLatitude(),
                                    longitude: Utility.getLongitude(),
                                    timezone: ChatApiServices.instance.timezone ?? '',
                                    onConfirm: (String formattedDateTime, int timestamp) {
                                      // Handle the selected date and time
                                      print('Selected: $formattedDateTime (timestamp: $timestamp)');
                                      onSendMessage('I want to book service for: \n$formattedDateTime', '', timestamp.toString());
                                    },
                                   );
                        // OrderService().triggerScheduledLaterScreenOpen(obj);
                          }else if (action.storeCategoryId == FoodStoreCategoryId.healthCare.value) {
                              SelectTimeScreen.show(
                                context,
                                userId: action.storeId ?? '', // TODO: Replace with actual userId
                                storeCategoryId: action.storeCategoryId, // TODO: Replace with actual storeCategoryId
                                timezone: ChatApiServices.instance.timezone ?? '',
                                onConfirm: (String formattedDateTime, int timestamp) {
                                  // Handle confirmation
                                  print('Selected: $formattedDateTime (timestamp: $timestamp)');
                                  onSendMessage('I want to book an appointment for: \n$formattedDateTime', '', timestamp.toString());
                                },
                              );
                          }
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.staff_selection.value,
        )) {
          for (final action in widget.selectStaff) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {

                            final staffData = widget.rawItems.isNotEmpty 
                              ? widget.rawItems.first 
                              : <String, dynamic>{};
                          
                          // Print the JSON from 'widget' key when type == 'staff_selection'
                          print('JSON: $staffData');

                          Map<String, dynamic> obj = {
                          'startTime': staffData['startTime'],
                          'storeId': staffData['storeId'],
                          'categoryId': staffData['categoryId'],
                          'bookingType': staffData['bookingType']
                        };
                        // Map<String, dynamic> obj = Map<String, dynamic>.from(staffData);
                        print("obj: $obj");
                        OrderService().triggerSelectStaffScreenOpen(obj);
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.prescription_screen.value,
        )) {
          for (final action in widget.prescriptionScreen) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () async {

                        OrderService().triggerPrescriptionScreenOpen({});
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.online_payment_confirm_order.value,
        )) {
          for (final action in widget.onlinePaymentConfirmOrder) {
            // actionButtons.add(
              // buildActionButton(
                // text: action.buttonText,
                // onTap:
                    // isApiLoading
                    //     ? () {}
                    //     : () async {
                          final userId = ChatApiServices.instance.userId ?? '';
                          final orderId = action.orderId ?? '';
                          final data = <String, dynamic>{
                                "metadata": {
                                    "trigger": "order",
                                    "orderId": orderId,
                                    "userType": "user",
                                    "paymentAction": 2,
                                    "userId": userId
                                },
                                "userId": userId,
                                "amount": action.orderAmount ?? '',
                                "currency": action.currency ?? '',
                                "userType": "user",
                                "capture": false,
                                "paymentAction": 2,
                                "orderId": orderId
                            };
                            if (gotStripePaymentCallback == false) {
                               Timer(Duration(seconds: 1), () {
                                print("Timer completed");
                                // BlackToastView.show(context, 'Timer completed');
                                OrderService().triggerStripePlaceOrderScreenOpen(data);
                                Timer(Duration(seconds: 1), () {
                                  latestActionWidgets.remove(widget);
                                });
                              });
                            }
                        // },
              // ),
            // );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.add_dependent.value,
        )) {
          for (final action in widget.addDependent) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                        OrderService().triggerClickManageScreenOpen({'action': 'add_dependent_healthcare'});
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.see_available_rooms.value,
        )) {
          for (final action in widget.seeAvailableRooms) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading
                    ? () {}
                    : () => _openChooseRoomSheet(context, action),
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.hotel_booking_for_me.value,
        )) {
          for (final action in widget.hotelBookingForMe) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading
                    ? () {}
                    : () {
                        apiData['hotel_booking'] = _hotelBookingWithForMeDetails();
                         onSendMessage(action.buttonText);
                      },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.car_booking_date_time.value,
        )) {
          for (final action in widget.carBookingDateTime) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          OrderService().triggerClickManageScreenOpen({
                            'flow': 'CarBooking',
                            'screenName': 'CarBookingDateTime',
                            'isForReturn': widget.isForReturn,
                            'isForPickup': widget.isForPickup,
                            'pickup_date': apiData['car_booking']['pickup_date'],
                          });
                        },
              ),
            );
          }
        }

         for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.car_driver_details.value,
        )) {
          for (final action in widget.carDriverDetails) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          OrderService().triggerClickManageScreenOpen({
                            'flow': 'CarBooking',
                            'screenName': 'CarDriverDetails',
                          });
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.hotel_booking_for_other.value,
        )) {
          for (final action in widget.hotelBookingForOther) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading
                    ? () {}
                    : () {
                        OrderService().triggerClickManageScreenOpen({
                        'flow': 'HotelBooking',
                        'screenName': 'HotelBookingUserDetails',
                      });
                      },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.see_more_hotels.value,
        )) {
          for (final action in widget.seeMoreHotels) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading
                    ? () {}
                    : () => _openHotelSearchScreen(context, action),
              ),
            );
          }
        }

         for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.see_more_cars.value,
        )) {
          for (final action in widget.seeMoreCars) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading
                    ? () {}
                    : () => _openCarSearchScreen(context, action),
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.see_more_flights.value,
        )) {
          for (final action in widget.seeMoreFlights) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap: isApiLoading
                    ? () {}
                    : () => _openFlightSearchScreen(context, action),
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.add_dropoff_address.value,
        )) {
          for (final action in widget.addDropoffAddress) {
            actionButtons.add(
              buildActionButton(text: action.buttonText, onTap: isApiLoading ? () {} : () {
                OrderService().triggerClickManageScreenOpen({
                'flow': 'PackageDelivery',
                'screenName': 'PackageDeliveryDropoffAddress',
                'action': 'PackageDeliveryDropoffAddress',
                'selectAddressId': apiData['package_delivery']['pickup_address_id'] ?? '',
                'userId': ChatApiServices.instance.userId ?? '',
              });
              }),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.package_instructions.value,
        )) {
          for (final action in widget.packageInstructions) {
            actionButtons.add(
              buildActionButton(text: action.buttonText, onTap: isApiLoading ? () {} : () {
                OrderService().triggerClickManageScreenOpen({
                'flow': 'PackageDelivery',
                'screenName': 'PackageDeliveryInstructions',
                'action': 'PackageDeliveryInstructions',
                'packageTypeId': apiData['package_delivery']['package_type_id'] ?? '',
              });
              }),
            );
          }
        }

         for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.hotel_confirm_booking.value,
        )) {
          for (final action in widget.hotelConfirmBooking) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          final existing = apiData['hotel_booking'];
                          final Map<String, dynamic> hotelBooking;
                          if (existing is Map) {
                            hotelBooking = Map<String, dynamic>.from(existing);
                            hotelBooking['pricingToken'] = action.pricingToken;
                          } else {
                            hotelBooking = {
                              'pricingToken': action.pricingToken,
                            };
                          }
                          apiData['hotel_booking'] = hotelBooking;
                          onSendMessage(action.buttonText);
                        },
              ),
            );
          }
        }

         for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.flight_booking_date_time.value,
        )) {
          for (final action in widget.flightBookingDateTime) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          OrderService().triggerClickManageScreenOpen({
                            'flow': 'FlightBooking',
                            'screenName': 'TravelFlightDateScreen',
                            'isDeparture': widget.isDeparture,
                            'departure_date': apiData['flight_booking']['departure_date'],
                          });
                        },
              ),
            );
          }
        }

         for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.flight_add_member.value,
        )) {
          for (final action in widget.flightAddMember) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                           OrderService().triggerClickManageScreenOpen({
                            'flow': 'FlightBooking',
                            'screenName': 'TravelFlightPassengerScreen',
                          });
                        },
              ),
            );
          }
        }

        for (final widget in latestActionWidgets.where(
          (w) => w.type == WidgetEnum.flight_traveller_details.value,
        )) {
          for (final action in widget.flightTravellerDetails) {
            actionButtons.add(
              buildActionButton(
                text: action.buttonText,
                onTap:
                    isApiLoading
                        ? () {}
                        : () {
                          OrderService().triggerClickManageScreenOpen({
                            'flow': 'FlightBooking',
                            'screenName': 'TravelFlightPassengerDetailsScreen',
                            'adults': apiData['flight_booking']['adults'],
                            'children': apiData['flight_booking']['children'],
                            'infants': apiData['flight_booking']['infants'],
                          });
                        },
              ),
            );
          }
        }

        for (final widgetType in [
          WidgetEnum.add_more.value,
          WidgetEnum.proceed_to_checkout.value,
          WidgetEnum.cash_on_delivery.value,
          WidgetEnum.hotel_booking_dates.value,
          WidgetEnum.hotel_guests_rooms.value,
          WidgetEnum.trip_type_selection.value,
          WidgetEnum.flight_cabin_type.value,
        ]) {
          final widgets = latestActionWidgets.where(
            (w) => w.type == widgetType,
          );
          for (final widget in widgets) {
            for (final item in widget.rawItems) {
              final String buttonText =
                  (item['button_text'] ?? item['title'] ?? 'Action').toString();
              actionButtons.add(
                buildActionButton(
                  text: buttonText,
                  onTap: () {
                    if (widget.isTableBookingFlow && widget.isTableBookingTimeSlot) {
                      final bookingTime24 = _to24HourWithSeconds(buttonText);
                      final existing = apiData['table_booking'];
                      final Map<String, dynamic> tableBooking = {};
                      if (existing is Map) {
                        tableBooking.addAll(
                          Map<String, dynamic>.from(existing),
                        );
                      }
                      tableBooking['booking_time'] = bookingTime24;
                      final Map<String, dynamic>? dict = {
                        'table_booking': tableBooking,
                      };
                      onSendMessage(
                        buttonText,
                        null,
                        null,
                        null,
                        dict,
                      );
                    }else if (widget.type == WidgetEnum.hotel_booking_dates.value && widget.isHotelBookingFlow == true) {
                      OrderService().triggerClickManageScreenOpen({
                        'flow': 'HotelBooking',
                        'screenName': 'HotelBookingDates',
                      });
                    } else if (widget.type == WidgetEnum.hotel_guests_rooms.value && widget.isHotelBookingFlow == true) {
                      OrderService().triggerClickManageScreenOpen({
                        'flow': 'HotelBooking',
                        'screenName': 'HotelBookingGuests',
                      });
                    } else if (widget.type == WidgetEnum.trip_type_selection.value && widget.isFlightBookingFlow == true) {
                         final existing = apiData['flight_booking'];
                      final Map<String, dynamic> flightBooking;
                      if (existing is Map) {
                        flightBooking = Map<String, dynamic>.from(existing);
                        flightBooking['trip_type'] = item['trip_type'];
                      } else {
                        flightBooking = {
                          'trip_type': item['trip_type'],
                        };
                      }
                      apiData['flight_booking'] = flightBooking;
                      onSendMessage(buttonText);
                    }else if (widget.type == WidgetEnum.flight_cabin_type.value && widget.isFlightBookingFlow == true) {
                         final existing = apiData['flight_booking'];
                      final Map<String, dynamic> flightBooking;
                      if (existing is Map) {
                        flightBooking = Map<String, dynamic>.from(existing);
                        flightBooking['cabinType'] = item['cabinType'];
                      } else {
                        flightBooking = {
                          'cabinType': item['cabinType'],
                        };
                      }
                      apiData['flight_booking'] = flightBooking;
                      onSendMessage(buttonText);
                    }else if (widget.type == WidgetEnum.proceed_to_checkout.value && widget.isCarBookingFlow == true) {
                        final String availabilityDetailsToken = (item['availability_details_token'] ?? '');
                      apiData['car_booking']['availabilityToken'] = availabilityDetailsToken;
                      onSendMessage(buttonText);
                    }else if (widget.type == WidgetEnum.proceed_to_checkout.value && widget.isFlightBookingFlow == true) {
                      final String availabilityToken = (item['cabin_availability_token'] ?? '');
                      apiData['flight_booking']['cabin_availability_token'] = availabilityToken;
                      onSendMessage(buttonText);
                    }else if (widget.type == WidgetEnum.proceed_to_checkout.value && widget.isHotelBookingFlow == true) {
                      final String pricingToken = (item['pricingToken'] ?? '');
                      apiData['hotel_booking']['pricingToken'] = pricingToken;
                      onSendMessage(buttonText);
                    } else {
                      onSendMessage(buttonText);
                    }
                  },
                ),
              );
            }
          }
        }

        if (actionButtons.isEmpty) {
          return const SizedBox.shrink();
        }
        final proceedToCheckoutWidget = latestActionWidgets.cast<dynamic>().firstWhere(
          (w) => w?.type == WidgetEnum.proceed_to_checkout.value,
          orElse: () => null,
        );

        final isTableBookingTimeSlot = proceedToCheckoutWidget?.isTableBookingTimeSlot == true;
        final isTableBookingFlow = proceedToCheckoutWidget?.isTableBookingFlow == true;

        if (isTableBookingFlow && isTableBookingTimeSlot) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: double.infinity,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                // 2-row horizontal grid; tweak if your button style changes.
                height: 93,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 18,
                    // For horizontal grids, this controls each tile's width.
                    mainAxisExtent: 90,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: actionButtons.length,
                  itemBuilder: (context, index) => actionButtons[index],
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
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

  Widget buildActionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppConstants.appThemeColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            fontWeight: FontWeight.w400,
            color: AppConstants.appThemeColor,
          ),
        ),
      ),
    );
  }

  Widget buildInputArea(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        bool isApiLoading = state is ChatLoading;

        return Container(
          padding: EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
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
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 64,
                      maxHeight: 200, // Maximum height for the input container
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFFE9DFFB),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 180, // Max height for scrollable text
                              ),
                              child: SingleChildScrollView(
                                child: TextField(
                                  autofocus: false,
                                  controller: messageController,
                                  focusNode: messageFocusNode,
                                  enabled: !isApiLoading,
                                  textCapitalization: TextCapitalization.sentences,
                                  maxLines: null,
                                  minLines: 1,
                                  style: AppTextStyles.chatInput.copyWith(
                                    color: const Color(0xFF242424),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: isRecording ? AppTranslations.listening : AppTranslations.askMeAnything,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintStyle: AppTextStyles.chatInput.copyWith(
                                      color: Colors.grey,
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onSubmitted: isApiLoading
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
                          ),
                          const SizedBox(width: 10),
                          // Speech button - Single tap to start/stop recording
                          if (isRecording) ...[
                            Opacity(
                              opacity: isApiLoading ? 0.4 : 1.0,
                              child: GestureDetector(
                                onTap:
                                    isApiLoading
                                        ? null
                                        : () async {
                                          await onCancelSpeechRecording();
                                        },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  child: SvgPicture.asset(
                                    AssetPath.get('images/ic_RecClose.svg'),
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
                                        : () async {
                                          await onStopSpeechRecording();
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
                          ] else ...[
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
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStoreCards(List<Store> stores, ChatWidget? storesWidget) {
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
          isFromChatHistory: isFromHistory,
          isTableBookingFlow: storesWidget?.isTableBookingFlow ?? false,
          onAddToCart: (message, product, store, quantity) {
            onSendMessage(message);
          },
          onTableBookingTap: (store) {
            onSendMessage('I want to book a table for ${store.storename}');
          },
          onDonationTap: (store, product) {
            onSendMessage('I want to donate for ${product?.productName ?? ''} from ${store.storename}');
          },
          // onHide: onHideStoreCards,
          onQuantityChanged: (product, store, newQuantity, isIncrease) {
            if (store.storeTypeId == FoodCategory.grocery.value ||
                store.storeTypeId == FoodCategory.pharmacy.value) {
              onQuantityChangedForGrocery(
                context,
                product?.parentProductId ?? '',
                product?.childProductId ?? '',
                product?.unitId ?? '',
                store.storeId,
                store.storeCategoryId,
                store.storeTypeId ?? -111,
                product?.variantsCount ?? 0,
                newQuantity,
                isIncrease,
                product?.productName ?? '',
                product?.productImage ?? '',
              );
            } else {
              onQuantityChanged(
                context,
                product,
                store,
                newQuantity,
                isIncrease,
              );
            }
          },
          onAddToCartRequested: (product, store, doctor) {
            if (store.isDoctore == true && doctor != null) {
              // DoctorServiceTypeSheet.show(
              //   context,
              //   doctor: doctor,
              //   store: store,
              //   onServiceTypeSelected: (selectedType, selectedProduct) {
                  // Selected: selectedType (DoctorServiceType), selectedProduct (Product? from store)
                  // final int serviceLocationAt;
                  //  String productName;
                  // int? estimatedProductPrice;
                  // switch (doctor.storeLocationAt) {
                  //   case 1:
                  //     serviceLocationAt = 1;
                  //     productName = "Visit at doctor's clinic";
                  //     // estimatedProductPrice = doctor.pricing?.inCallFee ?? 0;
                  //     break;
                  //   case 2:
                  //     // serviceLocationAt = 2;
                  //     productName = "Doctor's at home";
                  //     // estimatedProductPrice = doctor.pricing?.outCallFee ?? 0;
                  //     break;
                  //   case 3:
                  //     // serviceLocationAt = 3;
                  //     productName = "Tele appointment";
                  //     // estimatedProductPrice = doctor.pricing?.teleCallFee ?? 0;
                  //     break;
                  // }

                  Map<String, dynamic> doctorParams = {
                    "estimatedProductPrice": doctor.consultation_fee ?? 0,
                    "productName": doctor.storeLocationAt == 1 ? "Visit at doctor's clinic" : doctor.storeLocationAt == 2 ? "Doctor's at home" : "Tele appointment",
                    "providerId": doctor.id,
                    "cartType": 2,
                    "storeId": store.storeId,
                    "newQuantity": 0,
                    "productId": "",
                    "userType": 1,
                    "unitId": "",
                    "isDoctorFlow": true,
                    "serviceLocationAt": doctor.storeLocationAt ?? 0,
                    "longitude": Utility.getLongitude(),
                    "latitude": Utility.getLatitude(),
                    "centralProductId": "",
                    "storeTypeId": store.storeTypeId ?? 25,
                    "storeCategoryId": store.storeCategoryId,
                    "offers": {
                      "discountValue": 0,
                      "offerFor": 0,
                      "offerId": "",
                      "offerName": {},
                      "status": 0,
                      "discountType": 0
                    },
                    "action": 1
                  };

                  // Add doctor first; then add product only after first API completes (one by one)
                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: store.storeId,
                      cartType: 2,
                      action: 1,
                      storeCategoryId: store.storeCategoryId,
                      newQuantity: 0,
                      storeTypeId: store.storeTypeId ?? 25,
                      productId: '',
                      centralProductId: '',
                      unitId: '',
                      doctorParams: doctorParams,
                      needToShowLoaderForCartFetch: store.products.isEmpty,
                      needToSendMessage: store.products.isEmpty ? true : false,
                    ),
                  );
                  if (store.products.isNotEmpty) {
                  // if (selectedProduct != null) {
                    cartBloc.stream
                        .firstWhere(
                          (state) =>
                              state is CartProductAdded ,
                        )
                        .then((state) {
                      if (state is CartProductAdded) {
                        cartBloc.add(
                          CartAddItemRequested(
                            storeId: store.storeId,
                            cartType: 2,
                            action: 1,
                            storeCategoryId: store.storeCategoryId,
                            newQuantity: 1,
                            storeTypeId: store.storeTypeId ?? -111,
                            productId: product?.childProductId ?? '',
                            centralProductId: product?.parentProductId ?? '',
                            unitId: product?.unitId ?? '',
                            needToShowLoaderForCartFetch: true,
                            needToSendMessage: true,
                          ),
                        );
                      }
                    });
                  }
                // },
              // );
            } else {
               if ((product != null && product.variantsCount > 1 &&
                    store.storeTypeId == FoodCategory.food.value) ||
                (product != null && product.variantsCount > 0 &&
                    (store.storeTypeId == FoodCategory.grocery.value ||
                        store.storeTypeId == FoodCategory.pharmacy.value ||
                        store.storeTypeId == FoodCategory.services.value))) {
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
                          onAddToCartForGrocery(
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
                        onAddToCartWithAddOns: onAddToCartWithAddOns,
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
                  productId: product?.childProductId ?? '',
                  centralProductId: product?.parentProductId ?? '',
                  unitId: product?.unitId ?? '',
                  needToShowLoaderForCartFetch: false,
                ),
              );
            }
            }
          },
        );
      },
    );
  }

  /// Handle adding products with addons to cart
  void onAddToCartWithAddOns(
    Product? product,
    Store? store,
    dynamic variant,
    List<Map<String, dynamic>> addOns,
    String selectedProductId,
  ) {
    try {

      
        num? addToCartId = getAddToCartOnId(selectedProductId);
        if (addToCartId != null) {
          
          print("addToCartId: $addToCartId");
          final existingProductQuantity = getExistingProductQuantity(selectedProductId, addToCartId);
          print("existingProductQuantity: $existingProductQuantity");

           cartBloc.add(
        CartAddItemRequested(
          storeId: store?.storeId ?? '',
          cartType: 1,
          // Default cart type
          action: 2,
          // Add action
          storeCategoryId: store?.storeCategoryId ?? '',
          newQuantity: existingProductQuantity + 1,
          storeTypeId: store?.storeTypeId ?? -111,
          productId: selectedProductId,
          centralProductId: product?.parentProductId ?? '',
          unitId: variant.unitId,
          addToCartOnId: addToCartId,
          // newAddOns: addOns,
          needToShowLoaderForCartFetch: false,
        ),
      );
        }else {
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
        }

      print("Added product with addons to cart: ${product?.productName ?? ''}");
    } catch (e) {
      print(
        'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
      );
    }
  }

  void onAddToCartForGrocery(
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int? addToCartOnId,
  ) {
    try {

         num? addToCartId = getAddToCartOnId(productId);
        if (addToCartId != null) {
          
          print("addToCartId: $addToCartId");
          final existingProductQuantity = getExistingProductQuantity(productId, addToCartId);
          print("existingProductQuantity: $existingProductQuantity");


      //TODO:- Add Quantity
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          // Default cart type
          action: 2,
          // Add action
          storeCategoryId: storeCategoryId,
          newQuantity: existingProductQuantity + 1,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartId,
          needToShowLoaderForCartFetch: false,
        ),
      );

        }else {

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
        }

      print("Added product to cart: ${productId}");
    } catch (e) {
      print(
        'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
      );
    }
  }

  void onQuantityChangedForGrocery(
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
        addToCartOnId = getAddToCartOnId(productId);
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
                cartData: cartBloc.cartData,
                productId: productId,
                centralProductId: parentProductId,
                storeTypeId: storeTypeId,
                // store: store,
                // product: product,
                onChooseClicked: () {
                  openGroceryCustomization(
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
                  final addToCartOnId = getAddToCartOnId(productId);
                  print("addCartOnID: $addToCartOnId");

                  final existingProductQuantity = getExistingProductQuantity(productId, addToCartOnId);
                  print("existingProductQuantity: $existingProductQuantity");

                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: storeId,
                      cartType: 1,
                      action: 2,
                      // Add action
                      storeCategoryId: storeCategoryId,
                      newQuantity: existingProductQuantity + 1,
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
        final addToCartOnId = getAddToCartOnId(productId);
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
        addToCartOnId = getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
      }
      int? existingProductQuantity;
      existingProductQuantity = newQuantity;
      if (addToCartOnId != null) {
        existingProductQuantity = getExistingProductQuantity(productId, addToCartOnId);
        print("existingProductQuantity: $existingProductQuantity");
      }
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 2,
          action: (existingProductQuantity == 1) ? 3 : 2,
          // Add/Update action
          storeCategoryId: storeCategoryId,
          newQuantity: (existingProductQuantity == 1) ? 0 : (existingProductQuantity ?? 0) - 1,
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

  void openGroceryCustomization(
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
              onAddToCartForGrocery(
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

  void onQuantityChanged(
    BuildContext context,
    Product? product,
    Store store,
    int newQuantity,
    bool isIncrease,
  ) {
    if (isIncrease == false && newQuantity == 1) {
      //TODO:- 0 Quantity
      int? addToCartOnId;
      if (product != null && product.variantsCount > 1) {
        addToCartOnId = getAddToCartOnId(product.childProductId);
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
          productId: product?.childProductId ?? '',
          centralProductId: product?.parentProductId ?? '',
          unitId: product?.unitId ?? '',
          addToCartOnId: addToCartOnId,
          needToShowLoaderForCartFetch: false,
        ),
      );
    } else if (newQuantity > 0 && isIncrease == true) {
      if (product != null && product.variantsCount > 1) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => CustomizationSummaryScreen(
                cartData: cartBloc.cartData,
                productId: product.childProductId,
                centralProductId: product.parentProductId,
                storeTypeId: store.storeTypeId ?? -111,
                store: store,
                product: product,
                onChooseClicked: () {
                  // When "I'll choose" is clicked, open ProductCustomizationScreen
                  openProductCustomization(context, product, store);
                },
                onRepeatClicked: () {
                  //TODO:- Add Quantity
                  final addToCartOnId = getAddToCartOnId(
                    product.childProductId,
                  );
                  print("addCartOnID: $addToCartOnId");

                  final existingProductQuantity = getExistingProductQuantity(product.childProductId, addToCartOnId);
                  print("existingProductQuantity: $existingProductQuantity");

                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: store.storeId,
                      cartType: 1,
                      action: 2,
                      // Add action
                      storeCategoryId: store.storeCategoryId,
                      newQuantity: existingProductQuantity + 1,
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
            productId: product?.childProductId ?? '',
            centralProductId: product?.parentProductId ?? '',
            unitId: product?.unitId ?? '',
            needToShowLoaderForCartFetch: false,
          ),
        );
      }
    } else {
      //TODO:- Remove Quantity
      int? addToCartOnId;
      if (product != null && product.variantsCount > 1) {
        addToCartOnId = getAddToCartOnId(product.childProductId);
        print("addCartOnID: $addToCartOnId");
      }
      int? existingProductQuantity;
      existingProductQuantity = newQuantity;
      if (addToCartOnId != null) {
        existingProductQuantity = getExistingProductQuantity(product?.childProductId ?? '', addToCartOnId);
        print("existingProductQuantity: $existingProductQuantity");
      }
      cartBloc.add(
        CartAddItemRequested(
          storeId: store.storeId,
          cartType: 2,
          action: (existingProductQuantity == 1) ? 3 : 2,
          // Add/Update action
          storeCategoryId: store.storeCategoryId,
          newQuantity: (existingProductQuantity == 1) ? 0 : (existingProductQuantity ?? 0) - 1,
          storeTypeId: store.storeTypeId ?? -111,
          productId: product?.childProductId ?? '',
          centralProductId: product?.parentProductId ?? '',
          unitId: product?.unitId ?? '',
          addToCartOnId: addToCartOnId,
          needToShowLoaderForCartFetch: false,
        ),
      );
    }

    // Update cart totals
    // _updateCartTotals();
  }

   /// Get addToCartOnId from cart data for a specific product
  dynamic getAddToCartOnId(String productId) {
    try {
      // Find all products with matching ID and get the last one's addToCartOnId
      final matchingProducts = cartBloc.cartData
          .expand((cart) => cart.sellers)
          .expand((seller) => seller.products)
          .where((product) => product.id == productId)
          .toList();

      if (matchingProducts.isEmpty) {
        return null;
      }

      // Return addToCartOnId from the last matching product
      return matchingProducts.last.addToCartOnId;
    } catch (e) {
      print('Error getting addToCartOnId: $e');
      return null;
    }
  }

  dynamic getExistingProductQuantity(String productId, num addToCartOnId) {
    try {
      // Find all products with matching ID and addToCartOnId
      final matchingProducts = cartBloc.cartData
          .expand((cart) => cart.sellers)
          .expand((seller) => seller.products)
          .where((product) => product.id == productId && product.addToCartOnId == addToCartOnId)
          .toList();

      if (matchingProducts.isEmpty) {
        return null;
      }

      // Return quantity from the last matching product
      return matchingProducts.last.quantity?.value ?? 0;
    } catch (e) {
      print('Error getting existing product quantity: $e');
      return null;
    }
  }

  /// Open ProductCustomizationScreen with proper callbacks
  void openProductCustomization(
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
            onAddToCartWithAddOns: onAddToCartWithAddOns,
          ),
    );
  }

  Widget buildProductCards(
    List<Product> products,
    ChatWidget? productsWidget,
  ) {
    return Container(
      height: isFromHistory ? 187 : 232,
      // color: Colors.red,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.only(start: 6),
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final product = products[index];
          final String priceText = formatCurrency(
            product.currencySymbol,
            product.finalPriceList.finalPrice,
          );
          final String basePriceText = formatCurrency(
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
            isFromChatHistory: isFromHistory,
            onClick: () {
              if (isFromHistory) {
                return;
              }
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
                onQuantityChangedForGrocery(
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
                onQuantityChangedMenuItem(
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
                  AppTranslations.toastStoreClosedTryLater,
                );
                return;
              } else if (product.instock == false &&
                  (product.storeTypeId == FoodCategory.grocery.value ||
                      product.storeTypeId == FoodCategory.pharmacy.value)) {
                print('Product is not in stock');
                BlackToastView.show(
                  context,
                  AppTranslations.toastProductNotInStock,
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
                            onAddToCartForGrocery(
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
                  final addToCartOnId = getAddToCartOnId(productId);
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

                            num? addToCartId = getAddToCartOnId(selectedProductId);
                            if (addToCartId != null) {
                              
                              print("addToCartId: $addToCartId");
                              final existingProductQuantity = getExistingProductQuantity(selectedProductId, addToCartId);
                              print("existingProductQuantity: $existingProductQuantity");


                              
                            //TODO:- Add Quantity
                            cartBloc.add(
                              CartAddItemRequested(
                                storeId: product.storeId ?? '',
                                cartType: 1,
                                // Default cart type
                                action: 2,
                                // Add action
                                storeCategoryId: product.storeCategoryId ?? '',
                                newQuantity: existingProductQuantity + 1,
                                // Add 1 item
                                storeTypeId: product.storeTypeId ?? -111,
                                productId: selectedProductId,
                                centralProductId: centralProductId,
                                unitId: variant?.unitId ?? '',
                                // newAddOns: addOns,
                                addToCartOnId: addToCartId, 
                                needToShowLoaderForCartFetch: false,
                              ),
                            );
                            }else {

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
                            }
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

  void onQuantityChangedMenuItem(
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
          addToCartOnId = getAddToCartOnId(productId);
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
                  cartData: cartBloc.cartData,
                  productId: productId,
                  centralProductId: centralProductId,
                  storeTypeId: storeTypeId,
                  onChooseClicked: () {
                    // When "I'll choose" is clicked, open ProductCustomizationScreen
                    openProductCustomizationMenuItem(
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
                    final addToCartOnId = getAddToCartOnId(productId);
                    print("addCartOnID: $addToCartOnId");

                    final existingProductQuantity = getExistingProductQuantity(productId, addToCartOnId);
                    print("existingProductQuantity: $existingProductQuantity");

                    cartBloc.add(
                      CartAddItemRequested(
                        storeId: storeId,
                        cartType: 1,
                        action: 2,
                        // Add action
                        storeCategoryId: storeCategoryId,
                        newQuantity: existingProductQuantity + 1,
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
          addToCartOnId = getAddToCartOnId(productId);
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

  void openProductCustomizationMenuItem(
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
                    onAddToCartWithAddOnsMenuItem(
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
  void onAddToCartWithAddOnsMenuItem(
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

        num? addToCartId = getAddToCartOnId(selectedProductId);
        if (addToCartId != null) {
          
          print("addToCartId: $addToCartId");
          final existingProductQuantity = getExistingProductQuantity(selectedProductId, addToCartId);
          print("existingProductQuantity: $existingProductQuantity");



      //TODO:- Add Quantity
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          // Default cart type
          action: 2,
          // Add action
          storeCategoryId: storeCategoryId,
          newQuantity: existingProductQuantity + 1,
          storeTypeId: storeTypeId,
          productId: selectedProductId,
          centralProductId: centralProductId,
          unitId: variant.unitId,
          // newAddOns: addOns,
          addToCartOnId: addToCartId,
          needToShowLoaderForCartFetch: false,
        ),
      );

        }else {
          
          
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
        }


      // print("Added product with addons to cart: ${product.productName}");
    } catch (e) {
      print(
        'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
      );
    }
  }

  String formatCurrency(String symbol, double value) {
    if (symbol.isNotEmpty && symbol != 'AED') {
      return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return 'AED${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  Widget buildCartWidget(List<WidgetAction> cartItems) {
    return CartWidget(cartItems: cartItems, isFromChatHistory: isFromHistory);
  }

  Widget buildChooseAddressWidget(List<AddressOption> addressOptions) {
    return ChooseAddressWidget(
      addressOptions: addressOptions,
      isFromChatHistory: isFromHistory,
      onAddressSelected: (selectedAddress) {
        // Handle address selection
        print(
          'Selected address: ${selectedAddress.name} - ${selectedAddress.address}',
        );
        if (addressOptions.first.isPackageDelivery == true) {
          final existing = apiData['package_delivery'];
          final Map<String, dynamic> packageDeliveryData;
          if (existing is Map) {
            packageDeliveryData = Map<String, dynamic>.from(existing);
            packageDeliveryData['pickup_address_id'] =
                selectedAddress.addressId;
          } else {
            packageDeliveryData = {
              'pickup_address_id': selectedAddress.addressId,
            };
          }
          apiData['package_delivery'] = packageDeliveryData;
          onSendMessage('I have selected picked up address.\n${selectedAddress.address}.');
        }
      },
      onSendMessage: (message) {
        // Automatically send the selected address message
        if (addressOptions.first.isPackageDelivery == false) {
          onSendMessage(message);
        }
      },
    );
  }

  Widget buildChooseCardWidget(List<CardOption> cardOptions) {
    return ChooseCardWidget(
      cardOptions: cardOptions,
      isFromChatHistory: isFromHistory,
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

  Widget buildOrderSummaryWidget(List<WidgetAction> orderSummaryItems) {
    return OrderSummaryWidget(orderItems: orderSummaryItems, isFromChatHistory: isFromHistory);
  }

  Widget buildPackageTypesWidget(List<SendPackageType> packageTypes) {
    if (packageTypes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: PackageTypesWidget(
        packageTypes: packageTypes,
        isFromChatHistory: isFromHistory,
        onPackageTypeSelected: (packageType) {
          final existing = apiData['package_delivery'];
              final Map<String, dynamic> packageDeliveryData;
              if (existing is Map) {
                packageDeliveryData = Map<String, dynamic>.from(existing);
                packageDeliveryData['package_type_id'] = packageType.id;
              } else {
                packageDeliveryData = {
                  'package_type_id': packageType.id,
                };
              }
              apiData['package_delivery'] = packageDeliveryData;
              onSendMessage(
                'I want to book package types in ${packageType.sendPackageTypeName}',
              );
        },
      ),
    );
  }

  Widget buildOrderConfirmedWidget(ChatWidget orderConfirmedWidget) {
    final orderData = orderConfirmedWidget.getOrderConfirmedData();
    if (orderData != null) {
      final title = orderData['title'] as String? ?? '';

      return OrderConfirmedWidget(title: title);
    }
    return const SizedBox.shrink();
  }

  Widget buildServicesDeliveryOptionsWidget(List<WidgetAction> servicesDeliveryOptions) {
    return ServicesDeliveryOptionsWidget(
      servicesDeliveryOptions: servicesDeliveryOptions,
      isFromChatHistory: isFromHistory,
      onSendMessage: (message) {
        onSendMessage(message);
      },
    );
  }

  Widget buildRestaurantSectionsWidget(
    BuildContext context,
    List<WidgetAction> restaurantSectionsItems,
  ) {
    if (restaurantSectionsItems.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: RestaurantSectionsWidget(
        restaurantSectionsItems: restaurantSectionsItems,
      ),
    );
  }

  Widget buildCustomerProfileDetailsWidget(
    List<HotelDestination> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: CustomerProfileDetailsWidget(items: items),
    );
  }

  Widget buildHotelDestinationWidget(List<HotelDestination> destinations) {
    if (destinations.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: HotelDestinationWidget(
        destinations: destinations,
        isFromChatHistory: isFromHistory,
        onDestinationSelected: (destination) {
          final hotelBookingData = {
            'countryOfResidence': 'AE',
            'hotelCoordinates': {
              'lat': destination.lat,
              'lng': destination.lng,
            },
          };
          onSendMessage(
            'I want to book hotels in ${destination.fullName}',
            null,
            null,
            null,
            {'hotel_booking': hotelBookingData},
          );
        },
      ),
    );
  }

  Widget buildCarPickupPlacesWidget(List<CarPickupPlace> places) {
    return _buildCarPlacesWidget(
      places: places,
      onPlaceSelected: (place) {
        final carBooking = _carBookingMap()
          ..['countryOfResidence'] = 'AE'
          ..['pickup_code'] = place.iataCode
          ..['pickup_type'] = place.type
          ..['pickup_geo'] =
              '${place.coordinates.lat},${place.coordinates.lon}';
        onSendMessage(
          'I have selected ${place.name} as the pickup location.',
          null,
          null,
          null,
          {'car_booking': carBooking},
        );
      },
    );
  }

  Widget buildCarDropoffPlacesWidget(List<CarPickupPlace> places) {
    return _buildCarPlacesWidget(
      places: places,
      onPlaceSelected: (place) {
        final carBooking = _carBookingMap()
          ..['return_code'] = place.iataCode
          ..['return_type'] = place.type;
        onSendMessage(
          'I have selected ${place.name} as the drop-off location.',
          null,
          null,
          null,
          {'car_booking': carBooking},
        );
      },
    );
  }

  Widget buildFlightOriginPlacesWidget(List<CarPickupPlace> places) {
    if (places.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: FlightOriginPlacesWidget(
        places: places,
        isFromChatHistory: isFromHistory,
        onPlaceSelected: (place) {
          final flightBooking = _flightBookingMap()
            ..['flight_origin'] = place.iataCode;
          onSendMessage(
            'I want to book flight from ${place.name}',
            null,
            null,
            null,
            {'flight_booking': flightBooking},
          );
        },
      ),
    );
  }

  Widget buildFlightDestinationPlacesWidget(List<CarPickupPlace> places) {
    if (places.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: FlightDestinationPlacesWidget(
        places: places,
        isFromChatHistory: isFromHistory,
        onPlaceSelected: (place) {
          final flightBooking = _flightBookingMap()
            ..['flight_destination'] = place.iataCode;
          onSendMessage(
            'I want to book flight to ${place.name}',
            null,
            null,
            null,
            {'flight_booking': flightBooking},
          );
        },
      ),
    );
  }

  Widget _buildCarPlacesWidget({
    required List<CarPickupPlace> places,
    required void Function(CarPickupPlace place) onPlaceSelected,
  }) {
    if (places.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: CarPickupPlacesWidget(
        places: places,
        isFromChatHistory: isFromHistory,
        onPlaceSelected: onPlaceSelected,
      ),
    );
  }

  Map<String, dynamic> _carBookingMap() {
    final existing = apiData['car_booking'];
    if (existing is Map) {
      return Map<String, dynamic>.from(existing);
    }
    return {};
  }

  Map<String, dynamic> _flightBookingMap() {
    final existing = apiData['flight_booking'];
    if (existing is Map) {
      return Map<String, dynamic>.from(existing);
    }
    return {};
  }

  Map<String, dynamic> _hotelBookingMap() {
    final existing = apiData['hotel_booking'];
    if (existing is Map) {
      return Map<String, dynamic>.from(existing);
    }
    return {};
  }

  Map<String, dynamic> _packageDeliveryMap() {
    final existing = apiData['package_delivery'];
    if (existing is Map) {
      return Map<String, dynamic>.from(existing);
    }
    return {};
  }

  Map<String, dynamic> _hotelBookingWithForMeDetails() {
    final hotelBooking = _hotelBookingMap();
    final fullName = Utility.getName().trim();
    final nameParts =
        fullName.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final existingPhone = hotelBooking['phone'];
    final phoneMap = existingPhone is Map
        ? Map<String, dynamic>.from(existingPhone)
        : <String, dynamic>{};

    hotelBooking
      ..['email'] = Utility.getEmailId().trim()
      ..['phone'] = {
        'countryCode': Utility.getCountryCode().trim(),
        'number': Utility.getPhoneNumber().trim(),
      }
      ..['rooms'] = [
        {
          'title': 'Mr',
          'firstName': firstName,
          'lastName': firstName,
        },
      ]
      ..['countryOfResidence'] =
          (hotelBooking['countryOfResidence'] ?? 'AE').toString();

    return hotelBooking;
  }

  void _openFlightSearchScreen(BuildContext context, WidgetAction action) {
    final flightBooking = _flightBookingMap();
    final routeType = FlightSearchRepository.resolveRouteType(
      action,
      flightBooking.isNotEmpty ? flightBooking : null,
    );

    Navigator.push(
      context,
                              AppLocale.materialRoute(
        builder: (context) => BlocProvider(
          create: (_) => FlightSearchBloc(),
          child: FlightSearchScreen(
            actionData: action,
            flightBooking: action.toJson(), //flightBooking.isNotEmpty ? flightBooking : null,
            onFlightSelected: (flight, cabin) {
              final existing = apiData['flight_booking'];
              final Map<String, dynamic> updatedFlightBooking;
              if (existing is Map) {
                updatedFlightBooking = Map<String, dynamic>.from(existing);
                updatedFlightBooking['correlationId'] = flight.correlationId;
                updatedFlightBooking['cabinSearchSessionId'] =
                    cabin.cabinSearchSessionId;
                updatedFlightBooking['routeType'] = routeType;
              } else {
                updatedFlightBooking = {
                  'correlationId': flight.correlationId,
                  'cabinSearchSessionId': cabin.cabinSearchSessionId,
                  'routeType': routeType,
                };
              }
              apiData['flight_booking'] = updatedFlightBooking;
              Navigator.of(context).pop();
              onSendMessage(
                _flightSelectionMessage(flight, cabin, routeType),
              );
            },
            onOpenInEazyApp: (flight, cabin) {
              OrderService().triggerClickManageScreenOpen({
                'flow': 'FlightBooking',
                'screenName': 'TravelFlightDetailsScreen',
                'correlationId': flight.correlationId,
                'cabinSearchSessionId': cabin.cabinSearchSessionId,
                'routeType': routeType,
                'adults': flightBooking['adults'],
                'children': flightBooking['children'],
                'infants': flightBooking['infants'],
                'airlineName': flight.segments.isNotEmpty
                    ? flight.segments.first.airlineName
                    : 'flight',
                'needToBack': true,
              });
            },
          ),
        ),
      ),
    );
  }

  String _flightSelectionMessage(
    FlightSearch flight,
    FlightSearchCabin cabin,
    String routeType,
  ) {
    final airlineName = flight.segments.isNotEmpty
        ? flight.segments.first.airlineName
        : 'flight';

    if (routeType == 'return' && flight.segments.length > 1) {
      final outbound = flight.segments.first;
      final inbound = flight.segments.last;
      return 'I have selected $airlineName round-trip flight '
          '(${outbound.departureAirport}-${outbound.arrivalAirport} / '
          '${inbound.departureAirport}-${inbound.arrivalAirport}) ${cabin.cabin}';
    }

    return 'I have selected flight $airlineName ${cabin.cabin}';
  }

  void _openCarSearchScreen(BuildContext context, WidgetAction action) {
    Navigator.push(
      context,
                              AppLocale.materialRoute(
        builder: (context) => BlocProvider(
          create: (_) => CarSearchBloc(),
          child: CarSearchScreen(
            actionData: action,
            onCarRentalSelected: (rental) {
                final existing = apiData['car_booking'];
            final Map<String, dynamic> carBooking;
            if (existing is Map) {
              carBooking = Map<String, dynamic>.from(existing);
              carBooking['correlationId'] = rental.correlationId;
              carBooking['availabilityToken'] = rental.availabilityToken;
            } else {
              carBooking = {
                'correlationId': rental.correlationId,
                'availabilityToken': rental.availabilityToken,
              };
            }
              apiData['car_booking'] = carBooking;
              Navigator.of(context).pop();
              onSendMessage('I have selected car ${rental.name}');
            },
            onOpenInEazyApp: (rental) {
              OrderService().triggerClickManageScreenOpen({
                'flow': 'CarBooking',
                'screenName': 'TravelCarDetailsScreen',
                'needToBack': true,
                'correlationId': rental.correlationId,
                'availabilityToken': rental.availabilityToken,
                'pickup_date': action.pickupDate,
                'return_date': action.returnDate,
                'pickup_code': action.pickupCode,
                'return_code': action.returnCode,
                'pickup_type': action.pickupType,
                'return_type': action.returnType,
                'driver_age': action.driverAge,
                'countryOfResidence': action.country,
                'currency': rental.currency,
              });
            },
          ),
        ),
      ),
    );
  }

  void _openHotelSearchScreen(BuildContext context, WidgetAction action) {
    Navigator.push(
      context,
                              AppLocale.materialRoute(
        builder: (context) => BlocProvider(
          create: (_) => HotelSearchBloc(),
          child: HotelSearchScreen(
            actionData: action,
            onHotelSelected: (property) {
              if (isFromHistory) {
                return;
              }
              final existing = apiData['hotel_booking'];
              final Map<String, dynamic> hotelBooking;
              if (existing is Map) {
                hotelBooking = Map<String, dynamic>.from(existing);
                hotelBooking['correlationId'] = property.correlationId;
                hotelBooking['propertyId'] = property.propertyId;
              } else {
                hotelBooking = {
                  'correlationId': property.correlationId,
                  'propertyId': property.propertyId,
                };
              }
              apiData['hotel_booking'] = hotelBooking;
              Navigator.of(context).pop();
              onSendMessage(
                'I have selected hotel ${property.name}. Please show me available rooms',
              );
            },
            onOpenInEazyApp: (property) {
              OrderService().triggerClickManageScreenOpen({
                'flow': 'HotelBooking',
                'screenName': 'TravelHotelDetailsScreen',
                'needToBack': true,
                  'propertyId': property.propertyId,
                  'correlationId': property.correlationId,
                  'checkinDate': action.checkinDate,
                  'checkoutDate': action.checkoutDate,
                  'occupancy': action.occupancy,
                  'countryOfResidence': action.countryOfResidence,
                      });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openChooseRoomSheet(
    BuildContext context,
    WidgetAction action,
  ) async {
    // final hotelBooking = _hotelBookingMap();
    final hotelName = action.title.isNotEmpty
        ? action.title
        : (action.storeName ?? action.name ?? '');
    final hotelImageUrl = action.image ?? '';

    await ChooseRoomBottomSheet.show(
      context,
      hotelBooking: action.toJson(),
      hotelName: hotelName,
      hotelImageUrl: hotelImageUrl,
      onNext: (selected) {
         final existing = apiData['hotel_booking'];
            final Map<String, dynamic> hotelBooking;
            if (existing is Map) {
              hotelBooking = Map<String, dynamic>.from(existing);
              hotelBooking['roomId'] = selected.room.id;
              hotelBooking['roomName'] = selected.room.name;
              hotelBooking['availabilityToken'] = selected.bed?.availabilityToken ?? '';
            } else {
              hotelBooking = {
                'roomId': selected.room.id,
                'roomName': selected.room.name,
                'availabilityToken': selected.bed?.availabilityToken ?? '',
              };
            }
            apiData['hotel_booking'] = hotelBooking;

        onSendMessage(
          'I have selected room ${selected.room.name}'
        );
      },
    );
  }

  Widget buildHotelsWidget(List<HotelProperty> hotels) {
    if (hotels.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: HotelsWidget(
        properties: hotels,
        nights: HotelsWidget.nightsFromApiData(apiData),
        isFromChatHistory: isFromHistory,
        onHotelSelected: (property) {
          if (isFromHistory) {
            return;
          }
          print('onOpenInApp, onOpenInApp 1');
           final existing = apiData['hotel_booking'];
            final Map<String, dynamic> hotelBooking;
            if (existing is Map) {
              hotelBooking = Map<String, dynamic>.from(existing);
              hotelBooking['correlationId'] = property.correlationId;
              hotelBooking['propertyId'] = property.propertyId;
            } else {
              hotelBooking = {
                'correlationId': property.correlationId,
                'propertyId': property.propertyId,
              };
            }
            apiData['hotel_booking'] = hotelBooking;
          onSendMessage('I have selected hotel ${property.name}. Please show me available rooms');
        },
        onOpenInApp: (property) {
          print('onOpenInApp, onOpenInApp 2 ${property.toJson()}');
          OrderService().triggerClickManageScreenOpen({
            'flow': 'HotelBooking',
            'screenName': 'TravelHotelDetailsScreen',
            'propertyId': property.propertyId,
            'correlationId': property.correlationId,
            'checkinDate': property.checkinDate,
            'checkoutDate': property.checkoutDate,
            'occupancy': property.occupancy,
            'countryOfResidence': 'AE',
          });
        },
      ),
    );
  }

  Widget buildCarRentalsSearchWidget(List<CarRentalSearch> rentals) {
    if (rentals.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: CarRentalsSearchWidget(
        rentals: rentals,
        isFromChatHistory: isFromHistory,
        onCarRentalSelected: (rental) {
          if (isFromHistory) {
            return;
          }
           final existing = apiData['car_booking'];
            final Map<String, dynamic> carBooking;
            if (existing is Map) {
              carBooking = Map<String, dynamic>.from(existing);
              carBooking['correlationId'] = rental.correlationId;
              carBooking['availabilityToken'] = rental.availabilityToken;
            } else {
              carBooking = {
                'correlationId': rental.correlationId,
                'availabilityToken': rental.availabilityToken,
              };
            }
            apiData['car_booking'] = carBooking;
            
          onSendMessage(
            'I have selected car ${rental.name}'
          );
        },
        onOpenInApp: (rental) {
          // TODO: implement car rental open-in-app flow
            print('onOpenInApp, onOpenInApp 2 ${rental.toJson()}');
          OrderService().triggerClickManageScreenOpen({
            'flow': 'CarBooking',
            'screenName': 'TravelCarDetailsScreen',
            'correlationId': rental.correlationId,
            'availabilityToken': rental.availabilityToken,
            'currency': rental.currency,
            'countryOfResidence': 'AE',
          });
        },
      ),
    );
  }

  Widget buildFlightsSearchWidget(List<FlightSearch> flights) {
    if (flights.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: FlightsSearchWidget(
        flights: flights,
        isFromChatHistory: isFromHistory,
        onFlightSelected: (flight, cabin) {
          if (isFromHistory) {
            return;
          }
           final existing = apiData['flight_booking'];
            final Map<String, dynamic> flightBooking;
            if (existing is Map) {
              flightBooking = Map<String, dynamic>.from(existing);
              flightBooking['correlationId'] = flight.correlationId;
              flightBooking['cabinSearchSessionId'] = cabin.cabinSearchSessionId;
            } else {
              flightBooking = {
                'correlationId': flight.correlationId,
                'cabinSearchSessionId': cabin.cabinSearchSessionId,
              };
            }
            apiData['flight_booking'] = flightBooking;
            
          onSendMessage(
            'I have selected flight ${flight.segments.isNotEmpty ? flight.segments.first.airlineName : 'flight'} ${cabin.cabin}'
          );
        },
        onOpenInApp: (flight, cabin) {
          OrderService().triggerClickManageScreenOpen({
            'flow': 'FlightBooking',
            'screenName': 'TravelFlightDetailsScreen',
            'correlationId': flight.correlationId,
            'cabinSearchSessionId': cabin.cabinSearchSessionId,
            'adults': apiData['flight_booking']['adults'],
            'children': apiData['flight_booking']['children'],
            'infants': apiData['flight_booking']['infants'],
            'airlineName': flight.segments.isNotEmpty ? flight.segments.first.airlineName : 'flight',
            'needToBack': false
          });
        },
      ),
    );
  }

  Widget buildHotelOrderSummaryWidget(List<HotelOrderSummary> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: HotelOrderSummaryWidget(
        items: items,
        hotelBooking: _hotelBookingMap(),
      ),
    );
  }

  Widget buildCarOrderSummaryWidget(List<CarOrderSummary> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: CarOrderSummaryWidget(
        items: items,
        carBooking: _carBookingMap(),
      ),
    );
  }

  Widget buildFlightOrderSummaryWidget(List<FlightOrderSummary> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: FlightOrderSummaryWidget(
        items: items,
        flightBooking: _flightBookingMap(),
      ),
    );
  }

  Widget buildHotelBookingConfirmedWidget(List<WidgetAction> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: HotelBookingConfirmedWidget(items: items),
    );
  }

  Widget buildCarBookingConfirmedWidget(List<WidgetAction> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: CarBookingConfirmedWidget(items: items),
    );
  }

  Widget buildFlightBookingConfirmedWidget(List<WidgetAction> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 0.0),
      child: FlightBookingConfirmedWidget(items: items),
    );
  }
}

/// Birthday reminder card shown after the Complete setup button.
class _BirthdayReminderCard extends StatefulWidget {
  final VoidCallback? onBookRestaurant;
  final VoidCallback? onBrowseGifts;
  final GreetingReminder? greetingReminder;

  const _BirthdayReminderCard({
    this.onBookRestaurant,
    this.onBrowseGifts,
    this.greetingReminder,
  });

  @override
  State<_BirthdayReminderCard> createState() => _BirthdayReminderCardState();
}

class _BirthdayReminderCardState extends State<_BirthdayReminderCard> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Center(
      child: SizedBox(
        width: 343,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [
                    Color(0xFFF5E0FF),
                    Color(0xFFD59DFF),
                  ],
                  stops: [0.1555, 0.9554],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 39,
                        height: 39,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.125),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.greetingReminder?.emoji ?? '🎂',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECC6FE),
                                borderRadius: BorderRadius.circular(80),
                              ),
                              child: Text(
                                '${widget.greetingReminder?.daysUntil}',
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF414F85),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                             Text(
                              "${widget.greetingReminder?.title}!",
                              style: AppTextStyles.heading(
                                fontSize: 14,
                                color: const Color(0xFF2F3C70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.greetingReminder?.subtitle}',
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF2F3C70),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onBookRestaurant,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.greetingReminder?.buttons.first ?? AppTranslations.bookRestaurant,
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onBrowseGifts,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.greetingReminder?.buttons.last ?? AppTranslations.browseGifts,
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF007AFF),
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
            // Positioned(
            //   top: 15,
            //   right: 15,
            //   child: Material(
            //     color: Colors.transparent,
            //     child: InkWell(
            //       onTap: () => setState(() => _visible = false),
            //       borderRadius: BorderRadius.circular(32),
            //       child: Container(
            //         width: 20,
            //         height: 20,
            //         decoration: BoxDecoration(
            //           color: Colors.white.withOpacity(0.66),
            //           borderRadius: BorderRadius.circular(32),
            //         ),
            //         alignment: Alignment.center,
            //         child: Icon(
            //           Icons.close,
            //           size: 14,
            //           color: const Color(0xFF242424),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}