import 'package:flutter/material.dart';

class OrderConfirmedWidget extends StatelessWidget {
  final String title;

  const OrderConfirmedWidget({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 294,
      height: 110,
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: const Color(0xFFE9DFFB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order confirmation message
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.2,
                color: Color(0xFF242424),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
