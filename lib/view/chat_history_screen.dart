import 'package:chat_bot/view/chat_screen.dart';
import 'package:chat_bot/widgets/screen_header.dart';
import 'package:flutter/material.dart'; 
import '../utils/text_styles.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: SvgPicture.asset(
      //       AssetPath.get('images/ic_previous.svg'),
      //       width: 24,
      //       height: 24,
      //     ),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: SvgPicture.asset(
      //       AssetPath.get('images/ic_previous.svg'),
      //       width: 24,
      //       height: 24,
      //     ),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: Text(
      //     'Chats',
      //     style: AppTextStyles.launchTitle.copyWith(
      //       color: const Color(0xFF171212),
      //     ),
      //   ),
      //   centerTitle: true,
      //   actions: [
      //     Container(
      //       margin: const EdgeInsets.only(right: 16),
      //       child: Row(
      //         children: [
      //           Container(
      //             width: 40,
      //             height: 40,
      //             decoration: const BoxDecoration(
      //               gradient: LinearGradient(
      //                 colors: [
      //                   Color(0xFFD445EC),
      //                   Color(0xFFB02EFB),
      //                   Color(0xFF8E2FFD),
      //                   Color(0xFF5E3DFE),
      //                   Color(0xFF5186E0),
      //                 ],
      //                 stops: [0.0, 0.27, 0.48, 0.76, 1.0],
      //               ),
      //               shape: BoxShape.circle,
      //             ),
      //             child: Center(
      //               child: SvgPicture.asset(
      //                 AssetPath.get('images/ic_chat_profile.svg'),
      //                 width: 20,
      //                 height: 20,
      //                 colorFilter: const ColorFilter.mode(
      //                   Colors.white,
      //                   BlendMode.srcIn,
      //                 ),
      //               ),
      //             ),
      //           ),
      //           const SizedBox(width: 10),
      //           Container(
      //             width: 40,
      //             height: 40,
      //             decoration: BoxDecoration(
      //               color: Colors.white.withValues(alpha: 0.1),
      //               shape: BoxShape.circle,
      //             ),
      //             child: Center(
      //               child: SvgPicture.asset(
      //                 AssetPath.get('images/ic_close.svg'),
      //                 width: 16,
      //                 height: 16,
      //                 colorFilter: const ColorFilter.mode(
      //                   Color(0xFF585C77),
      //                   BlendMode.srcIn,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
      body: SafeArea(     
      child:  Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ScreenHeader(
              title: 'Chats',
              onClose: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 10),
          // Search Bar
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          //   child: Container(
          //     height: 54,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       border: Border.all(color: const Color(0xFFD8DEF3)),
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //     child: Row(
          //       children: [
          //         const SizedBox(width: 16),
          //         Expanded(
          //           child: Text(
          //             'Search',
          //             style: AppTextStyles.bodyText.copyWith(
          //               color: const Color(0xFF979797),
          //             ),
          //           ),
          //         ),
          //         Container(
          //           width: 34,
          //           height: 34,
          //           margin: const EdgeInsets.only(right: 10),
          //           decoration: BoxDecoration(
          //             color: const Color(0xFFF6F6F6),
          //             shape: BoxShape.circle,
          //           ),
          //           child: Center(
          //             child: const Icon(
          //               Icons.search, 
          //               size: 17, 
          //               color: Color(0xFF585C77)
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          
          // Filter Chips
          // Container(
          //   height: 50,
          //   margin: const EdgeInsets.only(bottom: 16),
          //   child: Center(
          //     child: ListView(
          //       scrollDirection: Axis.horizontal,
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       children: [
          //       _buildFilterChip('All', true),
          //       const SizedBox(width: 8),
          //       _buildFilterChip('Food', false),
          //       const SizedBox(width: 8),
          //       _buildFilterChip('Grocery', false),
          //       const SizedBox(width: 8),
          //       _buildFilterChip('Pharmacy', false),
          //       const SizedBox(width: 8),
          //       ],
          //     ),
          //   ),
          // ),
          
          // Chat History List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildChatHistorySection(context, '1 day ago', [
                  'Order pizza from pizza hut',
                  'Buy fresh avocados from the Mintfresh',
                ]),
                const SizedBox(height: 16),
                _buildChatHistorySection(context, '3 days ago', [
                  'Schedule a delivery for organic groceries',
                  'Pick up a cake for a friend\'s birthday',
                ]),
                const SizedBox(height: 16),
                _buildChatHistorySection(context, '5 days ago', [
                  'Order sushi from the new restaurant in to...',
                ]),
                const SizedBox(height: 16),
                _buildChatHistorySection(context, '6 days ago', [
                  'Purchase a weekly meal prep service',
                ]),
                const SizedBox(height: 16),
                _buildChatHistorySection(context, '6 days ago', [
                  'Purchase a weekly meal prep service',
                ]),
                const SizedBox(height: 16),
                _buildChatHistorySection(context, '6 days ago', [
                  'Get ingredients for homemade pasta',
                  'Reserve a table at a new vegan cafe',
                ]),
                const SizedBox(height: 16),
                _buildChatHistorySection(context, '2 weeks ago', [
                  'Sign up for a wine tasting event',
                  'Purchase a weekly meal prep service',
                  'Order burger from the new restaurant in ...',
                ]),
              ],
            ),
          ),
        ],
      ),
      )
      );
    }
  }

  Widget _buildChatHistorySection(BuildContext context, String timeLabel, List<String> messages) {
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
          children: messages.map((message) => _buildChatHistoryItem(context, message)).toList(),
        ),
      ],
    );
  }

  Widget _buildChatHistoryItem(BuildContext context, String message) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(isFromHistory: true)),
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
              message,
              style: AppTextStyles.chatMessage.copyWith(
                color: const Color(0xFF242424),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
