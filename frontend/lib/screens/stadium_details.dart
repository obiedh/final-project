import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:SportGrounds/providers/confirmOrderProvider.dart';
import 'package:SportGrounds/providers/filtersProvider.dart';
import 'package:SportGrounds/providers/locationPermissionProvider.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:http/http.dart' as http;
import 'package:SportGrounds/widgets/availabilityWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/constants.dart';
import '../model/reservation.dart';
import '../model/stadium.dart';
import '../providers/favoritesProvider.dart';

class StadiumDetailsScreen extends ConsumerStatefulWidget {
  StadiumDetailsScreen({
    super.key,
    required this.stadium,
    required this.remainingInterval,
    required this.dropDownInit,
  });
  final Stadium stadium;
  final List<Reservation> reservation = [];
  late List<Map<String, String>> remainingInterval;
  late final String dropDownInit;

  @override
  ConsumerState<StadiumDetailsScreen> createState() {
    return _StadiumDetailsScreenState();
  }
}

class _StadiumDetailsScreenState extends ConsumerState<StadiumDetailsScreen> {
  List<Map<String, String>> availableTimes = [];
  DateTime selectedDate = DateTime.now();
  String? selectedItem;
  var _isLoading = false;
  bool isExpanded = false;
  String authvar = "";
  double rating = 0.0;
  int selectedRating = 0;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.dropDownInit;
    selectedDate = ref.read(filterSingletonProvider).dateForInit;
  }

  List<Map<String, String>> parseAvailableTimes(String responseBody) {
    List<Map<String, String>> availableTimes = [];
    List<String> parts = responseBody
        .split(RegExp(r'[,\s]+'))
        .map((part) => part.trim())
        .toList();

    for (int i = 0; i < parts.length; i += 2) {
      String time = parts[i];
      String price =
          (i + 1 < parts.length) ? parts[i + 1] : "Price not available";
      availableTimes.add({
        'time': time,
        'price': price,
      });
    }

    return availableTimes;
  }

  Future<void> processIntervalsAndReservations(String id, WidgetRef ref) async {
    final url = Uri.http(httpIP, 'api/get_field_by_id');
    try {
      Map<String, dynamic> requestBody = {
        'field_id': id,
        'date': formatDateTimeToDateString(selectedDate),
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400) {
        setState(() {
          _isLoading = false;
        });
      } else {
        String responseBody = response.body.trim();

        if (responseBody.isEmpty) {
          availableTimes = [
            {"time": "All Reserved", "price": ""}
          ];
        } else {
          availableTimes = parseAvailableTimes(responseBody);
        }

        if (availableTimes.isEmpty) {
          availableTimes.add({"time": "No Available Times", "price": ""});
        }

        ref
            .read(filterSingletonProvider.notifier)
            .appliedAvailableTime(availableTimes);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorPopup(context, 'Error loading data. Please try again later.');
    }
  }

  void _showErrorPopup(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openMap(String lat, String long) async {
    String googleURL =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';

    try {
      await launch(googleURL);
    } catch (e) {
      throw 'Could not launch $googleURL: $e';
    }
  }

  Future<void> _addToFavorites() async {
    final url = Uri.http(httpIP, 'api/add_favorite');
    try {
      Map<String, dynamic> requestBody = {
        "user_id": ref.read(userSingletonProvider).id,
        "field_id": widget.stadium.id
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400) {
      } else {
        print(response.toString());
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> _removeFromFavorites() async {
    final url = Uri.http(httpIP, 'api/remove_favorite');
    try {
      Map<String, dynamic> requestBody = {
        "user_id": ref.read(userSingletonProvider).id,
        "field_id": widget.stadium.id
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode >= 400) {
      } else {
        print(response.toString());
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void _showUtilitiesDialog(BuildContext context, String utilities) {
    // Parse utilities string into a map
    final utilitiesMap = Map.fromEntries(
      utilities.split(',').map((e) {
        var parts = e.split('-');
        return MapEntry(parts[0], parts[1] == '1');
      }),
    );

    // Show dialog with checkboxes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Club Utilities'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: utilitiesMap.entries.map((entry) {
              return Row(
                children: [
                  Checkbox(
                    value: entry.value,
                    onChanged: null,
                  ),
                  Text(entry.key),
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userSingletonProvider);
    final favoriteStadiums = ref.watch(favoriteStadiumsProvider);
    bool isFavorite = false;

    for (int i = 0; i < favoriteStadiums.length; i++) {
      if (favoriteStadiums[i].id == widget.stadium.id) {
        isFavorite = true;
        i = favoriteStadiums.length;
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              if (ref.read(userSingletonProvider).authenticationVar == "") {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                        "You must be signed in to add stadiums to favorites!")));
              } else {
                final wasAdded = ref
                    .read(favoriteStadiumsProvider.notifier)
                    .toggleStadiumFavoriteStatus(widget.stadium);
                if (wasAdded) {
                  setState(() {
                    _isLoading = true;
                  });
                  await _addToFavorites();
                  setState(() {
                    _isLoading = false;
                  });
                } else {
                  setState(() {
                    _isLoading = true;
                  });
                  await _removeFromFavorites();
                  setState(() {
                    _isLoading = false;
                  });
                }
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(wasAdded
                        ? 'Stadium added as favorite'
                        : 'Stadium removed from favorites'),
                  ),
                );
              }
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: child,
                );
              },
              child: Icon(
                color: const Color.fromARGB(255, 255, 197, 158),
                isFavorite ? Icons.star : Icons.star_border,
                key: ValueKey(isFavorite),
              ),
            ),
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            widget.stadium.title!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Image.asset(
                    widget.stadium.imagePath,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showUtilitiesDialog(context, widget.stadium.utilities!);
                  },
                  icon: const Icon(Icons.stadium),
                  label: const Text('Club Utilities'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _showRatingDialog(context, ref, selectedRating);
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.star_border_purple500_sharp,
                          color: Color.fromARGB(255, 255, 197, 158),
                        ),
                        SizedBox(
                          width: 1,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    (widget.stadium.rating).toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Icon(Icons.location_on),
                  Text(widget.stadium.location),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    onPressed: () {
                      _openMap(widget.stadium.latitude.toString(),
                          widget.stadium.longitude.toString());
                    },
                    icon: const Icon(Icons.map_outlined),
                    color: const Color.fromARGB(255, 255, 197, 158),
                  ),
                  const Text(
                    'Navigate',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'The stadium boasts a state-of-the-art facility fans of all ages.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '0546333949 for any questions. ',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const IgnorePointer(ignoring: true, child: Icon(Icons.book)),
                IgnorePointer(
                  ignoring: true,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Card(child: Text('Booking')),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.date_range),
                  color: const Color.fromARGB(255, 255, 197, 158),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      _isLoading = true;
                      selectedDate = picked;
                      ref
                          .read(confirmOrderProvider.notifier)
                          .addDate(formatDateTimeToDateString(selectedDate));
                      setState(() {
                        _isLoading = true;
                      });
                      await processIntervalsAndReservations(
                          widget.stadium.id, ref);
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
                Text(
                  formatDateTimeToDateString(selectedDate),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color.fromARGB(255, 255, 197, 158),
                  ),
                ),
              ],
            ),
            ref
                    .read(filterSingletonProvider)
                    .availableTime
                    .toString()
                    .contains('[{time: All Reserved, price: }]')
                ? Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('looks like there is no available time'),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Standby (coming soon)'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                          child: AvailabilityWidget(
                        remainingInterval:
                            ref.read(filterSingletonProvider).availableTime,
                        stadium: widget.stadium,
                        date: formatDateTimeToDateString(selectedDate),
                      ))
                    ],
                  ),
            const SizedBox(
              height: 30,
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

  String formatDateTimeToDateString(DateTime dateTime) {
    final dateFormat = DateFormat('dd.M.yyyy');
    return dateFormat.format(dateTime);
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _showRatingDialog(
      BuildContext context, WidgetRef ref, int selectedRating) {
    if (ref.read(userSingletonProvider).authenticationVar == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: const Duration(seconds: 2),
          content: Text("You must be signed in in order to rate Stadium! ")));
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Rate this Stadium'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Color.fromARGB(255, 255, 197, 158),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  if (selectedRating == 0) {
                    print("do not send to backend");
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
                    await _addRating(selectedRating);
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> _addRating(int selectedRating) async {
    final url = Uri.http(httpIP, 'api/add_rating');
    try {
      Map<String, dynamic> requestBody = {
        "field_id": widget.stadium.id,
        "user_id": ref.read(userSingletonProvider).id,
        "rating": selectedRating,
      };

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        print(response.body);
        return false;
      }
    } catch (error) {
      print("Error: $error");
    }
    return true;
  }

  void _showBookSuccessDialog(
      BuildContext context, String stadiumName, String interval, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking has been processed successfully!!'),
          content: Column(
            children: [
              Text('You have Booked $stadiumName'),
              const SizedBox(
                height: 6,
              ),
              Text('At $date between hours $interval'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
