import 'dart:convert';

import 'package:gotruck_customer/screens/auth/user_model.dart';
import 'package:gotruck_customer/screens/auth/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyLoginResponse = 'loginResponse';
  static const _keyProfileData = 'profileData';
  static const _keyToken = 'token';
  static const _keyIsLoggedIn = 'isLoggedIn';

  Future<void> saveSession(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLoginResponse, jsonEncode(loginResponse.toJson()));
    await prefs.setString(_keyToken, loginResponse.data.accessToken);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  Future<LoginResponse?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) {
      return null;
    }

    final rawLoginResponse = prefs.getString(_keyLoginResponse);
    if (rawLoginResponse == null || rawLoginResponse.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawLoginResponse) as Map<String, dynamic>;
      return LoginResponse.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(ProfileData profileData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileData, jsonEncode(profileData.toJson()));
  }

  Future<ProfileData?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfileData = prefs.getString(_keyProfileData);
    if (rawProfileData == null || rawProfileData.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawProfileData) as Map<String, dynamic>;
      return ProfileData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoginResponse);
    await prefs.remove(_keyProfileData);
    await prefs.remove(_keyToken);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
