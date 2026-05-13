import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/utils.dart';

class RestaurantSectionsGalleryScreen extends StatefulWidget {
  final String? storeName;
  final Map<String, List<String>> sections;

  const RestaurantSectionsGalleryScreen({
    super.key,
    required this.sections,
    this.storeName,
  });

  @override
  State<RestaurantSectionsGalleryScreen> createState() =>
      _RestaurantSectionsGalleryScreenState();
}

class _RestaurantSectionsGalleryScreenState
    extends State<RestaurantSectionsGalleryScreen> {
  late final List<String> _sectionNames;
  late String _selectedSection;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _sectionNames = widget.sections.keys.toList();
    _selectedSection = _sectionNames.isNotEmpty ? _sectionNames.first : '';
  }

  List<String> get _currentImages => widget.sections[_selectedSection] ?? const [];

  void _selectSection(String sectionName) {
    if (sectionName == _selectedSection) return;
    setState(() {
      _selectedSection = sectionName;
      _selectedImageIndex = 0;
    });
  }

  void _selectImage(int index) {
    if (index < 0 || index >= _currentImages.length) return;
    setState(() => _selectedImageIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final images = _currentImages;
    final mainUrl = images.isNotEmpty
        ? images[math.min(_selectedImageIndex, images.length - 1)]
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'View Photos',
                      style: AppTextStyles.heading(
                        fontSize: 24,
                        color: const Color(0xFF171212),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: Color(0xFF585C77)),
                  ),
                ],
              ),
            ),
            if ((widget.storeName ?? '').trim().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'From ${widget.storeName}',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA2A2A2),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Divider(color: Color(0xFFD8DEF3), thickness: 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _sectionNames.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final name = _sectionNames[index];
                  final count = (widget.sections[name] ?? const []).length;
                  final selected = name == _selectedSection;
                  return _SectionChip(
                    title: name,
                    count: count,
                    selected: selected,
                    onTap: () => _selectSection(name),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 343 / 492,
                        child: Container(
                          color: const Color(0xFF0F0021).withValues(alpha: 0.7), // #0F0021 @ 70%
                          child: mainUrl == null
                              ? const SizedBox.expand()
                              : Image.network(
                                  mainUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox.expand(),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFF0F0021).withValues(alpha: 0.7),
                                      alignment: Alignment.center,
                                      child: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _DashedDivider(color: Color(0xFFD8DEF3)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 58,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final url = images[index];
                          final selected = index == _selectedImageIndex;
                          return _Thumbnail(
                            url: url,
                            selected: selected,
                            onTap: () => _selectImage(index),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final String title;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _SectionChip({
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF8E2FFD) : const Color(0xFFD8DEF3);
    final bgColor = selected ? const Color(0xFFFDFAFF) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(80),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(80),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF242424),
                height: 1.4,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.6),
              decoration: BoxDecoration(
                color: const Color(0xFF8E2FFD),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String url;
  final bool selected;
  final VoidCallback onTap;

  const _Thumbnail({
    required this.url,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF8E2FFD) : Colors.transparent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 54,
        height: 54,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Color color;

  const _DashedDivider({required this.color});

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

