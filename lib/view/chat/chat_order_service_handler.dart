import 'package:chat_bot/bloc/bloc.dart';
import 'package:chat_bot/bloc/cart/cart_bloc.dart';
import 'package:chat_bot/services/services.dart';
import 'package:chat_bot/utils/utility.dart';
import 'package:chat_bot/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef SendMessageCallback = void Function(
  String text, [
  String? scheduleLaterStaffId,
  String? serviceRequestedTime,
  String? storeCategoryId,
  Map<String, dynamic>? dict,
]);

class ChatOrderServiceHandler {
  ChatOrderServiceHandler({
    required this.isMounted,
    required this.sendMessage,
    required this.getApiData,
    required this.setApiData,
    required this.onStripePaymentSuccess,
    required this.onStripePaymentFailed,
    required this.popRoute,
    required this.context,
  });

  final bool Function() isMounted;
  final SendMessageCallback sendMessage;
  final Map<String, dynamic> Function() getApiData;
  final void Function(Map<String, dynamic> apiData) setApiData;
  final void Function() onStripePaymentSuccess;
  final void Function(String message) onStripePaymentFailed;
  final void Function() popRoute;
  final BuildContext context;

  void register() {
    _registerSendMessageCallback();
    _registerStripePaymentCallback();
    _registerAddressSummaryCallback();
    _registerSelectScheduleCallback();
    _registerSelectStaffCallback();
    _registerPrescriptionCallback();
    _registerStripePlaceOrderCallback();
    _registerSelectClickManageCallback();
  }

  void _registerSendMessageCallback() {
    OrderService().setSendMessageCallback((String message) {
      if (isMounted() && needToCallChatScreenSendMessageAPI) {
        print('ChatScreen: External message received - $message');
        sendMessage(message);
      }
    });
  }

  void _registerStripePaymentCallback() {
    OrderService().setStripePaymentCallback((String cartNumber) {
      if (isMounted()) {
        print('ChatScreen: Stripe payment received - $cartNumber');
        sendMessage('Card added successfully last 4 digits: $cartNumber');
      }
    });
  }

  void _registerAddressSummaryCallback() {
    OrderService().setAddressSummaryCallback((String addressSummary) {
      if (isMounted()) {
        print('ChatScreen: Address summary received - $addressSummary');
        sendMessage('I have added a new address.\n$addressSummary');
      }
    });
  }

  void _registerSelectScheduleCallback() {
    OrderService().setSelectScheduleCallback((Map<String, dynamic> schedule) {
      if (!isMounted()) return;
      print('ChatScreen: Select schedule received - $schedule');
      setApiData({
        ...getApiData(),
        'serviceRequestedTime': schedule['serviceRequestedTime'],
      });
      sendMessage(
        'I have selected a schedule: \n${schedule['dateTimeStr']}',
        schedule['scheduleLaterStaffId'],
        schedule['serviceRequestedTime'],
      );
    });
  }

  void _registerSelectStaffCallback() {
    OrderService().setSelectStaffCallback((Map<String, dynamic> staff) {
      if (!isMounted()) return;
      print('ChatScreen: Select staff received - $staff');
      setApiData({
        ...getApiData(),
        'scheduleLaterStaffId': staff['scheduleLaterStaffId'],
      });
      sendMessage(
        'I have selected a staff member: ${staff['staffName']}',
        staff['scheduleLaterStaffId'],
        staff['serviceRequestedTime'],
      );
    });
  }

  void _registerPrescriptionCallback() {
    OrderService().setPrescriptionCallback((Map<String, dynamic> prescription) {
      if (!isMounted()) return;
      print('ChatScreen: Prescription screen received');
      print('ChatScreen: Prescription screen received - $prescription');
      setApiData({
        ...getApiData(),
        'prescription_image_urls': prescription['imagesurls'] ?? '',
      });
      sendMessage(
        'I have uploaded the prescription. Please proceed with the order',
        null,
        null,
        null,
      );
    });
  }

  void _registerStripePlaceOrderCallback() {
    OrderService().setStripePlaceOrderCallback((
      Map<String, dynamic> stripePlaceOrder,
    ) {
      if (!isMounted()) return;
      print('ChatScreen: Stripe place order received - $stripePlaceOrder');
      if (stripePlaceOrder['isPaymentSuccess'] == true) {
        onStripePaymentSuccess();
        BlackToastView.show(context, 'Payment completed successfully');
        context.read<CartBloc>().add(
          CartFetchRequested(needToShowLoader: false),
        );
      } else if (stripePlaceOrder['isPaymentFailed'] == true) {
        onStripePaymentFailed(stripePlaceOrder['message']);
      }
    });
  }

