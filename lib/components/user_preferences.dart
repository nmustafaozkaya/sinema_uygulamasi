import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinema_uygulamasi/components/user.dart';

class RememberUserPrefs {
  static Future<void> saveRememberUser(User userInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData = jsonEncode({
      'user_id': userInfo.userId,
      'user_name': userInfo.userName,
      'user_email': userInfo.userEmail,
      'user_role_id': userInfo.userRoleId,
      'cinema_id': userInfo.cinemaId,
      'access_token': userInfo.accessToken,
    });
    await preferences.setString('currentUser', userJsonData);
  }

  static Future<User?> readUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userDataString = preferences.getString('currentUser');

    if (userDataString != null) {
      Map<String, dynamic> userMap = jsonDecode(userDataString);
      return User.fromJson(userMap);
    }
    return null;
  }

  static Future<void> removeUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('currentUser');
  }
}
