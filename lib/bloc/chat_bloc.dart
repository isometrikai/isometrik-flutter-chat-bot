import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/bloc/chat_event.dart';
import 'package:chat_bot/bloc/chat_state.dart';
import 'package:chat_bot/data/data.dart';
import 'package:chat_bot/utils/store_category_registry.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  ChatBloc() : super(ChatInitial()) {
    on<ChatLoadEvent>(_onFetchChat);
    on<ChatSessionIdEvent>(_onFetchChatWithSessionId);
    on<ChatHistorySessionIdEvent>(_onFetchChatWithHistorySessionId);
  }

  Future<void> _onFetchChat(ChatLoadEvent event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoading());
      final chat = await ChatService.instance.sendChatMessage(
        message: event.message,
        agentId: event.agentId,
        fingerPrintId: event.fingerPrintId,
        sessionId: event.sessionId,
        isLoggedIn: event.isLoggedIn,
        longitude: double.parse(event.longitude),
        latitude: double.parse(event.latitude),
        staffId: event.staffId,
        serviceRequestedTime: event.serviceRequestedTime,
        storeCategoryId: event.storeCategoryId,
        prescriptionImageUrls: event.prescriptionImageUrls,
        tableBookingData: event.tableBookingData,
        hotelDestinationData: event.hotelDestinationData,
        carPickupData: event.carPickupData,
        flightBookingData: event.flightBookingData,
      );
      print('CHINTU: $chat');
      if (chat != null) {
        emit(ChatLoaded(chat));
      } else {
        emit(ChatError('Failed to send message'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onFetchChatWithSessionId(ChatSessionIdEvent event, Emitter<ChatState> emit) async {
    try {
      if (event.needToShowLoader) {
        Utility.showLoader();
      }
      // No loading state - background API call only
      final response = await ChatService.instance.getSessionId();
      if (response != null) {
        sessionId = response.sessionId.toString();
        StoreCategoryRegistry.update(response.storeCategories);
        final zainPersonalization =
            await ChatService.instance.fetchCustomerProfilePersonalization();
        if (zainPersonalization != null) {
          Utility.setPersonalization(zainPersonalization);
        }
        // emit(ChatLoadedWithSessionId(response.sessionId.toString()));
      }
      if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }
      // Silently fail - no error emission
    } catch (e) {
      // Silently handle error - background call should not show errors
      if (event.needToShowLoader) {
        Utility.closeProgressDialog();
      }
    }
  }


  Future<void> _onFetchChatWithHistorySessionId(ChatHistorySessionIdEvent event, Emitter<ChatState> emit) async {
    try {
      Utility.showLoader();
      final response = await ChatService.instance.fetchChatHistory(event.sessionId);
      print('response: $response');
      Utility.closeProgressDialog();
      // TODO: Handle the chat history response - emit appropriate state
      emit(ChatLoadedWithHistorySessionId(response));
    } catch (e) {
      // if (event.needToShowLoader) {
      //   Utility.closeProgressDialog();
      // }
      // emit(ChatError(e.toString()));
    }
  }


}
