import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gotruck_customer/screens/auth/user_model.dart';
import 'package:gotruck_customer/screens/auth/user_profile_model.dart';
import 'package:gotruck_customer/services/auth_dio_client.dart';
import 'package:gotruck_customer/services/local_storage_service.dart';
import 'package:gotruck_customer/widgets/custom_snackbar.dart';

class AuthState {
  static const Object _unset = Object();

  final bool isLoadingPhone;
  final bool isLoading;
  final LoginResponse? userData;
  final ProfileData? profileData;
  final bool isGuestUser;

  AuthState({
    this.isLoading = false,
    this.userData,
    this.isLoadingPhone = false,
    this.isGuestUser = false,
    this.profileData,
  });

  bool get isLoggedIn => userData != null && !isGuestUser;

  AuthState copyWith({
    bool? isLoading,
    Object? userData = _unset,
    bool? isLoadingPhone,
    bool? isGuestUser,
    Object? profileData = _unset,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      userData: identical(userData, _unset)
          ? this.userData
          : userData as LoginResponse?,
      isLoadingPhone: isLoadingPhone ?? this.isLoadingPhone,
      isGuestUser: isGuestUser ?? this.isGuestUser,
      profileData: identical(profileData, _unset)
          ? this.profileData
          : profileData as ProfileData?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());
  final dioClient = AuthDioClientService();

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setUserData(LoginResponse userData) {
    state = state.copyWith(userData: userData);
  }

  void setProfileData(ProfileData profileData) {
    state = state.copyWith(profileData: profileData);
  }

  void setLoadingPhone(bool isLoadingPhone) {
    state = state.copyWith(isLoadingPhone: isLoadingPhone);
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    try {
      final Response response = await dioClient.dio.post(
        '/auth/login',
        data: {"username": email, "password": password},
      );
      if (response.data['success'] == true) {
        final userData = LoginResponse.fromJson(response.data);
        await LocalStorageService().saveSession(userData);
        state = state.copyWith(userData: userData, isGuestUser: false);
        getProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> getProfile() async {
    setLoading(true);
    try {
      final Response response = await dioClient.dio.get('/users/profile');
      if (response.data['success'] == true) {
        final profileResponse = ProfileResponse.fromJson(response.data);
        await LocalStorageService().saveProfile(profileResponse.data);
        state = state.copyWith(profileData: profileResponse.data);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register(
    String fname,
    String lname,
    String email,
    String phone,
    String countryCode,
    String gender,
    String password,
    String confirmPassword,
  ) async {
    setLoading(true);
    if (password == "") {
      CustomSnackbar.show(message: "Please enter password.");
      setLoading(false);
      return false;
    }
    if (password != confirmPassword && password != "") {
      CustomSnackbar.show(
        message: "Confirm password and password are not same!",
      );
      setLoading(false);
      return false;
    }
    try {
      final Response response = await dioClient.dio.post(
        '/auth/register',
        data: {
          "userType": "consumer",
          "firstName": fname,
          "lastName": lname,
          "email": email,
          "phoneNumber": phone,
          "gender": gender,
          "displayName": "",
          "password": password,
          "status": "active",
          "countryCode": countryCode,
        },
      );
      if (response.data['success'] == true) {
        await sendRegistrationOtps(
          email: email,
          phoneNumber: phone,
          countryCode: countryCode,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("--------------------------------------------------------");
      debugPrint(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> forgetPassword(String email) async {
    setLoading(true);
    if (email == "") {
      CustomSnackbar.show(message: "Please enter email.");
      setLoading(false);
      return false;
    }
    try {
      final Response response = await dioClient.dio.post(
        'forget-password',
        data: {"email": email},
      );
      if (response.data['success'] == true) {
        setLoading(false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> sendOtp({
    required String otpType,
    String? email,
    String? phoneNumber,
    String? countryCode,
  }) async {
    try {
      final data = <String, dynamic>{'otpType': otpType};
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        data['phoneNumber'] = phoneNumber;
      }
      if (countryCode != null && countryCode.isNotEmpty) {
        data['countryCode'] = countryCode;
      }

      final Response response = await dioClient.dio.post(
        '/otp/sendOtp',
        data: data,
      );
      return response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> sendRegistrationOtps({
    required String email,
    required String phoneNumber,
    required String countryCode,
  }) async {
    final otpPromises = <Future<bool>>[];

    if (email.trim().isNotEmpty) {
      otpPromises.add(sendOtp(otpType: 'email', email: email.trim()));
    }

    if (phoneNumber.trim().isNotEmpty) {
      otpPromises.add(
        sendOtp(
          otpType: 'phone',
          phoneNumber: phoneNumber.trim(),
          countryCode: countryCode.trim(),
        ),
      );
    }

    if (otpPromises.isNotEmpty) {
      await Future.wait(otpPromises);
    }
  }

  Future<bool> verifyOTP({
    required String otpType,
    required String otp,
    String? phoneNumber,
    String? email,
    String? countryCode,
  }) async {
    setLoadingPhone(true);
    if (otp == "") {
      CustomSnackbar.show(message: "Please enter otp.");
      setLoadingPhone(false);
      return false;
    }
    try {
      final data = <String, dynamic>{'otpType': otpType, 'otp': otp};
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        data['phoneNumber'] = phoneNumber;
      }
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }
      if (countryCode != null && countryCode.isNotEmpty) {
        data['countryCode'] = countryCode;
      }

      final Response response = await dioClient.dio.post(
        '/otp/verifyOtp',
        data: data,
      );
      if (response.data['success'] == true) {
        setLoadingPhone(false);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      setLoadingPhone(false);
    }
  }

  Future<void> logout() async {
    await LocalStorageService().clearSession();
    state = state.copyWith(userData: null, profileData: null, isGuestUser: true);
  }

  Future<bool> restoreSessionFromStorage() async {
    final localStorage = LocalStorageService();
    final savedSession = await LocalStorageService().getUserSession();
    if (savedSession == null) {
      state = state.copyWith(userData: null, profileData: null, isGuestUser: true);
      return false;
    }

    final savedProfile = await localStorage.getProfile();
    state = state.copyWith(
      userData: savedSession,
      profileData: savedProfile,
      isGuestUser: false,
    );
    return true;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
