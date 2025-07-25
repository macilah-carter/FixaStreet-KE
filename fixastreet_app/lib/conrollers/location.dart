import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class GetLocatiState extends StatefulWidget {
  const GetLocatiState({super.key, required this.locationController});
  final TextEditingController locationController;

  @override
  State<GetLocatiState> createState() => _GetLocatiStateState();
}

class _GetLocatiStateState extends State<GetLocatiState> {
  loc.LocationData? selectedLocation;
  final loc.Location location = loc.Location();

  Future<void> getLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    // Check permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    // Get location
    final currentLocation = await location.getLocation();
    setState(() {
      selectedLocation = currentLocation;
    });

    // print('📍 Raw Location: ${currentLocation.latitude}, ${currentLocation.longitude}');

    // Check if coordinates are valid
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      try {
        // Reverse geocoding to get address
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude as double,
          currentLocation.longitude as double,
        );

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          
          // Function to check if a string is a Plus Code (like JWP9+WM9)
          bool isPlusCode(String? text) {
            if (text == null || text.isEmpty) return false;
            // Plus codes typically have format: 4-8 chars + '+' + 2-3 chars
            final plusCodePattern = RegExp(r'^[0-9A-Z]{4,8}\+[0-9A-Z]{2,3}$');
            return plusCodePattern.hasMatch(text);
          }
          
          // Build address string in preferred format
          String address = '';
          
          // Add street if available and not a Plus Code
          if (placemark.street != null && 
              placemark.street!.isNotEmpty && 
              !isPlusCode(placemark.street)) {
            address += placemark.street!;
          }
          
          // If no valid street, try thoroughfare
          if (address.isEmpty && 
              placemark.thoroughfare != null && 
              placemark.thoroughfare!.isNotEmpty && 
              !isPlusCode(placemark.thoroughfare)) {
            address += placemark.thoroughfare!;
          }
          
          // If still no address, try name field
          if (address.isEmpty && 
              placemark.name != null && 
              placemark.name!.isNotEmpty && 
              !isPlusCode(placemark.name)) {
            address += placemark.name!;
          }
          
          // Add locality/area if available and different from what we already have
          if (placemark.locality != null && 
              placemark.locality!.isNotEmpty && 
              placemark.locality != address &&
              !isPlusCode(placemark.locality)) {
            if (address.isNotEmpty) address += ', ';
            address += placemark.locality!;
          }
          
          // Add sub-administrative area (like CBD, district)
          if (placemark.subAdministrativeArea != null && 
              placemark.subAdministrativeArea!.isNotEmpty &&
              !address.contains(placemark.subAdministrativeArea!) &&
              !isPlusCode(placemark.subAdministrativeArea)) {
            if (address.isNotEmpty) address += ', ';
            address += placemark.subAdministrativeArea!;
          }
          
          // Add administrative area (like county/state) if no sub-administrative area
          else if (placemark.administrativeArea != null && 
                   placemark.administrativeArea!.isNotEmpty &&
                   !address.contains(placemark.administrativeArea!) &&
                   !isPlusCode(placemark.administrativeArea)) {
            if (address.isNotEmpty) address += ', ';
            address += placemark.administrativeArea!;
          }

          // Update the controller with the formatted address
          widget.locationController.text = address.isNotEmpty ? address : 'Location found';
          
          // print('📍 Formatted Address: $address');
        } else {
          widget.locationController.text = 'Address not found';
        }
      } catch (e) {
        // print('Geocoding error: $e');
        // Fallback to coordinates if geocoding fails
        widget.locationController.text = 
            'Lat: ${currentLocation.latitude}, Lon: ${currentLocation.longitude}';
      }
    } else {
      widget.locationController.text = 'Unable to get location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.location_on, color: Colors.green[600]),
      onPressed: getLocation,
      tooltip: 'Get Current Location',
    );
  }
}