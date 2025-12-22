import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'colors.dart';

// NEW FILE: Map-based address picker using OpenStreetMap (Free, no credit card needed)
class MapAddressPickerPage extends StatefulWidget {
  final String? currentAddress;

  const MapAddressPickerPage({super.key, this.currentAddress});

  @override
  State<MapAddressPickerPage> createState() => _MapAddressPickerPageState();
}

class _MapAddressPickerPageState extends State<MapAddressPickerPage> {
  // Default location (Rawalpindi, Pakistan)
  LatLng selectedLocation = LatLng(33.5651, 73.0169);
  String selectedAddress = "Loading address...";
  bool isLoadingAddress = false;
  bool isLoadingLocation = true;

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get user's current location using GPS
  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => isLoadingLocation = false);
        _showPermissionDialog();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        isLoadingLocation = false;
      });

      // Get address for current location
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      // Move map to current location
      mapController.move(selectedLocation, 15.0);
    } catch (e) {
      print('Error getting location: $e');
      setState(() => isLoadingLocation = false);

      // Use default location if GPS fails
      await _getAddressFromCoordinates(
        selectedLocation.latitude,
        selectedLocation.longitude,
      );
    }
  }

  // Convert coordinates to readable address using Nominatim (OpenStreetMap's free geocoding service)
  Future<void> _getAddressFromCoordinates(double lat, double lon) async {
    setState(() => isLoadingAddress = true);

    try {
      // Nominatim API - Free geocoding service, no API key needed
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Cartify-Flutter-App', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract address components
        final address = data['address'];
        final displayName = data['display_name'];

        // Build a cleaner address string
        String formattedAddress = '';

        if (address['road'] != null) {
          formattedAddress += address['road'];
        }
        if (address['suburb'] != null || address['neighbourhood'] != null) {
          formattedAddress += ', ${address['suburb'] ?? address['neighbourhood']}';
        }
        if (address['city'] != null) {
          formattedAddress += ', ${address['city']}';
        } else if (address['town'] != null) {
          formattedAddress += ', ${address['town']}';
        }
        if (address['state'] != null) {
          formattedAddress += ', ${address['state']}';
        }

        setState(() {
          selectedAddress = formattedAddress.isNotEmpty
              ? formattedAddress
              : displayName;
          isLoadingAddress = false;
        });
      } else {
        setState(() {
          selectedAddress = 'Unable to fetch address';
          isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('Error fetching address: $e');
      setState(() {
        selectedAddress = 'Error getting address';
        isLoadingAddress = false;
      });
    }
  }

  // Show dialog if location permission is permanently denied
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Location Permission',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Location permission is required to show your current location. Please enable it in settings.',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openAppSettings();
            },
            child: Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Handle map tap to select new location
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      selectedLocation = point;
    });

    // Get address for tapped location
    _getAddressFromCoordinates(point.latitude, point.longitude);
  }

  // Recenter map to current GPS location
  void _recenterToCurrentLocation() {
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: Text(
          'Select Delivery Location',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // OpenStreetMap using flutter_map
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 15.0,
              onTap: _onMapTap,
              // Interaction options
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Map tiles from OpenStreetMap (Free)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.cartify',
                maxZoom: 19,
              ),

              // Marker showing selected location
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,
                    width: 50,
                    height: 50,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Loading overlay while getting location
          if (isLoadingLocation)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom sheet with address info and confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.accent,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IrishGrover',
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Address display
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: isLoadingAddress
                        ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Fetching address...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                      ],
                    )
                        : Text(
                      selectedAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Buttons row
                  Row(
                    children: [
                      // Recenter button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _recenterToCurrentLocation,
                          icon: Icon(
                            Icons.my_location,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          label: Text(
                            'My Location',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontFamily: 'ADLaMDisplay',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12),

                      // Confirm button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: isLoadingAddress
                              ? null
                              : () {
                            // Return selected address to previous screen
                            Navigator.pop(context, selectedAddress);
                          },
                          icon: Icon(Icons.check, color: Colors.white),
                          label: Text(
                            'Confirm Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ADLaMDisplay',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Instructions
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tap anywhere on the map to select your delivery location',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'ADLaMDisplay',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recenter floating button (top right)
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _recenterToCurrentLocation,
              child: Icon(Icons.my_location, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}