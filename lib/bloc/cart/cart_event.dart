abstract class CartEvent {}

class CartFetchRequested extends CartEvent {
  final bool needToShowLoader;  

  CartFetchRequested({this.needToShowLoader = true});
}
