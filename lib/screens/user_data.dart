import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setNickname(String nickname) async {
    await _prefs?.setString('nickname', nickname);
  }

  static String? getNickname() {
    return _prefs?.getString('nickname');
  }
}
