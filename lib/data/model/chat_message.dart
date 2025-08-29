import 'chat_response.dart';
import '../../widgets/choose_address_widget.dart';
import '../../widgets/choose_card_widget.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isBot;
  final bool showAvatar;
  final bool hasQuickReplies;
  final bool hasStoreCards;
  final bool hasProductCards;
  final bool hasCartWidget;
  final bool hasChooseAddressWidget;
  final bool hasChooseCardWidget;
  final bool hasOrderSummaryWidget;
  final bool isWelcomeMessage;
  final bool hasOptionButtons;
  final List<String> optionButtons;
  final List<Store> stores;
  final List<Product> products;
  final List<WidgetAction> cartItems;
  final List<AddressOption> addressOptions;
  final List<CardOption> cardOptions;
  final List<WidgetAction> orderSummaryItems;
  final ChatWidget? storesWidget;
  final ChatWidget? productsWidget;
  final ChatWidget? cartWidget;
      final ChatWidget? chooseAddressWidget;
    final ChatWidget? chooseCardWidget;
    final ChatWidget? orderSummaryWidget;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    this.showAvatar = false,
    this.hasQuickReplies = false,
    this.hasStoreCards = false,
    this.hasProductCards = false,
    this.hasCartWidget = false,
    this.hasChooseAddressWidget = false,
    this.hasChooseCardWidget = false,
    this.hasOrderSummaryWidget = false,
    this.isWelcomeMessage = false,
    this.hasOptionButtons = false,
    this.optionButtons = const [],
    this.stores = const [],
    this.products = const [],
    this.cartItems = const [],
    this.addressOptions = const [],
    this.cardOptions = const [],
    this.orderSummaryItems = const [],
    this.storesWidget,
    this.productsWidget,
    this.cartWidget,
    this.chooseAddressWidget,
    this.chooseCardWidget,
    this.orderSummaryWidget,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isBot,
    bool? showAvatar,
    bool? hasQuickReplies,
    bool? hasStoreCards,
    bool? hasProductCards,
    bool? hasCartWidget,
    bool? hasChooseAddressWidget,
    bool? hasChooseCardWidget,
    bool? hasOrderSummaryWidget,
    bool? isWelcomeMessage,
    bool? hasOptionButtons,
    List<String>? optionButtons,
    List<Store>? stores,
    List<Product>? products,
    List<WidgetAction>? cartItems,
    List<AddressOption>? addressOptions,
    List<CardOption>? cardOptions,
    List<WidgetAction>? orderSummaryItems,
    ChatWidget? storesWidget,
    ChatWidget? productsWidget,
    ChatWidget? cartWidget,
    ChatWidget? chooseAddressWidget,
    ChatWidget? chooseCardWidget,
    ChatWidget? orderSummaryWidget,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isBot: isBot ?? this.isBot,
      showAvatar: showAvatar ?? this.showAvatar,
      hasQuickReplies: hasQuickReplies ?? this.hasQuickReplies,
      hasStoreCards: hasStoreCards ?? this.hasStoreCards,
      hasProductCards: hasProductCards ?? this.hasProductCards,
      hasCartWidget: hasCartWidget ?? this.hasCartWidget,
      hasChooseAddressWidget: hasChooseAddressWidget ?? this.hasChooseAddressWidget,
      hasChooseCardWidget: hasChooseCardWidget ?? this.hasChooseCardWidget,
      hasOrderSummaryWidget: hasOrderSummaryWidget ?? this.hasOrderSummaryWidget,
      isWelcomeMessage: isWelcomeMessage ?? this.isWelcomeMessage,
      hasOptionButtons: hasOptionButtons ?? this.hasOptionButtons,
      optionButtons: optionButtons ?? this.optionButtons,
      stores: stores ?? this.stores,
      products: products ?? this.products,
      cartItems: cartItems ?? this.cartItems,
      addressOptions: addressOptions ?? this.addressOptions,
      cardOptions: cardOptions ?? this.cardOptions,
      orderSummaryItems: orderSummaryItems ?? this.orderSummaryItems,
      storesWidget: storesWidget ?? this.storesWidget,
      productsWidget: productsWidget ?? this.productsWidget,
      cartWidget: cartWidget ?? this.cartWidget,
              chooseAddressWidget: chooseAddressWidget ?? this.chooseAddressWidget,
        chooseCardWidget: chooseCardWidget ?? this.chooseCardWidget,
        orderSummaryWidget: orderSummaryWidget ?? this.orderSummaryWidget,
    );
  }
}