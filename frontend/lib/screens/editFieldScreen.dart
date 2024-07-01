import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:proj/model/constants.dart';
import 'package:proj/model/stadium.dart';
import 'package:proj/providers/fieldsProvider.dart';
import 'package:proj/widgets/CheckBoxItem.dart';


class EditFieldScreen extends ConsumerStatefulWidget {
  const EditFieldScreen({super.key, required this.stadium});
  final Stadium stadium;

  @override
  ConsumerState<EditFieldScreen> createState() {
    return _EditFieldScreenState();
  }
}

class _EditFieldScreenState extends ConsumerState<EditFieldScreen> {
  @override
  Widget build(BuildContext context) {
    // Rebuild the UI with updated stadium details
    final stadium = ref
        .watch(stadiumListProvider)
        .firstWhere((s) => s.id == widget.stadium.id);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit your field'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Edit Field Details'),
              Tab(text: 'Edit Availability'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EditFieldsTab(stadium: stadium),
            EditAvailabilityTab(stadium: stadium),
          ],
        ),
      ),
    );
  }
}

class EditFieldsTab extends ConsumerStatefulWidget {
  const EditFieldsTab({Key? key, required this.stadium}) : super(key: key);

  final Stadium stadium;

  @override
  ConsumerState<EditFieldsTab> createState() => _EditFieldsTabState();
}

class _EditFieldsTabState extends ConsumerState<EditFieldsTab> {
  final _formKey = GlobalKey<FormState>();
  bool hasChanges = false;
  Map<String, int> utilitiesMap = {
    'Pool': 0,
    'Lights': 0,
    'Bathroom': 0,
    'Sport equipment': 0,
    'Free parking': 0,
  };
  bool _isLoading = false;
  late String fieldName;

  @override
  void initState() {
    super.initState();
    final stadium = widget.stadium;
    fieldName = stadium.title!;
    final String utilitiesString = stadium.utilities ?? '';
    utilitiesMap = parseUtilities(utilitiesString);
  }

  Future<bool> _updateFieldDetails() async {
    final url = Uri.http(httpIP, 'api/update_field_details');
    try {
      Map<String, dynamic> requestBody = {
        "field_id": widget.stadium.id,
        "name": fieldName,
        "utilities": utilitiesMap,
      };

      setState(() {
        _isLoading = true;
      });
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print(response.body);
        setState(() {
          _isLoading = false;
        });
        return false;
      } else {
        // Update the provider with the new details
        final newUtilitiesString = generateUtilitiesString(utilitiesMap);
        ref.read(stadiumListProvider.notifier).updateStadiumDetails(
              widget.stadium.id,
              fieldName,
              newUtilitiesString,
            );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("error");
      print("Error: $error");
      setState(() {
        _isLoading = false;
      });
    }
    return true;
  }

  Map<String, int> parseUtilities(String utilities) {
    final Map<String, int> utilitiesMap = {};
    if (utilities.isNotEmpty) {
      final items = utilities.substring(1, utilities.length - 1).split(', ');
      for (final item in items) {
        final parts = item.split(': ');
        if (parts.length == 2) {
          utilitiesMap[parts[0].replaceAll('"', '')] = int.parse(parts[1]);
        }
      }
    }
    return utilitiesMap;
  }

  String generateUtilitiesString(Map<String, int> utilities) {
    return '{${utilities.entries.map((entry) => '"${entry.key}": ${entry.value}').join(', ')}}';
  }

  void handleCheckboxChange(String title, bool value) {
    setState(() {
      utilitiesMap[title] = value ? 1 : 0;
      hasChanges = true;
    });
  }

  void handleFieldNameChange(String value) {
    setState(() {
      fieldName = value;
      hasChanges = true;
    });
  }

