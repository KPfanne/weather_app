import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Model/weather.dart';

class WeatherService {
  //zeigt die aktuellen Wetterdaten in diesem Moment

  static Future<Weather> getWeatherData() async {
    bool isLocationAvailable = await Geolocator.isLocationServiceEnabled();

    if (!isLocationAvailable) {
      return Future.error("Standortdienste sind deaktiviert.");
    }

    LocationPermission locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error("Standortberechtigung wurde verweigert.");
      }
    }

    // Holt sich die aktuelle Position des Geräts
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    String url =
        "https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,weather_code&timezone=auto&current=temperature_2m,wind_speed_10m,precipitation,weather_code";

    try {
      http.Response response = await http.get(Uri.parse(url));

      print(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> dataMap = jsonDecode(response.body);

        Weather weather = Weather.fromMap(dataMap);
        weather.location = await weather.getLocation();
        return weather;
      } else {
        throw HttpException("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw HttpException("Fehler: $e");
    }
  }
}
