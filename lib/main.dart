//

// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String weatherInfo = 'Press the button to get weather info';
  TextEditingController _controller = TextEditingController();
  String apiKey = '6c2560190eb94f618d7170644240809';

  // Fetch weather based on user input (city/country)
  void fetchWeather(String location) async {
    final response = await http.get(Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$location'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        weatherInfo = 'Weather in $location: ${data['current']['temp_c']}°C';
      });
    } else {
      setState(() {
        weatherInfo = 'Failed to fetch weather data';
      });
    }
  }

  // Fetch weather based on user location
  void fetchWeatherByLocation() async {
    Position position = await _determinePosition();
    final response = await http.get(Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        weatherInfo =
            'Weather at your location: ${data['current']['temp_c']}°C in ${data['location']['name']}';
      });
    } else {
      setState(() {
        weatherInfo = 'Failed to fetch weather data';
      });
    }
  }

  // Function to get user's current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When location permissions are granted, return the position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter city or country',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                fetchWeather(_controller.text);
              },
              child: Text('Search Weather'),
            ),
            SizedBox(height: 20),
            Text(
              weatherInfo,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchWeatherByLocation,
              child: Text('Get Weather by Location'),
            ),
          ],
        ),
      ),
    );
  }
}
