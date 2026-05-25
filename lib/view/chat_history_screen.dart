import 'package:chat_bot/bloc/chat_history/chat_history_bloc.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_event.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_state.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/app_constants.dart';
import 'package:chat_bot/view/chat_screen.dart';
import 'package:chat_bot/widgets/black_toast_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/text_styles.dart';
import '../utils/asset_path.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatHistoryBloc()..add(const ChatHistoryFetchRequested()),
      child: _ChatHistoryContent(scrollController: _scrollController),
    );
  }
}

class _ChatHistoryContent extends StatefulWidget {
  final ScrollController scrollController;

  const _ChatHistoryContent({required this.scrollController});

  @override
  State<_ChatHistoryContent> createState() => _ChatHistoryContentState();
}

class _ChatHistoryContentState extends State<_ChatHistoryContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _currentKeyword = '';
  DateTime? _lastQueryAt;

  // final List<String> _categories = ['All', '🍕 Restaurant', '🥑 Grocery', '💊 Pharmacy'];
  final List<String> _categories = ['All', '🍕 Restaurant', '🥑 Grocery', '💊 Pharmacy', '🛒 Shopping', '💄 Services', "🏥 Health Care"];

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _currentKeyword = value.trim();
    final now = DateTime.now();
    _lastQueryAt = now;

    // Skip API call for empty queries - show all results
    if (_currentKeyword.isEmpty) {
      context.read<ChatHistoryBloc>().add(
        ChatHistorySearchRequested(query: ''),
      );
      return;
    }

    // Debounce: only proceed if this is the latest input
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      if (_lastQueryAt != now) return;
      
      context.read<ChatHistoryBloc>().add(
        ChatHistorySearchRequested(query: _currentKeyword),
      );
    });
  }

  void _onScroll() {
    
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200 pixels from the bottom
      context.read<ChatHistoryBloc>().add(const ChatHistoryLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(     
        child: BlocListener<ChatHistoryBloc, ChatHistoryState>(
          listener: (context, state) {
            if (state is ChatHistoryDeleteSuccess) {
              BlackToastView.show(context, 'Chat deleted successfully');
            } else if (state is ChatHistoryDeleteFailure) {
              BlackToastView.show(context, 'Failed to delete chat: ${state.message}');
            } else if (state is ChatHistoryArchiveSuccess) {
              BlackToastView.show(context, 'Chat archived successfully');
            } else if (state is ChatHistoryArchiveFailure) {
              BlackToastView.show(context, 'Failed to archive chat: ${state.message}');
            } else if (state is ChatHistoryShareSuccess) {
              Clipboard.setData(ClipboardData(text: state.shareUrl));
              BlackToastView.show(context, 'Share link copied');
            } else if (state is ChatHistoryShareFailure) {
              BlackToastView.show(context, 'Failed to share chat: ${state.message}');
            }
          },
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchBar(),
              ),
              const SizedBox(height: 16),
              // Category Filter Buttons - conditionally shown
              // BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
              //   builder: (context, state) {
              //     // Hide category buttons if "All" is selected and no data from API
              //     final shouldShowButtons = !(_selectedCategory == 'All' && 
              //       state is ChatHistoryLoadSuccess && 
              //       state.sessions.isEmpty);
                  
              //     if (shouldShowButtons && state is ChatHistoryLoadSuccess) {
              //       return Column(
              //         children: [
                        _buildCategoryButtons(),
                        const SizedBox(height: 24),
              //         ],
              //       );
              //     }
              //     return const SizedBox(height: 1);
              //   },
              // ),
              // Chat History List
              Expanded(
                child: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
                  builder: (context, state) {
                    if (state is ChatHistoryLoadInProgress) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is ChatHistoryLoadSuccess) {
                      if (state.sessions.isEmpty) {
                        return _buildEmptyCart();
                      }
                      // No local filtering needed - search and category filtering are now done via API
                      return _buildChatHistoryList(context, state.sessions, state);
                    } else if (state is ChatHistoryLoadFailure) {
                      return _buildEmptyCart();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
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
      leadingWidth: 0,
      leading: const SizedBox.shrink(), // Remove leading widget
      title: const Text(
        'Chats',
        style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.2,
                    color: Color(0xFF171212),
                  ),
      ),
      centerTitle: false, // Align title to the left
      titleSpacing: 16, // Add left padding for proper alignment
      actions: [
        //  IconButton(
        //   icon: SvgPicture.asset(
        //     AssetPath.get('images/ic_chat_new.svg'),
        //     width: 40,
        //     height: 40,
        //     fit: BoxFit.cover,
        //   ),
        //   onPressed: () => _showNewChatConfirmation(context),
        // ),
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

  Widget _buildChatHistoryList(BuildContext context, List<ChatHistoryResponse> sessions, ChatHistoryLoadSuccess state) {
    // Group sessions by date
    final groupedSessions = _groupSessionsByDate(sessions);
    
    return 
    RefreshIndicator(
      onRefresh: () async {
        context.read<ChatHistoryBloc>().add(const ChatHistoryRefreshed());
        // Wait for the state to change
        await Future.delayed(const Duration(seconds: 1));
      },
      child: 
      ListView.builder(
        controller: widget.scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groupedSessions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == groupedSessions.length) {
            // Load more indicator
            return _buildLoadMoreIndicator(state);
          }
          
          final entry = groupedSessions[index];
          final timeLabel = entry['label'] as String;
          final sessionsForDate = entry['sessions'] as List<ChatHistoryResponse>;
          
          return Column(
            children: [
              _buildChatHistorySection(context, timeLabel, sessionsForDate),
              if (index < groupedSessions.length - 1) const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator(ChatHistoryLoadSuccess state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              color: AppConstants.appThemeColor,
              // strokeWidth: 2.0,
            ),
          ),
        ),
      );
    } else if (state.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Scroll down to load more',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF6E4185),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

   Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DEF3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTextStyles.bodyText.copyWith(
                  color: const Color(0xFF979797),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 17),
              ),
              onChanged: (value) {
                _onSearchChanged(value);
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              // FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
              _searchController.clear();
              _onSearchChanged('');
            },
            child: Container(
            width: 25,
            height: 25,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(54),
            ),
            child: const Icon(Icons.close, size: 15, color: Color(0xFF585C77)),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
  return Container(
    height: 34,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    // Dismiss keyboard when tapping category filter
                    // FocusScope.of(context).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    _searchController.clear();
                    setState(() {
                      _selectedCategory = category;
                    });
                    // Trigger API call with new category filter
                    context.read<ChatHistoryBloc>().add(
                      ChatHistoryCategoryFilterRequested(category: category),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 60,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      // color: isSelected ? const Color(0xFFF0DAFE) : Colors.white,
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected ? AppConstants.appThemeColor : const Color(0xFFE9DFFB),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF242424),
                          height: 1.0, // Add this to control line height
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Add extra padding at the end to ensure last button is fully visible
            // const SizedBox(width: 24),
          ],
        ),
      ),
    ),
  );
}




  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty cart SVG icon
          SvgPicture.asset(
            AssetPath.get('images/ic_chat_empty.svg'),
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          // "Your cart is empty" text
          Text(
            'No conversations yet!',
            style: AppTextStyles.restaurantTitle.copyWith(
              color: const Color(0xFF242424),
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupSessionsByDate(List<ChatHistoryResponse> sessions) {
    // Filter out sessions with null timestamps
    final validSessions = sessions.where((s) => s.timestamp != null).toList();
    
    // Sort by timestamp descending (most recent first)
    validSessions.sort((a, b) {
      final aDate = DateTime.parse(a.timestamp!).toLocal();
      final bDate = DateTime.parse(b.timestamp!).toLocal();
      return bDate.compareTo(aDate);
    });
    
    // Group by relative date
    final Map<String, List<ChatHistoryResponse>> grouped = {};
    final now = DateTime.now();
    
    for (final session in validSessions) {
      // Convert UTC timestamp to local time
      final sessionDate = DateTime.parse(session.timestamp!).toLocal();
      final difference = now.difference(sessionDate);
      
      String label;
      if (difference.inDays == 0) {
        label = 'Today';
      } else if (difference.inDays == 1) {
        label = '1 day ago';
      } else if (difference.inDays < 7) {
        label = '${difference.inDays} days ago';
      } else if (difference.inDays < 14) {
        label = '1 week ago';
      } else if (difference.inDays < 21) {
        label = '2 weeks ago';
      } else if (difference.inDays < 30) {
        label = '3 weeks ago';
      } else if (difference.inDays < 60) {
        label = '1 month ago';
      } else {
        final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                       'July', 'August', 'September', 'October', 'November', 'December'];
        label = '${months[sessionDate.month - 1]} ${sessionDate.year}';
      }
      
      if (!grouped.containsKey(label)) {
        grouped[label] = [];
      }
      grouped[label]!.add(session);
    }
    
    // Convert to list of maps for ListView
    return grouped.entries.map((entry) {
      return {
        'label': entry.key,
        'sessions': entry.value,
      };
    }).toList();
  }

  Widget _buildChatHistorySection(BuildContext context, String timeLabel, List<ChatHistoryResponse> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeLabel,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF242424),
          ),
        ),
        const SizedBox(height: 4),
        Column(
          children: sessions.map((session) => _buildChatHistoryItem(context, session)).toList(),
        ),
      ],
    );
  }

  Widget _buildChatHistoryItem(BuildContext context, ChatHistoryResponse session) {
    // Use title if available, otherwise show session ID
    final displayText = session.title.isNotEmpty 
        ? session.title 
        : 'Session ${session.sessionId}';
        
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: ChatScreen.routeName),
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => ChatBloc()),
                BlocProvider(create: (context) => CartBloc()),
              ],
              child: ChatScreen(
                isFromHistory: true,
                historySessionId: session.sessionId.toString(),
                chatHistoryTitle: displayText,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          border: Border.all(color: const Color(0xFFEEF4FF)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: AppTextStyles.chatMessage.copyWith(
                  color: const Color(0xFF242424),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'More',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF242424),
                size: 22,
              ),
              onPressed: () {
                _showChatMoreOptions(
                  context,
                  chatId: session.sessionId.toString(),
                  chatTitle: displayText,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatMoreOptions(
    BuildContext context, {
    required String chatId,
    required String chatTitle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (BuildContext bottomSheetContext) {
        Widget optionTile({
          required IconData icon,
          required String title,
          required VoidCallback onTap,
          Color? iconColor,
          Color? textColor,
        }) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: iconColor ?? const Color(0xFF242424)),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? const Color(0xFF242424),
              ),
            ),
            onTap: onTap,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                'Chat options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              optionTile(
                icon: Icons.share_outlined,
                title: 'Share Chat',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.read<ChatHistoryBloc>().add(
                        ChatHistoryShareRequested(sessionId: chatId),
                      );
                },
              ),
              optionTile(
                icon: Icons.archive_outlined,
                title: 'Archive Chat',
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  context.read<ChatHistoryBloc>().add(
                        ChatHistoryArchiveRequested(sessionId: chatId),
                      );
                },
              ),
              optionTile(
                icon: Icons.delete_outline,
                title: 'Delete Chat',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showDeleteChatConfirmation(context, chatId, chatTitle);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
                'Are you sure want to start new chat? if you start new chat, you will lose your current chat history.',
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
                            color: AppConstants.appThemeColor,
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
                           Navigator.pop(context, {
                             'action': 'new_chat_selected',
                            //  'cartCount': widget.cartCount ?? 0,
                           });
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

  void _showDeleteChatConfirmation(BuildContext context, String chatId, String chatTitle) {
    final chatHistoryBloc = context.read<ChatHistoryBloc>();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (BuildContext bottomSheetContext) {
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
                'Are you sure you want to delete “$chatTitle”?',
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
                          Navigator.of(bottomSheetContext).pop();
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
                        child: const Text(
                          "No, Cancel",
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

                  Expanded(
                    child: SizedBox(
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop();
                          // Trigger delete action
                          chatHistoryBloc.add(
                            ChatHistoryDeleteRequested(sessionId: chatId),
                          );
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
                          ),
                          child: Container(
                            height: 62,
                            alignment: Alignment.center,
                            child: const Text(
                              "Yes, Delete",
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
}
