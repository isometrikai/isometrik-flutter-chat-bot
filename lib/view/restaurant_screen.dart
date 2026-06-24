import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/services/services.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/view/restaurant/restaurant_cart_actions.dart';
import 'package:chat_bot/view/restaurant/restaurant_store_list.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/search_result_states.dart';
import 'widgets/search_screen_scaffold.dart';

const _defaultRestaurantTitle = 'Choose from top restaurants';
const _chipBorderIdle = Color(0xFFD8DEF3);

class RestaurantScreen extends StatefulWidget {
  final WidgetAction? actionData;
  final bool isTableBookingFlow;
  final void Function(bool)? onCheckout;
  final void Function(Store)? onTableBookingTap;
  final void Function(Store, Product?)? onDonationTap;

  const RestaurantScreen({
    super.key,
    this.actionData,
    this.isTableBookingFlow = false,
    this.onCheckout,
    this.onTableBookingTap,
    this.onDonationTap,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  late final RestaurantBloc _bloc;
  late final CartBloc _cartBloc;
  List<UniversalCartData> _cartData = [];

  @override
  void initState() {
    super.initState();
    _bloc = RestaurantBloc();
    _cartBloc = CartBloc();
    _cartData = globalCartData;
    isCartAPICalled = false;
    _bootstrapData();
    _listenToCartUpdates();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _listenToCartUpdates() {
    OrderService().setCartUpdateCallback((bool isCartUpdate) {
      if (mounted && isCartUpdate) {
        isCartAPICalled = true;
        needToCallChatScreenSendMessageAPI = false;
        _cartBloc.add(CartFetchRequested(needToShowLoader: true));
      }
    });

    _cartBloc.stream.listen((state) {
      if (!mounted) return;

      if (state is CartLoaded && state.rawCartData != null) {
        setState(() => _cartData = state.rawCartData!.data);
      } else if (state is CartEmpty) {
        setState(() => _cartData = []);
      } else if (state is CartError) {
        BlackToastView.show(context, state.message);
      }
    });
  }

  void _bootstrapData() {
    _cartBloc.add(CartFetchRequested(needToShowLoader: false));
    _bloc.add(
      RestaurantFetchRequested(
        keyword: widget.actionData?.keyword ?? '',
        storeCategoryName: widget.actionData?.storeCategoryName ?? '',
        storeCategoryId: widget.actionData?.storeCategoryId ?? '',
        needToShowLoader: true,
      ),
    );
  }

  void _onClose() {
    widget.onCheckout?.call(true);
    Navigator.of(context).pop();
  }

  RestaurantCartActions get _cartActions => RestaurantCartActions(
        cartBloc: _cartBloc,
        context: context,
        cartData: _cartData,
      );

  @override
  Widget build(BuildContext context) {
    final action = widget.actionData;

    return BlocProvider.value(
      value: _bloc,
      child: SearchScreenScaffold(
        title: action != null
            ? searchScreenTitle(action, _defaultRestaurantTitle)
            : _defaultRestaurantTitle,
        subtitle: action != null ? searchScreenSubtitle(action) : null,
        onClose: _onClose,
        body: Column(
          children: [
            _RestaurantSearchBar(
              storeCategoryName: action?.storeCategoryName ?? '',
              storeCategoryId: action?.storeCategoryId ?? '',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RestaurantStoreList(
                isTableBookingFlow: widget.isTableBookingFlow,
                cartData: _cartData,
                cartActions: _cartActions,
                cartBloc: _cartBloc,
                onTableBookingTap: widget.onTableBookingTap,
                onDonationTap: widget.onDonationTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantSearchBar extends StatefulWidget {
  final String storeCategoryName;
  final String storeCategoryId;

  const _RestaurantSearchBar({
    required this.storeCategoryName,
    required this.storeCategoryId,
  });

  @override
  State<_RestaurantSearchBar> createState() => _RestaurantSearchBarState();
}

class _RestaurantSearchBarState extends State<_RestaurantSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _lastQueryAt;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final keyword = value.trim();
    final now = DateTime.now();
    _lastQueryAt = now;

    if (keyword.isEmpty) {
      context.read<RestaurantBloc>().add(
            RestaurantFetchRequested(
              keyword: '',
              storeCategoryName: widget.storeCategoryName,
              storeCategoryId: widget.storeCategoryId,
            ),
          );
      return;
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_lastQueryAt != now) return;

      context.read<RestaurantBloc>().add(
            RestaurantFetchRequested(
              keyword: keyword,
              storeCategoryName: widget.storeCategoryName,
              storeCategoryId: widget.storeCategoryId,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _chipBorderIdle),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTextStyles.bodyText.copyWith(
                  color: SearchResultTheme.emptyTextColor,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 17),
              ),
              onChanged: _onSearchChanged,
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
}
