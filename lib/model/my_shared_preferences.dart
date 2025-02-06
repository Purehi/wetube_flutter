import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {

  // Function to save data with an expiration date to SharedPreferences
  static Future<bool> saveDataWithExpiration(String key, String json, Duration expirationDuration, {bool zero = true}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(zero){
        final now = DateTime.now();
        final expirationTime = DateTime(now.year,now.month,now.day).add(expirationDuration);
        await prefs.setString(key, json);
        await prefs.setString('${key}_expirationTime', expirationTime.toIso8601String());
      }else{
        final now = DateTime.now();
        final expirationTime = now.add(expirationDuration);
        await prefs.setString(key, json);
        await prefs.setString('${key}_expirationTime', expirationTime.toIso8601String());
      }
      return true;
    } catch (e) {
      clearData(key);
      return false;
    }
  }

  // Function to save data with an expiration date to SharedPreferences
  static Future<bool> saveData(String key, String json) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json);
      return true;
    } catch (e) {
      clearData(key);
      return false;
    }
  }

  // Function to get data from SharedPreferences if it's not expired
  static Future<bool> ifExpired(String key) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString(key);
    String? expirationTimeStr = prefs.getString('${key}_expirationTime');
    if (data == null || expirationTimeStr == null) {
      return true; // No data or expiration time found.
    }
    DateTime expirationTime = DateTime.parse(expirationTimeStr);
    if (expirationTime.isAfter(DateTime.now())) {
      return false;
    } else {
      return true;
    }
  }
  static Future<dynamic> getDataIfNotExpired(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? data = prefs.getString(key);
      return data;
    } catch (e) {
      return null;
    }
  }

  // Function to clear data from SharedPreferences
  static Future<void> clearData(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      await prefs.remove('${key}_expirationTime');
    } catch (e) {
      debugPrint('Error clearing data from SharedPreferences: $e');
    }
  }
}