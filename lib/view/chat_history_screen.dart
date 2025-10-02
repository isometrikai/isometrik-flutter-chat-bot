import 'package:chat_bot/bloc/chat_history/chat_history_bloc.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_event.dart';
import 'package:chat_bot/bloc/chat_history/chat_history_state.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/chat_bloc.dart';
import 'package:chat_bot/data/model/chat_history_response.dart';
import 'package:chat_bot/view/chat_screen.dart';
import 'package:chat_bot/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/text_styles.dart';
import '../utils/asset_path.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatHistoryBloc()..add(const ChatHistoryFetchRequested()),
      child: Scaffold(
        backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(     
      child:  Column(
        children: [
          // const SizedBox(height: 24),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16),
          //   child: ScreenHeader(
          //     title: 'Chats',
          //     onClose: () => Navigator.pop(context),
          //   ),
          // ),
          // const SizedBox(height: 10),
          
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
                    return Center(
                      child: Text(
                        'No chat history available',
                        style: AppTextStyles.bodyText.copyWith(
                          color: const Color(0xFF979797),
                        ),
                      ),
                    );
                  }
                  return _buildChatHistoryList(context, state.sessions);
                } else if (state is ChatHistoryLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load chat history',
                          style: AppTextStyles.bodyText.copyWith(
                            color: const Color(0xFFFF0000),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ChatHistoryBloc>().add(const ChatHistoryRefreshed());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
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
        'Chats History',
        style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.2,
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

  Widget _buildChatHistoryList(BuildContext context, List<ChatHistoryResponse> sessions) {
    // Group sessions by date
    final groupedSessions = _groupSessionsByDate(sessions);
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChatHistoryBloc>().add(const ChatHistoryRefreshed());
        // Wait for the state to change
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groupedSessions.length,
        itemBuilder: (context, index) {
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
            // builder: (context) => ChatScreen(
            //   isFromHistory: true,
            //   historySessionId: session.sessionId.toString(),
            // ),
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => ChatBloc()),
                BlocProvider(create: (context) => CartBloc()),
              ],
              child: ChatScreen(
                isFromHistory: true,
                historySessionId: session.sessionId.toString(),
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
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
          ],
        ),
      ),
    );
  }
}
