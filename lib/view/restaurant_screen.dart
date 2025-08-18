import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../data/model/chat_response.dart';
import '../widgets/store_card.dart';

class RestaurantScreen extends StatefulWidget {
  final SeeMoreAction? actionData;
  final List<Store>? restaurantList;

  const RestaurantScreen({super.key, this.actionData, this.restaurantList});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterOptions = ['Wraps', 'Arabian', 'Pizza', 'Burgers', 'Deserts', 'Drinks'];
  String _selectedFilter = 'Wraps';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildTitleSection(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildRestaurantList()),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Here are some healthy\nrestaurants near you',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1.2,
                  color: Color(0xFF171212),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Which one sounds good?',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF6E4185),
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
                  onPressed: () => Navigator.pop(context),
                ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DEF3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Color(0xFF979797),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 17),
              ),
              onChanged: (value) {
                // Implement search functionality here
                setState(() {});
              },
            ),
          ),
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(54),
            ),
            child: const Icon(
              Icons.search,
              size: 17,
              color: Color(0xFF585C77),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRestaurantList() {
    final restaurants = widget.restaurantList;
    
    if (restaurants == null || restaurants.isEmpty) {
      return const Center(
        child: Text(
          'No restaurants available',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6E4185),
          ),
        ),
      );
    }
    
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: restaurants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        try {
          return StoreCard(
            store: restaurants[index],
            storesWidget: null,
            index: index,
            onTap: () {
              // Handle restaurant tap
              Navigator.pop(context);
            },
          );
        } catch (e) {
          // Fallback in case of error
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              border: Border.all(color: const Color(0xFFEEF4FF), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              restaurants[index].storename,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF242424),
              ),
            ),
          );
        }
      },
    );
  }

}
