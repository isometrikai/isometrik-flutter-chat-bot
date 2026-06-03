import 'package:equatable/equatable.dart';
import 'package:unique_identifier/unique_identifier.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatLoadEvent extends ChatEvent {
  final String message;
  final String agentId;
  final String fingerPrintId;
  final String sessionId;
  final bool isLoggedIn;
  final String longitude;
  final String latitude;
  final String staffId;
  final String serviceRequestedTime;
  final String storeCategoryId;
  final List<String> prescriptionImageUrls;
  final Map<String, dynamic> tableBookingData;
  final Map<String, dynamic> hotelDestinationData;
  const ChatLoadEvent({
    required this.message,
    this.agentId = "67a9df239dbfc422720f19b5",
    this.fingerPrintId = "default-device-id",
    String? sessionId,
    this.isLoggedIn = false,
    this.longitude = "0.0",
    this.latitude = "0.0",
    this.staffId = "",
    this.serviceRequestedTime = "",
    this.storeCategoryId = "",
    this.prescriptionImageUrls = const [],
    this.tableBookingData = const {},
    this.hotelDestinationData = const {},
  }) : sessionId = sessionId ?? "default-session";

  static Future<ChatLoadEvent> create({
    required String message,
    String agentId = "67a9df239dbfc422720f19b5",
    String? fingerPrintId,
    required String sessionId, // Changed to required parameter
    bool isLoggedIn = false,
    String longitude = "0.0",
    String latitude = "0.0",
    String staffId = "",
    String serviceRequestedTime = "",
    String storeCategoryId = "",
    List<String>? prescriptionImageUrls,
    Map<String, dynamic>? tableBookingData,
    Map<String, dynamic>? hotelDestinationData,
  }) async {
    String deviceId = fingerPrintId ?? await _getDeviceId();
    
    return ChatLoadEvent(
      message: message,
      agentId: agentId,
      fingerPrintId: deviceId,
      sessionId: sessionId, // Use provided sessionId directly
      isLoggedIn: isLoggedIn,
      longitude: longitude,
      latitude: latitude,
      staffId: staffId,
      serviceRequestedTime: serviceRequestedTime,
      storeCategoryId: storeCategoryId,
      prescriptionImageUrls: prescriptionImageUrls ?? [],
      tableBookingData: tableBookingData ?? {},
      hotelDestinationData: hotelDestinationData ?? {},
    );
  }

  static Future<String> _getDeviceId() async {
    try {
      return await UniqueIdentifier.serial ?? "default-device-id";
    } catch (e) {
      return "default-device-id";
    }
  }

  @override
  List<Object> get props => [
    message,
    agentId,
    fingerPrintId,
    sessionId,
    isLoggedIn,
    longitude,
    latitude,
  ];
}

class AddToCartEvent extends ChatEvent {
  final String storeId;
  final int cartType;
  final int action;
  final int newQuantity;
  final int storeTypeId;
  final String storeCategoryId;
  final String productId;
  final String centralProductId;
  final String quantity;
  final String unitId;

  const AddToCartEvent({
    required this.storeId,
    required this.storeCategoryId,
    required this.productId,
    required this.centralProductId,
    required this.quantity,
    required this.action,
    required this.cartType,
    required this.newQuantity,
    required this.storeTypeId,
    required this.unitId,
  });
}

class ChatSessionIdEvent extends ChatEvent {
  final bool needToShowLoader;

  const ChatSessionIdEvent({
    required this.needToShowLoader,
  });
}

class ChatHistorySessionIdEvent extends ChatEvent {
  final String sessionId;

  const ChatHistorySessionIdEvent({
    required this.sessionId,
  });
}