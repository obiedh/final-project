import 'dart:convert';

import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/model/category.dart';
import 'package:SportGrounds/widgets/category_grid_item.dart';
import '../model/constants.dart';
import '../model/stadium.dart';
import '../providers/locationPermissionProvider.dart';
import 'Stadiums.dart';
import 'package:http/http.dart' as http;

class SportsCategoriesScreen extends ConsumerStatefulWidget {
  const SportsCategoriesScreen({super.key});

  @override
  ConsumerState<SportsCategoriesScreen> createState() {
    return _SportsCategoriesState();
  }
}

class _SportsCategoriesState extends ConsumerState<SportsCategoriesScreen> {
  String address = "";
  bool _isLoading = false;
  List<Stadium> _loadedItems = [];
  final List<Stadium> _filteredStadiums = [];

  Future<void> _loadFields(String sportType) async {
    print(ref.read(locationPermissionProvider).latitude);
    const int maxRetries = 3; // Maximum number of retries
    int retries = 0;

    while (retries < maxRetries) {
      try {
        await _tryloadFields(sportType);
        // If successful, break the retry loop
        break;
      } catch (error) {
        print('Error: $error');
        retries++;

        if (retries == maxRetries) {
          print('Reached maximum retries. Request failed.');
          // Handle the failure or display an error message to the user
        } else {
          print('Retrying request (Attempt $retries/$maxRetries)');
          // Add a delay before retrying
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
  }

  Future<void> _getFieldsBySportType(String sportType) async {
    _loadedItems = [];
    final url = Uri.http(httpIP, 'api/get_fields_by_sport_type');
    final http.Response response;
    double distance = 1.0;
    try {
      Map<String, dynamic> requestBody = {
        'sport_type': sportType,
      };

      response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400) {
        {
          return;
        }
      }

      if (response.body == 'null') {
        print("null");
        return;
      }

      final List<dynamic> listData = json.decode(response.body);
      print(listData);
      final List<Stadium> loadedItems = [];

      for (final item in listData) {
        double? distance;
        if (ref.read(locationPermissionProvider).permission) {
          double stadiumLatitude = double.parse(item['latitude']);
          double stadiumLongitude = double.parse(item['longitude']);
          distance = calculateDistance(
            ref.read(locationPermissionProvider).latitude!,
            ref.read(locationPermissionProvider).longitude!,
            stadiumLatitude,
            stadiumLongitude,
          );
        }

        // Parse utilities
        String utilities = _parseUtilities(item['utilities']);

        _loadedItems.add(
          Stadium(
            id: item['uid'],
            title: item['name'],
            location: item['location'],
            imagePath: item['imageURL'],
            latitude: double.parse(item['latitude']),
            longitude: double.parse(item['longitude']),
            type: item['sport_type'],
            distance: distance ?? 0.0,
            rating: double.parse(item['average_rating'].toString())
                .toStringAsFixed(2),
            utilities: utilities,
          ),
        );
      }

      print("sort?");

      print(_filteredStadiums);
    } catch (error) {
      print("error!!!! $error");
    }
  }

  Future<void> _tryloadFields(String sportType) async {
    _loadedItems = [];
    print("entered here");
    print(ref.read(locationPermissionProvider).latitude);
    final url = Uri.http(httpIP, 'api/get_best_fields');
    final http.Response response;
    double distance = 1.0;
    try {
      Map<String, dynamic> requestBody = {
        "sport_type": sportType,
        "longitude": ref.read(locationPermissionProvider).longitude,
        "latitude": ref.read(locationPermissionProvider).latitude,
        "permission":
            ref.read(locationPermissionProvider).permission.toString(),
        "user_id": ref.read(userSingletonProvider).id
      };

      response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print(response.body);
        print("stuck");
        return;
      }

      final responseBody = json.decode(response.body);

      // Check if the response contains a 'message' field
      if (responseBody is Map<String, dynamic> &&
          responseBody.containsKey('message')) {
        String message = responseBody['message'];

        if (message == "No fields found for the given sport type") {
          _loadedItems = [];
          return;
        }
      } else {
        // Handle the case when the response is a list
        if (responseBody is List) {
          final List<dynamic> listData = responseBody;

          for (final item in listData) {
            double? distance;
            if (ref.read(locationPermissionProvider).permission) {
              double stadiumLatitude = double.parse(item['latitude']);
              double stadiumLongitude = double.parse(item['longitude']);
              distance = calculateDistance(
                ref.read(locationPermissionProvider).latitude!,
                ref.read(locationPermissionProvider).longitude!,
                stadiumLatitude,
                stadiumLongitude,
              );
            }

            // Parse utilities
            String utilities = _parseUtilities(item['utilities']);

            _loadedItems.add(
              Stadium(
                id: item['uid'],
                title: item['name'],
                location: item['location'],
                imagePath: item['imageURL'],
                latitude: double.parse(item['latitude']),
                longitude: double.parse(item['longitude']),
                type: item['sport_type'],
                distance: distance ?? 0.0,
                rating: double.parse(item['average_rating'].toString())
                    .toStringAsFixed(2),
                utilities: utilities,
              ),
            );
          }

          print("sort?");
        }
      }
    } catch (error) {
      print("error!!!! $error");
      rethrow;
    }
  }

  String _parseUtilities(Map<String, dynamic> utilitiesMap) {
    List<String> utilities = utilitiesMap.entries.map((entry) {
      return '${entry.key}-${entry.value == 1 ? 1 : 0}';
    }).toList();

    return utilities.join(', ');
  }

  @override
  void initState() {
    super.initState();
    //_getCurrentLocation(ref);
  }

  final availableCategories = [
    const Category(
      id: "football",
      title: "football",
    ),
    const Category(
      id: "tennis",
      title: "tennis",
    ),
  ];

  void _selectedCategory(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => StadiumsScreen(
          title: category.title,
          stadiums: _loadedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 350,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 400,
                child: Image.asset('lib/images/sportCategories.png'),
              ),
            ],
          ),
        ),
        // Background image

        GridView(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          children: [
            // availableCategories.map((category) => CategoryGridItems(category:category))
            for (final category in availableCategories)
              CategoryGridItem(
                category: category,
                onSelectCategory: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  ref.read(userSingletonProvider).id == ""
                      ? await _getFieldsBySportType(category.title)
                      : await _loadFields(category.title);
                  setState(() {
                    _isLoading = false;
                  });

                  print(_loadedItems);
                  _selectedCategory(context, category);
                },
              )
          ],
        ),
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ))
            : const SizedBox(),
      ],
    );
  }
}
