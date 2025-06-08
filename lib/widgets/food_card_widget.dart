import 'package:flutter/material.dart';

class FoodCardWidget extends StatelessWidget {
  final String name;
  final String restaurant;
  final String price;
  final String? imageUrl;
  final VoidCallback? onBuyPressed;
  final double? width;

  const FoodCardWidget({
    super.key,
    required this.name,
    required this.restaurant,
    required this.price,
    this.imageUrl,
    this.onBuyPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: imageUrl != null
                  ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
                  : _buildPlaceholderImage(),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Restaurant Name
                Text(
                  restaurant,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),

                // Price
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Buy Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onBuyPressed,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.blue[600]!,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      'buy',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[100]!,
            Colors.orange[50]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_pizza,
              size: 40,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pizza',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Horizontal Food Cards List Widget
class FoodCardsListWidget extends StatelessWidget {
  final List<FoodItem> foodItems;
  final Function(FoodItem)? onFoodItemBuy;

  const FoodCardsListWidget({
    super.key,
    required this.foodItems,
    this.onFoodItemBuy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final item = foodItems[index];
          return FoodCardWidget(
            name: item.name,
            restaurant: item.restaurant,
            price: item.price,
            imageUrl: item.imageUrl,
            onBuyPressed: () => onFoodItemBuy?.call(item),
          );
        },
      ),
    );
  }
}

// Data Model
class FoodItem {
  final String name;
  final String restaurant;
  final String price;
  final String? imageUrl;
  final String? id;

  const FoodItem({
    required this.name,
    required this.restaurant,
    required this.price,
    this.imageUrl,
    this.id,
  });
}