import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bot/data/model/chat_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:chat_bot/data/model/restaurant_menu_response.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final SeeMoreAction? actionData;

  const RestaurantMenuScreen({super.key, this.actionData});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  static const Color _purple = Color(0xFF8E2FFD);
  static const Color _border = Color(0xFFD8DEF3);
  static const Color _labelGrey = Color(0xFF979797);
  static const Color _subtitle = Color(0xFF6E4185);
  static const Color _veg = Color(0xFF66BB6A);
  static const Color _nonVeg = Color(0xFFF44336);

  final TextEditingController _searchController = TextEditingController();

  // ===== API config (replace token/headers if needed) =====
  static const String _menuUrl =
      'https://apisuperapp-staging.eazy-online.com/get/storeMenu?containsMeat=1&lat=25.20485&long=55.270782&storeId=63627cf6b35f2f000c9ecc23&timezone=Asia%2FKolkata&z_id=636dfc8c89b6a857b500ccd1';
  static const String _platform = '1';
  static const String _currencySymbolHeader = '2K8u2KU=';
  static const String _currencyCode = 'AED';
  static const String _language = 'en';
  static const String _ipAddress = '192.168.1.3';
  static const String _bearerToken =
      'Bearer eyJhbGciOiJSU0EtT0FFUCIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJ0eXAiOiJKV1QifQ.MF0rQcJe9Z4fllfF9MOmWSvaHF8wP3H-sLWJZEGzkZ_-SeKmijur8Roiqff7LGi8Q3uOtUzqGe16qZktQIGI3tazEbVIT8OCD6QVEZUeVauE9g48UBxgdf7PLNhV5hq8hBYJAjeM-vrsDgYQrGStXb8u_t7WK8xBYuRrBubgkuE._KO4NJPc0vrHuGv6.4cbF9gWArQvjK6AYd3o7VTvwoP9HDbPsK6EhWq9M-iwLi1Yg68M6HXVvM-YncmVDF121x_rMnf3E5NmZS44xXoDiakqWaeEWBKBq83S5-lpMS70zpzywqGEaalauJSR44TiHhG2vDh1CKqbAFQNQ880v52qgNdwlWnZpO8J1vWb0jsKuMFI5tXGtfgB8cA_W3Gi8ujn1kpmaqAIe5Bdj7dBWVoaV8Fa5iEYZDSuiKmUMLiiN3Hbv_kLG7y6FzotrplQCN2ZZUCJBGIFvf7wcv6nEnOj6MpZxu3ebYREj7zICtHJzfEEVNkJQOJYLQDBhv6YqXClG3lqsnxYO06E1cgrNslDMistA9bUUK-u_4Fr0_qODFA4BQ2On5KkS8wURODQTgibSLw4HyPzGYVlk0Fc2Y5vAheLTnq0h2YwkWrMt2oPSL_wZFM_4o33F-BbiY9JFkJTZ7d-45xeR0D6Fre7JTH_7BnTy-nZ0SHsmAMX7d3tAc7feq4OWo6_XRaPFeHOb8WIxjhoAy60fc64t404OvesmmRF-Yc9XLH4LQSErbnxnhJWQoV-jT_HCP-LH0wDeDmxCfSx2saPB5_8qq_CUwbwOHNPGLaeNcRhX1z-hmhh2-L7Jg35bD5gRmw5PJOW9Wq7R-N1O7rTDCx7B2iSmaf2bfME4BGEAy-7VjYMBfymysy8SiX_iZVuD3snFYG81QPbLGNWnvJDI5XZeDWiz0f__qMIK9UNaMoCAVAICCaamv3qdTkUBalji7CrRQpZFcb1rLI-UsX0oMkzapspr_tDrMR8M_rANU2mYO1FQga6D7r6_efyo5ClIF0W9aBhRn9KO4wtHXzuWVttgrfDgcB4S1un8K8l0TT64-JV2KzoxPJFWydmH4IjZVguZpiWb6UaHMrj48sg4wm9h43IXk0TVbHMhSnlgEHzhNJny4BqYJGXuwC_XBoqUg74k_dZq2g2zXhWTQRfqVcGlvgECg-02A7wbo0DC6hvuQMn_9WRgdSNWsagi-5Y9Jhr-rsYjnDRrUplOi3kL1mMvtwDtElAzMX4xQd4jAPKFG4fu_hc2lFH90IkO2E51GzTmo3xDWNHw8hffFctOBt-ZW7EaDI3EO7aDpA3w10ivF-Gn2hW9IUPMZKzB0FeXUbu33DGjF6b_5JEOO4HbB8XGm7gcStGkBnSP9Nqgu-gJaaIU83vf7iP2EVBpQ8xBj0ImVHUvV9RizUgTfJKmd9varp1GD1lNLf0kHTFuW9j_ACpQX-zZaYRLMScfxGbW-B3HeRsaJtDiNBWvA97TzRuo-ALDhI812Xb5TuzrOO6b6K3cpPBqOKcMdVDnB6mmvU7PBPwiYs1XsWZhGyy2wqtgdYLMnysuRlgKKlV6FwAPTi5FLj1a7tYoSWgrg0eSwu0c_FM_pONtpOa_R9msCkzXf1jNLKrO_6eaH9Nn8g-LZddcEnrrlcKjFBCbuELEU4-zplkZ8yVOKyWWeM52zlg1VDeg-UzZXrSupR2SI4a0l1LirnwO6g_F2Q3fpVX91vQ0sPAvihvZdYZB07AMy0sitNu_Cw2ys2UcqWYCEVm4pJVrWWKXHrC5Xep9Xx5Zgicqb1DagVmwPr-NpCLThtrkSktR9N1LIafv53l_BNQXaRjFVmBHQ_KBXe4Gdl86mOcK3vE8OyNWirmC80Z9K8JL1WdxZ8LkkaNKd50jnu9g4f86FXDMeaOVCklLdD_9u8l2o3BEgr3x2G5bg3b08-k4zl1YavyhEJhR-RTIKFjuCvfXX9Rhss1EpM1Dcyh9LzMDsrpR1H-VQsb1E96bGwdDDMO-Kg.-PTlUaqPZnnjWftXWoOHoQ';

  // Dynamic data from API
  List<ProductCategory> _categories = <ProductCategory>[];
  int _selectedMainCategoryIndex = 0;
  int _selectedBiriyaniSubIndex = 0;
  bool _filterVeg = false;
  bool _filterNonVeg = false;

  bool _isLoading = false;
  String? _errorMessage;

  // Maintain subcategory selection per category for ALL view
  final Map<String, int> _subIndexByCategory = <String, int>{};

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
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
                      _buildTopBar(context),
                      const SizedBox(height: 16),
                    _buildSearchBar(theme),
                    const SizedBox(height: 16),
                    _buildDietToggles(),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (_categories.isNotEmpty) ...<Widget>[
                      _buildMainCategories(),
                      const SizedBox(height: 24),
                      _buildCurrentCategorySection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(_menuUrl),
        headers: <String, String>{
          'platform': _platform,
          'currencysymbol': _currencySymbolHeader,
          'Authorization': _bearerToken,
          'currencycode': _currencyCode,
          'language': _language,
          'ipAddress': _ipAddress,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        final RestaurantMenuResponse parsed = RestaurantMenuResponse.fromJson(body);
        setState(() {
          _categories = parsed.data.productData;
          _selectedMainCategoryIndex = 0;
          _selectedBiriyaniSubIndex = 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Soup & Salad Co has amazing arabic food.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF171212),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here are their popular dishes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _subtitle,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
         IconButton(
                  icon: SvgPicture.asset(
                    'assets/images/ic_close.svg',
                    width: 40,
                    height: 40,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
      ],
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
      final List<RestaurantProduct> products =
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
              return _MenuItemCard(
                item: item,
                purple: _purple,
                nonVeg: _nonVeg,
                veg: _veg,
              );
            },
          ),
        ),
      ],
    );
  }

  _MenuItem _mapProduct(RestaurantProduct p) {
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

class _MenuItemCard extends StatelessWidget {
  final _MenuItem item;
  final Color purple;
  final Color veg;
  final Color nonVeg;

  const _MenuItemCard({
    required this.item,
    required this.purple,
    required this.veg,
    required this.nonVeg,
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
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: 108,
                        height: 108,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const SizedBox(width: 108, height: 108, child: ColoredBox(color: Color(0xFFF5F5F5))),
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
                      color: item.isVeg ? veg : nonVeg,
                      width: 1.05,
                    ),
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 8.4,
                      height: 8.4,
                      decoration: BoxDecoration(
                        color: item.isVeg ? veg : nonVeg,
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
              item.title,
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
                item.price,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF242424),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                item.originalPrice,
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
              onPressed: () {},
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


