import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gotruck_customer/models/booking_model.dart';
import 'package:gotruck_customer/models/pricing_response_model.dart';
import 'package:gotruck_customer/services/essential_dio_client.dart';

class HomeState {
  PricingResponse? pricingResponse;
  BookingResponse? bookingResponse;
  HomeState({this.pricingResponse, this.bookingResponse});

  HomeState copyWith({
    PricingResponse? pricingResponse,
    BookingResponse? bookingResponse,
  }) {
    return HomeState(
      pricingResponse: pricingResponse ?? this.pricingResponse,
      bookingResponse: bookingResponse ?? this.bookingResponse,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());
  final dioClient = EssentialDioClientService();

  Future<void> getTrucks(Map<String, dynamic> data) async {
    try {
      final Response response = await dioClient.dio.post(
        '/pricing-engine-master/filter',
        data: data,
      );
      final pricingResponse = PricingResponse.fromJson(response.data);
      state = state.copyWith(pricingResponse: pricingResponse);
    } catch (e) {
      print("error: $e");
    }
  }

  Future<void> getBookings() async {
    try {
      final Response response = await dioClient.dio.get('/booking-master');
      final bookingResponse = BookingResponse.fromJson(response.data);
      state = state.copyWith(bookingResponse: bookingResponse);
    } catch (e) {
      print("error: $e");
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
