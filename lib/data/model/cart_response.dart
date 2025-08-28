import 'dart:convert';

class CartResponse {
  final bool success;
  final String message;
  final CartData? data;

  CartResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CartData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CartData {
  final String? storeName;
  final String? storeId;
  final double? rating;
  final String? reviewCount;
  final String? deliveryTime;
  final String? address;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;

  CartData({
    this.storeName,
    this.storeId,
    this.rating,
    this.reviewCount,
    this.deliveryTime,
    this.address,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      storeName: json['storeName'],
      storeId: json['storeId'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      deliveryTime: json['deliveryTime'],
      address: json['address'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'storeId': storeId,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryTime': deliveryTime,
      'address': address,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
    };
  }
}

class CartItem {
  final String name;
  final int quantity;
  final double price;
  final String currencySymbol;

  CartItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.currencySymbol,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      currencySymbol: json['currencySymbol'] ?? 'AED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'currencySymbol': currencySymbol,
    };
  }
}
