import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/data.dart';
import '../utils/utils.dart';
import '../view/views.dart';

class RestaurantSectionsWidget extends StatelessWidget {
  final List<WidgetAction> restaurantSectionsItems;

  const RestaurantSectionsWidget({
    super.key,
    required this.restaurantSectionsItems,
  });

  @override
  Widget build(BuildContext context) {
    if (restaurantSectionsItems.isEmpty) return const SizedBox.shrink();

    final Map<String, List<String>> sectionToImages = {};
    for (final item in restaurantSectionsItems) {
      final String sectionName = (item.sectionName ?? '').trim();
      final String image = (item.image ?? '').trim();
      if (sectionName.isEmpty || image.isEmpty) continue;
      (sectionToImages[sectionName] ??= []).add(image);
    }

    if (sectionToImages.isEmpty) return const SizedBox.shrink();

    final List<MapEntry<String, List<String>>> sections = sectionToImages.entries.toList();
    final String? storeName = restaurantSectionsItems
        .cast<WidgetAction?>()
        .firstWhere(
          (e) => (e?.storeName ?? '').trim().isNotEmpty,
          orElse: () => null,
        )
        ?.storeName;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 294),
        child: Container(
          padding: const EdgeInsetsDirectional.only(start: 15, end: 15, top: 20, bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE9DFFB)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < sections.length; i++) ...[
                _RestaurantSectionBlock(
                  title: sections[i].key,
                  imageUrls: sections[i].value,
                ),
                if (i != sections.length - 1) ...[
                  const SizedBox(height: 12),
                  const _DashedDivider(color: Color(0xFFD8DEF3)),
                  const SizedBox(height: 12),
                ],
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 37,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RestaurantSectionsGalleryScreen(
                          storeName: storeName,
                          sections: sectionToImages,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8E2FFD),
                    side: const BorderSide(color: Color(0xFF8E2FFD), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    textStyle: AppTextStyles.bodyText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  child: Text(AppTranslations.viewMorePhotos),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantSectionBlock extends StatelessWidget {
  final String title;
  final List<String> imageUrls;

  const _RestaurantSectionBlock({
    required this.title,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> visibleUrls = imageUrls.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final url = visibleUrls[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 74,
                  height: 74,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFFF3F3F3)),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFF3F3F3),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Color color;

  const _DashedDivider({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const thickness = 1.0;
    const dashWidth = 6.0;
    const dashGap = 4.0;
    return SizedBox(
      height: thickness,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          thickness: thickness,
          dashWidth: dashWidth,
          dashGap: dashGap,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double dashGap;

  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      final x2 = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

