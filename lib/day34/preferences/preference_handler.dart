import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHandler {
  static const String tokenKey = "user_token";
  static const String userKey = "user_data";

  // ==========================
  // SAVE TOKEN
  // ==========================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // ==========================
  // GET TOKEN
  // ==========================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // ==========================
  // DELETE TOKEN (LOGOUT)
  // ==========================
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // ==========================
  // SAVE USER DATA
  // ==========================
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user));
  }

  // ==========================
  // GET USER DATA (AS MAP)
  // ==========================
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(userKey);

    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // ==========================
  // CLEAR USER DATA
  // ==========================
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
  }

  // ==========================
  // CHECK LOGIN STATUS
  // ==========================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey) != null;
  }

  // ==========================
  // LOGOUT (CLEAR ALL)
  // ==========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }
}
