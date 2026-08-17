import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/Model/weather.dart';

class WeatherService {
  static Future<Weather> getWeatherData() async {
    final Position position = await _determinePosition();

    final String url =
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=${position.latitude}&longitude=${position.longitude}"
        "&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,weather_code"
        "&timezone=auto"
        "&current=temperature_2m,wind_speed_10m,precipitation,weather_code,is_day";

    http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (_) {
      throw Exception(
        "Der Wetterdienst ist nicht erreichbar. Bitte prüfe deine Internetverbindung.",
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        "Der Wetterdienst hat mit Status ${response.statusCode} geantwortet.",
      );
    }

    try {
      final Map<String, dynamic> dataMap = jsonDecode(response.body);
      final Weather weather = Weather.fromMap(dataMap);
      weather.location = await weather.getLocation();
      return weather;
    } catch (_) {
      throw Exception("Die Wetterdaten konnten nicht gelesen werden.");
    }
  }

  static Future<Position> _determinePosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        "Die Standortdienste sind deaktiviert. Bitte aktiviere sie in den Systemeinstellungen.",
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Die Standortberechtigung wurde dauerhaft abgelehnt. Bitte erlaube den Zugriff in den App-Einstellungen.",
      );
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
        "Ohne Standortberechtigung kann das Wetter nicht geladen werden.",
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}
