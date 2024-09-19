import 'dart:convert';
import 'dart:math';

import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/providers/favoritesProvider.dart';
import 'package:SportGrounds/providers/filtersProvider.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:SportGrounds/screens/stadium_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/stadium.dart';
import '../widgets/stadium_item.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FavoriteScreenState();
  }
}

class _FavoriteScreenState extends ConsumerState<FavoritesScreen> {
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, String>> availableTimes = [
    {"time": "No Available Times", "price": ""}
  ];

  @override
  void initState() {
    super.initState();
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // Earth radius in kilometers

    // Convert latitude and longitude from degrees to radians
    lat1 = _degreesToRadians(lat1);
    lon1 = _degreesToRadians(lon1);
    lat2 = _degreesToRadians(lat2);
    lon2 = _degreesToRadians(lon2);

    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

  List<Map<String, String>> parseAvailableTimes(String responseBody) {
    List<Map<String, String>> availableTimes = [];
    List<String> parts = responseBody
        .split(RegExp(r'[,\s]+'))
        .map((part) => part.trim())
        .toList();

    print("Parts list: $parts");

    for (int i = 0; i < parts.length; i += 2) {
      String time = parts[i];
      String price = (i + 1 < parts.length)
          ? parts[i + 1]
          : "Price not available"; // Handle cases where price is missing
      availableTimes.add({
        'time': time,
        'price': price,
      });
    }

    print("Available times: $availableTimes");

    return availableTimes;
  }

  String formatDateTimeToDateString(DateTime dateTime) {
    // Create a date format with the desired format (yyyy-MM-dd)
    final dateFormat = DateFormat('dd.M.yyyy');

    // Format the DateTime to a string with the specified format
    return dateFormat.format(dateTime);
  }

  Future<void> _processIntervalsAndReservations(Stadium stadium) async {
    final url = Uri.http(httpIP, 'api/get_field_by_id');

    try {
      Map<String, dynamic> requestBody = {
        'field_id': stadium.id,
        'date': formatDateTimeToDateString(_selectedDate),
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print("Response body: ${response.body}");

      if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
        });
        // Handle error if needed
      } else {
        String responseBody = response.body.trim();

        if (responseBody.isEmpty) {
          // Set to "All Reserved" if the body is empty
          availableTimes = [
            {"time": "All Reserved", "price": ""}
          ];
        } else {
          // Parse the response string
          availableTimes = parseAvailableTimes(responseBody);
        }

        print("Parsed available times: $availableTimes");

        if (availableTimes.isEmpty) {
          availableTimes.add({"time": "No Available Times", "price": ""});
        }

        print("Final available times: $availableTimes");
        ref
            .read(filterSingletonProvider.notifier)
            .appliedAvailableTime(availableTimes);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Stadium> _favoritesStadiums = ref.read(favoriteStadiumsProvider);
    if (_favoritesStadiums.isEmpty) {
      return const Center(child: Text('No favorites stadiums were added'));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Your favorite Stadiums',
            textAlign: TextAlign.center,
          ),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 20.0), // Adjust top padding as needed
          child: ListView.builder(
            itemCount: _favoritesStadiums.length,
            itemBuilder: (ctx, index) => StadiumItem(
              stadium: _favoritesStadiums[index],
              onSelectStadium: (Stadium stadium) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => StadiumDetailsScreen(
                      stadium: stadium,
                      remainingInterval: availableTimes,
                      dropDownInit: availableTimes.isNotEmpty
                          ? availableTimes[0]['time']!
                          : "No Available Times",
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }
}
