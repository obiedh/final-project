import 'dart:convert';

import 'package:SportGrounds/model/constants.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class UserPreferenceScreen extends ConsumerStatefulWidget {
  const UserPreferenceScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _UserPreferenceScreenState();
  }
}

class _UserPreferenceScreenState extends ConsumerState<UserPreferenceScreen> {
  bool _isBathroomChecked = false;
  bool _isPoolChecked = false;
  bool _isLightsChecked = false;
  bool _isSportEquipmentChecked = false;
  bool _isFreeParkingChecked = false;
  bool _isLoading = false;
  bool _isUpdated = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final preferencesString = ref.read(userSingletonProvider).preferences;
    final preferencesMap = _parsePreferences(preferencesString!);

    setState(() {
      _isBathroomChecked = preferencesMap['Bathroom'] == 1;
      _isPoolChecked = preferencesMap['Pool'] == 1;
      _isLightsChecked = preferencesMap['Lights'] == 1;
      _isSportEquipmentChecked = preferencesMap['Sport equipment'] == 1;
      _isFreeParkingChecked = preferencesMap['Free Parking'] == 1;
    });
  }

  Map<String, int> _parsePreferences(String preferences) {
    final Map<String, int> preferencesMap = {};
    final items = preferences.split(',');

    for (var item in items) {
      final keyValue = item.split('-');
      if (keyValue.length == 2) {
        preferencesMap[keyValue[0].trim()] = keyValue[1].trim() == '1' ? 1 : 0;
      }
    }

    return preferencesMap;
  }

  void _savePreferences() {
    String preferences = '';
    preferences += _isBathroomChecked ? 'Bathroom-1, ' : 'Bathroom-0, ';
    preferences += _isPoolChecked ? 'Pool-1, ' : 'Pool-0, ';
    preferences += _isLightsChecked ? 'Lights-1, ' : 'Lights-0, ';
    preferences += _isSportEquipmentChecked
        ? 'Sport equipment-1, '
        : 'Sport equipment-0, ';
    preferences +=
        _isFreeParkingChecked ? 'Free Parking-1, ' : 'Free Parking-0, ';

    // Remove the last comma and space
    preferences = preferences.substring(0, preferences.length - 2);

    // Now you can use the preferences string as needed
    print(preferences);
    // Here you would typically save the preferences string to your database or state management solution
    ref.read(userSingletonProvider.notifier).updatePreferences(preferences);
  }

  Future<bool> _updatePreference() async {
    final url = Uri.http(httpIP, 'api/update_preference');
    try {
      String preferences = '';
      preferences += _isBathroomChecked ? 'Bathroom-1, ' : 'Bathroom-0, ';
      preferences += _isPoolChecked ? 'Pool-1, ' : 'Pool-0, ';
      preferences += _isLightsChecked ? 'Lights-1, ' : 'Lights-0, ';
      preferences += _isSportEquipmentChecked
          ? 'Sport equipment-1, '
          : 'Sport equipment-0, ';
      preferences +=
          _isFreeParkingChecked ? 'Free Parking-1, ' : 'Free Parking-0, ';

      // Remove the last comma and space
      preferences = preferences.substring(0, preferences.length - 2);

      Map<String, dynamic> requestBody = {
        "username": ref.read(userSingletonProvider).name,
        "preference": preferences,
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
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        print(response.body);

        return true;
      } else {
        return false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Preference'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'These preferences will help you in filtering for your stadiums and finding the best option.',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                CheckboxListTile(
                  title: const Text('Bathroom'),
                  value: _isBathroomChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isBathroomChecked = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Pool'),
                  value: _isPoolChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPoolChecked = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Lights'),
                  value: _isLightsChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isLightsChecked = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Sport Equipment'),
                  value: _isSportEquipmentChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isSportEquipmentChecked = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Free Parking'),
                  value: _isFreeParkingChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isFreeParkingChecked = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        _savePreferences();
                        _isUpdated = await _updatePreference();
                        _isUpdated
                            ? ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Preferences saved successfully!'),
                                ),
                              )
                            : ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Prefrences was not saved due to network ERROR'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                      },
                      child: const Text('Save Preferences'),
                    ),
                  ],
                ),
              ],
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
    );
  }
}

class UserSingleton {
  String preferences =
      'Free parking-1, Lights-1, Bathroom-1, Sport equipment-1, Pool-0';
}
