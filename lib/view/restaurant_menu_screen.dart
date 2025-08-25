import 'package:chat_bot/data/model/chat_response.dart';
import 'package:flutter/material.dart';
import 'package:chat_bot/data/model/restaurant_menu_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_bloc.dart';
import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_event.dart';
import 'package:chat_bot/bloc/restaurant_menu/restaurant_menu_state.dart';
import 'package:chat_bot/widgets/menu_item_card.dart';
import 'package:chat_bot/widgets/screen_header.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final WidgetAction? actionData;

  const RestaurantMenuScreen({super.key, this.actionData});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  static const Color _purple = Color(0xFF8E2FFD);
  static const Color _border = Color(0xFFD8DEF3);
  static const Color _labelGrey = Color(0xFF979797);
  static const Color _veg = Color(0xFF66BB6A);
  static const Color _nonVeg = Color(0xFFF44336);

  final TextEditingController _searchController = TextEditingController();
  late final RestaurantMenuBloc _bloc;

  // Dynamic data from API
  List<ProductCategory> _categories = <ProductCategory>[];
  int _selectedMainCategoryIndex = 0;
  int _selectedBiriyaniSubIndex = 0;
  bool _filterVeg = false;
  bool _filterNonVeg = false;

  

  // Maintain subcategory selection per category for ALL view
  final Map<String, int> _subIndexByCategory = <String, int>{};

  @override
  void initState() {
    super.initState();
    _bloc = RestaurantMenuBloc(actionData: widget.actionData);
    _bloc.add(const RestaurantMenuRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const ScreenHeader(
                        title: 'Soup & Salad Co has amazing arabic food.',
                        subtitle: 'Here are their popular dishes',
                      ),
                      const SizedBox(height: 16),
                      _buildSearchBar(theme),
                      const SizedBox(height: 16),
                      _buildDietToggles(),
                      const SizedBox(height: 16),
                      BlocBuilder<RestaurantMenuBloc, RestaurantMenuState>(
                        builder: (context, state) {
                          if (state is RestaurantMenuInitial || state is RestaurantMenuLoadInProgress) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (state is RestaurantMenuLoadFailure) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Text(
                                state.message,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          final categories = (state as RestaurantMenuLoadSuccess).categories;
                          _categories = categories;
                          if (categories.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Text('No menu available'),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildMainCategories(),
                              const SizedBox(height: 24),
                              _buildCurrentCategorySection(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: _labelGrey,
                      fontSize: 16,
                    ),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(54),
            ),
            child: const Icon(Icons.search, size: 18, color: Color(0xFF585C77)),
          ),
        ],
      ),
    );
  }

  Widget _buildDietToggles() {
    return Row(
      children: <Widget>[
        _DietToggle(
          color: _nonVeg,
          value: _filterNonVeg,
          onChanged: (bool v) {
            setState(() => _filterNonVeg = v);
          },
        ),
        const SizedBox(width: 8),
        _DietToggle(
          color: _veg,
          value: _filterVeg,
          onChanged: (bool v) {
            setState(() => _filterVeg = v);
          },
        ),
      ],
    );
  }

  Widget _buildMainCategories() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1, // +1 for ALL
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == _selectedMainCategoryIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedMainCategoryIndex = index;
              _selectedBiriyaniSubIndex = 0;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF9FF) : Colors.white,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: isSelected ? _purple : _border),
              ),
              alignment: Alignment.center,
              child: Text(
                index == 0 ? 'ALL' : _categories[index - 1].catName,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF242424),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoryChips({
    required ProductCategory category,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return SizedBox(
      height: 31,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: category.subCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => onSelected(index)),
            child: Container(
              height: 31,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF9FF) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? _purple : _border),
              ),
              alignment: Alignment.center,
              child: Text(
                category.subCategories[index].name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF242424),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ProductCategory? get _currentCategory =>
      (_categories.isNotEmpty && _selectedMainCategoryIndex > 0)
          ? _categories[_selectedMainCategoryIndex - 1]
          : null; // null means ALL

  Widget _buildCurrentCategorySection() {
    final ProductCategory? category = _currentCategory;
    if (category == null) {
      // ALL view: display each category as its own section
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final ProductCategory c in _categories) ...<Widget>[
            _buildOneCategorySection(
              category: c,
              selectedSubIndex:
                  _subIndexByCategory[c.catName] ?? 0,
              onSubSelected: (int idx) => _subIndexByCategory[c.catName] = idx,
            ),
            const SizedBox(height: 24),
          ]
        ],
      );
    }

    // Single category view
    return _buildOneCategorySection(
      category: category,
      selectedSubIndex: _selectedBiriyaniSubIndex,
      onSubSelected: (int idx) => _selectedBiriyaniSubIndex = idx,
    );
  }

  Widget _buildOneCategorySection({
    required ProductCategory category,
    required int selectedSubIndex,
    required ValueChanged<int> onSubSelected,
  }) {
    final List<_MenuItem> items = <_MenuItem>[];
    if (category.isSubCategories && category.subCategories.isNotEmpty) {
      final int subIndex = (selectedSubIndex >= 0 &&
              selectedSubIndex < category.subCategories.length)
          ? selectedSubIndex
          : 0;
      final List<Product> products =
          category.subCategories[subIndex].products;
      items.addAll(products.map(_mapProduct));
    } else {
      items.addAll(category.products.map(_mapProduct));
    }

    final List<_MenuItem> filtered = items.where((menuItem) {
      if (_filterVeg && !menuItem.isVeg) return false;
      if (_filterNonVeg && menuItem.isVeg) return false;
      if (_searchController.text.trim().isNotEmpty &&
          !menuItem.title
              .toLowerCase()
              .contains(_searchController.text.trim().toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          category.catName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF242424),
          ),
        ),
        const SizedBox(height: 8),
        if (category.isSubCategories && category.subCategories.isNotEmpty) ...<Widget>[
          _buildSubcategoryChips(
            category: category,
            selectedIndex: selectedSubIndex,
            onSelected: onSubSelected,
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 222,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final _MenuItem item = filtered[index];
              return MenuItemCard(
                title: item.title,
                price: item.price,
                originalPrice: item.originalPrice,
                isVeg: item.isVeg,
                imageUrl: item.imageUrl,
                purple: _purple,
                vegColor: _veg,
                nonVegColor: _nonVeg,
                onClick: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  _MenuItem _mapProduct(Product p) {
    final String priceText = _formatCurrency(
      p.currencySymbol,
      p.finalPriceList.finalPrice,
    );
    final String basePriceText = _formatCurrency(
      p.currencySymbol,
      p.finalPriceList.basePrice,
    );
    final String? imageUrl = _extractImageUrl(p.images);
    return _MenuItem(
      title: p.productName,
      price: priceText,
      originalPrice: basePriceText,
      isVeg: !p.containsMeat,
      assetPath: imageUrl ?? 'assets/images/men.png',
      imageUrl: imageUrl,
    );
  }

  String _formatCurrency(String symbol, double value) {
    // Keep simple formatting matching the mock (e.g., AED25)
    if (symbol.isNotEmpty && symbol != 'AED') {
      return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return 'AED${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
  }

  String? _extractImageUrl(dynamic images) {
    if (images == null) return null;
    if (images is String) {
      return images.isNotEmpty ? images : null;
    }
    if (images is List && images.isNotEmpty) {
      final dynamic first = images.first;
      if (first is String && first.isNotEmpty) return first;
    }
    return null;
  }

  // Removed mock items in favor of API-driven content
}

class _DietToggle extends StatelessWidget {
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DietToggle({
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: 28,
        height: 20,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              width: 28,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DEF3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Positioned(
              top: -5,
              left: value ? 12 : 0, // Move to right when ON
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1.2),
                ),
                child: Center(
                  child: Container(
                    width: 9.6,
                    height: 9.6,
                    decoration: BoxDecoration(
                      color: color , // Show color only when ON
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Replaced inline card with shared MenuItemCard

class _MenuItem {
  final String title;
  final String price;
  final String originalPrice;
  final bool isVeg;
  final String assetPath;
  final String? imageUrl;

  const _MenuItem({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isVeg,
    required this.assetPath,
    this.imageUrl,
  });
}


