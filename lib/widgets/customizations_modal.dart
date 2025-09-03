import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/chat_response.dart';

class CustomizationsModal extends StatelessWidget {
  final Product product;
  final Store store;
  final VoidCallback onClose;
  final VoidCallback onChooseNew;
  final VoidCallback onRepeatLast;
  final Map<String, List<String>>? lastCustomizations;

  const CustomizationsModal({
    super.key,
    required this.product,
    required this.store,
    required this.onClose,
    required this.onChooseNew,
    required this.onRepeatLast,
    this.lastCustomizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: const Color(0x0F000021), // rgba(15, 0, 33, 0.7)
            ),
          ),
          
          // Modal content at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      children: [
                        // Title and close button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Your customisations',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF242424),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: onClose,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.circular(38.18),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 9.6,
                                  color: Color(0xFF585C77),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Product info
                        Text(
                          'AED${product.finalPrice.toStringAsFixed(0)} | ${product.productName}',
                          style: const TextStyle(
                            fontFamily: 'aed',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6E4185),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Customizations display
                  if (lastCustomizations != null && lastCustomizations!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildCustomizationsList(lastCustomizations!),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 59),
                    child: Row(
                      children: [
                        // I'll choose button
                        Expanded(
                          child: GestureDetector(
                            onTap: onChooseNew,
                            child: Container(
                              height: 62,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF8E2FFD)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  "I'll choose",
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF8E2FFD),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Repeat last button
                        Expanded(
                          child: GestureDetector(
                            onTap: onRepeatLast,
                            child: Container(
                              height: 62,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF5186E0),
                                    Color(0xFF5E3DFE),
                                    Color(0xFF8E2FFD),
                                    Color(0xFFB02EFB),
                                    Color(0xFFD445EC),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Repeat last',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildCustomizationsList(Map<String, List<String>> customizations) {
    final List<Widget> items = [];
    
    customizations.forEach((category, options) {
      if (options.isNotEmpty) {
        for (int i = 0; i < options.length; i++) {
          items.add(Text(
            options[i],
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF242424),
            ),
          ));
          
          // Add separator dot if not the last item
          if (i < options.length - 1 || 
              customizations.keys.toList().indexOf(category) < customizations.length - 1) {
            items.add(const SizedBox(width: 8));
            items.add(Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFCBCBCB),
                shape: BoxShape.circle,
              ),
            ));
            items.add(const SizedBox(width: 8));
          }
        }
      }
    });
    
    return Wrap(
      children: items,
    );
  }
}
