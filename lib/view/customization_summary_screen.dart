import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';



class CustomizationSummaryScreen extends StatefulWidget {
  final Store? store;
  final Product? product;
  final VoidCallback? onChooseClicked; 
  final VoidCallback? onRepeatClicked; // Callback when "I'll choose" is clicked

  const CustomizationSummaryScreen({
    super.key,
    this.store,
    this.product,
    this.onChooseClicked,
    this.onRepeatClicked,
  });

  @override
  State<CustomizationSummaryScreen> createState() => _CustomizationSummaryScreenState();
}

class _CustomizationSummaryScreenState extends State<CustomizationSummaryScreen> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                // Expanded(
                //   child: _buildCustomizationsList(),
                // ),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your customisations',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF242424),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.product?.productName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6E4185),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(38),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    size: 9.6,
                    color: Color(0xFF585C77),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customization item
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quarter - 1 Pc',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF242424),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Kubboos',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF242424),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCBCBCB),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mashed Potato',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF242424),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
    ),
    child: Row(
      children: [
        // Left button - "I'll choose" (Outlined)
        Expanded(
          child: SizedBox(
            height: 62,
            child: OutlinedButton(
              onPressed: () {
                print("I'll choose button clicked for: ${widget.product?.productName}");
                Navigator.of(context).pop();
                
                // Call the callback to let parent know "I'll choose" was clicked
                if (widget.onChooseClicked != null) {
                  widget.onChooseClicked!();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8E2FFD), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                "I'll choose",
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
                if (widget.onRepeatClicked != null) {
                  widget.onRepeatClicked!();
                }
                Navigator.of(context).pop();
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
                    "Repeat last",
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
  );
}
}
