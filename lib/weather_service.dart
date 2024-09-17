import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class WeatherService {
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';
  final String apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '';

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = '$baseUrl/weather?q=$city&appid=$apiKey&units=metric';
    debugPrint('Requesting URL: $url');

    final response = await http.get(Uri.parse(url));

    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getWeatherByZip(
      String zip, String countryCode) async {
    final url =
        '$baseUrl/weather?zip=$zip,$countryCode&appid=$apiKey&units=metric';
    debugPrint('Requesting URL: $url');

    final response = await http.get(Uri.parse(url));

    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }
}
