abstract class CartEvent {}

class CartFetchRequested extends CartEvent {
  final bool needToShowLoader;  

  CartFetchRequested({this.needToShowLoader = true});
}

class CartAddItemRequested extends CartEvent {
  final String storeId;
  final int cartType;
  final int action;
  final String storeCategoryId;
  final int newQuantity;
  final int storeTypeId;
  final String productId;
  final String centralProductId;
  final String unitId;
  final List<Map<String, dynamic>>? newAddOns;
  final dynamic addToCartOnId;
  final bool needToShowLoader;
  final bool needToShowLoaderForCartFetch;

  CartAddItemRequested({
    required this.storeId,
    required this.cartType,
    required this.action,
    required this.storeCategoryId,
    required this.newQuantity,
    required this.storeTypeId,
    required this.productId,
    required this.centralProductId,
    required this.unitId,
    this.newAddOns,
    this.addToCartOnId,
    this.needToShowLoader = true,
    this.needToShowLoaderForCartFetch = true,
  });
}
