import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart'; // Cinema modelini import et

class RememberMoviePrefs {
  static const String _rememberKey = 'remembered_cinema';

  // Cinema kaydet
  static Future<void> saveRememberMovie(Cinema cinema) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String cinemaJsonData = jsonEncode({
      'cinema_id': cinema.cinemaId,
      'cinema_name': cinema.cinemaName,
      'cinema_address': cinema.cinemaAddress,
      'city_id': cinema.cityId,
      'city_name': cinema.cityName,
      'cinema_phone': cinema.cinemaPhone,
      'cinema_email': cinema.cinemaEmail,
      'hall_count': cinema.hallCount,
      'total_capacity': cinema.totalCapacity,
      'active_halls': cinema.activeHalls,
    });
    await preferences.setString(_rememberKey, cinemaJsonData);
  }

  static Future<Cinema?> getRememberMovie() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? cinemaJsonData = preferences.getString(_rememberKey);
    if (cinemaJsonData != null) {
      Map<String, dynamic> cinemaMap = jsonDecode(cinemaJsonData);
      return Cinema.fromJson(cinemaMap);
    }
    return null;
  }

  static Future<void> clearRememberMovie() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_rememberKey);
  }
}