  void _registerSelectClickManageCallback() {
    OrderService().setSelectClickManageCallback((
      Map<String, dynamic> clickManage,
    ) {
      if (!isMounted()) return;
      print('ChatScreen: Click manage received - $clickManage');
      _handleClickManage(clickManage);
    });
  }

  void _handleClickManage(Map<String, dynamic> clickManage) {
    final flow = clickManage['flow'];
    if (flow == 'HotelBooking') {
      _handleHotelBookingClickManage(clickManage);
    } else if (flow == 'CarBooking') {
      _handleCarBookingClickManage(clickManage);
    } else if (flow == 'FlightBooking') {
      _handleFlightBookingClickManage(clickManage);
    } else {
      setApiData({
        ...getApiData(),
        'dependent_id': clickManage['dependentId'] ?? '',
      });
      sendMessage(
        'I have selected a dependent:\n${clickManage['firstName'] ?? ''} ${clickManage['lastName'] ?? ''}',
        null,
        null,
        null,
      );
    }
  }

  void _handleHotelBookingClickManage(Map<String, dynamic> clickManage) {
    final screenName = clickManage['screenName'];
    if (screenName == 'HotelBookingDates') {
      final checkinDate = Utility.formatHotelBookingDate(
        (clickManage['checkIn'] ?? '').toString(),
      );
      final checkoutDate = Utility.formatHotelBookingDate(
        (clickManage['checkOut'] ?? '').toString(),
      );
      setApiData(_mergeBookingData(
        'hotel_booking',
        {
          'checkinDate': checkinDate,
          'checkoutDate': checkoutDate,
        },
        defaults: {'countryOfResidence': 'AE'},
      ));
      sendMessage(
        'I have selected the checkin and checkout dates: \n'
        '${Utility.formatHotelBookingDateForDisplay((clickManage['checkIn'] ?? '').toString())} '
        'to ${Utility.formatHotelBookingDateForDisplay((clickManage['checkOut'] ?? '').toString())}',
      );
    } else if (screenName == 'HotelBookingGuests') {
      setApiData(_mergeBookingData(
        'hotel_booking',
        {'occupancy': clickManage['occupancy']},
        defaults: {'countryOfResidence': 'AE'},
      ));
      sendMessage(
        'I have selected the number of guests:\n'
        '${Utility.formatHotelOccupancyForDisplay(clickManage['occupancy'])}',
      );
    } else if (screenName == 'HotelBookingUserDetails') {
      setApiData(_mergeBookingData(
        'hotel_booking',
        {'hotel_booking': clickManage['hotel_booking']},
      ));
      sendMessage('I have added the customer details.');
    } else if (screenName == 'TravelHotelDetailsScreen') {
      setApiData(_mergeBookingData('hotel_booking', {
        'roomId': clickManage['roomId'],
        'roomName': clickManage['roomName'],
        'availabilityToken': clickManage['availabilityToken'],
        'correlationId': clickManage['correlationId'],
        'propertyId': clickManage['propertyId'],
      }));
      if (clickManage['needToBack'] == true) {
        popRoute();
      }
      sendMessage('I have selected room ${clickManage['roomName']}');
    }
  }

  void _handleCarBookingClickManage(Map<String, dynamic> clickManage) {
    print('ChatScreen: Car booking received - $clickManage');
    final screenName = clickManage['screenName'];

    if (screenName == 'CarBookingDateTime' &&
        clickManage['isForPickup'] == true) {
      setApiData(_mergeBookingData(
        'car_booking',
        {'pickup_date': clickManage['pickup_date']},
      ));
      sendMessage(
        'I have selected the car pickup date and time. ${clickManage['pickup_date_display']}',
      );
    } else if (screenName == 'CarBookingDateTime' &&
        clickManage['isForReturn'] == true) {
      setApiData(_mergeBookingData(
        'car_booking',
        {'return_date': clickManage['return_date']},
      ));
      sendMessage(
        'I have selected the car return date and time. ${clickManage['return_date_display']}',
      );
    } else if (screenName == 'CarDriverDetails') {
      final driverData = _driverDetailsFromClickManage(clickManage);
      setApiData(_mergeBookingData('car_booking', driverData));
      sendMessage('I have added the car driver details.');
    } else if (screenName == 'TravelCarDetailsScreen') {
      print(
        'ChatScreen: Travel car details screen received - $clickManage',
      );
      setApiData(_mergeBookingData('car_booking', {
        'availabilityToken': clickManage['availabilityToken'],
        'correlationId': clickManage['correlationId'],
        'equipments': clickManage['equipments'],
      }));
      if (clickManage['needToBack'] == true) {
        popRoute();
      }
      sendMessage('I have selected the car: ${clickManage['carName']}');
    }
  }

