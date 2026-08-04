import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/view/cart_screen.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/services/services.dart';
import 'package:chat_bot/view/restaurant_menu/helpers/menu_filter.dart';
import 'package:chat_bot/view/restaurant_menu/helpers/restaurant_menu_cart_actions.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/animated_menu_header.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/bottom_cart_bar.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/diet_toggles.dart';
import 'package:chat_bot/view/restaurant_menu/widgets/menu_content.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final chat.WidgetAction? actionData;
  final Function(bool)? onCheckout;

  const RestaurantMenuScreen({super.key, this.actionData, this.onCheckout});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _headerAnimDuration = Duration(milliseconds: 300);
  static const double _collapseScrollDistance = 80;

  final ScrollController _scrollController = ScrollController();
  late final RestaurantMenuBloc _bloc;
  late final CartBloc _cartBloc;
  late final AnimationController _collapseController;
  late final Animation<double> _collapseAnimation;
  late final RestaurantMenuCartActions _cartActions;

  int _selectedMainCategoryIndex = 0;
  int _selectedSubIndex = 0;
  bool _filterVeg = false;
  bool _filterNonVeg = false;
  List<UniversalCartData> _cartData = [];
  final Map<String, int> _subIndexByCategory = <String, int>{};

  @override
  void initState() {
    super.initState();
    isCartAPICalled = false;
    _cartData = globalCartData;
    _bloc = RestaurantMenuBloc(actionData: widget.actionData);
    _cartBloc = CartBloc();
    _cartActions = RestaurantMenuCartActions(
      cartBloc: _cartBloc,
      storeId: widget.actionData?.storeId ?? '',
      storeCategoryId: widget.actionData?.storeCategoryId ?? '',
      storeTypeId: widget.actionData?.storeTypeId ?? -111,
    );
    _cartBloc.add(CartFetchRequested(needToShowLoader: false));
    _bloc.add(const RestaurantMenuRequested());

    _collapseController = AnimationController(
      vsync: this,
      duration: _headerAnimDuration,
    );
    _collapseAnimation = CurvedAnimation(
      parent: _collapseController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );

    _scrollController.addListener(_onScroll);

    OrderService().setCartUpdateCallback((bool isCartUpdate) {
      if (mounted && isCartUpdate) {
        debugPrint('RestaurantMenuScreen: Cart update received - $isCartUpdate');
        isCartAPICalled = true;
        needToCallChatScreenSendMessageAPI = false;
        _cartBloc.add(CartFetchRequested(needToShowLoader: true));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double progress =
        (_scrollController.offset / _collapseScrollDistance).clamp(0.0, 1.0);
    if ((progress - _collapseController.value).abs() > 0.001) {
      _collapseController.value = progress;
    }
  }

  void _onClose() {
    widget.onCheckout?.call(true);
    Navigator.of(context).pop();
  }

  String _resolveStoreName(StoreData? storeData) {
    if (storeData?.storeName.isNotEmpty == true) {
      return storeData!.storeName;
    }
    if (widget.actionData?.storeName?.isNotEmpty == true) {
      return widget.actionData!.storeName!;
    }
    return widget.actionData?.title ?? '';
  }

  void _updateCartData(List<UniversalCartData> cartData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _cartData = cartData);
      }
    });
  }

  void _onViewCart() {
    Navigator.push(
      context,
      AppLocale.materialRoute<void>(
        builder: (BuildContext context) => BlocProvider<CartBloc>.value(
          value: _cartBloc,
          child: CartScreen(
            needToShowCheckoutButton: false,
            storeCategoryId: widget.actionData?.storeCategoryId,
            onCheckout: (String message, String? storeCategoryId) {
              widget.onCheckout?.call(true);
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLocale.wrap(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _bloc),
          BlocProvider.value(value: _cartBloc),
        ],
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocListener<CartBloc, CartState>(
              listener: (BuildContext context, CartState state) {
                if (state is CartLoaded && state.rawCartData != null) {
                  _updateCartData(state.rawCartData!.data);
                } else if (state is CartEmpty) {
                  _updateCartData([]);
                }
              },
              child: BlocBuilder<RestaurantMenuBloc, RestaurantMenuState>(
                builder: (BuildContext context, RestaurantMenuState state) {
                  final StoreData? storeData =
                      state is RestaurantMenuLoadSuccess
                          ? state.storeData
                          : null;
                  final String storeName = _resolveStoreName(storeData);

                  return BlocBuilder<CartBloc, CartState>(
                    builder: (BuildContext context, CartState cartState) {
                      final int itemCount = _cartBloc.getFoodCategoryCount;
                      return Column(
                        children: <Widget>[
                          RestaurantMenuAnimatedHeader(
                            storeData: storeData,
                            storeName: storeName,
                            actionData: widget.actionData,
                            collapseAnimation: _collapseAnimation,
                            onClose: _onClose,
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              16,
                              0,
                              16,
                              0,
                            ),
                            child: RestaurantDietToggles(
                              filterVeg: _filterVeg,
                              filterNonVeg: _filterNonVeg,
                              onVegChanged: (value) =>
                                  setState(() => _filterVeg = value),
                              onNonVegChanged: (value) =>
                                  setState(() => _filterNonVeg = value),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                16,
                                0,
                                16,
                                itemCount > 0 ? 16 : 24,
                              ),
                              child: RestaurantMenuContent(
                                state: state,
                                selectedMainCategoryIndex:
                                    _selectedMainCategoryIndex,
                                selectedSubIndex: _selectedSubIndex,
                                subIndexByCategory: _subIndexByCategory,
                                filterCriteria: MenuFilterCriteria(
                                  filterVeg: _filterVeg,
                                  filterNonVeg: _filterNonVeg,
                                ),
                                cartData: _cartData,
                                cartActions: _cartActions,
                                actionData: widget.actionData,
                                onMainCategorySelected: (index) {
                                  setState(() {
                                    _selectedMainCategoryIndex = index;
                                    _selectedSubIndex = 0;
                                  });
                                },
                                onSubSelected: (category, index) {
                                  setState(() {
                                    if (_selectedMainCategoryIndex == 0) {
                                      _subIndexByCategory[category.catName] =
                                          index;
                                    } else {
                                      _selectedSubIndex = index;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          if (itemCount > 0)
                            RestaurantBottomCartBar(
                              itemCount: itemCount,
                              onViewCart: _onViewCart,
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
