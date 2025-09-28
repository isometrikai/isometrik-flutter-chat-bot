import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/greeting_response.dart';

class PopupOverlayScreen extends StatelessWidget {
  final GreetingResponse? greetingData;
  
  const PopupOverlayScreen({super.key, this.greetingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.3),
          child: Column(
            children: [
              // Add space for app bar (typically around 100-120px)
              const SizedBox(height: 100),
              // Position popup below app bar
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      // Prevent closing when tapping on the popup itself
                    },
                    child: _buildInfoPopup(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPopup(BuildContext context) {
    return Container(
      width: 300,
      // Remove fixed height to allow dynamic sizing
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // Max 70% of screen height
        minHeight: 200, // Minimum height
      ),
      margin: const EdgeInsets.only(bottom: 50), // Add bottom margin for safety
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        child: _buildPopupContent(),
      ),
    );
  }

  Widget _buildPopupContent() {
    // Extract data from passed greetingData
    final personaTitle = greetingData?.personaTitle ?? 'The Organized Weekly Planner';
    final personaDesc = greetingData?.personaDesc ?? 
        'Rahul is a meticulous weekly shopper who plans his Fridays around food, groceries, and pharmacy deliveries. He maintains a consistent routine, making sure lunch is ordered on time while also handling essential groceries for his family. Rahul values quick delivery for health-related items like paracetamol and Dabber Bronco syrup, usually expecting them within an hour. Recently, he updated his payment details with a new card to ensure smooth and seamless checkouts. He manages multiple addresses efficiently, keeping his mother\'s grocery needs separate from his own, while reserving his home at 12, Al Ohood Street 6 for restaurant deliveries. Rahul\'s behavior shows a blend of reliability, structure, and care, making him a detail-oriented user who values speed and convenience.';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          personaTitle,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: Color(0xFF242424),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          personaDesc,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: Color(0xFF242424),
          ),
        ),
      ],
    );
  }
}