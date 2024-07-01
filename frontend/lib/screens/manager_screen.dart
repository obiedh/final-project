import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proj/providers/fieldsProvider.dart';
import 'package:proj/providers/usersProvider.dart';
import 'package:proj/widgets/stadium_item_manager.dart';
import '../model/constants.dart';
import '../model/stadium.dart';
import '../providers/locationPermissionProvider.dart';
import 'package:http/http.dart' as http;

class ManagerScreen extends ConsumerStatefulWidget {
  const ManagerScreen({super.key});

  @override
  ConsumerState<ManagerScreen> createState() {
    return _ManagerScreenState();
  }
}

class _ManagerScreenState extends ConsumerState<ManagerScreen> {
  bool _isLoading = true;
  List<Stadium> _stadiums = [];

  @override
  void initState() {
    super.initState();
    _loadFields();
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

  Future<void> _loadFields() async {
    print("entered here");
    print(ref.read(locationPermissionProvider).latitude);
    final url = Uri.http(httpIP, 'api/get_fields_by_manager_id');
    final http.Response response;

    try {
      Map<String, dynamic> requestBody = {
        "manager_id": ref.read(userSingletonProvider).id,
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

      if (response.statusCode >= 400) {
        {
          print(response.body);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (response.body == 'null') {
        print("null");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<dynamic> listData = json.decode(response.body);
      print(listData);
      final List<Stadium> loadedItems = [];

      for (final item in listData) {
        double? distance; // Initialize distance here for each stadium

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
        final utilities = item['utilities'];
        final utilitiesString = parseUtilities(utilities);

        loadedItems.add(
          Stadium(
            id: item['uid'],
            title: item['name'],
            location: item['location'],
            imagePath: item['imageURL'],
            latitude: double.parse(item['latitude']),
            longitude: double.parse(item['longitude']),
            type: item['sport_type'],
            distance:
                distance ?? 0.0, // Use a default value if distance is null
            utilities: utilitiesString, // Add the parsed utilities string
            rating: double.parse(item['average_rating'].toString())
                .toStringAsFixed(2),
            availability: item['conf_interval'],
          ),
        );
      }

      setState(() {
        ref.read(stadiumListProvider.notifier).setStadiums(loadedItems);

        _isLoading = false;
      });

      print("sort?");
      // Sort the loaded items by distance in ascending order
    } catch (error) {
      print("error!!!! $error");
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

// Helper function to parse utilities map into a string
  String parseUtilities(Map<String, dynamic> utilities) {
    final List<String> utilityList = [];
    utilities.forEach((key, value) {
      final int intValue = value == 1 ? 1 : 0; // Handle integer values
      utilityList.add('$key-$intValue');
    });
    return '(${utilityList.join(',')})';
  }

  @override
  Widget build(BuildContext context) {
    _stadiums = ref.watch(stadiumListProvider);
    print("Activated BUILD in manager_screen");
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 0,
                  bottom: 50,
                  left: 20,
                  right: 20,
                ),
                width: 100,
                child: Image.asset('lib/images/manager.png'),
              ),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ))
                  : const SizedBox(),
              Expanded(
                child: ListView.builder(
                  itemCount: _stadiums.length,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      onTap: () {
                        /*Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ReservationDetailsScreen(
                                  reservation: pendingReservations[index]),
                            ),
                          );*/
                      },
                      child: StadiumItemManager(
                        stadium: _stadiums[index],
                        onSelectStadium: (Stadium stadium) {},
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
