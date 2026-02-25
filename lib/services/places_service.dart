import 'package:dio/dio.dart';

/// Google Places REST API (Official)
class PlacesService {
  final String apiKey;
  final Dio _dio;

  PlacesService(this.apiKey)
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://maps.googleapis.com/maps/api/place',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  /// ======================
  /// AUTOCOMPLETE
  /// ======================
  Future<List<PlaceSuggestion>> fetchSuggestions(String input) async {
    if (input.length < 3) return [];

    try {
      final res = await _dio.get(
        '/autocomplete/json',
        queryParameters: {'input': input, 'key': apiKey},
      );

      if (res.data['status'] != 'OK') return [];

      final List list = res.data['predictions'];

      return list.map((e) => PlaceSuggestion.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// ======================
  /// PLACE DETAILS
  /// ======================
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    try {
      final res = await _dio.get(
        '/details/json',
        queryParameters: {'place_id': placeId, 'key': apiKey},
      );

      if (res.data['status'] != 'OK') return null;

      return PlaceDetails.fromJson(res.data['result']);
    } catch (e) {
      return null;
    }
  }
}

/// ======================
/// MODELS
/// ======================

class PlaceSuggestion {
  final String description;
  final String placeId;

  PlaceSuggestion({required this.description, required this.placeId});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}

class PlaceDetails {
  final double lat;
  final double lng;
  final String address;

  PlaceDetails({required this.lat, required this.lng, required this.address});

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final loc = json['geometry']['location'];

    return PlaceDetails(
      lat: loc['lat'],
      lng: loc['lng'],
      address: json['formatted_address'],
    );
  }
}
