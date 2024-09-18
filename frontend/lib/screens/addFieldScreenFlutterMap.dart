/*import 'dart:convert';
import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/model/stadium.dart';
import 'package:SportGrounds/providers/fieldsProvider.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:SportGrounds/screens/stadiums.dart';
import 'package:SportGrounds/widgets/CheckBoxItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart' as latlng;

class AddFieldScreen extends ConsumerStatefulWidget {
  const AddFieldScreen({super.key, required this.stadium});
  final Stadium stadium;

  @override
  ConsumerState<AddFieldScreen> createState() {
    return _AddFieldScreenState();
  }
}

class _AddFieldScreenState extends ConsumerState<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  bool _isFieldCreated = false;
  String title = "";
  bool canAddField = false;
  bool isLocationValid = true;
  bool areTimeSlotsValid = true;
  String _location = '';
  var _isLoading = false;
  String? selectedSport;
  String country = '';
  String postalCode = '';
  String administrativeArea = '';
  String subLocality = '';
  String street = '';
  String cityName = '';
  String name = '';
  String fieldName = '';
  String utilitiesString = '';
  String timeSlotsAndPrices = '';
  bool isFieldNameValid = true;
  bool areUtilitiesValid = true;
  List<bool> arePricesValid = [];

  double? latitude;
  double? longitude;
  double? fieldLatitude;
  double? fieldLongitude;

  Map<String, bool> utilitiesMap = {
    'Pool': false,
    'Lights': false,
    'Bathroom': false,
    'Sport equipment': false,
    'Free parking': false,
  };

  List<Map<String, String>> timePriceList = [];
  List<String> timeSlots = [];

  List<Prediction> predictions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    timeSlots = generateTimeSlots();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          predictions = [];
        });
      }
    });
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    // Get city name from latitude and longitude
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude!, longitude!);
    if (placemarks.isNotEmpty) {
      setState(() {
        cityName = placemarks.first.locality ?? '';
      });
    }
  }

  Future<void> _searchLocation(String input) async {
    final requestUrl =
        Uri.https("maps.googleapis.com", "/maps/api/place/autocomplete/json", {
      "input": input,
      "key": kGoogleApiKey,
      "components": "country:il",
    });

    try {
      final response = await http.get(requestUrl);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          setState(() {
            predictions = (json['predictions'] as List)
                .map((p) => Prediction.fromJson(p))
                .toList();
          });
        } else {
          print("Error from API: ${json['status']}");
        }
      } else {
        print(
            "Error occurred while fetching predictions: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error occurred while searching location: $e");
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    final apiKey = "AIzaSyD9fiODgq_4Qgwh25uEB1ON5ywYxI1Gbuw";
    final requestUrl =
        Uri.https("maps.googleapis.com", "/maps/api/place/details/json", {
      "place_id": placeId,
      "key": apiKey,
    });

    try {
      final response = await http.get(requestUrl);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'OK') {
          final lat = json['result']['geometry']['location']['lat'];
          final lng = json['result']['geometry']['location']['lng'];

          setState(() {
            fieldLatitude = lat;
            fieldLongitude = lng;

            // Extract the city name and update the location parameter
            final addressComponents =
                json['result']['address_components'] as List;
            final cityComponent = addressComponents.firstWhere(
                (component) =>
                    (component['types'] as List).contains('locality'),
                orElse: () => null);
            if (cityComponent != null) {
              _location = cityComponent['long_name'];
              print("location is here: $_location");
            }
          });
        } else {
          print("Error from API: ${json['status']}");
        }
      } else {
        print(
            "Error occurred while fetching place details: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error occurred while getting place details: $e");
    }
  }

  void handleMapTap(latlng.LatLng latlng) async {
    setState(() {
      fieldLatitude = latlng.latitude;
      fieldLongitude = latlng.longitude;
    });

    // Get city name from latitude and longitude
    List<Placemark> placemarks =
        await placemarkFromCoordinates(fieldLatitude!, fieldLongitude!);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        cityName = place.locality ?? '';
        name = place.name ?? '';
        street = place.street ?? '';
        subLocality = place.subLocality ?? '';
        administrativeArea = place.administrativeArea ?? '';
        postalCode = place.postalCode ?? '';
        country = place.country ?? '';

        // Update the location parameter with the city name
        _location = cityName;
      });
    }

    print(fieldLatitude);
    print(fieldLongitude);
    print(cityName);
    print(name);
    print(street);
    print(postalCode);
    print(country);
  }

  void updateFieldData(String name, String utilities, String timeSlots) {
    setState(() {
      fieldName = name;
      utilitiesString = utilities;
      timeSlotsAndPrices = timeSlots;
      arePricesValid = List.generate(timePriceList.length, (index) => true);
    });
  }

  void validateForm() {
    setState(() {
      isFieldNameValid = fieldName.isNotEmpty;
      areUtilitiesValid = utilitiesMap.values.any((value) => value == true);
      isLocationValid = fieldLatitude != null && fieldLongitude != null;
      arePricesValid = timePriceList
          .map((item) =>
              int.tryParse(item['price']!) != null &&
              int.parse(item['price']!) > 0)
          .toList();
      areTimeSlotsValid = timePriceList.isNotEmpty;

      // Check if any time slot has start time after end time
      bool areTimeSlotsInOrder = timePriceList.every((item) {
        int startHour = int.parse(item['startTime']!.split(':')[0]);
        int endHour = int.parse(item['endTime']!.split(':')[0]);
        return startHour < endHour;
      });

      bool isSportTypeValid = selectedSport != null;

      canAddField = isFieldNameValid &&
          areUtilitiesValid &&
          arePricesValid.every((valid) => valid) &&
          isLocationValid &&
          areTimeSlotsValid &&
          areTimeSlotsInOrder &&
          isSportTypeValid;
    });
  }

  Future<bool> _createField() async {
    final url = Uri.http(httpIP, 'api/create_field');
    print(utilitiesMap);
    try {
      Map<String, dynamic> requestBody = {
        "name": fieldName,
        "location": _location,
        "latitude": fieldLatitude,
        "longitude": fieldLongitude,
        "sport_type": selectedSport,
        "conf_interval": timeSlotsAndPrices,
        "imageURL": "lib/images/katsef_field.jpg",
        "manager_id": ref.read(userSingletonProvider).id,
        "utilities": utilitiesMap
      };

      setState(() {
        _isLoading = true;
      });
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 201) {
        print(response.body);
        _isFieldCreated = false;
        setState(() {
          _isLoading = false;
        });
        return false;
      } else {
        _isFieldCreated = true;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        // Handle the error
      });
    }
    return true;
  }

  Future<void> handleAddFieldButtonPressed() async {
    validateForm();

    if (canAddField) {
      bool? confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm'),
            content: Text('Are you sure you want to add the field?'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Return false when "No" is pressed
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);

                  // Return true when "Yes" is pressed
                },
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        print('Field Name: $fieldName');
        print('Utilities: $utilitiesString');
        print('Time Slots and Prices: $timeSlotsAndPrices');
        print('Latitude: $latitude');
        print('Longitude: $longitude');
        print(selectedSport);
        print(cityName);

        setState(() {
          _isLoading = true;
        });
        bool success = await _createField();
        setState(() {
          _isLoading = false;
        });

        if (success) {
          Stadium newStadium = Stadium(
            id: 'newId', // replace with the actual ID if available
            title: fieldName,
            location: _location,
            imagePath: 'lib/images/katsef_field.jpg',
            latitude: fieldLatitude!,
            longitude: fieldLongitude!,
            type: selectedSport!,
            distance: 0.0, // replace with actual distance if needed
            utilities: utilitiesString,
            rating: '0.0', // replace with actual rating if available
            availability: timeSlotsAndPrices,
          );
          Navigator.pop(context, newStadium);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Field added successfully.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The field already exists!!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      String errorMessage =
          'Please ensure all conditions are met to add the field.';
      if (!isFieldNameValid) {
        errorMessage = 'Field name cannot be empty.';
      } else if (!areUtilitiesValid) {
        errorMessage = 'At least one utility must be selected.';
      } else if (!isLocationValid) {
        errorMessage = 'Please select a valid location.';
      } else if (selectedSport == null) {
        errorMessage = 'Please select a sport type.';
      } else if (!arePricesValid.every((valid) => valid)) {
        errorMessage = 'All prices must be greater than 0.';
      } else if (!areTimeSlotsValid) {
        errorMessage = 'Please add at least one time slot.';
      } else if (!timePriceList.every((item) {
        int startHour = int.parse(item['startTime']!.split(':')[0]);
        int endHour = int.parse(item['endTime']!.split(':')[0]);
        return startHour < endHour;
      })) {
        errorMessage = 'Start time cannot be after end time.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String generateUtilitiesString(Map<String, bool> utilities) {
    return '(' +
        utilities.entries
            .map((entry) => '${entry.key}-${entry.value ? '1' : '0'}')
            .join(',') +
        ')';
  }

  void handleCheckboxChange(String title, bool value) {
    setState(() {
      utilitiesMap[title] = value;
      updateFieldData(
          fieldName, generateUtilitiesString(utilitiesMap), timePriceString());
      validateForm(); // Revalidate the form
    });
  }

  void handleFieldNameChange(String value) {
    setState(() {
      fieldName = value;
      updateFieldData(
          fieldName, generateUtilitiesString(utilitiesMap), timePriceString());
      validateForm(); // Revalidate the form
    });
  }

  List<Map<String, String>> parseTimePriceString(String timePriceString) {
    List<Map<String, String>> parsedList = [];
    List<String> items = timePriceString.split(' ');

    for (String item in items) {
      List<String> parts = item.split(',');
      if (parts.length == 2) {
        String timeRange = parts[0];
        String price = parts[1];

        List<String> times = timeRange.split('-');
        if (times.length == 2) {
          String startTime = times[0];
          String endTime = times[1];
          parsedList.add({
            'startTime': startTime,
            'endTime': endTime,
            'price': price,
          });
        }
      }
    }

    return parsedList;
  }

  String timePriceString() {
    return timePriceList
        .map((item) =>
            '${item['startTime']}-${item['endTime']},${item['price']}')
        .join(' ');
  }

  List<String> generateTimeSlots() {
    List<String> timeSlots = [];
    for (int hour = 8; hour <= 22; hour++) {
      timeSlots.add('${hour.toString().padLeft(2, '0')}:00');
    }
    return timeSlots;
  }

  List<String> getFilteredStartTimes(String? selectedStartTime) {
    Set<String> excludedTimes = {};
    for (var item in timePriceList) {
      int startHour = int.parse(item['startTime']!.split(':')[0]);
      int endHour = int.parse(item['endTime']!.split(':')[0]);
      for (int hour = startHour; hour < endHour; hour++) {
        excludedTimes.add('${hour.toString().padLeft(2, '0')}:00');
      }
    }

    List<String> availableTimes = timeSlots.where((time) {
      return !excludedTimes.contains(time) || time == selectedStartTime;
    }).toList();

    return availableTimes;
  }

  List<String> getFilteredEndTimes(String startTime, String? selectedEndTime) {
    int startHour = int.parse(startTime.split(':')[0]);
    List<String> availableTimes = timeSlots.where((time) {
      int hour = int.parse(time.split(':')[0]);
      return hour > startHour || time == selectedEndTime;
    }).toList();
    return availableTimes;
  }

  void addNewTimePriceEntry() {
    setState(() {
      timePriceList.add({
        'startTime': timeSlots.first,
        'endTime': getFilteredEndTimes(timeSlots.first, null).first,
        'price': '0',
      });
      updateFieldData(
          fieldName, generateUtilitiesString(utilitiesMap), timePriceString());
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void deleteTimePriceEntry(int index) {
    setState(() {
      timePriceList.removeAt(index);
      updateFieldData(
          fieldName, generateUtilitiesString(utilitiesMap), timePriceString());
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];

    if (latitude != null && longitude != null) {
      markers.add(
        Marker(
          point: latlng.LatLng(latitude!, longitude!),
          builder: (context) => Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    if (fieldLatitude != null && fieldLongitude != null) {
      markers.add(
        Marker(
          point: latlng.LatLng(fieldLatitude!, fieldLongitude!),
          builder: (context) => Icon(
            Icons.location_on,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Field'),
        actions: [
          ElevatedButton(
            onPressed: handleAddFieldButtonPressed,
            child: Text(
              'Add Field',
              style: TextStyle(fontSize: 23),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canAddField ? Colors.blue : Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 25),
              // Add the search TextField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  focusNode: _focusNode,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Location (powered by Google)',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _searchLocation(value);
                    } else {
                      setState(() {
                        predictions = [];
                      });
                    }
                  },
                ),
              ),
              // Display the predictions in a ListView.builder
              ListView.builder(
                shrinkWrap: true,
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(predictions[index].description!),
                    onTap: () {
                      _getPlaceDetails(predictions[index].placeId!);
                      setState(() {
                        _searchController.clear(); // Clear the text field
                        predictions = []; // Clear the predictions list
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Field Location',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLocationValid ? Colors.white : Colors.red),
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    center: ref.read(locationPermissionProvider).permission
                        ? latlng.LatLng(
                            ref.read(locationPermissionProvider).latitude!,
                            ref.read(locationPermissionProvider).longitude!)
                        : latlng.LatLng(51.5, -0.09),
                    zoom: 13.0,
                    onTap: (latLng) =>
                        handleMapTap(latLng), // Corrected onTap callback
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayerOptions(
                      markers: markers,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      initialValue: fieldName,
                      decoration: InputDecoration(
                        icon: Icon(Icons.stadium),
                        hintText: 'Enter field name',
                        labelText: 'Field Name *',
                        errorText: isFieldNameValid
                            ? null
                            : 'Field name cannot be empty',
                        errorStyle: TextStyle(color: Colors.red),
                      ),
                      onChanged: handleFieldNameChange,
                      onSaved: (String? value) {
                        fieldName = value!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Field Utilities *',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: areUtilitiesValid ? Colors.white : Colors.red),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              CheckboxItem(
                title: 'Pool',
                initialState: utilitiesMap['Pool'] ?? false,
                onChanged: (value) => handleCheckboxChange('Pool', value),
              ),
              CheckboxItem(
                title: 'Lights',
                initialState: utilitiesMap['Lights'] ?? false,
                onChanged: (value) => handleCheckboxChange('Lights', value),
              ),
              CheckboxItem(
                title: 'Bathroom',
                initialState: utilitiesMap['Bathroom'] ?? false,
                onChanged: (value) => handleCheckboxChange('Bathroom', value),
              ),
              CheckboxItem(
                title: 'Sport equipment',
                initialState: utilitiesMap['Sport equipment'] ?? false,
                onChanged: (value) =>
                    handleCheckboxChange('Sport equipment', value),
              ),
              CheckboxItem(
                title: 'Free parking',
                initialState: utilitiesMap['Free parking'] ?? false,
                onChanged: (value) =>
                    handleCheckboxChange('Free parking', value),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    'Sport Type *',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedSport == null ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: selectedSport,
                    hint: Text('Select Sport Type'),
                    items: ['football', 'tennis'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSport = newValue;
                        validateForm(); // Revalidate form when the sport type changes
                      });
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text(
                      'Time Slots and Prices *',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: areTimeSlotsValid ? Colors.white : Colors.red,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: timePriceList.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            DropdownButton<String>(
                              value: timePriceList[index]['startTime'],
                              items: getFilteredStartTimes(
                                      timePriceList[index]['startTime'])
                                  .map((time) => DropdownMenuItem(
                                        value: time,
                                        child: Text(time),
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  timePriceList[index]['startTime'] = newValue!;
                                  updateFieldData(
                                      fieldName,
                                      generateUtilitiesString(utilitiesMap),
                                      timePriceString());
                                  validateForm(); // Revalidate the form
                                });
                              },
                            ),
                            Text(' - '),
                            DropdownButton<String>(
                              value: timePriceList[index]['endTime'],
                              items: getFilteredEndTimes(
                                      timePriceList[index]['startTime']!,
                                      timePriceList[index]['endTime'])
                                  .map((time) => DropdownMenuItem(
                                        value: time,
                                        child: Text(time),
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  timePriceList[index]['endTime'] = newValue!;
                                  updateFieldData(
                                      fieldName,
                                      generateUtilitiesString(utilitiesMap),
                                      timePriceString());
                                  validateForm(); // Revalidate the form
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: timePriceList[index]['price'],
                                decoration: InputDecoration(
                                  hintText: 'Price',
                                  errorText: arePricesValid[index]
                                      ? null
                                      : 'Invalid price',
                                  errorStyle: TextStyle(color: Colors.red),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (newValue) {
                                  setState(() {
                                    timePriceList[index]['price'] = newValue;
                                    updateFieldData(
                                        fieldName,
                                        generateUtilitiesString(utilitiesMap),
                                        timePriceString());
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                deleteTimePriceEntry(index);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: addNewTimePriceEntry,
                      child: Text('Add Time Slot'),
                    ),
                  ],
                ),
              ),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ))
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
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
}*/
