import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const GeolocationApp());
}

class GeolocationApp extends StatelessWidget {
  const GeolocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GeolocationScreen(),
    );
  }
}

class GeolocationScreen extends StatefulWidget {
  const GeolocationScreen({super.key});

  @override
  GeolocationScreenState createState() => GeolocationScreenState();
}

class GeolocationScreenState extends State<GeolocationScreen> {
  String _locationMessage = "Press the button to get location";
  String _addressMessage = "";

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });

    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _addressMessage =
            "${data['address']['city']}, ${data['address']['state']}, ${data['address']['country']}";
      });
    } else {
      setState(() {
        _addressMessage = "Failed to get address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geolocation App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_locationMessage),
            Text(_addressMessage),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text("Get Location"),
            ),
          ],
        ),
      ),
    );
  }
}
