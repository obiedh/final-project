import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:SportGrounds/model/stadium.dart';
import 'package:SportGrounds/providers/filtersProvider.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';
import 'package:SportGrounds/screens/stadium_details.dart';
import 'package:SportGrounds/widgets/stadium_item.dart';
import 'package:http/http.dart' as http;
import 'package:SportGrounds/widgets/MapWidget.dart';
import '../model/constants.dart';
import '../widgets/locationDropDown.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:convert';
import 'dart:math';

class StadiumsScreen extends ConsumerStatefulWidget {
  const StadiumsScreen({
    super.key,
    required this.title,
    required this.stadiums,
  });
  final String title;
  final List<Stadium> stadiums;

  @override
  ConsumerState<StadiumsScreen> createState() {
    return _StadiumsScreenState();
  }
}

class _StadiumsScreenState extends ConsumerState<StadiumsScreen> {
  String locationMessage = "";
  late String lat;
  late String long;
  double? latitude;
  double? longitude;
  List<Map<String, String>> availableTimes = [
    {"time": "No Available Times", "price": ""}
  ]; // Updated type
  List<Stadium> _filteredStadiums = [];
  TimeOfDay selectedStartTime = const TimeOfDay(hour: 8, minute: 0); // 12:00 PM
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 22, minute: 0); // 10:00 PM
  var _isFiltersOn = false;
  var _displayFiltersOn = false;
  var _isLoading = false;
  var _isMapOn = false;
  DateTime _selectedDate = DateTime.now();
  List<Stadium> _AllStadiums = [];
  Marker? _userLocationMarker;
  int _counter = 0;
  final TextEditingController searchController = TextEditingController();
  List<Stadium> _savedFilteredStadiums = [];
  GoogleMapController? _mapController;
  final _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<Prediction> predictions = [];
  BitmapDescriptor? customIcon;
  List<String> locationList = [];

  @override
  void initState() {
    super.initState();
    _filteredStadiums = widget.stadiums;
    _AllStadiums = widget.stadiums;
    _savedFilteredStadiums = widget.stadiums;
    searchController.addListener(onSearchTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          predictions = [];
        });
      }
    });
    _loadCustomIcon();
    _loadMapStyle();

    // Extract unique locations from the list of stadiums
    Set<String> uniqueLocations =
        widget.stadiums.map((stadium) => stadium.location).toSet();
    locationList = uniqueLocations.toList();
  }

  Future<void> _loadCustomIcon() async {
    String title = widget.title + '_icon.png';
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'lib/images/$title',
    );
    setState(() {}); // Refresh to update markers with the new icon
  }

  Future<void> _loadMapStyle() async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    _mapController?.setMapStyle(style);
  }

  void _selectStadium(BuildContext context, Stadium stadium) {
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

  void handleMapTap(LatLng latlng) async {
    setState(() {
      latitude = latlng.latitude;
      longitude = latlng.longitude;
    });

    // Get city name from latitude and longitude
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude!, longitude!);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
    }
  }

  Future<void> _getFilteredFields() async {
    final url = Uri.http(httpIP, 'api/get_filtered_fields');
    final http.Response response;
    double distance = 1.0;
    try {
      Map<String, dynamic> requestBody = {
        'date': formatDateTimeToDateString(_selectedDate),
        'start_time': timeOfDayToString(selectedStartTime),
        'end_time': timeOfDayToString(selectedEndTime),
        'location': ref.read(filterSingletonProvider).location,
        'sport_type': widget.title,
        "user_id": ref.read(userSingletonProvider).id,
        "user_latitude": ref.read(locationPermissionProvider).permission
            ? ref.read(locationPermissionProvider).latitude
            : 0.00000001,
        "user_longitude": ref.read(locationPermissionProvider).permission
            ? ref.read(locationPermissionProvider).longitude
            : 0.000001
      };

      response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      print(ref.read(locationPermissionProvider).permission);
      print(ref.read(userSingletonProvider).id);

      print(response.body);

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
            // Ensure price is parsed as double
            rating: '5',
          ),
        );
      }
      print(response.body);
      print("sort?");
      // Sort the loaded items by distance in ascending order
      /*_filteredStadiums = loadedItems //SORTING
        ..sort((a, b) => a.distance!.compareTo(b.distance as num));*/

      _filteredStadiums = loadedItems;

      _savedFilteredStadiums = _filteredStadiums;

      print(_filteredStadiums);
    } catch (error) {
      print("error!!!! $error");
    }
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
      setState(() {
        locationMessage = 'Latitude: $lat, Longitude: $long';
      });
    });
  }

  void onSearchTextChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredStadiums = _savedFilteredStadiums.where((stadium) {
        return stadium.title!.toLowerCase().contains(query);
      }).toList();
      _AllStadiums = widget.stadiums.where((stadium) {
        return stadium.title!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("LONG:");
    print(ref.read(locationPermissionProvider).longitude);
    print("LAT");
    print(ref.read(locationPermissionProvider).latitude);
    ref.watch(filterSingletonProvider);
    Widget content;
    var filters = Column(
      children: [
        Row(
          children: [
            Card(
              child: IgnorePointer(
                ignoring: !_isFiltersOn,
                child: Opacity(
                  opacity: _isFiltersOn ? 1 : 0.4,
                  child: DropdownButton<TimeOfDay>(
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 197, 158),
                    ),
                    underline: Container(),
                    value: selectedStartTime,
                    onChanged: _onStartTimeChanged,
                    items: _buildTimeItems(),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: _isFiltersOn ? 1 : 0.4,
              child: const Text('To'),
            ),
            Card(
              child: Opacity(
                opacity: _isFiltersOn ? 1 : 0.4,
                child: IgnorePointer(
                  ignoring: !_isFiltersOn,
                  child: DropdownButton<TimeOfDay>(
                    value: selectedEndTime,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 255, 197, 158)),
                    onChanged: _onEndTimeChanged,
                    items: _buildTimeItems(),
                    underline: Container(
                      // Set an empty container to remove the underline
                      height: 0,
                      color: const Color.fromARGB(255, 255, 197, 158),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 14,
            ),
            Opacity(
              opacity: _isFiltersOn ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !_isFiltersOn,
                child: Card(
                  child: IconButton(
                    iconSize: 32,
                    onPressed: () async {
                      setState(() {
                        _counter = 2;
                        _isLoading = true;
                      });
                      await _getFilteredFields();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 18,
        ),
        Row(
          children: [
            Opacity(
              opacity: _isFiltersOn ? 1 : 0.4,
              child: const Icon(
                Icons.location_on_sharp,
              ),
            ),
            Opacity(
              opacity: _isFiltersOn ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !_isFiltersOn,
                child: DropdownLocationButton(locations: locationList),
              ),
            ),
            Opacity(
              opacity: _isFiltersOn ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !_isFiltersOn,
                child: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        ref
                            .read(filterSingletonProvider.notifier)
                            .appliedDateFilter(picked);
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ),
            ),
            Opacity(
              opacity: _isFiltersOn ? 1 : 0.4,
              child: Text(
                formatDateTimeToDateString(_selectedDate),
                style: const TextStyle(
                    fontSize: 12, color: Color.fromARGB(255, 255, 197, 158)),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search Stadiums by Name',
            hintText: 'Enter stadium name',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            return ListTile();
          },
        ),
      ],
    );
    var appbar = AppBar(
      title: const Text('Fields'),
      actions: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 40,
            maxWidth: 130,
          ),
          child: SwitchListTile(
            secondary: const Tooltip(
                message: 'Enable or Disable Map', child: Icon(Icons.map)),
            activeColor: const Color.fromARGB(255, 255, 197, 158),
            value: _isMapOn,
            onChanged: (isChecked) {
              setState(() {
                _isMapOn = isChecked;
              });
            },
          ),
        ),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 40,
            maxWidth: 130,
          ),
          child: SwitchListTile(
            secondary: const Tooltip(
                message: 'Enable or Disable Filters',
                child: Icon(Icons.info_outline)),
            activeColor: const Color.fromRGBO(255, 197, 158, 1),
            value: _isFiltersOn,
            onChanged: (isChecked) async {
              setState(() {
                ref
                    .read(filterSingletonProvider.notifier)
                    .appliedLocationFilter("All");
                _isFiltersOn = !_isFiltersOn;
                if (_isFiltersOn == false) {
                  _counter = 0;
                  print("turn off");
                  print('$_counter,$_isFiltersOn');

                  ref.read(filterSingletonProvider.notifier).restoreFilters();
                  ref
                      .read(filterSingletonProvider.notifier)
                      .turnFiltersStatus(false);
                  _selectedDate = DateTime.now();
                  selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
                  selectedEndTime = const TimeOfDay(hour: 22, minute: 0);
                  ref
                      .read(filterSingletonProvider.notifier)
                      .turnFiltersStatus(false);
                } else {
                  _counter = 1;
                  _displayFiltersOn = true;
                  print('$_counter,$_isFiltersOn');
                  ref
                      .read(filterSingletonProvider.notifier)
                      .turnFiltersStatus(true);
                  setState(() {
                    _isLoading = true;
                  });
                  //await _getFilteredFields();
                  setState(() {
                    _isLoading = false;
                    ref
                        .read(filterSingletonProvider.notifier)
                        .appliedLocationFilter("All");
                  });
                }
              });
            },
          ),
        ),
      ],
    );
    if (_isMapOn) {
      content = Column(
        children: [
          _displayFiltersOn ? filters : const SizedBox(),
          Center(
            child: IconButton(
                onPressed: () {
                  setState(() {
                    _displayFiltersOn = !_displayFiltersOn;
                  });
                },
                icon: Icon(_displayFiltersOn
                    ? Icons.arrow_upward
                    : Icons.arrow_downward)),
          ),
          Expanded(
            flex: 14,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                _loadMapStyle(); // Apply the map style once the map is created
              },
              initialCameraPosition: CameraPosition(
                target: ref.read(locationPermissionProvider).permission
                    ? LatLng(ref.read(locationPermissionProvider).latitude!,
                        ref.read(locationPermissionProvider).longitude!)
                    : LatLng(
                        32.794044,
                        34.989571,
                      ), // Center map on user location
                zoom: 13.0,
              ),
              markers: {
                if (_userLocationMarker != null) _userLocationMarker!,
                ..._filteredStadiums.map((stadium) {
                  return Marker(
                    markerId: MarkerId(stadium.id),
                    position: LatLng(stadium.latitude, stadium.longitude),
                    icon: customIcon ??
                        BitmapDescriptor.defaultMarker, // Use custom icon
                    infoWindow: InfoWindow(
                      title: stadium.title,
                      snippet: stadium.location,
                      onTap: () => _selectStadium(context, stadium),
                    ),
                  );
                }).toSet(),
              },
              onTap: (latlng) {
                handleMapTap(latlng);
              },
            ),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          _displayFiltersOn ? filters : const SizedBox(),
          Center(
            child: IconButton(
                onPressed: () {
                  setState(() {
                    _displayFiltersOn = !_displayFiltersOn;
                  });
                },
                icon: Icon(_displayFiltersOn
                    ? Icons.arrow_upward
                    : Icons.arrow_downward)),
          ),
          Expanded(
            flex: 14,
            child: _filteredStadiums.isEmpty && _isFiltersOn && _counter == 2
                ? const Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Oops.. seems like there is no fields matching your filters, change the filter or you can Turn them off to see Stadiums!!',
                            style: TextStyle(fontSize: 24),
                          ),
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: ListView.builder(
                      itemCount: _isFiltersOn == true && _counter != 2 ||
                              _isFiltersOn == false && _counter != 2
                          ? _AllStadiums.length
                          : _filteredStadiums.length,
                      itemBuilder: (ctx, index) => StadiumItem(
                        stadium: _isFiltersOn == true && _counter != 2 ||
                                _isFiltersOn == false && _counter != 2
                            ? _AllStadiums[index]
                            : _filteredStadiums[index],
                        onSelectStadium: (stadium) async {
                          setState(() {
                            _isLoading = true;
                          });
                          await _processIntervalsAndReservations(stadium);

                          setState(() {
                            _isLoading = false;
                          });

                          _selectStadium(context, stadium);
                        },
                      ),
                    ),
                  ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: appbar,
          body: content,
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

  String timeOfDayToString(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _onStartTimeChanged(TimeOfDay? newValue) {
    if (newValue != null) {
      if (_isEndTimeBeforeStartTime(newValue, selectedEndTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Start time cannot be after end time"),
          ),
        );
      } else {
        setState(() {
          selectedStartTime = newValue;
        });
      }
    }
  }

  void _onEndTimeChanged(TimeOfDay? newValue) {
    if (newValue != null) {
      if (_isEndTimeBeforeStartTime(selectedStartTime, newValue)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("End time cannot be before start time"),
          ),
        );
      } else {
        setState(() {
          selectedEndTime = newValue;
        });
      }
    }
  }

  bool _isEndTimeBeforeStartTime(TimeOfDay startTime, TimeOfDay endTime) {
    return endTime.hour < startTime.hour ||
        (endTime.hour == startTime.hour && endTime.minute < startTime.minute);
  }

  List<DropdownMenuItem<TimeOfDay>> _buildTimeItems() {
    final List<DropdownMenuItem<TimeOfDay>> items = [];
    for (int hour = 8; hour <= 22; hour++) {
      final String displayHour = hour.toString().padLeft(2, '0');
      final String displayTime = '$displayHour:00';
      items.add(DropdownMenuItem<TimeOfDay>(
        value: TimeOfDay(hour: hour, minute: 0),
        child: Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Text(
            displayTime,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ));
    }
    return items;
  }
}

class Prediction {
  final String description;
  final String placeId;

  Prediction({required this.description, required this.placeId});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}

double _degreesToRadians(double degrees) {
  return degrees * (pi / 180.0);
}

//calculate distanc

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

String formatDateTimeToDateString(DateTime dateTime) {
  // Create a date format with the desired format (yyyy-MM-dd)
  final dateFormat = DateFormat('dd.M.yyyy');

  // Format the DateTime to a string with the specified format
  return dateFormat.format(dateTime);
}
