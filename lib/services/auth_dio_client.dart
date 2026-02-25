import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gotruck_customer/constants/core.dart';
import 'package:gotruck_customer/router/app_router.dart';
import 'package:gotruck_customer/widgets/custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthDioClientService {
  final dio = createDio();
  final navigatorKey = GlobalKey<NavigatorState>();
  static const excludeErrorUrl = ["user/delivery_addresses"];

  AuthDioClientService._internal();
  static final _singleton = AuthDioClientService._internal();

  factory AuthDioClientService() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(baseUrl: Constant.authPrefix));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (
              RequestOptions requestOptions,
              RequestInterceptorHandler handler,
            ) async {
              final url = requestOptions.uri.toString();
              SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();

              if (!url.contains('/login')) {
                final token = sharedPreferences.get('token');
                if (token != null) {
                  requestOptions.headers.putIfAbsent(
                    'Authorization',
                    () => 'Bearer $token',
                  );
                }
              }
              requestOptions.headers.putIfAbsent(
                'Accept',
                () => 'application/json',
              );
              handler.next(requestOptions);
            },
        onResponse:
            (Response response, ResponseInterceptorHandler handler) async {
              if (response.statusCode == 401 &&
                  response.requestOptions.path.contains('login')) {
                CustomSnackbar.show(message: 'Password or Email Incorrect.');
              }
              // Check if response is HTML
              else if ((!response.requestOptions.path.contains('login') &&
                  response.headers
                      .value('content-type')!
                      .contains('text/html'))) {
                // Convert HTML response to a format your app can handle
                response.data = {
                  'message': 'Received HTML response',
                  'html_content': response.data.toString(),
                  'isHtml': true,
                };
                CustomSnackbar.show(
                  message: 'Session expired. Please login again.',
                );
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigate to login screen
                AppRouter.go('/login');
              }
              return handler.next(response);
            },
        onError: (error, ErrorInterceptorHandler handler) async {
          if (error.response != null) {
            // Handle 401 Unauthorized error

            if (error.response?.statusCode == 401) {
              if (error.requestOptions.path.contains('login')) {
                CustomSnackbar.show(message: 'Password or Email Incorrect.');
                return handler.reject(error);
              } else {
                // Clear all local storage
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Show error message
                CustomSnackbar.show(
                  message: 'Session expired. Please login again.',
                );
                // Navigate to login screen
                AppRouter.go('/login');

                return handler.reject(error);
              }
            }
            if (!excludeErrorUrl.any(
              (url) => error.requestOptions.path.contains(url),
            )) {
              final responseData = error.response!.data;

              debugPrint("error $responseData");

              // Final error message
              String errorMessage = 'Unknown error occurred';
              List<String> flattenedList = [];

              // Helper to flatten Laravel validation messages
              void flatten(Map<String, dynamic> map) {
                map.forEach((key, value) {
                  if (value is List) {
                    flattenedList.add(value.join("\n"));
                  } else {
                    flattenedList.add(value.toString());
                  }
                });
              }

              // --------------------------
              // CASE 1: Laravel "errors"
              // --------------------------
              if (responseData is Map && responseData.containsKey("errors")) {
                final errorsMap = responseData["errors"];
                if (errorsMap is Map<String, dynamic>) {
                  flatten(errorsMap);
                }
              }

              // --------------------------
              // CASE 2: Laravel "message"
              // --------------------------
              if (responseData is Map && responseData.containsKey("message")) {
                final msg = responseData["message"];

                if (msg is Map<String, dynamic>) {
                  flatten(msg); // <-- FIX: message can be Map
                } else if (msg is String) {
                  flattenedList.add(msg);
                }
              }

              // If flattened output exists, override main message
              if (flattenedList.isNotEmpty) {
                errorMessage = flattenedList.join("\n");
              }
              CustomSnackbar.show(message: errorMessage);
            }
          } else {
            CustomSnackbar.show(
              message:
                  'Connection error. Please check your internet connection.',
            );
          }
          handler.reject(error);
        },
      ),
    );
    return dio;
  }
}
