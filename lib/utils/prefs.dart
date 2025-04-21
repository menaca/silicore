import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static Future<void> saveClientId(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('client_id', clientId);
  }

  static Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('client_id');
  }

  static Future<void> clearClientId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('client_id');
  }


  static Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  static Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code');
  }

  static Future<void> clearLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
  }
}
