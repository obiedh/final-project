/*import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isGettingLocation = false;

  Future<void> _requestPermission(WidgetRef ref) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request');
      }

      setState(() {
        _isGettingLocation = true;
      });

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _isGettingLocation = false;
      });

      ref
          .read(locationPermissionProvider.notifier)
          .addedPermission(true, position.longitude, position.latitude);

      // Reverse geocoding to get street and administrative area
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String street = place.street ?? "Unknown Street";
        String administrativeArea = place.administrativeArea ?? "Unknown Area";

        ref.read(locationPermissionProvider.notifier).addedCurrentLocation(
              true,
              street,
              administrativeArea,
            );
      }
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationPermission = ref.watch(locationPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Location Permission'),
      ),
      body: _isGettingLocation
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text('Enable Location Permission'),
                    value: locationPermission.permission,
                    onChanged: (value) {
                      if (value) {
                        _requestPermission(ref);
                      } else {
                        ref
                            .read(locationPermissionProvider.notifier)
                            .addedPermission(false, 0.0, 0.0);
                      }
                    },
                  ),
                  if (locationPermission.permission)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Location:'),
                        if (locationPermission.street != null)
                          Text('Street: ${locationPermission.street}'),
                        if (locationPermission.administrativeArea != null)
                          Text(
                              'Administrative Area: ${locationPermission.administrativeArea}'),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}*/