  void saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _updateFieldDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilities updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the updated stadium details from the provider
    final stadium = ref
        .watch(stadiumListProvider)
        .firstWhere((s) => s.id == widget.stadium.id);

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ))
          : Stack(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              initialValue: stadium.title,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.stadium),
                                hintText: 'Enter field name',
                                labelText: 'Field Name *',
                              ),
                              onChanged: handleFieldNameChange,
                              onSaved: (String? value) {
                                fieldName = value!;
                              },
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field name cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Field Utilities',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      CheckboxItem(
                        title: 'Pool',
                        initialState: utilitiesMap['Pool'] == 1,
                        onChanged: (value) =>
                            handleCheckboxChange('Pool', value),
                      ),
                      CheckboxItem(
                        title: 'Lights',
                        initialState: utilitiesMap['Lights'] == 1,
                        onChanged: (value) =>
                            handleCheckboxChange('Lights', value),
                      ),
                      CheckboxItem(
                        title: 'Bathroom',
                        initialState: utilitiesMap['Bathroom'] == 1,
                        onChanged: (value) =>
                            handleCheckboxChange('Bathroom', value),
                      ),
                      CheckboxItem(
                        title: 'Sport equipment',
                        initialState: utilitiesMap['Sport equipment'] == 1,
                        onChanged: (value) =>
                            handleCheckboxChange('Sport equipment', value),
                      ),
                      CheckboxItem(
                        title: 'Free parking',
                        initialState: utilitiesMap['Free parking'] == 1,
                        onChanged: (value) =>
                            handleCheckboxChange('Free parking', value),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: hasChanges ? saveChanges : null,
                      child: const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class EditAvailabilityTab extends ConsumerStatefulWidget {
  const EditAvailabilityTab({Key? key, required this.stadium})
      : super(key: key);

  final Stadium stadium;

  @override
  _EditAvailabilityTabState createState() => _EditAvailabilityTabState();
}

class _EditAvailabilityTabState extends ConsumerState<EditAvailabilityTab> {
  bool hasChanges = false;
  List<Map<String, String>> timePriceList = [];
  List<String> timeSlots = [];
  bool _isLoading = false;
  String timePriceString = "";

  @override
  void initState() {
    super.initState();
    timeSlots = generateTimeSlots();
    timePriceString = widget.stadium.availability ?? ''; // Example string
    timePriceList = parseTimePriceString(timePriceString);
  }

  Future<bool> _updateFieldAvailability() async {
    final url = Uri.http(httpIP, 'api/update_conf_interval');
    print(timePriceList);
    try {
      Map<String, dynamic> requestBody = {
        "field_id": widget.stadium.id,
        "conf_interval": parseTimePriceListToString(timePriceList),
      };

      setState(() {
        _isLoading = true;
      });
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print(response.body);
        setState(() {
          _isLoading = false;
        });
        return false;
      } else {
        ref.read(stadiumListProvider.notifier).updateStadiumAvailability(
              widget.stadium.id,
              parseTimePriceListToString(timePriceList),
            );
        final newAvailabilityString = parseTimePriceListToString(timePriceList);
        ref.read(stadiumListProvider.notifier).updateStadiumAvailability(
              widget.stadium.id,
              newAvailabilityString,
            );
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

  Future<void> saveData() async {
    // Validate that all prices are greater than 0
    if (!hasChanges) {
      return;
    }
    bool pricesValid =
        timePriceList.every((item) => int.parse(item['price']!) > 0);
    if (!pricesValid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please enter a price greater than 0 for all time slots.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      hasChanges = false;
    } else {
      setState(() {
        _isLoading = true;
      });
      await _updateFieldAvailability();
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updates were successful!'),
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        hasChanges = false;
      });
    }

    // Save logic here
    timePriceString =
        '[${timePriceList.map((item) => '${item['startTime']}-${item['endTime']},${item['price']}').join(' ')}]';

    //timePriceList = parseTimePriceString(timePriceString);
  }

  String parseTimePriceListToString(List<Map<String, dynamic>> timePriceList) {
    return timePriceList.map((item) {
      return '${item['startTime']}-${item['endTime']},${item['price']}';
    }).join(' ');
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

  List<String> generateTimeSlots() {
    List<String> timeSlots = [];
    for (int hour = 8; hour <= 22; hour++) {
      timeSlots.add('${hour.toString().padLeft(2, '0')}:00');
    }
    return timeSlots;
  }

  List<String> getFilteredStartTimes(String? selectedStartTime) {
    // Exclude times that are within any existing time range
    Set<String> excludedTimes = {};
    for (var item in timePriceList) {
      int startHour = int.parse(item['startTime']!.split(':')[0]);
      int endHour = int.parse(item['endTime']!.split(':')[0]);
      for (int hour = startHour; hour < endHour; hour++) {
        excludedTimes.add('${hour.toString().padLeft(2, '0')}:00');
      }
    }

    // Allow currently selected time if set
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
      hasChanges = true;
    });
  }

  void deleteTimePriceEntry(int index) {
    setState(() {
      timePriceList.removeAt(index);
      hasChanges = true; // Set hasChanges to true when a time slot is deleted
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: addNewTimePriceEntry,
              child: const Text('Add Time Slot'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: timePriceList.length,
                itemBuilder: (context, index) {
                  final item = timePriceList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: item['startTime'],
                          items: getFilteredStartTimes(item['startTime'])
                              .map((time) {
                            return DropdownMenuItem<String>(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              item['startTime'] = newValue!;
                              item['endTime'] =
                                  getFilteredEndTimes(newValue, null).first;
                              hasChanges = true; // Set hasChanges to true
                            });
                          },
                        ),
                        const Text(' TO '),
                        DropdownButton<String>(
                          value: item['endTime'],
                          items: getFilteredEndTimes(
                                  item['startTime']!, item['endTime'])
                              .map((time) {
                            return DropdownMenuItem<String>(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              item['endTime'] = newValue!;
                              hasChanges = true; // Set hasChanges to true
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: item['price'],
                            decoration: const InputDecoration(
                              labelText: 'Price',
                            ),
                            onSaved: (String? value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            validator: (String? value) {
                              return (value != null &&
                                      double.tryParse(value) == null)
                                  ? 'Enter a valid price.'
                                  : null;
                            },
                            onChanged: (newValue) {
                              setState(() {
                                item['price'] = newValue;
                                hasChanges = true; // Set hasChanges to true
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteTimePriceEntry(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: hasChanges ? saveData : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