  void _handleFlightBookingClickManage(Map<String, dynamic> clickManage) {
    final screenName = clickManage['screenName'];

    if (screenName == 'TravelFlightPassengerScreen') {
      setApiData(_mergeBookingData('flight_booking', {
        'adults': clickManage['adults'],
        'children': clickManage['children'],
        'infants': clickManage['infants'],
      }));
      sendMessage(
        'I have selected the number of passengers: ${clickManage['adults']} adults, ${clickManage['children']} children, ${clickManage['infants']} infants',
      );
    } else if (screenName == 'TravelFlightDateScreen') {
      if (clickManage['isDeparture'] == true) {
        setApiData(_mergeBookingData('flight_booking', {
          'departure_date': clickManage['departure_date'],
        }));
        sendMessage(
          'I have selected the flight date: ${Utility.formatHotelBookingDateForDisplay((clickManage['departure_date'] ?? '').toString())}',
        );
      } else {
        setApiData(_mergeBookingData('flight_booking', {
          'return_date': clickManage['return_date'],
          'departure_date': clickManage['departure_date'],
        }));
        sendMessage(
          'I have selected the flight date: ${Utility.formatHotelBookingDateForDisplay((clickManage['departure_date'] ?? '').toString())} to ${Utility.formatHotelBookingDateForDisplay((clickManage['return_date'] ?? '').toString())}',
        );
      }
    } else if (screenName == 'TravelFlightPassengerDetailsScreen') {
      final details = clickManage['details'];
      final updates = details is Map
          ? Map<String, dynamic>.from(details)
          : <String, dynamic>{};
      setApiData(_mergeBookingData('flight_booking', updates));
      sendMessage('I have added the passenger details.');
    } else if (screenName == 'TravelFlightDetailsScreen') {
      setApiData(_mergeBookingData('flight_booking', {
        'correlationId': clickManage['correlationId'],
        'cabinSearchSessionId': clickManage['cabinSearchSessionId'],
      }));
      if (clickManage['needToBack'] == true) {
        popRoute();
      }
      sendMessage('I have selected flight ${clickManage['airlineName']}');
    }
  }

  Map<String, dynamic> _mergeBookingData(
    String key,
    Map<String, dynamic> updates, {
    Map<String, dynamic>? defaults,
  }) {
    final apiData = getApiData();
    final existing = apiData[key];
    final Map<String, dynamic> booking;
    if (existing is Map) {
      booking = Map<String, dynamic>.from(existing)..addAll(updates);
    } else {
      booking = {...?defaults, ...updates};
    }
    return {...apiData, key: booking};
  }

  static Map<String, dynamic> driverDetailsFromClickManage(
    Map<String, dynamic> clickManage,
  ) {
    final driverDetails = clickManage['driver_details'];
    final detailsMap = driverDetails is Map
        ? Map<String, dynamic>.from(driverDetails)
        : <String, dynamic>{};

    final firstName = (detailsMap['first_name'] ?? '').toString().trim();
    final lastName = (detailsMap['last_name'] ?? '').toString().trim();
    final driverName =
        [firstName, lastName].where((part) => part.isNotEmpty).join(' ');

    final birthDateStr = (detailsMap['birth_date'] ?? '').toString();
    int? driverAge;
    if (birthDateStr.isNotEmpty) {
      try {
        final birthDate = DateTime.parse(birthDateStr);
        final today = DateTime.now();
        var age = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          age--;
        }
        driverAge = age;
      } catch (_) {}
    }

    return {
      'driver_details': detailsMap,
      'driver_name': driverName,
      'driver_age': driverAge,
    };
  }

  Map<String, dynamic> _driverDetailsFromClickManage(
    Map<String, dynamic> clickManage,
  ) =>
      driverDetailsFromClickManage(clickManage);
}
