import 'package:flutter/material.dart';
import 'package:weather_forecast_app/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FuturisticMainScreen extends StatefulWidget {
  const FuturisticMainScreen({Key? key}) : super(key: key);

  @override
  _FuturisticMainScreenState createState() => _FuturisticMainScreenState();
}

class _FuturisticMainScreenState extends State<FuturisticMainScreen>
    with SingleTickerProviderStateMixin {
  Widget _buildWeatherIcon(String iconCode) {
    return SvgPicture.network(
      'https://openweathermap.org/img/wn/$iconCode.svg',
      height: 100,
      width: 100,
      color: Colors.white,
    );
  }

  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic>? _weatherData;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _loadLastSearch();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeInAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSearch = prefs.getString('lastSearch');
    if (lastSearch != null) {
      _searchController.text = lastSearch;
      _fetchWeather(lastSearch);
    }
  }

  Future<void> _fetchWeather(String search) async {
    setState(() {
      _weatherData = null;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> data;
      if (search.contains(',')) {
        final parts = search.split(',');
        data = await _weatherService.getWeatherByZip(
            parts[0].trim(), parts[1].trim());
      } else {
        data = await _weatherService.getWeatherByCity(search);
      }

      setState(() {
        _weatherData = data;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastSearch', search);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 40),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: _weatherData != null
                        ? _buildWeatherInfo()
                        : _errorMessage != null
                            ? _buildErrorMessage()
                            : _buildLoadingIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Enter city or zip code',
          hintStyle: TextStyle(color: Colors.white70),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onSubmitted: _fetchWeather,
      ),
    );
  }

  Widget _buildWeatherInfo() {
    final temp = _weatherData!['main']['temp'];
    final humidity = _weatherData!['main']['humidity'];
    final windSpeed = _weatherData!['wind']['speed'];
    final description = _weatherData!['weather'][0]['description'];
    final iconCode = _weatherData!['weather'][0]['icon'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWeatherIcon(iconCode),
        const SizedBox(height: 20),
        Text(
          '${temp.toStringAsFixed(1)}°C',
          style: const TextStyle(
              fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          description.toUpperCase(),
          style: const TextStyle(fontSize: 24, color: Colors.white70),
        ),
        const SizedBox(height: 40),
        _buildWeatherDetail(Icons.water_drop, '$humidity%', 'Humidity'),
        const SizedBox(height: 20),
        _buildWeatherDetail(Icons.wind_power,
            '${windSpeed.toStringAsFixed(1)} m/s', 'Wind Speed'),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 30),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Text(
        _errorMessage!,
        style: TextStyle(color: Colors.red.shade300, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
