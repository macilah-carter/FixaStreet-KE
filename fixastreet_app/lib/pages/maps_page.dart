import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  static const LatLng _initialPosition = LatLng(-1.2921, 36.8219); // Nairobi
  Set<Marker> _markers = {};
  bool _isLoading = true; // To track loading state
  bool _hasData = true; // To track if data is available

  Future<void> getLocation() async {
    try {
      final response = await http.get(
        Uri.parse('https://fixa-street-ke-api.vercel.app/api/reports'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final validLocations = data
            .where((item) => item['coordinates'] != null)
            .toList();

        if (validLocations.isEmpty) {
          // No valid locations found
          setState(() {
            _isLoading = false;
            _hasData = false;
          });
          return;
        }

        Set<Marker> fetchedMarkers = {};
        for (int i = 0; i < validLocations.length; i++) {
          final coordinatesString = validLocations[i]['coordinates'] as String;
          final coordinates = coordinatesString.split(',');
          if (coordinates.length == 2) {
            final lat = double.parse(coordinates[0].trim());
            final lng = double.parse(coordinates[1].trim());

            fetchedMarkers.add(
              Marker(
                markerId: MarkerId('marker_$i'),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                infoWindow: InfoWindow(
                  title: validLocations[i]['title'] ?? 'Marker $i',
                  snippet: validLocations[i]['location'] ?? '',
                ),
              ),
            );
          }
        }

        setState(() {
          _markers = fetchedMarkers;
          _isLoading = false;
          _hasData = true;
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : !_hasData
          ? const Center(
              child: Text(
                'No locations available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ), // Show message if no data
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 13,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                // Map controller can be used here if needed in the future
              },
            ),
    );
  }
}
