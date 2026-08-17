import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Model/weather.dart';
import 'package:weather_app/Service/weather_service.dart';
import 'package:weather_icons_animated/weather_icons_animated.dart';

void main() async {
  await initializeDateFormatting("de_DE");
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherService.getWeatherData();
  }

  void _reload() {
    setState(() {
      _weatherFuture = WeatherService.getWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(255, 14, 79, 192),
                const Color.fromARGB(255, 107, 200, 243),
              ],
            ),
          ),
          child: FutureBuilder<Weather>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Wetter wird geladen...",
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasData) {
                return Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxSize =
                          constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;
                      final cardSize = maxSize * 0.8;

                      return Card(
                        child: Container(
                          width: cardSize,
                          height: cardSize,
                          margin: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      snapshot.data!.location,
                                      style: GoogleFonts.manrope(
                                        fontSize: cardSize * 0.06,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "Letzter Stand: ${DateFormat('dd.MM.yyyy, HH:mm', 'de_DE').format(snapshot.data!.currentTime)}",
                                      style: GoogleFonts.manrope(
                                        fontSize: cardSize * 0.03,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              WeatherIcon(
                                icon: WeatherIcons.fromOpenMeteoCode(
                                  snapshot.data!.weatherCode,
                                  isDay: snapshot.data!.isDay,
                                ),
                                size: cardSize * 0.7,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: cardSize * 0.02,
                                      children: [
                                        Text(
                                          "Niederschlag: ${snapshot.data!.precipitation}",
                                          style: GoogleFonts.manrope(
                                            fontSize: cardSize * 0.035,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          "Windstärke: ${snapshot.data!.windSpeed} km/h",
                                          style: GoogleFonts.manrope(
                                            fontSize: cardSize * 0.035,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${snapshot.data!.temperature}°C",
                                      style: GoogleFonts.archivoBlack(
                                        fontSize: cardSize * 0.12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return _ErrorView(
                message: snapshot.hasError
                    ? snapshot.error.toString().replaceFirst("Exception: ", "")
                    : "Es konnten keine Wetterdaten geladen werden.",
                onRetry: _reload,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text("Erneut versuchen"),
            ),
          ],
        ),
      ),
    );
  }
}
