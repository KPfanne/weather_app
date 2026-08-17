import 'package:geocoding/geocoding.dart';

class Weather {
  DateTime currentTime = DateTime.now();
  double latitude = 0;
  double longitude = 0;
  String location = "";
  double temperature = 0;
  double precipitation = 0; // Niederschlag
  double windSpeed = 0;
  int weatherCode = 0;

  Weather({
    required this.currentTime,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
  });

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      currentTime: DateTime.parse(map["current"]["time"]),
      latitude: map["latitude"],
      longitude: map["longitude"],
      temperature: map["current"]["temperature_2m"],
      precipitation: map["current"]["precipitation"],
      windSpeed: map["current"]["wind_speed_10m"],
      weatherCode: map["current"]["weather_code"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "time": currentTime,
      "latitude": latitude,
      "longitude": longitude,
      "temperature_2m": temperature,
      "precipitation": precipitation,
      "wind_speed_10m": windSpeed,
      "weather_code": weatherCode,
    };
  }

  final Geocoding _geoCoding = Geocoding();

  Future<String> getLocation() async {
    try {
      List<Placemark> placemarks = await _geoCoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      final location = placemarks.first;

      return "${location.locality}, ${location.country}";
    } catch (e) {
      return "Unbekannter Ort";
    }
  }

  @override
  String toString() {
    return "$currentTime\n$temperature\n$precipitation\n$windSpeed\n$weatherCode";
  }
}
