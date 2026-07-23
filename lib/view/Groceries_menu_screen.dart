import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/data/data.dart' as chat;
import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:chat_bot/view/views.dart';
import 'package:chat_bot/utils/utils.dart';
import 'package:chat_bot/services/services.dart';

class GroceriesMenuScreen extends StatefulWidget {
  final chat.WidgetAction? actionData;
  final Function(bool)? onCheckout;

  const GroceriesMenuScreen({super.key, this.actionData, this.onCheckout});

  @override
  State<GroceriesMenuScreen> createState() => _GroceriesMenuScreenState();
}

class _GroceriesMenuScreenState extends State<GroceriesMenuScreen>
    with SingleTickerProviderStateMixin {
  static const Color _purple = AppConstants.appThemeColor;
  static const Color _border = Color(0xFFD8DEF3);
  static const Color _veg = Color(0xFF66BB6A);
  static const Color _nonVeg = Color(0xFFF44336);
  static const Duration _headerAnimDuration = Duration(milliseconds: 300);
  static const double _collapseScrollDistance = 80;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _expandedHeaderKey = GlobalKey();
  late final GroceryMenuBloc _bloc;
  late final CartBloc cartBloc;
  late final AnimationController _collapseController;
  late final Animation<double> _collapseAnimation;
  double _measuredExpandedHeaderHeight = 0;

  // Dynamic data from API
  int _selectedMainCategoryIndex = 0;

  // Cart state
  List<UniversalCartData> _cartData = []; // Store cart data from getCart API

  @override
  void initState() {
    super.initState();
    isCartAPICalled = false;
    _cartData = globalCartData;
    _bloc = GroceryMenuBloc(actionData: widget.actionData);
    cartBloc = CartBloc();
    cartBloc.add(CartFetchRequested(needToShowLoader: false));
    _fetchSubCategoryProducts();
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
        print('GroceriesMenuScreen: Cart update received - $isCartUpdate');
        isCartAPICalled = true;
        needToCallChatScreenSendMessageAPI = false;
        cartBloc.add(CartFetchRequested(needToShowLoader: true));
      }
    });
  }

  void _fetchSubCategoryProducts() {
    _bloc.add(
      SubCategoryProductsRequested(
        storeId: widget.actionData?.storeId ?? '',
        subCategoryId: widget.actionData?.storeCategoryId ?? '',
        storeTypeId: widget.actionData?.storeTypeId,
        storeCategoryName: widget.actionData?.storeCategoryName ?? widget.actionData?.title,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseController.dispose();
    _searchController.dispose();
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
    if (widget.onCheckout != null) {
      widget.onCheckout!(true);
    }
    Navigator.of(context).pop();
  }

  String _resolveStoreName() {
    if (widget.actionData?.storeName?.trim().isNotEmpty == true) {
      return widget.actionData!.storeName!.trim();
    }
    return widget.actionData?.title ?? '';
  }

  int _cartItemCount() {
    if (widget.actionData?.storeCategoryId ==
        FoodStoreCategoryId.grocery.value) {
      return cartBloc.getGroceryCategoryCount;
    }
    if (widget.actionData?.storeCategoryId ==
        FoodStoreCategoryId.pharmacy.value) {
      return cartBloc.getPharmacyCategoryCount;
    }
    if (widget.actionData?.storeCategoryId ==
        FoodStoreCategoryId.services.value) {
      return cartBloc.getServicesCategoryCount;
    }
    if (widget.actionData?.storeCategoryId ==
        FoodStoreCategoryId.healthCare.value) {
      return cartBloc.getHealthCareCategoryCount;
    }
    if (widget.actionData?.storeCategoryId ==
        FoodStoreCategoryId.shopping.value) {
      return cartBloc.getShoppingCategoryCount;
    }
    if (widget.actionData?.storeCategoryId ==
        FoodStoreCategoryId.donation.value) {
      return cartBloc.getDonationCategoryCount;
    }
    if (widget.actionData?.storeCategoryId == FoodStoreCategoryId.food.value) {
      return cartBloc.getFoodCategoryCount;
    }
    return cartBloc.getTotalProductCount;
  }

  void _scheduleMeasureExpandedHeader() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderBox? box =
          _expandedHeaderKey.currentContext?.findRenderObject() as RenderBox?;
      final double height = box?.size.height ?? 0;
      if (height > 0 && (height - _measuredExpandedHeaderHeight).abs() > 1) {
        setState(() => _measuredExpandedHeaderHeight = height);
      }
    });
  }

  double _fallbackExpandedHeaderHeight() {
    double height = 16 + 56;
    final String subtitle = widget.actionData?.subtitle ?? '';
    if (subtitle.isNotEmpty) {
      height += 12 + 44;
    }
    if (_resolveStoreName().isNotEmpty) {
      height += 8 + 99 + 8;
    }
    return height;
  }

  Widget _buildCloseAction() {
    return IconButton(
      icon: SvgPicture.asset(
        AssetPath.get('images/ic_close.svg'),
        width: 40,
        height: 40,
      ),
      padding: EdgeInsets.zero,
      onPressed: _onClose,
    );
  }

  Widget _buildExpandedHeader({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
          child: ScreenHeader(
            title: widget.actionData?.title ?? '',
            subtitle: widget.actionData?.subtitle ?? '',
            onClose: _onClose,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: _buildStoreInfoCard(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAnimatedHeader(String storeName) {
    _scheduleMeasureExpandedHeader();

    return AnimatedBuilder(
      animation: _collapseAnimation,
      builder: (BuildContext context, Widget? child) {
        final double t = _collapseAnimation.value;

        if (t <= 0.001) {
          return _buildExpandedHeader(key: _expandedHeaderKey);
        }

        if (t >= 0.999) {
          return _buildCollapsedNavBar(storeName);
        }

        final double expandedHeight =
            _measuredExpandedHeaderHeight > 0
                ? _measuredExpandedHeaderHeight
                : _fallbackExpandedHeaderHeight();
        final double height =
            expandedHeight + (kToolbarHeight - expandedHeight) * t;

        return SizedBox(
          height: height,
          width: double.infinity,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.topCenter,
              children: <Widget>[
                IgnorePointer(
                  ignoring: t > 0.5,
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: _buildExpandedHeader(),
                  ),
                ),
                IgnorePointer(
                  ignoring: t < 0.5,
                  child: Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: _buildCollapsedNavBar(storeName),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsedNavBar(String storeName) {
    return Material(
      key: const ValueKey<String>('collapsed-header'),
      color: Colors.white,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                    color: Color(0xFF171212),
                  ),
                ),
              ),
              _buildCloseAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    const Color cardBackground = Color(0xFFF5F7FF);
    const Color cardBorder = Color(0xFFEEF4FF);
    const Color titleColor = Color(0xFF242424);
    const Color accentPurple = Color(0xFF8E2FFD);

    final String storeName = _resolveStoreName();
    final String imageUrl = (widget.actionData?.image ?? '').trim();

    if (storeName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBackground,
        border: Border.all(color: cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildStoreLogo(imageUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.restaurantTitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.actionData != null) {
                      OrderService().triggerStoreOrder(
                        widget.actionData!.toJson(),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SvgPicture.asset(
                        AssetPath.get('images/ic_eazy_app.svg'),
                        width: 13.8,
                        height: 12.96,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          accentPurple,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        AppTranslations.openInEazyApp,
                        style: AppTextStyles.restaurantDescription.copyWith(
                          color: accentPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreLogo(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 69,
        height: 69,
        child:
            imageUrl.isNotEmpty
                ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) return child;
                    return _buildStoreLogoPlaceholder();
                  },
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => _buildStoreLogoPlaceholder(),
                )
                : _buildStoreLogoPlaceholder(),
      ),
    );
  }

  Widget _buildStoreLogoPlaceholder() {
    return SvgPicture.asset(
      AssetPath.get('images/ic_placeHolder.svg'),
      width: 69,
      height: 69,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLocale.wrap(
      MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bloc),
        BlocProvider.value(value: cartBloc),
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
              } else if (state is CartError) {
                BlackToastView.show(
                  context,
                  state.message,
                );
              }
            },
            child: BlocBuilder<CartBloc, CartState>(
              builder: (BuildContext context, CartState cartState) {
                final int itemCount = _cartItemCount();
                final String storeName = _resolveStoreName();

                return Column(
                  children: <Widget>[
                    _buildAnimatedHeader(storeName),
                    Expanded(
                      child: BlocListener<GroceryMenuBloc, GroceryMenuState>(
                        listener: (
                          BuildContext context,
                          GroceryMenuState state,
                        ) {
                          if (state is SubCategoryProductsLoadFailure) {
                            print(
                              'SubCategoryProducts API Error: ${state.message}',
                            );
                          }
                        },
                        child: BlocBuilder<GroceryMenuBloc, GroceryMenuState>(
                          builder: (
                            BuildContext context,
                            GroceryMenuState state,
                          ) {
                            if (state is SubCategoryProductsLoadInProgress) {
                              return const SizedBox.shrink();
                            }
                            if (state is SubCategoryProductsLoadFailure) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 32),
                                child: Text(
                                  state.message,
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            }
                            if (state is SubCategoryProductsLoadSuccess) {
                              return _buildGroceryContent(
                                state.subCategoryProducts,
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    if (itemCount > 0) _buildBottomCartBar(itemCount),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildGroceryContent(
    SubCategoryProductsResponse subCategoryProducts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.actionData?.storeTypeId != FoodCategory.services.value) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCategoryFilterChips(subCategoryProducts),
          ),
          const SizedBox(height: 16),
        ],
        Expanded(child: _buildProductsGrid(subCategoryProducts)),
      ],
    );
  }

  Widget _buildCategoryFilterChips(
    SubCategoryProductsResponse subCategoryProducts,
  ) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subCategoryProducts.categoryData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final categoryData = subCategoryProducts.categoryData[index];
          final bool isSelected = index == _selectedMainCategoryIndex;
          return GestureDetector(
            onTap:
                () => setState(() {
                  _selectedMainCategoryIndex = index;
                }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF9FF) : Colors.white,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: isSelected ? _purple : _border),
              ),
              alignment: Alignment.center,
              child: Text(
                categoryData.subCategoryName,
                style: AppTextStyles.button.copyWith(
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

  // Calculate dynamic dimensions based on screen size
  Map<String, double> _calculateDynamicDimensions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate available width (screen width - horizontal padding - spacing)
    final horizontalPadding = 32.0;
    final availableWidth = screenWidth - horizontalPadding;

    // Calculate item width based on screen size
    double itemWidth;
    double itemHeight;
    double spacing;

    // Calculate fixed content height:
    // - Spacing after image: 4px
    // - Service time text (if present): ~14px + 4px spacing = 18px
    // - Title: 38px
    // - Spacing after title: 4px
    // - Price row: ~18px
    // - Spacing before controls: 8px
    // - Quantity controls: 37px
    // Total: 4 + 18 + 38 + 4 + 18 + 8 + 37 = 127px (with service time)
    // Total: 4 + 38 + 4 + 18 + 8 + 37 = 109px (without service time)
    // Use 130px to account for service time and add buffer for overflow
    const double fixedContentHeight = 130.0;

    if (screenWidth < 360) {
      // Small devices (like iPhone SE)
      itemWidth = (availableWidth - 12) / 2; // 12px spacing between items
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight + fixedContentHeight;
      spacing = 8.0;
    } else if (screenWidth < 400) {
      // Medium devices
      itemWidth = (availableWidth - 16) / 2; // 16px spacing
      final imageHeight = itemWidth * 0.9;
      itemHeight = imageHeight + fixedContentHeight;
      spacing = 10.0;
    } else {
      // Large devices (like iPhone Pro Max, tablets)
      itemWidth = (availableWidth - 20) / 2; // 20px spacing
      final imageHeight = itemWidth * 0.9;
      // Add extra height for services if needed
      itemHeight = imageHeight + fixedContentHeight + (widget.actionData?.storeTypeId == FoodCategory.services.value ? 38 : 0);
      spacing = 12.0;
    }

    return {
      'itemWidth': itemWidth,
      'itemHeight': itemHeight,
      'spacing': spacing,
      'aspectRatio': itemWidth / itemHeight,
    };
  }

  Widget _buildProductsGrid(SubCategoryProductsResponse subCategoryProducts) {
    if (subCategoryProducts.categoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Color(0xFF979797),
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.noProductsAvailable,
              style: AppTextStyles.restaurantTitle.copyWith(
                color: const Color(0xFF979797),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTranslations.tryAdjustingSearch,
              style: AppTextStyles.restaurantDescription.copyWith(
                color: const Color(0xFF979797),
              ),
            ),
          ],
        ),
      );
    }

    // Get products from selected category or all categories
    List<SubCategoryProduct> allProducts = [];
    if (_selectedMainCategoryIndex < subCategoryProducts.categoryData.length) {
      allProducts =
          subCategoryProducts
              .categoryData[_selectedMainCategoryIndex]
              .subCategory;
    } else {
      // Show all products from all categories
      for (final categoryData in subCategoryProducts.categoryData) {
        allProducts.addAll(categoryData.subCategory);
      }
    }

    return Builder(
      builder: (BuildContext context) {
        final dimensions = _calculateDynamicDimensions(context);
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: dimensions['aspectRatio']!,
            crossAxisSpacing: dimensions['spacing']!,
            mainAxisSpacing: dimensions['spacing']!,
          ),
          itemCount: allProducts.length,
          itemBuilder: (BuildContext context, int index) {
              final subCategoryProduct = allProducts[index];
              final product = subCategoryProduct.toProduct();
              final menuItem = _mapProduct(product);

              return MenuItemCard(
                title: menuItem.title,
                price: menuItem.price,
                originalPrice: menuItem.originalPrice,
                isVeg: menuItem.isVeg,
                imageUrl: menuItem.imageUrl,
                productId: menuItem.productId,
                centralProductId: menuItem.centralProductId,
                isCustomizable: menuItem.isCustomizable,
                purple: _purple,
                vegColor: _veg,
                nonVegColor: _nonVeg,
                imageWidth: dimensions['itemWidth']!,
                imageHeight: dimensions['itemWidth']! * 0.9,
                // Better proportion for taller cards
                cardWidth: dimensions['itemWidth']!,
                cartData: _cartData,
                instock: product.instock ?? true,
                storeIsOpen: widget.actionData?.storeIsOpen ?? true,
                storeType: product.storeTypeId ?? -111,
                serviceRequireTime: menuItem.serviceRequireTime,
                onQuantityChanged: (
                  productId,
                  centralProductId,
                  quantity,
                  isIncrease,
                  isCustomizable,
                ) {
                  _onQuantityChangedForGrocery(
                    product.parentProductId,
                    product.childProductId,
                    product.unitId,
                    product.storeId ?? '',
                    product.storeCategoryId ?? '',
                    product.storeTypeId ?? -111,
                    product.variantsCount,
                    quantity,
                    isIncrease,
                    product.productName,
                    product.productImage,
                    isCustomizable,
                  );
                },
                onClick: () {
                  // Handle product click
                  final Map<String, dynamic> productJson = product.toJson();
                  // Add store information to the JSON
                  productJson['storeId'] = widget.actionData?.storeId;
                  productJson['storeCategoryId'] =
                      widget.actionData?.storeCategoryId;
                  productJson['storeTypeId'] = widget.actionData?.storeTypeId;

                  print("productJson: $productJson");
                  OrderService().triggerProductOrder(productJson);
                },
                onAddToCart: (
                  productId,
                  centralProductId,
                  quantity,
                  isCustomizable,
                ) {
                  if (isCustomizable) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => GroceryCustomizationScreen(
                            parentProductId: product.parentProductId,
                            productId: product.childProductId,
                            storeId: widget.actionData?.storeId ?? '',
                            productName: product.productName,
                            productImage: product.productImage,
                            onAddToCart: (parentProductId, productId, unitId) {
                              _onAddToCartForGrocery(
                                parentProductId,
                                productId,
                                unitId,
                                widget.actionData?.storeId ?? '',
                                widget.actionData?.storeCategoryId ?? '',
                                FoodCategory.grocery.value,
                                null,
                              );
                            },
                          ),
                    );
                  } else {
                    cartBloc.add(
                      CartAddItemRequested(
                        storeId: widget.actionData?.storeId ?? '',
                        cartType: 1,
                        action: 1,
                        storeCategoryId:
                            widget.actionData?.storeCategoryId ?? '',
                        newQuantity: quantity,
                        storeTypeId: widget.actionData?.storeTypeId ?? -111,
                        productId: productId,
                        centralProductId: centralProductId,
                        unitId: '',
                      ),
                    );
                  }
                },
              );
            },
          );
        },
    );
  }

  void _onAddToCartForGrocery(
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int? addToCartOnId,
  ) {
    try {
      num? addToCartId = _getAddToCartOnId(productId);
        if (addToCartId != null) {
          
          print("addToCartId: $addToCartId");
          final existingProductQuantity = _getExistingProductQuantity(productId, addToCartId);
          print("existingProductQuantity: $existingProductQuantity");

        //TODO:- Add Quantity
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          // Default cart type
          action: 2,
          // Add action
          storeCategoryId: storeCategoryId,
          newQuantity: existingProductQuantity + 1,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartId,
        ),
      );

        }else {
            //TODO:- Add Quantity
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 1,
          // Default cart type
          action: 1,
          // Add action
          storeCategoryId: storeCategoryId,
          newQuantity: 1,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartOnId,
        ),
      );
        }
      

      print("Added product to cart: ${productId}");
    } catch (e) {
      print(
        'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
      );
    }
  }

  _MenuItem _mapProduct(chat.Product p) {
    final String priceText = _formatCurrency(
      p.currency,
      p.finalPriceList.finalPrice,
    );
    final String basePriceText = _formatCurrency(
      p.currency,
      p.finalPriceList.basePrice,
    );
    final String? imageUrl = _extractImageUrl(p.images);
    return _MenuItem(
      title: p.productName,
      price: priceText,
      originalPrice: basePriceText,
      isVeg: !p.containsMeat,
      assetPath: imageUrl ?? '',
      imageUrl: imageUrl,
      productId: p.childProductId,
      centralProductId: p.parentProductId,
      isCustomizable: p.variantCount ?? false,
      serviceRequireTime: p.serviceRequireTime,
    );
  }

  String _formatCurrency(String symbol, double value) {
    // Format currency with proper symbol
    if (symbol.isNotEmpty) {
      return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
    }
    return '$symbol ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}';
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

  void _onViewCart() {
    Navigator.push(
      context,
      AppLocale.materialRoute<void>(
        builder: (BuildContext context) => BlocProvider<CartBloc>.value(
          value: cartBloc,
          child: CartScreen(
            needToShowCheckoutButton: false,
            storeCategoryId: widget.actionData?.storeCategoryId,
            onCheckout: (String message, String? storeCategoryId) {
              if (widget.onCheckout != null) {
                widget.onCheckout!(true);
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCartBar(int itemCount) {
    final String itemLabel =
        itemCount == 1 ? AppTranslations.oneItemAdded : AppTranslations.itemsAdded(itemCount.toString());
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFD4D4D4).withValues(alpha: 0.25),
            offset: const Offset(0, -4),
            blurRadius: 9,
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.fromSTEB(16, 15, 16, bottomInset > 0 ? 8 : 16),
      child: GestureDetector(
        onTap: _onViewCart,
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            // gradient: const LinearGradient(
            //   begin: Alignment.centerLeft,
            //   end: Alignment.centerRight,
            //   colors: <Color>[
            //     Color(0xFFD445EC),
            //     Color(0xFFB02EFB),
            //     Color(0xFF8E2FFD),
            //     Color(0xFF5E3DFE),
            //     Color(0xFF5186E0),
            //   ],
            //   stops: <double>[0.0, 0.27, 0.48, 0.76, 1.0],
            // ),
            color: AppConstants.appThemeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                itemLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.2,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppTranslations.viewCart,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Transform.rotate(
                    angle: -1.5708,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update cart data from getCart API response
  void _updateCartData(List<UniversalCartData> cartData) {
    // Use post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _cartData = cartData;
        });
      }
    });
  }

   /// Get addToCartOnId from cart data for a specific product
  dynamic _getAddToCartOnId(String productId) {
    try {
      // Find all products with matching ID and get the last one's addToCartOnId
      final matchingProducts =
          cartBloc.cartData
              .expand((cart) => cart.sellers)
              .expand((seller) => seller.products)
              .where((product) => product.id == productId)
              .toList();

      if (matchingProducts.isEmpty) {
        return null;
      }

      // Return addToCartOnId from the last matching product
      return matchingProducts.last.addToCartOnId;
    } catch (e) {
      print('Error getting addToCartOnId: $e');
      return null;
    }
  }

  dynamic _getExistingProductQuantity(String productId, num addToCartOnId) {
    try {
      // Find all products with matching ID and addToCartOnId
      final matchingProducts =
          cartBloc.cartData
              .expand((cart) => cart.sellers)
              .expand((seller) => seller.products)
              .where(
                (product) =>
                    product.id == productId &&
                    product.addToCartOnId == addToCartOnId,
              )
              .toList();

      if (matchingProducts.isEmpty) {
        return null;
      }

      // Return quantity from the last matching product
      return matchingProducts.last.quantity?.value ?? 0;
    } catch (e) {
      print('Error getting existing product quantity: $e');
      return null;
    }
  }

  void _onQuantityChangedForGrocery(
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    int variantsCount,
    int newQuantity,
    bool isIncrease,
    String productName,
    String productImage,
    bool isCustomizable,
  ) {
    if (isIncrease == false && newQuantity == 1) {
      //TODO:- 0 Quantity
      int? addToCartOnId;
      if (isCustomizable) {
        addToCartOnId = _getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
      }

      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 2,
          action: 3,
          // Add/Update action
          storeCategoryId: storeCategoryId,
          newQuantity: 0,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartOnId,
        ),
      );
    } else if (newQuantity > 0 && isIncrease == true) {
      if (isCustomizable) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => CustomizationSummaryScreen(
                cartData: _cartData,
                productId: productId,
                centralProductId: parentProductId,
                storeTypeId: storeTypeId,
                // store: store,
                // product: product,
                onChooseClicked: () {
                  _openGroceryCustomization(
                    parentProductId,
                    productId,
                    unitId,
                    storeId,
                    storeCategoryId,
                    storeTypeId,
                    productName,
                    productImage,
                  );
                },
                onRepeatClicked: () {
                  //TODO:- Add Quantity
                  final addToCartOnId = _getAddToCartOnId(productId);
                  print("addCartOnID: $addToCartOnId");

                  final existingProductQuantity = _getExistingProductQuantity(productId, addToCartOnId);
                  print("existingProductQuantity: $existingProductQuantity");

                  cartBloc.add(
                    CartAddItemRequested(
                      storeId: storeId,
                      cartType: 1,
                      action: 2,
                      // Add action
                      storeCategoryId: storeCategoryId,
                      newQuantity: newQuantity + 1,
                      storeTypeId: storeTypeId,
                      productId: productId,
                      centralProductId: parentProductId,
                      unitId: unitId,
                      addToCartOnId: addToCartOnId,
                    ),
                  );
                },
              ),
        );
      } else {
        //TODO:- Add Quantity
        final addToCartOnId = _getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
        cartBloc.add(
          CartAddItemRequested(
            storeId: storeId,
            cartType: 1,
            action: 2,
            // Add action
            storeCategoryId: storeCategoryId,
            newQuantity: newQuantity + 1,
            storeTypeId: storeTypeId,
            productId: productId,
            centralProductId: parentProductId,
            unitId: unitId,
            addToCartOnId: addToCartOnId,
          ),
        );
      }
    } else {
      //TODO:- Remove Quantity
      int? addToCartOnId;
      if (isCustomizable) {
        addToCartOnId = _getAddToCartOnId(productId);
        print("addCartOnID: $addToCartOnId");
      }
      int? existingProductQuantity;
      existingProductQuantity = newQuantity;
      if (addToCartOnId != null) {
        existingProductQuantity = _getExistingProductQuantity(productId, addToCartOnId);
        print("existingProductQuantity: $existingProductQuantity");
      }
      cartBloc.add(
        CartAddItemRequested(
          storeId: storeId,
          cartType: 2,
          action: (existingProductQuantity == 1) ? 3 : 2,
          // Add/Update action
          storeCategoryId: storeCategoryId,
          newQuantity: (existingProductQuantity == 1) ? 0 : (existingProductQuantity ?? 0) - 1,
          storeTypeId: storeTypeId,
          productId: productId,
          centralProductId: parentProductId,
          unitId: unitId,
          addToCartOnId: addToCartOnId,
        ),
      );
    }
  }

  void _openGroceryCustomization(
    String parentProductId,
    String productId,
    String unitId,
    String storeId,
    String storeCategoryId,
    int storeTypeId,
    String productName,
    String productImage,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GroceryCustomizationScreen(
            parentProductId: parentProductId,
            productId: productId,
            storeId: storeId,
            productName: productName,
            productImage: productImage,
            onAddToCart: (parentProductId, productId, unitId) {
              _onAddToCartForGrocery(
                parentProductId,
                productId,
                unitId,
                storeId,
                storeCategoryId,
                storeTypeId,
                null,
              );
            },
          ),
    );
  }

  // /// Handle adding products with addons to cart
  // void _onAddToCartWithAddOns(
  //   String productId,
  //   String centralProductId,
  //   String storeId,
  //   String storeCategoryId,
  //   int storeTypeId,
  //   BuildContext context,
  //   dynamic variant,
  //   List<Map<String, dynamic>> addOns,
  // ) {
  //   try {
  //     //TODO:- Add Quantity
  //     cartBloc.add(
  //       CartAddItemRequested(
  //         storeId: storeId,
  //         cartType: 1,
  //         // Default cart type
  //         action: 1,
  //         // Add action
  //         storeCategoryId: storeCategoryId,
  //         newQuantity: 1,
  //         storeTypeId: storeTypeId,
  //         productId: productId,
  //         centralProductId: centralProductId,
  //         unitId: variant.unitId,
  //         newAddOns: addOns,
  //       ),
  //     );

  //     // print("Added product with addons to cart: ${product.productName}");
  //   } catch (e) {
  //     print(
  //       'RestaurantScreen: Error dispatching CartAddItemRequeste with addons: $e',
  //     );
  //   }
  // }
}

// Replaced inline card with shared MenuItemCard

class _MenuItem {
  final String title;
  final String price;
  final String originalPrice;
  final bool isVeg;
  final String assetPath;
  final String? imageUrl;
  final String? productId;
  final String? centralProductId;
  final bool isCustomizable;
  final String? serviceRequireTime;

  const _MenuItem({
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.isVeg,
    required this.assetPath,
    this.imageUrl,
    this.productId,
    this.centralProductId,
    this.isCustomizable = false,
    this.serviceRequireTime,
  });
}
