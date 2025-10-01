import 'package:chat_bot/utils/asset_path.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/greeting_response.dart';
import 'package:flutter_svg/svg.dart';

class PopupOverlayScreen extends StatelessWidget {
  final GreetingResponse? greetingData;
  
  const PopupOverlayScreen({super.key, this.greetingData});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.6),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {
                // Prevent closing when tapping on the popup itself
              },
              child: _buildInfoPopup(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPopup(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: 580,
        minHeight: 200,
      ),
      // margin: const EdgeInsets.only(bottom: 34),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
        child: _buildPopupContent(),
      ),
    );
  }

  Widget _buildPopupContent() {
    // Extract data from passed greetingData
    final personaTitle = greetingData?.personaTitle ?? '';
    final personaDesc = greetingData?.personaDesc ?? '';//'Abram is a meticulous weekly shopper who plans hisFridays around food, groceries, and pharmacydeliveries. He maintains a consistent routine, makingre lunch is ordered on time while also handlingssential groceries for his family. Abram values quickdelivery for health-related items like paracetamoland Dabber Bronco syrup, usually expecting themwithin an hour.Recently, he updated his payment details with anew card to ensure smooth and seamless checkouts.He manages multiple addresses efficiently, keepinghis mother’s grocery needs separate from his own,while reserving his home at 12, Al Ohood Street 6 forrestaurant deliveries. Abram’s behavior shows ablend of reliability, structure, and care, making hima detail- oriented user who values speed andconvenience.';//greetingData?.personaDesc ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        // Header section with title and close button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shopping persona badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Star icon
                        Container(
                          width: 18.59,
                          height: 19.67,
                          child: SvgPicture.asset(
                            AssetPath.get('images/ic_popUp_star.svg'),
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Your shopping persona',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: Color(0xFF242424),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Title text
                   Text(
                    personaTitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: Color(0xFF171212),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            // Close button
            Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(63.6364),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Color(0xFF585C77),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Description section with scroll
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              personaDesc,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: Color(0xFF242424),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Bottom info section
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'This profile is built from your interactions with zAIn and helps us provide personalized recommendations tailored to your preferences and habits.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: Color(0xFF585C77),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}