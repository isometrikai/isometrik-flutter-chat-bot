import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/chat_response.dart';
import '../widgets/store_card.dart';
import '../widgets/screen_header.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_bloc.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_event.dart';
import 'package:chat_bot/bloc/restaurant/restaurant_state.dart';

class RestaurantScreen extends StatefulWidget {
  final WidgetAction? actionData;
  final Function(AddToCartEvent)? onAddToCart;

  const RestaurantScreen({
    super.key, 
    this.actionData,
    this.onAddToCart,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final RestaurantBloc _bloc;
  String _currentKeyword = '';
  DateTime? _lastQueryAt;

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _currentKeyword = value.trim();
    final now = DateTime.now();
    _lastQueryAt = now;
    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      // Debounce: only proceed if this is the latest input
      if (_lastQueryAt != now) return;
      _bloc.add(RestaurantFetchRequested(keyword: _currentKeyword));
    });
  }

  @override
  void initState() {
    super.initState();
    _bloc = RestaurantBloc();
    _bootstrapData();
  }

  Future<void> _bootstrapData() async {
    _bloc.add(RestaurantFetchRequested(keyword: _currentKeyword));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
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
                      ScreenHeader(
                        title: widget.actionData?.title ?? '',
                        subtitle: widget.actionData?.subtitle ?? '',
                      ),
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
      ),
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
                _onSearchChanged(value);
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
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoadInProgress || state is RestaurantInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RestaurantLoadFailure) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6E4185),
              ),
            ),
          );
        }

        final restaurants = (state as RestaurantLoadSuccess).restaurants;
        if (restaurants.isEmpty) {
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
                  Navigator.pop(context);
                },
                onAddToCart: widget.onAddToCart,
              );
            } catch (e) {
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
      },
    );
  }

}
