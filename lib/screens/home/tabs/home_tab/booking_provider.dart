import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gotruck_customer/screens/home/tabs/home_tab/map_route_picker_screen.dart';
import 'package:gotruck_customer/services/essential_dio_client.dart';

class BookingAddressFormData {
  const BookingAddressFormData({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.landmark = '',
    this.city = '',
    this.postalCode = '',
    this.stateRegion = '',
    this.country = '',
    this.latitude = '',
    this.longitude = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String landmark;
  final String city;
  final String postalCode;
  final String stateRegion;
  final String country;
  final String latitude;
  final String longitude;

  bool get hasAnyValue =>
      firstName.isNotEmpty ||
      lastName.isNotEmpty ||
      email.isNotEmpty ||
      phone.isNotEmpty ||
      addressLine1.isNotEmpty ||
      addressLine2.isNotEmpty ||
      landmark.isNotEmpty ||
      city.isNotEmpty ||
      postalCode.isNotEmpty ||
      stateRegion.isNotEmpty ||
      country.isNotEmpty ||
      latitude.isNotEmpty ||
      longitude.isNotEmpty;

  BookingAddressFormData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? postalCode,
    String? stateRegion,
    String? country,
    String? latitude,
    String? longitude,
  }) {
    return BookingAddressFormData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      stateRegion: stateRegion ?? this.stateRegion,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory BookingAddressFormData.fromLocationDetails({
    required LocationDetails details,
    required String addressLine1,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    return BookingAddressFormData(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: details.address,
      city: details.city,
      stateRegion: details.state,
      country: details.country,
      latitude: details.position.latitude.toString(),
      longitude: details.position.longitude.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'landmark': landmark,
      'city': city,
      'postalCode': postalCode,
      'stateRegion': stateRegion,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class BookingFormState {
  const BookingFormState({
    this.isLoading = false,
    this.pickupAddress = const BookingAddressFormData(),
    this.dropAddress = const BookingAddressFormData(),
  });

  final bool isLoading;
  final BookingAddressFormData pickupAddress;
  final BookingAddressFormData dropAddress;

  BookingFormState copyWith({
    BookingAddressFormData? pickupAddress,
    BookingAddressFormData? dropAddress,
    bool? isLoading,
  }) {
    return BookingFormState(
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(const BookingFormState());
  final dioClient = EssentialDioClientService();

  void setAddresses({
    required BookingAddressFormData pickupAddress,
    required BookingAddressFormData dropAddress,
  }) {
    state = state.copyWith(
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
    );
  }

  void clear() {
    state = const BookingFormState();
  }

  Future<bool> createBooking(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isLoading: true);
      debugPrint("data: $data");
      final Response response = await dioClient.dio.post(
        '/booking-master',
        data: data,
      );
      debugPrint("response: ${response.data}");
      if (response.statusCode == 200 && response.data['success']) {
        final bookingId = response.data['data']['id'];
        await createBookingAddress(
          bookingId,
          state.pickupAddress.toJson(),
          'pickup',
        );
        await createBookingAddress(
          bookingId,
          state.dropAddress.toJson(),
          'drop',
        );
      }
      state = state.copyWith(isLoading: false);
      return response.data['success'];
    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> createBookingAddress(
    String bookingId,
    Map<String, dynamic> data,
    String addressType,
  ) async {
    try {
      var payload = data;
      payload['bookingId'] = bookingId;
      payload['addressType'] = addressType;
      final Response response = await dioClient.dio.post(
        '/booking-addresses',
        data: payload,
      );

      return response.statusCode == 200 && response.data['success'];
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}

final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
      return BookingFormNotifier();
    });
