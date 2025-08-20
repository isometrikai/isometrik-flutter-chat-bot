import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MenuItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String originalPrice;
  final bool isVeg;
  final String? imageUrl;
  final VoidCallback? onAdd;

  final Color purple;
  final Color vegColor;
  final Color nonVegColor;

  const MenuItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isVeg,
    this.imageUrl,
    this.onAdd,
    this.purple = const Color(0xFF8E2FFD),
    this.vegColor = const Color(0xFF66BB6A),
    this.nonVegColor = const Color(0xFFF44336),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        width: 108,
                        height: 108,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: 108,
                          height: 108,
                          child: ColoredBox(color: Color(0xFFF5F5F5)),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(
                          width: 108,
                          height: 108,
                          child: ColoredBox(color: Color(0xFFF5F5F5)),
                        ),
                      )
                    : const SizedBox(
                        width: 108,
                        height: 108,
                        child: ColoredBox(color: Color(0xFFF5F5F5)),
                      ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isVeg ? vegColor : nonVegColor,
                      width: 1.05,
                    ),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 8.4,
                      height: 8.4,
                      decoration: BoxDecoration(
                        color: isVeg ? vegColor : nonVegColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 34,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF242424),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Text(
                price,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF242424),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                originalPrice,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF979797),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 37,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: purple, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: onAdd,
              child: Text(
                'Add',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


