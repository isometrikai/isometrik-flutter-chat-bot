import 'chat_response.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isBot;
  final bool showAvatar;
  final bool hasQuickReplies;
  final bool hasStoreCards;
  final bool hasProductCards;
  final bool isWelcomeMessage;
  final bool hasOptionButtons;
  final List<String> optionButtons;
  final List<Store> stores;
  final List<Product> products;
  final ChatWidget? storesWidget;
  final ChatWidget? productsWidget;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isBot,
    this.showAvatar = false,
    this.hasQuickReplies = false,
    this.hasStoreCards = false,
    this.hasProductCards = false,
    this.isWelcomeMessage = false,
    this.hasOptionButtons = false,
    this.optionButtons = const [],
    this.stores = const [],
    this.products = const [],
    this.storesWidget,
    this.productsWidget,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isBot,
    bool? showAvatar,
    bool? hasQuickReplies,
    bool? hasStoreCards,
    bool? hasProductCards,
    bool? isWelcomeMessage,
    bool? hasOptionButtons,
    List<String>? optionButtons,
    List<Store>? stores,
    List<Product>? products,
    ChatWidget? storesWidget,
    ChatWidget? productsWidget,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isBot: isBot ?? this.isBot,
      showAvatar: showAvatar ?? this.showAvatar,
      hasQuickReplies: hasQuickReplies ?? this.hasQuickReplies,
      hasStoreCards: hasStoreCards ?? this.hasStoreCards,
      hasProductCards: hasProductCards ?? this.hasProductCards,
      isWelcomeMessage: isWelcomeMessage ?? this.isWelcomeMessage,
      hasOptionButtons: hasOptionButtons ?? this.hasOptionButtons,
      optionButtons: optionButtons ?? this.optionButtons,
      stores: stores ?? this.stores,
      products: products ?? this.products,
      storesWidget: storesWidget ?? this.storesWidget,
      productsWidget: productsWidget ?? this.productsWidget,
    );
  }
}